import { DataTypes } from "sequelize";
import sequelize from "../config/database.js";
import User from "./User.js";
import Task from "./Task.js";

const Reminder = sequelize.define("Reminder", {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  taskId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    unique: true, // One reminder per task (MVP)
    references: {
      model: Task,
      key: "id",
    },
  },
  userId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: User,
      key: "id",
    },
  },
  // How many days before due date to send reminder
  daysBeforeDue: {
    type: DataTypes.INTEGER,
    allowNull: false,
    defaultValue: 1, // Default: 1 day before
  },
  // When the reminder should be sent (calculated: dueDate - daysBeforeDue)
  reminderDate: {
    type: DataTypes.DATE,
    allowNull: true,
  },
  // Has the reminder been triggered?
  isTriggered: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
    allowNull: false,
  },
  // Is reminder active?
  isActive: {
    type: DataTypes.BOOLEAN,
    defaultValue: true,
    allowNull: false,
  },
  // When was reminder actually sent
  triggeredAt: {
    type: DataTypes.DATE,
    allowNull: true,
  },
  // Store metadata about task at reminder time
  metadata: {
    type: DataTypes.JSON,
    allowNull: true,
    // e.g., { taskTitle, dueDate, category, description, priority }
  },
  // Reminder history (stores all reminder events)
  history: {
    type: DataTypes.JSON,
    allowNull: true,
    defaultValue: [],
    // e.g., [
    //   { triggeredAt: "2026-01-15T10:00:00Z", status: "sent" },
    //   { triggeredAt: "2026-01-20T09:00:00Z", status: "snoozed" }
    // ]
  },
  // Reminder type: email, sms, push, in-app
  type: {
    type: DataTypes.ENUM("email", "sms", "push", "in-app"),
    defaultValue: "in-app",
    allowNull: false,
  },
  createdAt: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW,
  },
  updatedAt: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW,
  },
});

// Associations
Reminder.belongsTo(User, { foreignKey: "userId" });
Reminder.belongsTo(Task, { foreignKey: "taskId" });

export default Reminder;
