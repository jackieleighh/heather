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
// Callable function: stores { fcmToken, lat, lon, updatedAt } in Firestore.
// Called from the Flutter app on FCM token refresh.

export const registerDevice = onCall({invoker: "public"}, async (request) => {
  const {fcmToken, latitude, longitude} = request.data as {
    fcmToken?: string;
    latitude?: number;
    longitude?: number;
  };

  if (!fcmToken || latitude == null || longitude == null) {
    throw new HttpsError(
      "invalid-argument",
      "fcmToken, latitude, and longitude are required."
    );
  }

  await db.collection("devices").doc(fcmToken).set(
    {
      fcmToken,
      latitude,
      longitude,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    {merge: true}
  );

  return {success: true};
});

// ─── checkAlerts ─────────────────────────────────────────────────────────────
// Scheduled every 5 minutes. For each unique location registered, queries the
// NWS API and sends FCM pushes for any alerts not already sent.

export const checkAlerts = onSchedule("every 5 minutes", async () => {
  const devicesSnapshot = await db.collection("devices").get();

  if (devicesSnapshot.empty) return;

  // Group devices by approximate location (rounded to 2 decimal places ~1km)
  // to avoid duplicate NWS API calls for nearby devices.
  const locationMap = new Map<
    string,
    {lat: number; lon: number; tokens: string[]}
  >();

  for (const doc of devicesSnapshot.docs) {
    const data = doc.data();
    const lat = Math.round(data.latitude * 100) / 100;
    const lon = Math.round(data.longitude * 100) / 100;
    const key = `${lat},${lon}`;

    const entry = locationMap.get(key);
    if (entry) {
      entry.tokens.push(data.fcmToken);
    } else {
      locationMap.set(key, {
        lat,
        lon,
        tokens: [data.fcmToken],
      });
    }
  }

  // Process each unique location
  for (const [locationKey, {lat, lon, tokens}] of locationMap) {
    const alerts = await fetchAlerts(lat, lon);
    if (alerts.length === 0) continue;

    // Filter out alerts already sent for this location
    const newAlerts = await filterNewAlerts(locationKey, alerts);
    if (newAlerts.length === 0) continue;

    // Send push notification for the most severe alert
    const primary = newAlerts[0];
    const message: admin.messaging.MulticastMessage = {
      tokens,
      notification: {
        title: primary.event,
        body: primary.headline || `${primary.event} for ${primary.areaDesc}`,
      },
      data: {
        alertId: primary.id,
        severity: primary.severity,
        event: primary.event,
      },
      android: {
        priority: "high",
        notification: {
          channelId: "heather_weather_alerts",
          priority: "high",
        },
      },
      apns: {
        payload: {
          aps: {
            sound: "default",
            "content-available": 1,
          },
        },
      },
    };

    try {
      const response = await messaging.sendEachForMulticast(message);

      // Remove tokens that are no longer valid
      const failedTokens: string[] = [];
      response.responses.forEach((resp, idx) => {
        if (
          resp.error &&
          (resp.error.code === "messaging/invalid-registration-token" ||
            resp.error.code ===
              "messaging/registration-token-not-registered")
        ) {
          failedTokens.push(tokens[idx]);
        }
      });

      if (failedTokens.length > 0) {
        const batch = db.batch();
        for (const token of failedTokens) {
          batch.delete(db.collection("devices").doc(token));
        }
        await batch.commit();
      }
    } catch (error) {
      console.error(`Failed to send alerts for ${locationKey}:`, error);
    }

    // Mark alerts as sent
    await markAlertsSent(locationKey, newAlerts);
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
