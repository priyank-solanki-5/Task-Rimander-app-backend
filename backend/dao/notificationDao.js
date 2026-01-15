import Notification from "../models/Notification.js";
import NotificationRule from "../models/NotificationRule.js";
import Task from "../models/Task.js";
import User from "../models/User.js";

class NotificationDAO {
  /**
   * Create a notification rule
   */
  async createNotificationRule(data) {
    try {
      return await NotificationRule.create(data);
    } catch (error) {
      throw error;
    }
  }

  /**
   * Get all notification rules for a user
   */
  async getNotificationRulesByUserId(userId) {
    try {
      return await NotificationRule.findAll({
        where: { userId },
        include: [
          { model: Task, attributes: ["id", "title", "dueDate"] },
          { model: User, attributes: ["id", "username", "email"] },
        ],
      });
    } catch (error) {
      throw error;
    }
  }

  /**
   * Get notification rules for a specific task
   */
  async getNotificationRulesByTaskId(taskId) {
    try {
      return await NotificationRule.findAll({
        where: { taskId },
        include: [
          { model: Task, attributes: ["id", "title", "dueDate", "status"] },
          { model: User, attributes: ["id", "username", "email"] },
        ],
      });
    } catch (error) {
      throw error;
    }
  }

  /**
   * Get a single notification rule
   */
  async getNotificationRuleById(ruleId) {
    try {
      return await NotificationRule.findByPk(ruleId, {
        include: [
          { model: Task, attributes: ["id", "title", "dueDate", "status"] },
          { model: User, attributes: ["id", "username", "email"] },
        ],
      });
    } catch (error) {
      throw error;
    }
  }

  /**
   * Update a notification rule
   */
  async updateNotificationRule(ruleId, data) {
    try {
      const rule = await NotificationRule.findByPk(ruleId);
      if (!rule) {
        throw new Error("Notification rule not found");
      }
      return await rule.update(data);
    } catch (error) {
      throw error;
    }
  }

  /**
   * Delete a notification rule
   */
  async deleteNotificationRule(ruleId) {
    try {
      return await NotificationRule.destroy({
        where: { id: ruleId },
      });
    } catch (error) {
      throw error;
    }
  }

  /**
   * Create a notification
   */
  async createNotification(data) {
    try {
      return await Notification.create(data);
    } catch (error) {
      throw error;
    }
  }

  /**
   * Get all notifications for a user
   */
  async getNotificationsByUserId(userId, filter = {}) {
    try {
      const where = { userId };

      // Filter by read status
      if (filter.isRead !== undefined) {
        where.isRead = filter.isRead;
      }

      // Filter by status
      if (filter.status) {
        where.status = filter.status;
      }

      // Filter by type
      if (filter.type) {
        where.type = filter.type;
      }

      return await Notification.findAll({
        where,
        include: [
          { model: Task, attributes: ["id", "title", "dueDate", "status"] },
          { model: User, attributes: ["id", "username"] },
        ],
        order: [["createdAt", "DESC"]],
      });
    } catch (error) {
      throw error;
    }
  }

  /**
   * Get unread notifications count for a user
   */
  async getUnreadNotificationsCount(userId) {
    try {
      return await Notification.count({
        where: { userId, isRead: false },
      });
    } catch (error) {
      throw error;
    }
  }

  /**
   * Get a single notification
   */
  async getNotificationById(notificationId) {
    try {
      return await Notification.findByPk(notificationId, {
        include: [
          { model: Task, attributes: ["id", "title", "dueDate", "status"] },
          { model: User, attributes: ["id", "username"] },
        ],
      });
    } catch (error) {
      throw error;
    }
  }

  /**
   * Mark notification as read
   */
  async markNotificationAsRead(notificationId) {
    try {
      return await Notification.update(
        { isRead: true, readAt: new Date() },
        { where: { id: notificationId } }
      );
    } catch (error) {
      throw error;
    }
  }

  /**
   * Mark all notifications as read for a user
   */
  async markAllNotificationsAsRead(userId) {
    try {
      return await Notification.update(
        { isRead: true, readAt: new Date() },
        { where: { userId, isRead: false } }
      );
    } catch (error) {
      throw error;
    }
  }

  /**
   * Update notification status (sent, failed, etc)
   */
  async updateNotificationStatus(notificationId, status, errorMessage = null) {
    try {
      const updateData = {
        status,
      };

      if (status === "sent") {
        updateData.sentAt = new Date();
      }

      if (errorMessage) {
        updateData.errorMessage = errorMessage;
      }

      return await Notification.update(updateData, {
        where: { id: notificationId },
      });
    } catch (error) {
      throw error;
    }
  }

  /**
   * Delete a notification
   */
  async deleteNotification(notificationId) {
    try {
      return await Notification.destroy({
        where: { id: notificationId },
      });
    } catch (error) {
      throw error;
    }
  }

  /**
   * Get pending notifications (not yet sent)
   */
  async getPendingNotifications() {
    try {
      return await Notification.findAll({
        where: { status: "pending" },
        include: [
          { model: Task, attributes: ["id", "title", "dueDate", "status"] },
          { model: User, attributes: ["id", "username", "email"] },
        ],
        order: [["createdAt", "ASC"]],
      });
    } catch (error) {
      throw error;
    }
  }

  /**
   * Get active notification rules for a task
   */
  async getActiveRulesForTask(taskId) {
    try {
      return await NotificationRule.findAll({
        where: { taskId, isActive: true },
        include: [
          { model: Task, attributes: ["id", "title", "dueDate", "status"] },
          { model: User, attributes: ["id", "username", "email"] },
        ],
      });
    } catch (error) {
      throw error;
    }
  }

  /**
   * Disable all notification rules for a task
   */
  async disableRulesForTask(taskId) {
    try {
      return await NotificationRule.update(
        { isActive: false },
        { where: { taskId } }
      );
    } catch (error) {
      throw error;
    }
  }
}

export default new NotificationDAO();
