import taskDao from "../dao/taskDao.js";
import categoryDao from "../dao/categoryDao.js";
import documentDao from "../dao/documentDao.js";
import reminderDao from "../dao/reminderDao.js";
import notificationDao from "../dao/notificationDao.js";

/**
 * Middleware to verify task ownership
 * Ensures the authenticated user owns the task
 */
export const verifyTaskOwnership = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const taskId = req.params.id || req.body.taskId;

    if (!taskId) {
      return res.status(400).json({
        success: false,
        error: "Task ID is required",
      });
    }

    const task = await taskDao.findTaskById(taskId, userId);

    if (!task) {
      return res.status(404).json({
        success: false,
        error: "Task not found or you don't have permission to access it",
      });
    }

    // Attach task to request for later use
    req.task = task;
    next();
  } catch (error) {
    return res.status(500).json({
      success: false,
      error: "Error verifying task ownership",
    });
  }
};

/**
 * Middleware to verify category ownership
 * Ensures the authenticated user owns the category (for custom categories)
 */
export const verifyCategoryOwnership = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const categoryId = req.params.id;

    if (!categoryId) {
      return res.status(400).json({
        success: false,
        error: "Category ID is required",
      });
    }

    const category = await categoryDao.findCategoryById(categoryId);

    if (!category) {
      return res.status(404).json({
        success: false,
        error: "Category not found",
      });
    }

    // Check if category is predefined (can't be modified) or belongs to user
    if (!category.isPredefined && category.userId.toString() !== userId) {
      return res.status(403).json({
        success: false,
        error: "You don't have permission to access this category",
      });
    }

    if (
      category.isPredefined &&
      ["PUT", "DELETE", "PATCH"].includes(req.method)
    ) {
      return res.status(403).json({
        success: false,
        error: "Cannot modify or delete predefined categories",
      });
    }

    req.category = category;
    next();
  } catch (error) {
    return res.status(500).json({
      success: false,
      error: "Error verifying category ownership",
    });
  }
};

/**
 * Middleware to verify document ownership
 * Ensures the authenticated user owns the document
 */
export const verifyDocumentOwnership = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const documentId = req.params.id;

    if (!documentId) {
      return res.status(400).json({
        success: false,
        error: "Document ID is required",
      });
    }

    const document = await documentDao.findDocumentById(documentId, userId);

    if (!document) {
      return res.status(404).json({
        success: false,
        error: "Document not found",
      });
    }

    if (document.userId.toString() !== userId) {
      return res.status(403).json({
        success: false,
        error: "You don't have permission to access this document",
      });
    }

    req.document = document;
    next();
  } catch (error) {
    return res.status(500).json({
      success: false,
      error: "Error verifying document ownership",
    });
  }
};

/**
 * Middleware to verify reminder ownership
 * Ensures the authenticated user owns the reminder
 */
export const verifyReminderOwnership = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const reminderId = req.params.reminderId;

    if (!reminderId) {
      return res.status(400).json({
        success: false,
        error: "Reminder ID is required",
      });
    }

    const reminder = await reminderDao.getReminderById(reminderId);

    if (!reminder) {
      return res.status(404).json({
        success: false,
        error: "Reminder not found",
      });
    }

    // Check ownership (handle both populated and unpopulated userId)
    const reminderUserId = reminder.userId._id || reminder.userId;
    if (reminderUserId.toString() !== userId) {
      return res.status(403).json({
        success: false,
        error: "You don't have permission to access this reminder",
      });
    }

    req.reminder = reminder;
    next();
  } catch (error) {
    return res.status(500).json({
      success: false,
      error: "Error verifying reminder ownership",
    });
  }
};

/**
 * Middleware to verify notification ownership
 * Ensures the authenticated user owns the notification
 */
export const verifyNotificationOwnership = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const notificationId = req.params.id;

    if (!notificationId) {
      return res.status(400).json({
        success: false,
        error: "Notification ID is required",
      });
    }

    const notification = await notificationDao.getNotificationById(
      notificationId
    );

    if (!notification) {
      return res.status(404).json({
        success: false,
        error: "Notification not found",
      });
    }

    // Check ownership (handle both populated and unpopulated userId)
    const notificationUserId = notification.userId._id || notification.userId;
    if (notificationUserId.toString() !== userId) {
      return res.status(403).json({
        success: false,
        error: "You don't have permission to access this notification",
      });
    }

    req.notification = notification;
    next();
  } catch (error) {
    return res.status(500).json({
      success: false,
      error: "Error verifying notification ownership",
    });
  }
};

export default {
  verifyTaskOwnership,
  verifyCategoryOwnership,
  verifyDocumentOwnership,
  verifyReminderOwnership,
  verifyNotificationOwnership,
};
