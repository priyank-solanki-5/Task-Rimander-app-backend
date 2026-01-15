import sequelize from "../config/database.js";
import Notification from "../models/Notification.js";
import Reminder from "../models/Reminder.js";
import Document from "../models/Document.js";
import Task from "../models/Task.js";
import { Op } from "sequelize";
import fs from "fs";
import path from "path";

/**
 * TTL (Time To Live) Service
 * Manages automatic cleanup of expired records
 * Supports retention policies for different document types
 */
class TTLService {
  constructor() {
    this.retentionPolicies = {
      // Notifications: Delete read notifications after 90 days, unread after 180 days
      notification: {
        read: 90, // days
        unread: 180, // days
        all: 365, // absolute max retention
      },
      // Reminders: Delete triggered reminders (inactive) after 180 days
      reminder: {
        triggered: 180, // days
        inactive: 180, // days
        all: 365, // absolute max retention
      },
      // Documents: Delete soft-deleted documents after 30 days, unused documents after 2 years
      document: {
        deleted: 30, // days
        unused: 730, // days (2 years)
        all: 1095, // absolute max retention (3 years)
      },
      // Completed tasks: Delete permanently completed tasks after 1 year
      task: {
        completed: 365, // days
        deleted: 30, // days (soft delete)
        all: 1095, // absolute max retention (3 years)
      },
    };
  }

  /**
   * Clean expired notifications
   * Retention policy:
   * - Read notifications: 90 days
   * - Unread notifications: 180 days
   * - Absolute max: 365 days
   */
  async cleanExpiredNotifications() {
    try {
      const deletedCount = await Notification.destroy({
        where: {
          [Op.or]: [
            // Read notifications older than 90 days
            {
              isRead: true,
              readAt: {
                [Op.lt]: this.getDateDaysAgo(
                  this.retentionPolicies.notification.read
                ),
              },
            },
            // Unread notifications older than 180 days
            {
              isRead: false,
              createdAt: {
                [Op.lt]: this.getDateDaysAgo(
                  this.retentionPolicies.notification.unread
                ),
              },
            },
            // All notifications older than 365 days (hard limit)
            {
              createdAt: {
                [Op.lt]: this.getDateDaysAgo(
                  this.retentionPolicies.notification.all
                ),
              },
            },
          ],
        },
      });

      return {
        service: "Notification Cleanup",
        deletedCount,
        retentionDays: {
          read: this.retentionPolicies.notification.read,
          unread: this.retentionPolicies.notification.unread,
          absolute: this.retentionPolicies.notification.all,
        },
        timestamp: new Date().toISOString(),
      };
    } catch (error) {
      console.error("❌ Error cleaning notifications:", error.message);
      throw error;
    }
  }

  /**
   * Clean expired reminders
   * Retention policy:
   * - Triggered inactive reminders: 180 days
   * - Inactive reminders: 180 days
   * - Absolute max: 365 days
   */
  async cleanExpiredReminders() {
    try {
      const deletedCount = await Reminder.destroy({
        where: {
          [Op.or]: [
            // Triggered and inactive reminders older than 180 days
            {
              isTriggered: true,
              isActive: false,
              triggeredAt: {
                [Op.lt]: this.getDateDaysAgo(
                  this.retentionPolicies.reminder.triggered
                ),
              },
            },
            // Inactive reminders older than 180 days
            {
              isActive: false,
              updatedAt: {
                [Op.lt]: this.getDateDaysAgo(
                  this.retentionPolicies.reminder.inactive
                ),
              },
            },
            // All reminders older than 365 days (hard limit)
            {
              createdAt: {
                [Op.lt]: this.getDateDaysAgo(
                  this.retentionPolicies.reminder.all
                ),
              },
            },
          ],
        },
      });

      return {
        service: "Reminder Cleanup",
        deletedCount,
        retentionDays: {
          triggered: this.retentionPolicies.reminder.triggered,
          inactive: this.retentionPolicies.reminder.inactive,
          absolute: this.retentionPolicies.reminder.all,
        },
        timestamp: new Date().toISOString(),
      };
    } catch (error) {
      console.error("❌ Error cleaning reminders:", error.message);
      throw error;
    }
  }

  /**
   * Clean expired documents
   * Retention policy:
   * - Unused documents: 2 years (not accessed)
   * - Absolute max: 3 years
   */
  async cleanExpiredDocuments() {
    try {
      const filesToDelete = [];
      let deletedCount = 0;

      // Query documents for deletion (without deleting yet)
      const documents = await Document.findAll({
        where: {
          [Op.or]: [
            // Unused documents not accessed for 2 years
            {
              updatedAt: {
                [Op.lt]: this.getDateDaysAgo(
                  this.retentionPolicies.document.unused
                ),
              },
            },
            // All documents older than 3 years (hard limit)
            {
              createdAt: {
                [Op.lt]: this.getDateDaysAgo(
                  this.retentionPolicies.document.all
                ),
              },
            },
          ],
        },
        attributes: ["id", "filePath"],
      });

      // Delete associated files from storage
      for (const doc of documents) {
        try {
          if (doc.filePath && fs.existsSync(doc.filePath)) {
            fs.unlinkSync(doc.filePath);
            filesToDelete.push(doc.filePath);
          }
        } catch (err) {
          console.warn(
            `⚠️  Failed to delete file: ${doc.filePath}`,
            err.message
          );
        }
      }

      // Delete database records
      deletedCount = await Document.destroy({
        where: {
          id: {
            [Op.in]: documents.map((d) => d.id),
          },
        },
      });

      return {
        service: "Document Cleanup",
        deletedCount,
        filesDeleted: filesToDelete.length,
        files: filesToDelete,
        retentionDays: {
          unused: this.retentionPolicies.document.unused,
          absolute: this.retentionPolicies.document.all,
        },
        timestamp: new Date().toISOString(),
      };
    } catch (error) {
      console.error("❌ Error cleaning documents:", error.message);
      throw error;
    }
  }

  /**
   * Clean expired completed tasks
   * Retention policy:
   * - Completed tasks: 1 year
   * - Absolute max: 3 years
   */
  async cleanExpiredTasks() {
    try {
      const deletedCount = await Task.destroy({
        where: {
          [Op.or]: [
            // Completed tasks older than 1 year
            {
              status: "Completed",
              updatedAt: {
                [Op.lt]: this.getDateDaysAgo(
                  this.retentionPolicies.task.completed
                ),
              },
            },
            // All tasks older than 3 years (hard limit)
            {
              createdAt: {
                [Op.lt]: this.getDateDaysAgo(this.retentionPolicies.task.all),
              },
            },
          ],
        },
      });

      return {
        service: "Task Cleanup",
        deletedCount,
        retentionDays: {
          completed: this.retentionPolicies.task.completed,
          absolute: this.retentionPolicies.task.all,
        },
        timestamp: new Date().toISOString(),
      };
    } catch (error) {
      console.error("❌ Error cleaning tasks:", error.message);
      throw error;
    }
  }

  /**
   * Run all TTL cleanup operations
   * Returns summary of all cleanup activities
   */
  async cleanExpiredRecords() {
    console.log("\n🧹 Starting comprehensive TTL cleanup operations...\n");

    try {
      const results = {
        timestamp: new Date().toISOString(),
        status: "success",
        operations: [],
        summary: {
          totalDeleted: 0,
          operationsCompleted: 0,
        },
      };

      // Clean notifications
      const notifResult = await this.cleanExpiredNotifications();
      results.operations.push(notifResult);
      results.summary.totalDeleted += notifResult.deletedCount;

      // Clean reminders
      const remindResult = await this.cleanExpiredReminders();
      results.operations.push(remindResult);
      results.summary.totalDeleted += remindResult.deletedCount;

      // Clean documents
      const docResult = await this.cleanExpiredDocuments();
      results.operations.push(docResult);
      results.summary.totalDeleted += docResult.deletedCount;

      // Clean tasks
      const taskResult = await this.cleanExpiredTasks();
      results.operations.push(taskResult);
      results.summary.totalDeleted += taskResult.deletedCount;

      results.summary.operationsCompleted = results.operations.length;

      // Log summary
      console.log("✅ TTL Cleanup Summary:");
      console.log(`   Total records deleted: ${results.summary.totalDeleted}`);
      console.log(
        `   Operations completed: ${results.summary.operationsCompleted}`
      );
      console.log(`   Timestamp: ${results.timestamp}\n`);

      return results;
    } catch (error) {
      console.error("❌ Error during TTL cleanup:", error.message);
      return {
        timestamp: new Date().toISOString(),
        status: "error",
        error: error.message,
        operations: [],
      };
    }
  }

  /**
   * Get retention policy for a specific resource type
   * @param {string} resourceType - Type of resource (notification, reminder, document, task)
   * @returns {object} Retention policy
   */
  getRetentionPolicy(resourceType) {
    return this.retentionPolicies[resourceType] || null;
  }

  /**
   * Update retention policy for a resource type
   * @param {string} resourceType - Type of resource
   * @param {object} policy - New retention policy
   */
  updateRetentionPolicy(resourceType, policy) {
    if (this.retentionPolicies[resourceType]) {
      this.retentionPolicies[resourceType] = {
        ...this.retentionPolicies[resourceType],
        ...policy,
      };
      console.log(
        `✅ Updated retention policy for ${resourceType}:`,
        this.retentionPolicies[resourceType]
      );
      return this.retentionPolicies[resourceType];
    }
    throw new Error(`Unknown resource type: ${resourceType}`);
  }

  /**
   * Get all retention policies
   * @returns {object} All retention policies
   */
  getAllRetentionPolicies() {
    return this.retentionPolicies;
  }

  /**
   * Calculate date from N days ago
   * @param {number} days - Number of days
   * @returns {Date} Date object
   */
  getDateDaysAgo(days) {
    const date = new Date();
    date.setDate(date.getDate() - days);
    return date;
  }

  /**
   * Get statistics about TTL-eligible records
   * Useful for previewing what will be deleted
   */
  async getTTLStatistics() {
    try {
      const stats = {
        timestamp: new Date().toISOString(),
        notifications: {
          readEligibleForDeletion: await Notification.count({
            where: {
              isRead: true,
              readAt: {
                [Op.lt]: this.getDateDaysAgo(
                  this.retentionPolicies.notification.read
                ),
              },
            },
          }),
          unreadEligibleForDeletion: await Notification.count({
            where: {
              isRead: false,
              createdAt: {
                [Op.lt]: this.getDateDaysAgo(
                  this.retentionPolicies.notification.unread
                ),
              },
            },
          }),
        },
        reminders: {
          inactiveEligibleForDeletion: await Reminder.count({
            where: {
              isActive: false,
              updatedAt: {
                [Op.lt]: this.getDateDaysAgo(
                  this.retentionPolicies.reminder.inactive
                ),
              },
            },
          }),
        },
        documents: {
          eligibleForDeletion: await Document.count({
            where: {
              updatedAt: {
                [Op.lt]: this.getDateDaysAgo(
                  this.retentionPolicies.document.unused
                ),
              },
            },
          }),
        },
        tasks: {
          completedEligibleForDeletion: await Task.count({
            where: {
              status: "Completed",
              updatedAt: {
                [Op.lt]: this.getDateDaysAgo(
                  this.retentionPolicies.task.completed
                ),
              },
            },
          }),
        },
      };

      return stats;
    } catch (error) {
      console.error("❌ Error getting TTL statistics:", error.message);
      throw error;
    }
  }
}

export default new TTLService();
