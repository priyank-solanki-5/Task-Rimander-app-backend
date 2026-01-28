import express from "express";
import notificationController from "../controller/notification.controller.js";
import authMiddleware from "../utils/authMiddleware.js";

const router = express.Router();

// All routes require authentication
router.use(authMiddleware);

// ===== NOTIFICATION RULES ROUTES =====

// Create a new notification rule
router.post("/rules", (req, res) =>
  notificationController.createRule(req, res),
);

// Get all rules for authenticated user
router.get("/rules", (req, res) =>
  notificationController.getUserRules(req, res),
);

// Get rules for a specific task
router.get("/rules/task/:taskId", (req, res) =>
  notificationController.getTaskRules(req, res),
);

// Get a single rule
router.get("/rules/:ruleId", (req, res) =>
  notificationController.getRule(req, res),
);

// Update a notification rule
router.put("/rules/:ruleId", (req, res) =>
  notificationController.updateRule(req, res),
);

// Delete a notification rule
router.delete("/rules/:ruleId", (req, res) =>
  notificationController.deleteRule(req, res),
);

// ===== NOTIFICATIONS ROUTES =====

// Get all notifications for authenticated user (with optional filters)
router.get("/", (req, res) =>
  notificationController.getNotifications(req, res),
);

// Get unread notification count
router.get("/unread-count", (req, res) =>
  notificationController.getUnreadCount(req, res),
);

// Get upcoming tasks for next 7 days
router.get("/upcoming-tasks", (req, res) =>
  notificationController.getUpcomingTasks(req, res),
);

// Mark a single notification as read
router.put("/:notificationId/read", (req, res) =>
  notificationController.markAsRead(req, res),
);

// Mark all notifications as read
router.put("/mark-all-read", (req, res) =>
  notificationController.markAllAsRead(req, res),
);

// Delete a notification
router.delete("/:notificationId", (req, res) =>
  notificationController.deleteNotification(req, res),
);

// ===== ADMIN/DEBUG ROUTES =====

// Manually trigger notification check (for testing)
router.post("/trigger-check", (req, res) =>
  notificationController.triggerNotificationCheck(req, res),
);

// ===== NOTIFICATION PREFERENCES ROUTES =====

// Get user notification preferences
router.get("/preferences", (req, res) =>
  notificationController.getPreferences(req, res),
);

// Update user notification preferences
router.put("/preferences", (req, res) =>
  notificationController.updatePreferences(req, res),
);

// Update push notification token
router.post("/push-token", (req, res) =>
  notificationController.updatePushToken(req, res),
);

// Test push notification
router.post("/test-push", (req, res) =>
  notificationController.testPushNotification(req, res),
);

export default router;
