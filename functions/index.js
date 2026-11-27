// Sends an FCM push to a user's devices whenever a notification document is
// written for them (a new follower, a new message).
//
// Devices are stored by the app at users/{uid}/devices/{installationId}.
const { onDocumentWritten } = require("firebase-functions/v2/firestore");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

exports.sendNotificationPush = onDocumentWritten(
  "users/{uid}/notifications/{notificationId}",
  async (event) => {
    const after = event.data && event.data.after;
    if (!after || !after.exists) return; // deleted

    const n = after.data();
    if (n.read) return;

    // Marking a notification read updates it without changing createdAt.
    const before = event.data.before;
    if (
      before.exists &&
      before.data().createdAt &&
      n.createdAt &&
      before.data().createdAt.isEqual(n.createdAt)
    ) {
      return;
    }

    const { uid } = event.params;
    const devices = await db.collection(`users/${uid}/devices`).get();
    if (devices.empty) return;

    const isMessage = n.type === "message";
    const fromName = n.fromName || "Someone";
    const title = isMessage ? fromName : "New follower";
    const body = isMessage ? n.body || "Sent you a message" : `${fromName} started following you`;

    await Promise.all(
      devices.docs.map(async (device) => {
        try {
          await admin.messaging().send({
            token: device.id,
            notification: { title, body },
            data: { type: String(n.type || ""), fromUid: String(n.fromUid || "") },
            android: { priority: "high" },
          });
        } catch (err) {
          logger.warn("push failed", device.id, err.code);
          // The app was uninstalled or the ID is stale: stop sending to it.
          if (
            err.code === "messaging/registration-token-not-registered" ||
            err.code === "messaging/invalid-registration-token"
          ) {
            await device.ref.delete();
          }
        }
      }),
    );
  },
);
