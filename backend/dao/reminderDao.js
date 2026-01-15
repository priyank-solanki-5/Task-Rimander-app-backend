import Reminder from "../models/Reminder.js";
import Task from "../models/Task.js";
import User from "../models/User.js";

class ReminderDAO {
  /**
   * Create a new reminder
   */
  async createReminder(data) {
    try {
      return await Reminder.create(data);
    } catch (error) {
      throw error;
    }
  }

  /**
   * Get reminder for a specific task
   */
  async getReminderByTaskId(taskId) {
    try {
      return await Reminder.findOne({
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
   * Get all reminders for a user
   */
  async getRemindersByUserId(userId) {
    try {
      return await Reminder.findAll({
        where: { userId },
        include: [
          { model: Task, attributes: ["id", "title", "dueDate", "status"] },
          { model: User, attributes: ["id", "username"] },
        ],
        order: [["reminderDate", "ASC"]],
      });
    } catch (error) {
      throw error;
    }
  }

  /**
   * Get a single reminder by ID
   */
  async getReminderById(reminderId) {
    try {
      return await Reminder.findByPk(reminderId, {
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
   * Update reminder
   */
  async updateReminder(reminderId, data) {
    try {
      const reminder = await Reminder.findByPk(reminderId);
      if (!reminder) {
        throw new Error("Reminder not found");
      }
      return await reminder.update(data);
    } catch (error) {
      throw error;
    }
  }

  /**
   * Delete reminder
   */
  async deleteReminder(reminderId) {
    try {
      return await Reminder.destroy({
        where: { id: reminderId },
      });
    } catch (error) {
      throw error;
    }
  }

  /**
   * Get all pending reminders (not yet triggered)
   */
  async getPendingReminders() {
    try {
      return await Reminder.findAll({
        where: { isTriggered: false, isActive: true },
        include: [
          { model: Task, attributes: ["id", "title", "dueDate", "status"] },
          { model: User, attributes: ["id", "username", "email"] },
        ],
        order: [["reminderDate", "ASC"]],
      });
    } catch (error) {
      throw error;
    }
  }

  /**
   * Get reminders that should be triggered (reminder date has passed)
   */
  async getRemindersToTrigger() {
    try {
      const now = new Date();
      return await Reminder.findAll({
        where: {
          isTriggered: false,
          isActive: true,
          reminderDate: {
            [require("sequelize").Op.lte]: now, // Less than or equal to now
          },
        },
        include: [
          { model: Task, attributes: ["id", "title", "dueDate", "status"] },
          { model: User, attributes: ["id", "username", "email"] },
        ],
        order: [["reminderDate", "ASC"]],
      });
    } catch (error) {
      throw error;
    }
  }

  /**
   * Mark reminder as triggered
   */
  async markAsTriggered(reminderId, metadata = null) {
    try {
      return await Reminder.update(
        {
          isTriggered: true,
          triggeredAt: new Date(),
          metadata: metadata,
        },
        { where: { id: reminderId } }
      );
    } catch (error) {
      throw error;
    }
  }

  /**
   * Add to reminder history
   */
  async addToHistory(reminderId, historyEntry) {
    try {
      const reminder = await Reminder.findByPk(reminderId);
      if (!reminder) {
        throw new Error("Reminder not found");
      }

      const currentHistory = reminder.history || [];
      const updatedHistory = [...currentHistory, historyEntry];

      return await reminder.update({ history: updatedHistory });
    } catch (error) {
      throw error;
    }
  }

  /**
   * Get reminder history for a task
   */
  async getReminderHistory(reminderId) {
    try {
      const reminder = await Reminder.findByPk(reminderId);
      if (!reminder) {
        throw new Error("Reminder not found");
      }
      return reminder.history || [];
    } catch (error) {
      throw error;
    }
  }

  /**
   * Check if reminder exists for task
   */
  async reminderExistsForTask(taskId) {
    try {
      const reminder = await Reminder.findOne({
        where: { taskId },
      });
      return !!reminder;
    } catch (error) {
      throw error;
    }
  }

  /**
   * Get active reminders for user (not triggered, active)
   */
  async getActiveRemindersByUserId(userId) {
    try {
      return await Reminder.findAll({
        where: { userId, isActive: true, isTriggered: false },
        include: [
          { model: Task, attributes: ["id", "title", "dueDate", "status"] },
        ],
        order: [["reminderDate", "ASC"]],
      });
    } catch (error) {
      throw error;
    }
  }

  /**
   * Get triggered reminders for user (reminder history)
   */
  async getTriggeredRemindersByUserId(userId) {
    try {
      return await Reminder.findAll({
        where: { userId, isTriggered: true },
        include: [
          { model: Task, attributes: ["id", "title", "dueDate", "status"] },
        ],
        order: [["triggeredAt", "DESC"]],
      });
    } catch (error) {
      throw error;
    }
  }

  /**
   * Disable reminder (soft delete)
   */
  async disableReminder(reminderId) {
    try {
      return await Reminder.update(
        { isActive: false },
        { where: { id: reminderId } }
      );
    } catch (error) {
      throw error;
    }
  }

  /**
   * Enable reminder
   */
  async enableReminder(reminderId) {
    try {
      return await Reminder.update(
        { isActive: true, isTriggered: false },
        { where: { id: reminderId } }
      );
    } catch (error) {
      throw error;
    }
  }

  /**
   * Update days before due for reminder
   */
  async updateDaysBeforeDue(reminderId, daysBeforeDue) {
    try {
      return await Reminder.update(
        { daysBeforeDue },
        { where: { id: reminderId } }
      );
    } catch (error) {
      throw error;
    }
  }
}

export default new ReminderDAO();
