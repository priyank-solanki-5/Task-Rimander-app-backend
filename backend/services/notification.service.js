import notificationDao from "../dao/notificationDao.js";
import taskDao from "../dao/taskDao.js";
import Task from "../models/Task.js";
import User from "../models/User.js";
import NotificationPreferences from "../models/NotificationPreferences.js";
import pushNotificationService from "./pushNotification.service.js";

class NotificationService {
  constructor() {
    // Initialize push notification service
    this.initializePushService();
  }

  /**
   * Initialize push notification service
   */
  async initializePushService() {
    try {
      await pushNotificationService.initialize();
    } catch (error) {
      console.warn(
        "Push notification service initialization failed:",
        error.message,
      );
    }
  }

  /**
   * Create a notification rule
   */
  async createRule(userId, taskId, ruleData) {
    try {
      // Verify task exists and belongs to user
      const task = await Task.findOne({
        _id: taskId,
        userId: userId,
      });

      if (!task) {
        throw new Error("Task not found or does not belong to this user");
      }

      const rulePayload = {
        userId,
        taskId,
        type: ruleData.type || "in-app",
        triggerType: ruleData.triggerType || "on_due_date",
        hoursBeforeDue: ruleData.hoursBeforeDue || null,
        isActive: true,
      };

      return await notificationDao.createNotificationRule(rulePayload);
    } catch (error) {
      throw error;
    }
  }

  /**
   * Get all rules for a user
   */
  async getUserRules(userId) {
    try {
      return await notificationDao.getNotificationRulesByUserId(userId);
    } catch (error) {
      throw error;
    }
  }

  /**
   * Get rules for a specific task
   */
  async getTaskRules(taskId) {
    try {
      return await notificationDao.getNotificationRulesByTaskId(taskId);
    } catch (error) {
      throw error;
    }
  }

  /**
   * Get a single rule
   */
  async getRuleById(ruleId) {
    try {
      return await notificationDao.getNotificationRuleById(ruleId);
    } catch (error) {
      throw error;
    }
  }

  /**
   * Update a notification rule
   */
  async updateRule(ruleId, updateData) {
    try {
      // Don't allow changing taskId or userId
      const { taskId, userId, ...safeData } = updateData;

      return await notificationDao.updateNotificationRule(ruleId, safeData);
    } catch (error) {
      throw error;
    }
  }

  /**
   * Delete a notification rule
   */
  async deleteRule(ruleId) {
    try {
      return await notificationDao.deleteNotificationRule(ruleId);
    } catch (error) {
      throw error;
    }
  }

  /**
   * Get all notifications for a user
   */
  async getUserNotifications(userId, filter = {}) {
    try {
      return await notificationDao.getNotificationsByUserId(userId, filter);
    } catch (error) {
      throw error;
    }
  }

  /**
   * Get unread count
   */
  async getUnreadCount(userId) {
    try {
      return await notificationDao.getUnreadNotificationsCount(userId);
    } catch (error) {
      throw error;
    }
  }

  /**
   * Mark a notification as read
   */
  async markAsRead(notificationId) {
    try {
      return await notificationDao.markNotificationAsRead(notificationId);
    } catch (error) {
      throw error;
    }
  }

  /**
   * Mark all notifications as read
   */
  async markAllAsRead(userId) {
    try {
      return await notificationDao.markAllNotificationsAsRead(userId);
    } catch (error) {
      throw error;
    }
  }

  /**
   * Delete a notification
   */
  async deleteNotification(notificationId) {
    try {
      return await notificationDao.deleteNotification(notificationId);
    } catch (error) {
      throw error;
    }
  }

  /**
   * Find tasks with upcoming due dates and create notifications
   * This is called by the scheduler
   */
  async checkAndCreateNotifications() {
    try {
      const now = new Date();
      const upcomingTasks = await Task.find({
        status: "Pending",
      }).populate("userId");

      let notificationsCreated = 0;

      for (const task of upcomingTasks) {
        if (!task.dueDate) continue;

        // Get active rules for this task
        const rules = await notificationDao.getActiveRulesForTask(task.id);

        for (const rule of rules) {
          const shouldNotify = this.shouldSendNotification(
            rule,
            task.dueDate,
            now,
          );

          if (shouldNotify) {
            // Create notification
            const notification = await notificationDao.createNotification({
              userId: task.userId,
              taskId: task.id,
              type: rule.type,
              message: this.generateNotificationMessage(rule, task),
              status: "pending",
              metadata: {
                taskTitle: task.title,
                dueDate: task.dueDate,
                category: task.category,
                priority: task.priority,
                description: task.description,
              },
            });

            notificationsCreated++;
          }
        }
      }

      return {
        success: true,
        notificationsCreated,
        timestamp: new Date(),
      };
    } catch (error) {
      console.error("Error in checkAndCreateNotifications:", error);
      throw error;
    }
  }

  /**
   * Determine if notification should be sent based on rule and task due date
   */
  shouldSendNotification(rule, dueDate, currentTime) {
    const now = new Date(currentTime);
    const due = new Date(dueDate);

    switch (rule.triggerType) {
      case "on_due_date":
        // Check if today is the due date
        return (
          now.toDateString() === due.toDateString() && !rule.lastNotifiedDate
        );

      case "before_due_date":
        // Check if we're within the hours before due date
        const hoursMs = (rule.hoursBeforeDue || 24) * 60 * 60 * 1000;
        const notificationTime = new Date(due.getTime() - hoursMs);
        return (
          now >= notificationTime &&
          now < due &&
          (!rule.lastNotifiedDate || rule.lastNotifiedDate < notificationTime)
        );

      case "after_due_date":
        // Check if task is overdue
        return now > due && !rule.lastNotifiedDate;

      case "on_completion":
        // This is handled separately when task is marked complete
        return false;

      default:
        return false;
    }
  }

  /**
   * Generate notification message
   */
  generateNotificationMessage(rule, task) {
    const dueDate = new Date(task.dueDate).toLocaleDateString();

    switch (rule.triggerType) {
      case "on_due_date":
        return `⏰ Task "${task.title}" is due today (${dueDate})`;

      case "before_due_date":
        const hours = rule.hoursBeforeDue || 24;
        return `⏰ Task "${task.title}" is due in ${hours} hours`;

      case "after_due_date":
        return `⚠️ Task "${task.title}" is overdue (was due on ${dueDate})`;

      case "on_completion":
        return `✅ Task "${task.title}" has been completed`;

      default:
        return `Notification for task "${task.title}"`;
    }
  }

  /**
   * Create completion notification and disable rules
   */
  async onTaskCompleted(taskId, userId) {
    try {
      // Get task details
      const task = await Task.findById(taskId);

      if (!task) {
        throw new Error("Task not found");
      }

      // Create completion notification
      const notification = await notificationDao.createNotification({
        userId,
        taskId,
        type: "in-app",
        message: `✅ Task "${task.title}" has been marked as completed`,
        status: "sent",
        sentAt: new Date(),
        metadata: {
          taskTitle: task.title,
          completedAt: new Date(),
          dueDate: task.dueDate,
        },
      });

      // Disable all active rules for this task
      await notificationDao.disableRulesForTask(taskId);

      return notification;
    } catch (error) {
      console.error("Error in onTaskCompleted:", error);
      throw error;
    }
  }

  /**
   * Get upcoming tasks for next 7 days
   */
  async getUpcomingTasks(userId, days = 7) {
    try {
      const now = new Date();
      const futureDate = new Date();
      futureDate.setDate(futureDate.getDate() + days);

      const tasks = await Task.find({
        userId,
        status: "Pending",
        dueDate: {
          $gte: now,
          $lte: futureDate,
        },
      }).sort({ dueDate: 1 });

      return tasks;
    } catch (error) {
      throw error;
    }
  }

  // ========== NOTIFICATION PREFERENCES ==========

  /**
   * Get or create user notification preferences
   */
  async getUserPreferences(userId) {
    try {
      let preferences = await NotificationPreferences.findOne({ userId });

      if (!preferences) {
        // Create default preferences
        preferences = new NotificationPreferences({
          userId,
          pushEnabled: true,
          emailEnabled: true,
          inAppEnabled: true,
          taskDueReminders: true,
          taskOverdueReminders: true,
          taskCompletionNotifications: true,
        });
        await preferences.save();
      }

      return preferences;
    } catch (error) {
      throw error;
    }
  }

  /**
   * Update user notification preferences
   */
  async updateUserPreferences(userId, updates) {
    try {
      let preferences = await NotificationPreferences.findOne({ userId });

      if (!preferences) {
        preferences = new NotificationPreferences({ userId, ...updates });
      } else {
        Object.assign(preferences, updates);
      }

      await preferences.save();
      return preferences;
    } catch (error) {
      throw error;
    }
  }

  /**
   * Update push notification token for user
   */
  async updatePushToken(userId, pushToken) {
    try {
      const preferences = await this.getUserPreferences(userId);
      preferences.pushToken = pushToken;
      preferences.pushTokenUpdatedAt = new Date();
      await preferences.save();

      console.log(`✅ Updated push token for user ${userId}`);
      return preferences;
    } catch (error) {
      throw error;
    }
  }

  /**
   * Check if user has quiet hours enabled and if current time is within quiet hours
   */
  isQuietHours(preferences) {
    if (!preferences.quietHoursEnabled) {
      return false;
    }

    const now = new Date();
    const currentTime = `${String(now.getHours()).padStart(2, "0")}:${String(
      now.getMinutes(),
    ).padStart(2, "0")}`;

    const start = preferences.quietHoursStart;
    const end = preferences.quietHoursEnd;

    // Handle overnight quiet hours (e.g., 22:00 to 08:00)
    if (start > end) {
      return currentTime >= start || currentTime <= end;
    }

    // Handle same-day quiet hours (e.g., 01:00 to 05:00)
    return currentTime >= start && currentTime <= end;
  }

  /**
   * Send notification through appropriate channels based on preferences
   */
  async sendNotification(userId, notification) {
    try {
      const preferences = await this.getUserPreferences(userId);

      // Check quiet hours
      if (this.isQuietHours(preferences)) {
        console.log(
          `⏰ Skipping notification for user ${userId} (quiet hours)`,
        );
        return {
          success: false,
          reason: "quiet_hours",
        };
      }

      const results = {
        inApp: false,
        push: false,
        email: false,
        sms: false,
      };

      // Create in-app notification
      if (preferences.inAppEnabled) {
        await notificationDao.createNotification({
          userId,
          taskId: notification.taskId,
          type: "in-app",
          message: notification.message,
          status: "sent",
          sentAt: new Date(),
          metadata: notification.metadata,
        });
        results.inApp = true;
      }

      // Send push notification
      if (preferences.pushEnabled && preferences.pushToken) {
        const pushResult = await pushNotificationService.sendToDevice(
          preferences.pushToken,
          {
            title: notification.title || "Task Reminder",
            body: notification.message,
          },
          {
            taskId: notification.taskId?.toString(),
            notificationType: notification.type || "task_reminder",
          },
        );

        results.push = pushResult.success;

        // If token is invalid, clear it
        if (pushResult.reason === "invalid_token") {
          preferences.pushToken = null;
          await preferences.save();
        }
      }

      // Email and SMS can be implemented here
      // results.email = await this.sendEmail(...);
      // results.sms = await this.sendSMS(...);

      return {
        success: true,
        channels: results,
      };
    } catch (error) {
      console.error("Error sending notification:", error);
      throw error;
    }
  }

  /**
   * Send bulk notifications
   */
  async sendBulkNotifications(notifications) {
    try {
      const results = [];

      for (const notification of notifications) {
        try {
          const result = await this.sendNotification(
            notification.userId,
            notification,
          );
          results.push({
            userId: notification.userId,
            success: true,
            ...result,
          });
        } catch (error) {
          results.push({
            userId: notification.userId,
            success: false,
            error: error.message,
          });
        }
      }

      return {
        total: notifications.length,
        successful: results.filter((r) => r.success).length,
        failed: results.filter((r) => !r.success).length,
        results,
      };
    } catch (error) {
      throw error;
    }
  }
}

export default new NotificationService();
