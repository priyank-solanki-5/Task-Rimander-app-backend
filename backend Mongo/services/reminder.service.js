import reminderDao from "../dao/reminderDao.js";
import Task from "../models/Task.js";

class ReminderService {
  /**
   * Create a reminder for a task
   * MVP: One reminder per task
   */
  async createReminder(userId, taskId, daysBeforeDue = 1, type = "in-app") {
    try {
      // Check if task exists and belongs to user
      const task = await Task.findOne({
        where: { id: taskId, userId },
      });

      if (!task) {
        throw new Error("Task not found or does not belong to this user");
      }

      if (!task.dueDate) {
        throw new Error("Task must have a due date to create a reminder");
      }

      // Check if reminder already exists (MVP: one per task)
      const existingReminder = await reminderDao.getReminderByTaskId(taskId);
      if (existingReminder) {
        throw new Error("Reminder already exists for this task");
      }

      // Calculate reminder date (X days before due date)
      const dueDate = new Date(task.dueDate);
      const reminderDate = new Date(dueDate);
      reminderDate.setDate(reminderDate.getDate() - daysBeforeDue);

      const reminderData = {
        userId,
        taskId,
        daysBeforeDue,
        reminderDate,
        type,
        isActive: true,
        isTriggered: false,
      };

      return await reminderDao.createReminder(reminderData);
    } catch (error) {
      throw error;
    }
  }

  /**
   * Get reminder for a task
   */
  async getReminder(taskId) {
    try {
      return await reminderDao.getReminderByTaskId(taskId);
    } catch (error) {
      throw error;
    }
  }

  /**
   * Get all reminders for a user
   */
  async getUserReminders(userId) {
    try {
      return await reminderDao.getRemindersByUserId(userId);
    } catch (error) {
      throw error;
    }
  }

  /**
   * Get single reminder by ID
   */
  async getReminderById(reminderId) {
    try {
      return await reminderDao.getReminderById(reminderId);
    } catch (error) {
      throw error;
    }
  }

  /**
   * Update reminder
   */
  async updateReminder(reminderId, updateData) {
    try {
      // Don't allow changing taskId or userId
      const { taskId, userId, ...safeData } = updateData;

      // If updating daysBeforeDue, recalculate reminderDate
      if (safeData.daysBeforeDue !== undefined) {
        const reminder = await reminderDao.getReminderById(reminderId);
        if (!reminder) {
          throw new Error("Reminder not found");
        }

        const task = await Task.findByPk(reminder.taskId);
        const dueDate = new Date(task.dueDate);
        const newReminderDate = new Date(dueDate);
        newReminderDate.setDate(
          newReminderDate.getDate() - safeData.daysBeforeDue
        );

        safeData.reminderDate = newReminderDate;
      }

      return await reminderDao.updateReminder(reminderId, safeData);
    } catch (error) {
      throw error;
    }
  }

  /**
   * Delete reminder
   */
  async deleteReminder(reminderId) {
    try {
      return await reminderDao.deleteReminder(reminderId);
    } catch (error) {
      throw error;
    }
  }

  /**
   * Snooze reminder (disable for now, can be re-enabled)
   */
  async snoozeReminder(reminderId) {
    try {
      return await reminderDao.disableReminder(reminderId);
    } catch (error) {
      throw error;
    }
  }

  /**
   * Re-enable snoozed reminder
   */
  async unsnoozeReminder(reminderId) {
    try {
      return await reminderDao.enableReminder(reminderId);
    } catch (error) {
      throw error;
    }
  }

  /**
   * Check and trigger reminders that are due
   * Called by scheduler periodically
   */
  async checkAndTriggerReminders() {
    try {
      const remindersToTrigger = await reminderDao.getRemindersToTrigger();
      let remindersTriggered = 0;

      for (const reminder of remindersToTrigger) {
        // Capture metadata before marking as triggered
        const metadata = {
          taskTitle: reminder.Task.title,
          dueDate: reminder.Task.dueDate,
          reminderSentAt: new Date(),
          daysBeforeDue: reminder.daysBeforeDue,
        };

        // Mark as triggered
        await reminderDao.markAsTriggered(reminder.id, metadata);

        // Add to history
        await reminderDao.addToHistory(reminder.id, {
          triggeredAt: new Date(),
          status: "triggered",
          message: `Reminder triggered for task: ${reminder.Task.title}`,
        });

        remindersTriggered++;
      }

      return {
        success: true,
        remindersTriggered,
        timestamp: new Date(),
      };
    } catch (error) {
      console.error("Error in checkAndTriggerReminders:", error);
      throw error;
    }
  }

  /**
   * Get active reminders for user (upcoming)
   */
  async getActiveReminders(userId) {
    try {
      return await reminderDao.getActiveRemindersByUserId(userId);
    } catch (error) {
      throw error;
    }
  }

  /**
   * Get reminder history for user (triggered reminders)
   */
  async getReminderHistory(userId) {
    try {
      return await reminderDao.getTriggeredRemindersByUserId(userId);
    } catch (error) {
      throw error;
    }
  }

  /**
   * Get detailed history for a specific reminder
   */
  async getReminderDetailedHistory(reminderId) {
    try {
      const reminder = await reminderDao.getReminderById(reminderId);
      if (!reminder) {
        throw new Error("Reminder not found");
      }

      return {
        reminderId: reminder.id,
        taskId: reminder.taskId,
        taskTitle: reminder.Task.title,
        daysBeforeDue: reminder.daysBeforeDue,
        reminderDate: reminder.reminderDate,
        isTriggered: reminder.isTriggered,
        triggeredAt: reminder.triggeredAt,
        metadata: reminder.metadata,
        history: reminder.history || [],
      };
    } catch (error) {
      throw error;
    }
  }

  /**
   * Clear reminder history (delete triggered reminders)
   */
  async clearReminderHistory(userId) {
    try {
      const triggeredReminders =
        await reminderDao.getTriggeredRemindersByUserId(userId);

      for (const reminder of triggeredReminders) {
        await reminderDao.deleteReminder(reminder.id);
      }

      return {
        success: true,
        count: triggeredReminders.length,
        message: `Cleared ${triggeredReminders.length} reminder(s) from history`,
      };
    } catch (error) {
      throw error;
    }
  }

  /**
   * Handle task completion - disable reminder if exists
   */
  async onTaskCompleted(taskId) {
    try {
      const reminder = await reminderDao.getReminderByTaskId(taskId);
      if (reminder) {
        await reminderDao.disableReminder(reminder.id);
      }
      return { success: true };
    } catch (error) {
      throw error;
    }
  }

  /**
   * Update reminder days before due
   */
  async updateDaysBeforeDue(reminderId, daysBeforeDue) {
    try {
      const reminder = await reminderDao.getReminderById(reminderId);
      if (!reminder) {
        throw new Error("Reminder not found");
      }

      // Recalculate reminder date
      const task = await Task.findByPk(reminder.taskId);
      const dueDate = new Date(task.dueDate);
      const newReminderDate = new Date(dueDate);
      newReminderDate.setDate(newReminderDate.getDate() - daysBeforeDue);

      return await reminderDao.updateReminder(reminderId, {
        daysBeforeDue,
        reminderDate: newReminderDate,
      });
    } catch (error) {
      throw error;
    }
  }

  /**
   * Get upcoming reminders (next 7 days)
   */
  async getUpcomingReminders(userId, days = 7) {
    try {
      const reminders = await reminderDao.getActiveRemindersByUserId(userId);

      const now = new Date();
      const futureDate = new Date();
      futureDate.setDate(futureDate.getDate() + days);

      const upcomingReminders = reminders.filter((reminder) => {
        const reminderDate = new Date(reminder.reminderDate);
        return reminderDate >= now && reminderDate <= futureDate;
      });

      return upcomingReminders.sort(
        (a, b) => new Date(a.reminderDate) - new Date(b.reminderDate)
      );
    } catch (error) {
      throw error;
    }
  }
}

export default new ReminderService();
