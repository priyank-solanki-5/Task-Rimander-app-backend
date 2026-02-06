import reminderService from "../services/reminder.service.js";

class ReminderController {
  /**
   * Create multiple reminders for a task (5,4,3,2,1 minutes before due)
   * POST /api/reminders
   */
  async createReminder(req, res) {
    try {
      const userId = req.user.id;
      const { taskId, type = "in-app" } = req.body;

      // Validate required fields
      if (!taskId) {
        return res.status(400).json({ error: "taskId is required" });
      }

      const reminders = await reminderService.createMultipleReminders(
        userId,
        taskId,
        type
      );

      return res.status(201).json({
        success: true,
        message: `Created ${reminders.length} reminders for task`,
        reminders,
      });
    } catch (error) {
      console.error("Error creating reminders:", error.message);
      return res.status(400).json({ error: error.message });
    }
  }

  /**
   * Create a single reminder for a task (legacy support)
   * POST /api/reminders/single
   */
  async createSingleReminder(req, res) {
    try {
      const userId = req.user.id;
      const { taskId, minutesBeforeDue = 5, type = "in-app" } = req.body;

      // Validate required fields
      if (!taskId) {
        return res.status(400).json({ error: "taskId is required" });
      }

      if (minutesBeforeDue < 0) {
        return res
          .status(400)
          .json({ error: "minutesBeforeDue must be a positive number" });
      }

      const reminder = await reminderService.createReminder(
        userId,
        taskId,
        minutesBeforeDue,
        type
      );

      return res.status(201).json({
        success: true,
        message: "Reminder created successfully",
        reminder,
      });
    } catch (error) {
      console.error("Error creating reminder:", error.message);
      return res.status(400).json({ error: error.message });
    }
  }

  /**
   * Get reminder for a task
   * GET /api/reminders/task/:taskId
   */
  async getReminder(req, res) {
    try {
      const { taskId } = req.params;

      const reminder = await reminderService.getReminder(taskId);

      if (!reminder) {
        return res
          .status(404)
          .json({ error: "Reminder not found for this task" });
      }

      return res.status(200).json({
        success: true,
        reminder,
      });
    } catch (error) {
      console.error("Error fetching reminder:", error.message);
      return res.status(400).json({ error: error.message });
    }
  }

  /**
   * Get all reminders for authenticated user
   * GET /api/reminders
   */
  async getUserReminders(req, res) {
    try {
      const userId = req.user.id;

      const reminders = await reminderService.getUserReminders(userId);

      return res.status(200).json({
        success: true,
        count: reminders.length,
        reminders,
      });
    } catch (error) {
      console.error("Error fetching user reminders:", error.message);
      return res.status(400).json({ error: error.message });
    }
  }

  /**
   * Get single reminder by ID
   * GET /api/reminders/:reminderId
   */
  async getReminderById(req, res) {
    try {
      const { reminderId } = req.params;

      const reminder = await reminderService.getReminderById(reminderId);

      if (!reminder) {
        return res.status(404).json({ error: "Reminder not found" });
      }

      return res.status(200).json({
        success: true,
        reminder,
      });
    } catch (error) {
      console.error("Error fetching reminder:", error.message);
      return res.status(400).json({ error: error.message });
    }
  }

  /**
   * Update reminder
   * PUT /api/reminders/:reminderId
   */
  async updateReminder(req, res) {
    try {
      const { reminderId } = req.params;
      const updateData = req.body;

      const reminder = await reminderService.updateReminder(
        reminderId,
        updateData
      );

      return res.status(200).json({
        success: true,
        message: "Reminder updated successfully",
        reminder,
      });
    } catch (error) {
      console.error("Error updating reminder:", error.message);
      return res.status(400).json({ error: error.message });
    }
  }

  /**
   * Delete reminder
   * DELETE /api/reminders/:reminderId
   */
  async deleteReminder(req, res) {
    try {
      const { reminderId } = req.params;

      await reminderService.deleteReminder(reminderId);

      return res.status(200).json({
        success: true,
        message: "Reminder deleted successfully",
      });
    } catch (error) {
      console.error("Error deleting reminder:", error.message);
      return res.status(400).json({ error: error.message });
    }
  }

  /**
   * Snooze reminder
   * PUT /api/reminders/:reminderId/snooze
   */
  async snoozeReminder(req, res) {
    try {
      const { reminderId } = req.params;

      await reminderService.snoozeReminder(reminderId);

      return res.status(200).json({
        success: true,
        message: "Reminder snoozed successfully",
      });
    } catch (error) {
      console.error("Error snoozing reminder:", error.message);
      return res.status(400).json({ error: error.message });
    }
  }

  /**
   * Unsnooze reminder
   * PUT /api/reminders/:reminderId/unsnooze
   */
  async unsnoozeReminder(req, res) {
    try {
      const { reminderId } = req.params;

      await reminderService.unsnoozeReminder(reminderId);

      return res.status(200).json({
        success: true,
        message: "Reminder unsnoozed successfully",
      });
    } catch (error) {
      console.error("Error unsnozing reminder:", error.message);
      return res.status(400).json({ error: error.message });
    }
  }

  /**
   * Get active (upcoming) reminders for user
   * GET /api/reminders/active
   */
  async getActiveReminders(req, res) {
    try {
      const userId = req.user.id;

      const reminders = await reminderService.getActiveReminders(userId);

      return res.status(200).json({
        success: true,
        count: reminders.length,
        reminders,
      });
    } catch (error) {
      console.error("Error fetching active reminders:", error.message);
      return res.status(400).json({ error: error.message });
    }
  }

  /**
   * Get reminder history for user (triggered reminders)
   * GET /api/reminders/history
   */
  async getReminderHistory(req, res) {
    try {
      const userId = req.user.id;

      const history = await reminderService.getReminderHistory(userId);

      return res.status(200).json({
        success: true,
        count: history.length,
        history,
      });
    } catch (error) {
      console.error("Error fetching reminder history:", error.message);
      return res.status(400).json({ error: error.message });
    }
  }

  /**
   * Get detailed history for a specific reminder
   * GET /api/reminders/:reminderId/history
   */
  async getReminderDetailedHistory(req, res) {
    try {
      const { reminderId } = req.params;

      const detailedHistory = await reminderService.getReminderDetailedHistory(
        reminderId
      );

      return res.status(200).json({
        success: true,
        history: detailedHistory,
      });
    } catch (error) {
      console.error("Error fetching detailed history:", error.message);
      return res.status(400).json({ error: error.message });
    }
  }

  /**
   * Clear reminder history
   * DELETE /api/reminders/history/clear
   */
  async clearReminderHistory(req, res) {
    try {
      const userId = req.user.id;

      const result = await reminderService.clearReminderHistory(userId);

      return res.status(200).json({
        success: true,
        ...result,
      });
    } catch (error) {
      console.error("Error clearing reminder history:", error.message);
      return res.status(400).json({ error: error.message });
    }
  }

  /**
   * Get upcoming reminders (next 7 days)
   * GET /api/reminders/upcoming
   */
  async getUpcomingReminders(req, res) {
    try {
      const userId = req.user.id;
      const { days } = req.query;

      const reminders = await reminderService.getUpcomingReminders(
        userId,
        days ? parseInt(days) : 7
      );

      return res.status(200).json({
        success: true,
        count: reminders.length,
        reminders,
      });
    } catch (error) {
      console.error("Error fetching upcoming reminders:", error.message);
      return res.status(400).json({ error: error.message });
    }
  }

  /**
   * Manually trigger reminder check (for testing)
   * POST /api/reminders/trigger-check
   */
  async triggerReminderCheck(req, res) {
    try {
      const result = await reminderService.checkAndTriggerReminders();

      return res.status(200).json({
        success: true,
        message: "Reminder check completed",
        result,
      });
    } catch (error) {
      console.error("Error triggering reminder check:", error.message);
      return res.status(400).json({ error: error.message });
    }
  }

  /**
   * Update days before due for reminder
   * PUT /api/reminders/:reminderId/days
   */
  async updateDaysBeforeDue(req, res) {
    try {
      const { reminderId } = req.params;
      const { daysBeforeDue } = req.body;

      if (daysBeforeDue === undefined) {
        return res.status(400).json({ error: "daysBeforeDue is required" });
      }

      if (daysBeforeDue < 0) {
        return res
          .status(400)
          .json({ error: "daysBeforeDue must be a positive number" });
      }

      const reminder = await reminderService.updateDaysBeforeDue(
        reminderId,
        daysBeforeDue
      );

      return res.status(200).json({
        success: true,
        message: "Days before due updated successfully",
        reminder,
      });
    } catch (error) {
      console.error("Error updating days before due:", error.message);
      return res.status(400).json({ error: error.message });
    }
  }
}

export default new ReminderController();
