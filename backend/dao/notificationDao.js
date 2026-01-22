import Notification from "../models/Notification.js";
import NotificationRule from "../models/NotificationRule.js";
import Task from "../models/Task.js";
import User from "../models/User.js";

class NotificationDAO {
  /**
   * Create a notification rule
   */
  async createNotificationRule(data) {
    const rule = new NotificationRule(data);
    return await rule.save();
  }

  /**
   * Get all notification rules for a user
   */
  async getNotificationRulesByUserId(userId) {
    return await NotificationRule.find({ userId })
      .populate("taskId", "id title dueDate")
      .populate("userId", "id username email");
  }

  /**
   * Get notification rules for a specific task
   */
  async getNotificationRulesByTaskId(taskId) {
    return await NotificationRule.find({ taskId })
      .populate("taskId", "id title dueDate status")
      .populate("userId", "id username email");
  }

  /**
   * Get a single notification rule
   */
  async getNotificationRuleById(ruleId) {
    return await NotificationRule.findById(ruleId)
      .populate("taskId", "id title dueDate status")
      .populate("userId", "id username email");
  }

  /**
   * Update a notification rule
   */
  async updateNotificationRule(ruleId, data) {
    const rule = await NotificationRule.findById(ruleId);
    if (!rule) {
      throw new Error("Notification rule not found");
    }
    Object.assign(rule, data);
    return await rule.save();
  }

  /**
   * Delete a notification rule
   */
  async deleteNotificationRule(ruleId) {
    return await NotificationRule.findByIdAndDelete(ruleId);
  }

  /**
   * Create a notification
   */
  async createNotification(data) {
    const notification = new Notification(data);
    return await notification.save();
  }

  /**
   * Get all notifications for a user
   */
  async getNotificationsByUserId(userId, filter = {}) {
    const query = { userId };

    // Filter by read status
    if (filter.isRead !== undefined) {
      query.isRead = filter.isRead;
    }

    // Filter by status
    if (filter.status) {
      query.status = filter.status;
    }

    // Filter by type
    if (filter.type) {
      query.type = filter.type;
    }

    return await Notification.find(query)
      .populate("taskId", "id title dueDate status")
      .populate("userId", "id username")
      .sort({ createdAt: -1 });
  }

  /**
   * Get unread notifications count for a user
   */
  async getUnreadNotificationsCount(userId) {
    return await Notification.countDocuments({ userId, isRead: false });
  }

  /**
   * Get a single notification
   */
  async getNotificationById(notificationId) {
    return await Notification.findById(notificationId)
      .populate("taskId", "id title dueDate status")
      .populate("userId", "id username");
  }

  /**
   * Mark notification as read
   */
  async markNotificationAsRead(notificationId) {
    return await Notification.findByIdAndUpdate(
      notificationId,
      { isRead: true, readAt: new Date() },
      { new: true }
    );
  }

  /**
   * Mark all notifications as read for a user
   */
  async markAllNotificationsAsRead(userId) {
    return await Notification.updateMany(
      { userId, isRead: false },
      { isRead: true, readAt: new Date() }
    );
  }

  /**
   * Update notification status (sent, failed, etc)
   */
  async updateNotificationStatus(notificationId, status, errorMessage = null) {
    const updateData = { status };

    if (status === "sent") {
      updateData.sentAt = new Date();
    }

    if (errorMessage) {
      updateData.errorMessage = errorMessage;
    }

    return await Notification.findByIdAndUpdate(notificationId, updateData, {
      new: true,
    });
  }

  /**
   * Delete a notification
   */
  async deleteNotification(notificationId) {
    return await Notification.findByIdAndDelete(notificationId);
  }

  /**
   * Get pending notifications (not yet sent)
   */
  async getPendingNotifications() {
    return await Notification.find({ status: "pending" })
      .populate("taskId", "id title dueDate status")
      .populate("userId", "id username email")
      .sort({ createdAt: 1 });
  }

  /**
   * Get active notification rules for a task
   */
  async getActiveRulesForTask(taskId) {
    return await NotificationRule.find({ taskId, isActive: true })
      .populate("taskId", "id title dueDate status")
      .populate("userId", "id username email");
  }

  /**
   * Disable all notification rules for a task
   */
  async disableRulesForTask(taskId) {
    return await NotificationRule.updateMany({ taskId }, { isActive: false });
  }
}

export default new NotificationDAO();
