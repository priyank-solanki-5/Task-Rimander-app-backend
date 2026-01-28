import mongoose from "mongoose";

const notificationPreferencesSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
      unique: true,
    },
    // Push notification settings
    pushEnabled: {
      type: Boolean,
      default: true,
    },
    pushToken: {
      type: String,
      default: null,
    },
    pushTokenUpdatedAt: {
      type: Date,
      default: null,
    },
    // Email notification settings
    emailEnabled: {
      type: Boolean,
      default: true,
    },
    emailAddress: {
      type: String,
      default: null,
    },
    // SMS notification settings
    smsEnabled: {
      type: Boolean,
      default: false,
    },
    phoneNumber: {
      type: String,
      default: null,
    },
    // In-app notification settings
    inAppEnabled: {
      type: Boolean,
      default: true,
    },
    // Notification timing preferences
    quietHoursEnabled: {
      type: Boolean,
      default: false,
    },
    quietHoursStart: {
      type: String, // Format: "22:00"
      default: "22:00",
    },
    quietHoursEnd: {
      type: String, // Format: "08:00"
      default: "08:00",
    },
    // Notification categories
    taskDueReminders: {
      type: Boolean,
      default: true,
    },
    taskOverdueReminders: {
      type: Boolean,
      default: true,
    },
    taskCompletionNotifications: {
      type: Boolean,
      default: true,
    },
    taskAssignmentNotifications: {
      type: Boolean,
      default: true,
    },
    dailyDigest: {
      type: Boolean,
      default: false,
    },
    dailyDigestTime: {
      type: String, // Format: "08:00"
      default: "08:00",
    },
    weeklyDigest: {
      type: Boolean,
      default: false,
    },
    weeklyDigestDay: {
      type: String, // "monday", "tuesday", etc.
      enum: [
        "monday",
        "tuesday",
        "wednesday",
        "thursday",
        "friday",
        "saturday",
        "sunday",
      ],
      default: "monday",
    },
  },
  {
    timestamps: true,
  },
);

notificationPreferencesSchema.index({ userId: 1 });

const NotificationPreferences = mongoose.model(
  "NotificationPreferences",
  notificationPreferencesSchema,
);

export default NotificationPreferences;
