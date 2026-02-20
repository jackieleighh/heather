import {setGlobalOptions} from "firebase-functions";
import * as admin from "firebase-admin";
import {onCall, HttpsError} from "firebase-functions/v2/https";
import {onSchedule} from "firebase-functions/v2/scheduler";
import {fetchAlerts, NwsAlert} from "./nws.js";

admin.initializeApp();
setGlobalOptions({maxInstances: 10});

const db = admin.firestore();
const messaging = admin.messaging();

// ─── registerDevice ──────────────────────────────────────────────────────────
// Callable function: stores { fcmToken, locations, updatedAt } in Firestore.
// Called from the Flutter app on FCM token refresh or saved-locations change.
// Accepts either a `locations` array or legacy single `latitude`/`longitude`.

export const registerDevice = onCall({invoker: "public"}, async (request) => {
  const {fcmToken, locations, latitude, longitude} = request.data as {
    fcmToken?: string;
    locations?: Array<{latitude: number; longitude: number; name?: string}>;
    latitude?: number;
    longitude?: number;
  };

  if (!fcmToken) {
    throw new HttpsError("invalid-argument", "fcmToken is required.");
  }

  // Empty locations array = unregister (user disabled alerts)
  if (Array.isArray(locations) && locations.length === 0) {
    await db.collection("devices").doc(fcmToken).delete();
    return {success: true};
  }

  // Support new `locations` array or fall back to legacy single lat/lon
  let resolvedLocations: Array<{
    latitude: number;
    longitude: number;
    name?: string;
  }>;

  if (Array.isArray(locations) && locations.length > 0) {
    resolvedLocations = locations;
  } else if (latitude != null && longitude != null) {
    resolvedLocations = [{latitude, longitude}];
  } else {
    throw new HttpsError(
      "invalid-argument",
      "Either locations array or latitude/longitude are required."
    );
  }

  await db.collection("devices").doc(fcmToken).set(
    {
      fcmToken,
      locations: resolvedLocations,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    {merge: true}
  );

  return {success: true};
});

// ─── checkAlerts ─────────────────────────────────────────────────────────────
// Scheduled every 5 minutes. For each unique location registered, queries the
// NWS API and sends FCM pushes for any alerts not already sent.
// Deduplicates alerts per-token across all of a device's locations.

/**
 * Rank severity for sorting (lower = more severe).
 */
function severityRank(severity: string): number {
  switch (severity.toLowerCase()) {
    case "extreme":
      return 0;
    case "severe":
      return 1;
    case "moderate":
      return 2;
    case "minor":
      return 3;
    default:
      return 4;
  }
}

export const checkAlerts = onSchedule("every 5 minutes", async () => {
  const devicesSnapshot = await db.collection("devices").get();

  if (devicesSnapshot.empty) return;

  // Group tokens by approximate location (rounded to 2 decimal places ~1km)
  // to avoid duplicate NWS API calls for nearby devices.
  // Each device may have multiple locations now.
  const locationMap = new Map<
    string,
    {lat: number; lon: number; tokens: string[]}
  >();

  for (const doc of devicesSnapshot.docs) {
    const data = doc.data();
    const token = data.fcmToken as string;

    // Support new `locations` array or fall back to legacy single lat/lon
    const deviceLocations: Array<{latitude: number; longitude: number}> =
      Array.isArray(data.locations) && data.locations.length > 0
        ? data.locations
        : data.latitude != null && data.longitude != null
          ? [{latitude: data.latitude, longitude: data.longitude}]
          : [];

    for (const loc of deviceLocations) {
      const lat = Math.round(loc.latitude * 100) / 100;
      const lon = Math.round(loc.longitude * 100) / 100;
      const key = `${lat},${lon}`;

      const entry = locationMap.get(key);
      if (entry) {
        if (!entry.tokens.includes(token)) {
          entry.tokens.push(token);
        }
      } else {
        locationMap.set(key, {lat, lon, tokens: [token]});
      }
    }
  }

  // Accumulate the most severe new alert per token (dedup by alert ID)
  const tokenAlerts = new Map<string, NwsAlert>();
  const tokenSentAlertIds = new Map<string, Set<string>>();
  const staleTokens = new Set<string>();

  // Process each unique location
  for (const [locationKey, {lat, lon, tokens}] of locationMap) {
    const alerts = await fetchAlerts(lat, lon);
    if (alerts.length === 0) continue;

    const newAlerts = await filterNewAlerts(locationKey, alerts);
    if (newAlerts.length === 0) continue;

    // Mark alerts as sent for this location
    await markAlertsSent(locationKey, newAlerts);

    // Assign the most severe unseen alert to each token
    for (const token of tokens) {
      if (!tokenSentAlertIds.has(token)) {
        tokenSentAlertIds.set(token, new Set());
      }
      const seenIds = tokenSentAlertIds.get(token)!;

      for (const alert of newAlerts) {
        if (seenIds.has(alert.id)) continue;
        seenIds.add(alert.id);

        const existing = tokenAlerts.get(token);
        if (
          !existing ||
          severityRank(alert.severity) < severityRank(existing.severity)
        ) {
          tokenAlerts.set(token, alert);
        }
      }
    }
  }

  // Send one notification per token with the most severe alert
  for (const [token, alert] of tokenAlerts) {
    const message: admin.messaging.Message = {
      token,
      notification: {
        title: alert.event,
        body: alert.headline || `${alert.event} for ${alert.areaDesc}`,
      },
      data: {
        alertId: alert.id,
        severity: alert.severity,
        event: alert.event,
      },
      android: {
        priority: "high",
        notification: {
          channelId: "heather_weather_alerts",
          priority: "high",
        },
      },
      apns: {
        headers: {
          "apns-priority": "10",
          "apns-push-type": "alert",
        },
        payload: {
          aps: {
            alert: {
              title: alert.event,
              body: alert.headline || `${alert.event} for ${alert.areaDesc}`,
            },
            sound: "default",
            "content-available": 1,
          },
        },
      },
    };

    try {
      await messaging.send(message);
    } catch (error: unknown) {
      const fcmError = error as {code?: string};
      if (
        fcmError.code === "messaging/invalid-registration-token" ||
        fcmError.code === "messaging/registration-token-not-registered"
      ) {
        staleTokens.add(token);
      } else {
        console.error(`Failed to send alert to ${token}:`, error);
      }
    }
  }

  // Remove stale tokens
  if (staleTokens.size > 0) {
    const batch = db.batch();
    for (const token of staleTokens) {
      batch.delete(db.collection("devices").doc(token));
    }
    await batch.commit();
  }
});

/**
 * Filter out alerts that have already been sent for a given location.
 */
async function filterNewAlerts(
  locationKey: string,
  alerts: NwsAlert[]
): Promise<NwsAlert[]> {
  const sentDoc = await db.collection("sent_alerts").doc(locationKey).get();
  const sentIds = new Set<string>(
    sentDoc.exists ? (sentDoc.data()?.alertIds as string[]) ?? [] : []
  );

  return alerts.filter((alert) => !sentIds.has(alert.id));
}

/**
 * Record alert IDs as sent for a given location, with a TTL.
 */
async function markAlertsSent(
  locationKey: string,
  alerts: NwsAlert[]
): Promise<void> {
  const newIds = alerts.map((a) => a.id);

  await db
    .collection("sent_alerts")
    .doc(locationKey)
    .set(
      {
        alertIds: admin.firestore.FieldValue.arrayUnion(...newIds),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      {merge: true}
    );
}

// ─── cleanupStaleDevices ─────────────────────────────────────────────────────
// Daily cleanup: removes devices not refreshed in 30+ days and expired
// sent_alerts records.

export const cleanupStaleDevices = onSchedule("every day 03:00", async () => {
  const cutoff = new Date();
  cutoff.setDate(cutoff.getDate() - 30);
  const cutoffTimestamp = admin.firestore.Timestamp.fromDate(cutoff);

  // Clean stale devices
  const staleDevices = await db
    .collection("devices")
    .where("updatedAt", "<", cutoffTimestamp)
    .get();

  if (!staleDevices.empty) {
    const batch = db.batch();
    for (const doc of staleDevices.docs) {
      batch.delete(doc.ref);
    }
    await batch.commit();
    console.log(`Cleaned up ${staleDevices.size} stale device(s).`);
  }

  // Clean expired sent_alerts (older than 2 days)
  const alertCutoff = new Date();
  alertCutoff.setDate(alertCutoff.getDate() - 2);
  const alertCutoffTimestamp =
    admin.firestore.Timestamp.fromDate(alertCutoff);

  const staleSentAlerts = await db
    .collection("sent_alerts")
    .where("updatedAt", "<", alertCutoffTimestamp)
    .get();

  if (!staleSentAlerts.empty) {
    const batch = db.batch();
    for (const doc of staleSentAlerts.docs) {
      batch.delete(doc.ref);
    }
    await batch.commit();
    console.log(`Cleaned up ${staleSentAlerts.size} stale sent_alert(s).`);
  }
});
