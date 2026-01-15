import { DataTypes } from "sequelize";
import sequelize from "../config/database.js";

const User = sequelize.define("User", {
  username: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  mobilenumber: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  email: {
    type: DataTypes.STRING,
    allowNull: false,
    unique: true,
  },
  password: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  // Notification Preferences
  notificationPreferences: {
    type: DataTypes.JSON,
    allowNull: true,
    defaultValue: {
      email: true,
      push: true,
      sms: false,
      inApp: true,
      remindersBefore: 1, // days before due date
      overdueNotifications: true,
      completionNotifications: true,
      recurringNotifications: true,
    },
    comment: "User notification preferences stored as JSON",
  },
  // User Settings
  settings: {
    type: DataTypes.JSON,
    allowNull: true,
    defaultValue: {
      theme: "light",
      language: "en",
      timezone: "UTC",
      dateFormat: "YYYY-MM-DD",
      timeFormat: "24h",
      weekStartsOn: "monday",
    },
    comment: "User settings and preferences stored as JSON",
  },
  // Additional metadata
  metadata: {
    type: DataTypes.JSON,
    allowNull: true,
    defaultValue: {},
    comment: "Additional user metadata",
  },
  lastLogin: {
    type: DataTypes.DATE,
    allowNull: true,
  },
  isActive: {
    type: DataTypes.BOOLEAN,
    defaultValue: true,
  },
});

export default User;
