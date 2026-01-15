import { DataTypes } from "sequelize";
import sequelize from "../config/database.js";
import Task from "./Task.js";
import User from "./User.js";

const Document = sequelize.define(
  "Document",
  {
    filename: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    originalName: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    mimeType: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    fileSize: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    filePath: {
      type: DataTypes.STRING,
      allowNull: false,
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
  },
  {
    // TTL Indexes for efficient cleanup
    indexes: [
      // Index for finding old unused documents (TTL cleanup)
      {
        fields: ["updatedAt"],
        name: "idx_document_updated_ttl",
      },
      // Index for finding documents by creation time
      {
        fields: ["createdAt"],
        name: "idx_document_created_ttl",
      },
      // Index for user-specific document queries
      {
        fields: ["userId", "createdAt"],
        name: "idx_document_user_created_ttl",
      },
      // Index for task-specific document queries
      {
        fields: ["taskId", "updatedAt"],
        name: "idx_document_task_updated_ttl",
      },
    ],
  }
);

// Define associations
Document.belongsTo(Task, { foreignKey: "taskId", as: "task" });
Document.belongsTo(User, { foreignKey: "userId", as: "user" });
Task.hasMany(Document, { foreignKey: "taskId", as: "documents" });
User.hasMany(Document, { foreignKey: "userId", as: "documents" });

export default Document;
