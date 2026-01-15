import { DataTypes } from "sequelize";
import sequelize from "../config/database.js";
import User from "./User.js";
import Task from "./Task.js";

const NotificationRule = sequelize.define("NotificationRule", {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  taskId: {
    type: DataTypes.INTEGER,
    allowNull: false,
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
  // Notification type: email, sms, push, in-app
  type: {
    type: DataTypes.ENUM("email", "sms", "push", "in-app"),
    defaultValue: "in-app",
    allowNull: false,
  },
  // When to send: on_due_date, before_due_date, after_due_date, on_completion
  triggerType: {
    type: DataTypes.ENUM(
      "on_due_date",
      "before_due_date",
      "after_due_date",
      "on_completion"
    ),
    defaultValue: "on_due_date",
    allowNull: false,
  },
  // How many hours/days before due date (if before_due_date)
  hoursBeforeDue: {
    type: DataTypes.INTEGER,
    allowNull: true, // e.g., 24 for 1 day before, 1 for 1 hour before
  },
  // Is this notification rule active?
  isActive: {
    type: DataTypes.BOOLEAN,
    defaultValue: true,
    allowNull: false,
  },
  // Store when this rule was created
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
NotificationRule.belongsTo(User, { foreignKey: "userId" });
NotificationRule.belongsTo(Task, { foreignKey: "taskId" });

export default NotificationRule;
