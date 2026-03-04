const { onSchedule } = require('firebase-functions/v2/scheduler');
const { initializeApp } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');
const { getMessaging } = require('firebase-admin/messaging');
const fetch = require('node-fetch');

initializeApp();

const db = getFirestore();
const messaging = getMessaging();

const NWS_BASE = 'https://api.weather.gov/alerts/active';
const NWS_HEADERS = {
  'User-Agent': '(Heather Weather App)',
  Accept: 'application/geo+json',
};

/**
 * Runs every 5 minutes. For each device with alertsEnabled,
 * fetches NWS alerts for its locations and sends FCM pushes
 * for any new severe alerts.
 */
exports.checkWeatherAlerts = onSchedule(
  {
    schedule: 'every 5 minutes',
    timeoutSeconds: 120,
    memory: '256MiB',
    region: 'us-central1',
  },
  async () => {
    const devicesSnap = await db
      .collection('devices')
      .where('alertsEnabled', '==', true)
      .get();

    if (devicesSnap.empty) return;

    // Build a map of unique locations (rounded to 2 decimals) -> device tokens
    const locationMap = new Map(); // "lat,lon" -> Set<token>
    const tokenPlatforms = new Map(); // token -> platform

    devicesSnap.forEach((doc) => {
      const data = doc.data();
      const token = doc.id;
      const locations = data.locations || [];
      const platform = data.platform || 'android';
      tokenPlatforms.set(token, platform);

      for (const loc of locations) {
        const key = `${loc.latitude.toFixed(2)},${loc.longitude.toFixed(2)}`;
        if (!locationMap.has(key)) {
          locationMap.set(key, new Set());
        }
        locationMap.get(key).add(token);
      }
    });

    // Fetch NWS alerts for each unique location
    const alertsByToken = new Map(); // token -> [{alert}]

    const locationEntries = Array.from(locationMap.entries());
    const batchSize = 5;

    for (let i = 0; i < locationEntries.length; i += batchSize) {
      const batch = locationEntries.slice(i, i + batchSize);
      await Promise.all(
        batch.map(async ([coordKey, tokens]) => {
          const [lat, lon] = coordKey.split(',');
          try {
            const res = await fetch(
              `${NWS_BASE}?point=${lat},${lon}`,
              { headers: NWS_HEADERS, timeout: 10000 }
            );
            if (!res.ok) return;

            const data = await res.json();
            const features = data.features || [];
            const now = new Date();

            for (const feature of features) {
              const props = feature.properties || {};
              const alertId = props.id || '';
              const expires = props.expires ? new Date(props.expires) : null;

              if (expires && expires < now) continue;

              const severity = (props.severity || '').toLowerCase();
              if (!['extreme', 'severe', 'moderate'].includes(severity))
                continue;

              for (const token of tokens) {
                if (!alertsByToken.has(token)) {
                  alertsByToken.set(token, []);
                }
                alertsByToken.get(token).push({
                  id: alertId,
                  event: props.event || 'Weather Alert',
                  headline: props.headline || '',
                  severity,
                  description: props.description || '',
                });
              }
            }
          } catch (err) {
            console.warn(`Failed to fetch alerts for ${coordKey}:`, err.message);
          }
        })
      );
    }

    if (alertsByToken.size === 0) return;

    // Check which alerts have already been sent (within 48h)
    const sentAlertsRef = db.collection('sentAlerts');

    // Collect all unique alert IDs across all tokens
    const allAlertIds = new Set();
    for (const alerts of alertsByToken.values()) {
      for (const alert of alerts) {
        allAlertIds.add(alert.id);
      }
    }

    // Batch-read sent alert docs
    const alreadySent = new Set();
    const alertIdArray = Array.from(allAlertIds);

    for (let i = 0; i < alertIdArray.length; i += 30) {
      const chunk = alertIdArray.slice(i, i + 30);
      const docs = await Promise.all(
        chunk.map((id) => sentAlertsRef.doc(encodeId(id)).get())
      );
      for (const doc of docs) {
        if (doc.exists) {
          alreadySent.add(doc.id);
        }
      }
    }

    // Send FCM messages for new alerts
    const staleTokens = [];
    const newAlertIds = new Set();

    for (const [token, alerts] of alertsByToken.entries()) {
      // Find the most severe new alert for this token
      const newAlerts = alerts.filter(
        (a) => !alreadySent.has(encodeId(a.id))
      );
      if (newAlerts.length === 0) continue;

      // Sort by severity (extreme first)
      const severityOrder = { extreme: 0, severe: 1, moderate: 2 };
      newAlerts.sort(
        (a, b) =>
          (severityOrder[a.severity] ?? 3) - (severityOrder[b.severity] ?? 3)
      );

      const top = newAlerts[0];
      const platform = tokenPlatforms.get(token) || 'android';

      const message = {
        token,
        notification: {
          title: top.event,
          body: top.headline,
        },
        data: {
          alertId: top.id,
          event: top.event,
          severity: top.severity,
          type: 'weather_alert',
        },
        android: {
          priority: 'high',
          notification: {
            channelId: 'heather_weather_alerts',
            priority: 'high',
          },
        },
        apns: {
          headers: {
            'apns-priority': '10',
            'apns-push-type': 'alert',
          },
          payload: {
            aps: {
              alert: {
                title: top.event,
                body: top.headline,
              },
              sound: 'default',
            },
          },
        },
      };

      try {
        await messaging.send(message);
        newAlertIds.add(top.id);
      } catch (err) {
        if (
          err.code === 'messaging/registration-token-not-registered' ||
          err.code === 'messaging/invalid-registration-token'
        ) {
          staleTokens.push(token);
        } else {
          console.warn(`FCM send failed for token ${token.slice(0, 10)}...:`, err.message);
        }
      }
    }

    // Record sent alerts with TTL (auto-expire after 48h)
    const batch = db.batch();
    const expireAt = new Date(Date.now() + 48 * 60 * 60 * 1000);

    for (const alertId of newAlertIds) {
      const docRef = sentAlertsRef.doc(encodeId(alertId));
      batch.set(docRef, {
        sentAt: FieldValue.serverTimestamp(),
        expireAt,
      });
    }

    // Clean up stale tokens
    for (const token of staleTokens) {
      batch.delete(db.collection('devices').doc(token));
    }

    await batch.commit();
  }
);

/**
 * Encode an alert ID for use as a Firestore document ID.
 * NWS alert IDs contain slashes and dots which are not allowed.
 */
function encodeId(alertId) {
  return Buffer.from(alertId).toString('base64url');
}
