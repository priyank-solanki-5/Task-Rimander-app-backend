/**
 * Push Notification Service
 * Handles sending push notifications via Firebase Cloud Messaging (FCM)
 *
 * Setup instructions:
 * 1. Create a Firebase project at https://console.firebase.google.com
 * 2. Download serviceAccountKey.json
 * 3. Add to backend/config/firebaseServiceAccount.json
 * 4. Install: npm install firebase-admin
 * 5. Set environment variable: FIREBASE_SERVICE_ACCOUNT_PATH
 */

class PushNotificationService {
  constructor() {
    this.admin = null;
    this.initialized = false;
  }

  /**
   * Initialize Firebase Admin SDK
   */
  async initialize() {
    if (this.initialized) {
      return;
    }

    try {
      // Dynamically import firebase-admin only if configured
      const admin = await import("firebase-admin");

      const serviceAccountPath =
        process.env.FIREBASE_SERVICE_ACCOUNT_PATH ||
        "./config/firebaseServiceAccount.json";

      // Check if service account file exists
      const fs = await import("fs");
      if (!fs.existsSync(serviceAccountPath)) {
        console.warn(
          "⚠️  Firebase service account not found. Push notifications will be disabled.",
        );
        console.warn(`    Expected path: ${serviceAccountPath}`);
        console.warn(
          "    To enable push notifications, add your Firebase service account JSON file.",
        );
        return;
      }

      const serviceAccount = await import(serviceAccountPath, {
        assert: { type: "json" },
      });

      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount.default),
      });

      this.admin = admin;
      this.initialized = true;
      console.log("✅ Firebase Admin SDK initialized for push notifications");
    } catch (error) {
      console.warn(
        "⚠️  Failed to initialize Firebase Admin SDK:",
        error.message,
      );
      console.warn("    Push notifications will be disabled.");
    }
  }

  /**
   * Send push notification to a single device
   */
  async sendToDevice(token, notification, data = {}) {
    if (!this.initialized || !this.admin) {
      console.log("Push notification skipped (Firebase not initialized)");
      return { success: false, reason: "Firebase not initialized" };
    }

    try {
      const message = {
        notification: {
          title: notification.title,
          body: notification.body,
          imageUrl: notification.imageUrl || undefined,
        },
        data: {
          ...data,
          timestamp: new Date().toISOString(),
        },
        token: token,
        android: {
          priority: "high",
          notification: {
            sound: "default",
            channelId: "task-reminders",
          },
        },
        apns: {
          payload: {
            aps: {
              sound: "default",
              badge: 1,
            },
          },
        },
      };

      const response = await this.admin.messaging().send(message);
      console.log("✅ Push notification sent successfully:", response);
      return { success: true, messageId: response };
    } catch (error) {
      console.error("❌ Error sending push notification:", error.message);

      // Handle invalid token
      if (
        error.code === "messaging/invalid-registration-token" ||
        error.code === "messaging/registration-token-not-registered"
      ) {
        return {
          success: false,
          reason: "invalid_token",
          error: error.message,
        };
      }

      return { success: false, error: error.message };
    }
  }

  /**
   * Send push notification to multiple devices
   */
  async sendToMultipleDevices(tokens, notification, data = {}) {
    if (!this.initialized || !this.admin) {
      console.log("Push notifications skipped (Firebase not initialized)");
      return { success: false, reason: "Firebase not initialized" };
    }

    try {
      const message = {
        notification: {
          title: notification.title,
          body: notification.body,
          imageUrl: notification.imageUrl || undefined,
        },
        data: {
          ...data,
          timestamp: new Date().toISOString(),
        },
        tokens: tokens,
        android: {
          priority: "high",
          notification: {
            sound: "default",
            channelId: "task-reminders",
          },
        },
        apns: {
          payload: {
            aps: {
              sound: "default",
              badge: 1,
            },
          },
        },
      };

      const response = await this.admin.messaging().sendMulticast(message);
      console.log(
        `✅ Push notifications sent: ${response.successCount}/${tokens.length}`,
      );

      return {
        success: true,
        successCount: response.successCount,
        failureCount: response.failureCount,
        responses: response.responses,
      };
    } catch (error) {
      console.error("❌ Error sending push notifications:", error.message);
      return { success: false, error: error.message };
    }
  }

  /**
   * Send topic-based notification
   */
  async sendToTopic(topic, notification, data = {}) {
    if (!this.initialized || !this.admin) {
      console.log("Push notification skipped (Firebase not initialized)");
      return { success: false, reason: "Firebase not initialized" };
    }

    try {
      const message = {
        notification: {
          title: notification.title,
          body: notification.body,
        },
        data: data,
        topic: topic,
      };

      const response = await this.admin.messaging().send(message);
      console.log("✅ Topic notification sent successfully:", response);
      return { success: true, messageId: response };
    } catch (error) {
      console.error("❌ Error sending topic notification:", error.message);
      return { success: false, error: error.message };
    }
  }

  /**
   * Subscribe device to topic
   */
  async subscribeToTopic(tokens, topic) {
    if (!this.initialized || !this.admin) {
      return { success: false, reason: "Firebase not initialized" };
    }

    try {
      const response = await this.admin
        .messaging()
        .subscribeToTopic(tokens, topic);
      console.log(`✅ Subscribed to topic ${topic}:`, response);
      return { success: true, ...response };
    } catch (error) {
      console.error("❌ Error subscribing to topic:", error.message);
      return { success: false, error: error.message };
    }
  }

  /**
   * Unsubscribe device from topic
   */
  async unsubscribeFromTopic(tokens, topic) {
    if (!this.initialized || !this.admin) {
      return { success: false, reason: "Firebase not initialized" };
    }

    try {
      const response = await this.admin
        .messaging()
        .unsubscribeFromTopic(tokens, topic);
      console.log(`✅ Unsubscribed from topic ${topic}:`, response);
      return { success: true, ...response };
    } catch (error) {
      console.error("❌ Error unsubscribing from topic:", error.message);
      return { success: false, error: error.message };
    }
  }
}

export default new PushNotificationService();
