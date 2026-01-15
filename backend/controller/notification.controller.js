import notificationService from "../services/notification.service.js";

class NotificationController {
  /**
   * Create a notification rule
   * POST /api/notifications/rules
   */
  async createRule(req, res) {
    try {
      const userId = req.user.id;
      const { taskId, type, triggerType, hoursBeforeDue } = req.body;

      // Validate required fields
      if (!taskId) {
        return res.status(400).json({ error: "taskId is required" });
      }

      const rule = await notificationService.createRule(userId, taskId, {
        type,
        triggerType,
        hoursBeforeDue,
      });

      return res.status(201).json({
        success: true,
        message: "Notification rule created successfully",
        rule,
      });
    } catch (error) {
      console.error("Error creating notification rule:", error.message);
      return res.status(400).json({ error: error.message });
    }
  }

  /**
   * Get all rules for authenticated user
   * GET /api/notifications/rules
   */
  async getUserRules(req, res) {
    try {
      const userId = req.user.id;
      const rules = await notificationService.getUserRules(userId);

      return res.status(200).json({
        success: true,
        count: rules.length,
        rules,
      });
    } catch (error) {
      console.error("Error fetching user rules:", error.message);
      return res.status(400).json({ error: error.message });
    }
  }

  /**
   * Get rules for a specific task
   * GET /api/notifications/rules/task/:taskId
   */
  async getTaskRules(req, res) {
    try {
      const { taskId } = req.params;
      const rules = await notificationService.getTaskRules(taskId);

      return res.status(200).json({
        success: true,
        count: rules.length,
        rules,
      });
    } catch (error) {
      console.error("Error fetching task rules:", error.message);
      return res.status(400).json({ error: error.message });
    }
  }

  /**
   * Get a single rule
   * GET /api/notifications/rules/:ruleId
   */
  async getRule(req, res) {
    try {
      const { ruleId } = req.params;
      const rule = await notificationService.getRuleById(ruleId);

      if (!rule) {
        return res.status(404).json({ error: "Notification rule not found" });
      }

      return res.status(200).json({
        success: true,
        rule,
      });
    } catch (error) {
      console.error("Error fetching rule:", error.message);
      return res.status(400).json({ error: error.message });
    }
  }

  /**
   * Update a notification rule
   * PUT /api/notifications/rules/:ruleId
   */
  async updateRule(req, res) {
    try {
      const { ruleId } = req.params;
      const updateData = req.body;

      const rule = await notificationService.updateRule(ruleId, updateData);

      return res.status(200).json({
        success: true,
        message: "Notification rule updated successfully",
        rule,
      });
    } catch (error) {
      console.error("Error updating rule:", error.message);
      return res.status(400).json({ error: error.message });
    }
  }

  /**
   * Delete a notification rule
   * DELETE /api/notifications/rules/:ruleId
   */
  async deleteRule(req, res) {
    try {
      const { ruleId } = req.params;
      await notificationService.deleteRule(ruleId);

      return res.status(200).json({
        success: true,
        message: "Notification rule deleted successfully",
      });
    } catch (error) {
      console.error("Error deleting rule:", error.message);
      return res.status(400).json({ error: error.message });
    }
  }

  /**
   * Get all notifications for authenticated user
   * GET /api/notifications
   */
  async getNotifications(req, res) {
    try {
      const userId = req.user.id;
      const { isRead, status, type } = req.query;

      const filter = {};
      if (isRead !== undefined) {
        filter.isRead = isRead === "true";
      }
      if (status) {
        filter.status = status;
      }
      if (type) {
        filter.type = type;
      }

      const notifications = await notificationService.getUserNotifications(
        userId,
        filter
      );

      return res.status(200).json({
        success: true,
        count: notifications.length,
        notifications,
      });
    } catch (error) {
      console.error("Error fetching notifications:", error.message);
      return res.status(400).json({ error: error.message });
    }
  }

  /**
   * Get unread notification count
   * GET /api/notifications/unread-count
   */
  async getUnreadCount(req, res) {
    try {
      const userId = req.user.id;
      const count = await notificationService.getUnreadCount(userId);

      return res.status(200).json({
        success: true,
        unreadCount: count,
      });
    } catch (error) {
      console.error("Error fetching unread count:", error.message);
      return res.status(400).json({ error: error.message });
    }
  }

  /**
   * Mark a notification as read
   * PUT /api/notifications/:notificationId/read
   */
  async markAsRead(req, res) {
    try {
      const { notificationId } = req.params;

      await notificationService.markAsRead(notificationId);

      return res.status(200).json({
        success: true,
        message: "Notification marked as read",
      });
    } catch (error) {
      console.error("Error marking notification as read:", error.message);
      return res.status(400).json({ error: error.message });
    }
  }

  /**
   * Mark all notifications as read
   * PUT /api/notifications/mark-all-read
   */
  async markAllAsRead(req, res) {
    try {
      const userId = req.user.id;

      await notificationService.markAllAsRead(userId);

      return res.status(200).json({
        success: true,
        message: "All notifications marked as read",
      });
    } catch (error) {
      console.error("Error marking all as read:", error.message);
      return res.status(400).json({ error: error.message });
    }
  }

  /**
   * Delete a notification
   * DELETE /api/notifications/:notificationId
   */
  async deleteNotification(req, res) {
    try {
      const { notificationId } = req.params;

      await notificationService.deleteNotification(notificationId);

      return res.status(200).json({
        success: true,
        message: "Notification deleted successfully",
      });
    } catch (error) {
      console.error("Error deleting notification:", error.message);
      return res.status(400).json({ error: error.message });
    }
  }

  /**
   * Get upcoming tasks for the next 7 days
   * GET /api/notifications/upcoming-tasks
   */
  async getUpcomingTasks(req, res) {
    try {
      const userId = req.user.id;
      const { days } = req.query;

      const tasks = await notificationService.getUpcomingTasks(
        userId,
        days ? parseInt(days) : 7
      );

      return res.status(200).json({
        success: true,
        count: tasks.length,
        tasks,
      });
    } catch (error) {
      console.error("Error fetching upcoming tasks:", error.message);
      return res.status(400).json({ error: error.message });
    }
  }

  /**
   * Manually trigger notification check (for testing)
   * POST /api/notifications/trigger-check
   */
  async triggerNotificationCheck(req, res) {
    try {
      const result = await notificationService.checkAndCreateNotifications();

      return res.status(200).json({
        success: true,
        message: "Notification check completed",
        result,
      });
    } catch (error) {
      console.error("Error triggering notification check:", error.message);
      return res.status(400).json({ error: error.message });
    }
  }
}

export default new NotificationController();
