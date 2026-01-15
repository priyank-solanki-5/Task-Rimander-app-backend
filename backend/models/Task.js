import { DataTypes } from "sequelize";
import sequelize from "../config/database.js";
import User from "./User.js";
import Category from "./Category.js";

const Task = sequelize.define(
  "Task",
  {
    title: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    description: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    status: {
      type: DataTypes.ENUM("Pending", "Completed"),
      defaultValue: "Pending",
      allowNull: false,
    },
    dueDate: {
      type: DataTypes.DATE,
      allowNull: true,
    },
    isRecurring: {
      type: DataTypes.BOOLEAN,
      defaultValue: false,
      allowNull: false,
    },
    recurrenceType: {
      type: DataTypes.ENUM(
        "Monthly",
        "Every 3 months",
        "Every 6 months",
        "Yearly"
      ),
      allowNull: true,
    },
    nextOccurrence: {
      type: DataTypes.DATE,
      allowNull: true,
    },
    userId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: User,
        key: "id",
      },
    },
    categoryId: {
      type: DataTypes.INTEGER,
      allowNull: true,
      references: {
        model: Category,
        key: "id",
      },
    },
  },
  {
    // TTL Indexes for efficient cleanup
    indexes: [
      // Index for finding completed tasks (TTL cleanup)
      {
        fields: ["status", "updatedAt"],
        name: "idx_task_status_updated_ttl",
      },
      // Index for finding old tasks
      {
        fields: ["createdAt"],
        name: "idx_task_created_ttl",
      },
      // Index for user-specific task queries
      {
        fields: ["userId", "status"],
        name: "idx_task_user_status_ttl",
      },
    ],
  }
);

// Define associations
Task.belongsTo(User, { foreignKey: "userId", as: "user" });
Task.belongsTo(Category, { foreignKey: "categoryId", as: "category" });
User.hasMany(Task, { foreignKey: "userId", as: "tasks" });
Category.hasMany(Task, { foreignKey: "categoryId", as: "tasks" });

export default Task;
