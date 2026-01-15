import notificationDao from "../dao/notificationDao.js";
import taskDao from "../dao/taskDao.js";
import Task from "../models/Task.js";
import User from "../models/User.js";

class NotificationService {
  /**
   * Create a notification rule
   */
  async createRule(userId, taskId, ruleData) {
    try {
      // Verify task exists and belongs to user
      const task = await Task.findOne({
        where: { id: taskId, userId },
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
      const upcomingTasks = await Task.findAll({
        where: {
          status: "Pending",
        },
        include: [{ model: User }],
      });

      let notificationsCreated = 0;

      for (const task of upcomingTasks) {
        if (!task.dueDate) continue;

        // Get active rules for this task
        const rules = await notificationDao.getActiveRulesForTask(task.id);

        for (const rule of rules) {
          const shouldNotify = this.shouldSendNotification(
            rule,
            task.dueDate,
            now
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
      const task = await Task.findByPk(taskId);

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

      const tasks = await Task.findAll({
        where: {
          userId,
          status: "Pending",
          dueDate: {
            [require("sequelize").Op.between]: [now, futureDate],
          },
        },
        order: [["dueDate", "ASC"]],
      });

      return tasks;
    } catch (error) {
      throw error;
    }
  }
}

export default new NotificationService();
