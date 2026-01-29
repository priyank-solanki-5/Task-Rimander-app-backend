import mongoose from "mongoose";

const userSchema = new mongoose.Schema(
  {
    username: {
      type: String,
      required: true,
    },
    mobilenumber: {
      type: String,
      required: true,
    },
    email: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
    },
    password: {
      type: String,
      required: true,
    },
    notificationPreferences: {
      type: {
        email: { type: Boolean, default: true },
        push: { type: Boolean, default: true },
        sms: { type: Boolean, default: false },
        inApp: { type: Boolean, default: true },
        remindersBefore: { type: Number, default: 1 },
        overdueNotifications: { type: Boolean, default: true },
        completionNotifications: { type: Boolean, default: true },
        recurringNotifications: { type: Boolean, default: true },
      },
      default: {},
    },
    settings: {
      type: {
        theme: { type: String, default: "light" },
        language: { type: String, default: "en" },
        timezone: { type: String, default: "UTC" },
        dateFormat: { type: String, default: "YYYY-MM-DD" },
        timeFormat: { type: String, default: "24h" },
        weekStartsOn: { type: String, default: "monday" },
      },
      default: {},
    },
    metadata: {
      type: mongoose.Schema.Types.Mixed,
      default: {},
    },
    lastLogin: {
      type: Date,
      default: null,
    },
    isActive: {
      type: Boolean,
      default: true,
    },
    isAdmin: {
      type: Boolean,
      default: false,
    },
  },
  {
    timestamps: true,
  },
);

userSchema.index({ email: 1 }, { unique: true });

const User = mongoose.model("User", userSchema);

export default User;
