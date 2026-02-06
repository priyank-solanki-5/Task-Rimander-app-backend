import Reminder from "../models/Reminder.js";
import Task from "../models/Task.js";
import User from "../models/User.js";

class ReminderDAO {
  /**
   * Create a new reminder
   */
  async createReminder(data) {
    const reminder = new Reminder(data);
    return await reminder.save();
  }

  /**
   * Get reminder for a specific task and minutes before due
   */
  async getReminderByTaskIdAndMinutes(taskId, minutesBeforeDue) {
    return await Reminder.findOne({ taskId, minutesBeforeDue })
      .populate("taskId", "id title dueDate status")
      .populate("userId", "id username email");
  }

  /**
   * Get all reminders for a task
   */
  async getRemindersByTaskId(taskId) {
    return await Reminder.find({ taskId })
      .populate("taskId", "id title dueDate status")
      .populate("userId", "id username email")
      .sort({ reminderDate: 1 });
  }

  /**
   * Get all reminders for a user
   */
  async getRemindersByUserId(userId) {
    return await Reminder.find({ userId })
      .populate("taskId", "id title dueDate status")
      .populate("userId", "id username")
      .sort({ reminderDate: 1 });
  }

  /**
   * Get a single reminder by ID
   */
  async getReminderById(reminderId) {
    return await Reminder.findById(reminderId)
      .populate("taskId", "id title dueDate status")
      .populate("userId", "id username email");
  }

  /**
   * Update reminder
   */
  async updateReminder(reminderId, data) {
    const reminder = await Reminder.findById(reminderId);
    if (!reminder) {
      throw new Error("Reminder not found");
    }
    Object.assign(reminder, data);
    return await reminder.save();
  }

  /**
   * Delete reminder
   */
  async deleteReminder(reminderId) {
    return await Reminder.findByIdAndDelete(reminderId);
  }

  /**
   * Get all pending reminders (not yet triggered)
   */
  async getPendingReminders() {
    return await Reminder.find({ isTriggered: false, isActive: true })
      .populate("taskId", "id title dueDate status")
      .populate("userId", "id username email")
      .sort({ reminderDate: 1 });
  }

  /**
   * Get reminders that should be triggered (reminder date has passed)
   */
  async getRemindersToTrigger() {
    const now = new Date();
    return await Reminder.find({
      isTriggered: false,
      isActive: true,
      reminderDate: { $lte: now },
    })
      .populate("taskId", "id title dueDate status")
      .populate("userId", "id username email")
      .sort({ reminderDate: 1 });
  }

  /**
   * Mark reminder as triggered
   */
  async markAsTriggered(reminderId, metadata = null) {
    return await Reminder.findByIdAndUpdate(
      reminderId,
      {
        isTriggered: true,
        triggeredAt: new Date(),
        metadata: metadata,
      },
      { new: true }
    );
  }

  /**
   * Add to reminder history
   */
  async addToHistory(reminderId, historyEntry) {
    const reminder = await Reminder.findById(reminderId);
    if (!reminder) {
      throw new Error("Reminder not found");
    }

    const currentHistory = reminder.history || [];
    const updatedHistory = [...currentHistory, historyEntry];

    return await Reminder.findByIdAndUpdate(
      reminderId,
      { history: updatedHistory },
      { new: true }
    );
  }

  /**
   * Get reminder history for a task
   */
  async getReminderHistory(reminderId) {
    const reminder = await Reminder.findById(reminderId);
    if (!reminder) {
      throw new Error("Reminder not found");
    }
    return reminder.history || [];
  }

  /**
   * Check if reminder exists for task
   */
  async reminderExistsForTask(taskId) {
    const reminder = await Reminder.findOne({ taskId });
    return !!reminder;
  }

  /**
   * Get active reminders for user (not triggered, active)
   */
  async getActiveRemindersByUserId(userId) {
    return await Reminder.find({ userId, isActive: true, isTriggered: false })
      .populate("taskId", "id title dueDate status")
      .sort({ reminderDate: 1 });
  }

  /**
   * Get triggered reminders for user (reminder history)
   */
  async getTriggeredRemindersByUserId(userId) {
    return await Reminder.find({ userId, isTriggered: true })
      .populate("taskId", "id title dueDate status")
      .sort({ triggeredAt: -1 });
  }

  /**
   * Disable reminder (soft delete)
   */
  async disableReminder(reminderId) {
    return await Reminder.findByIdAndUpdate(
      reminderId,
      { isActive: false },
      { new: true }
    );
  }

  /**
   * Enable reminder
   */
  async enableReminder(reminderId) {
    return await Reminder.findByIdAndUpdate(
      reminderId,
      { isActive: true, isTriggered: false },
      { new: true }
    );
  }

  /**
   * Update days before due for reminder
   */
  async updateDaysBeforeDue(reminderId, daysBeforeDue) {
    return await Reminder.findByIdAndUpdate(
      reminderId,
      { daysBeforeDue },
      { new: true }
    );
  }
}

export default new ReminderDAO();
