import express from "express";
import reminderController from "../controller/reminder.controller.js";
import authMiddleware from "../utils/authMiddleware.js";
import { apiLimiter } from "../utils/rateLimitMiddleware.js";
import { verifyReminderOwnership } from "../utils/ownershipMiddleware.js";
import {
  validateReminderCreation,
  validateIdParam,
} from "../utils/validationMiddleware.js";

const router = express.Router();

// Apply authentication and rate limiting to all reminder routes
router.use(authMiddleware);
router.use(apiLimiter);

// ===== CREATE & DELETE =====

// Create a new reminder for a task
router.post("/", validateReminderCreation, (req, res) =>
  reminderController.createReminder(req, res),
);

// Delete a reminder (with ownership verification)
router.delete(
  "/:reminderId",
  validateIdParam,
  verifyReminderOwnership,
  (req, res) => reminderController.deleteReminder(req, res),
);

// ===== GET REMINDERS =====

// Get all reminders for authenticated user
router.get("/", (req, res) => reminderController.getUserReminders(req, res));

// Get active (upcoming) reminders (must be before /:reminderId)
router.get("/active", (req, res) =>
  reminderController.getActiveReminders(req, res),
);

// Get upcoming reminders (next 7 days) (must be before /:reminderId)
router.get("/upcoming", (req, res) =>
  reminderController.getUpcomingReminders(req, res),
);

// Get reminder for a specific task (must be before /:reminderId)
router.get("/task/:taskId", validateIdParam, (req, res) =>
  reminderController.getReminder(req, res),
);

// Get a single reminder by ID (with ownership verification)
router.get(
  "/:reminderId",
  validateIdParam,
  verifyReminderOwnership,
  (req, res) => reminderController.getReminderById(req, res),
);

// ===== UPDATE REMINDER =====

// Update reminder (with ownership verification)
router.put(
  "/:reminderId",
  validateIdParam,
  verifyReminderOwnership,
  (req, res) => reminderController.updateReminder(req, res),
);

// ===== HISTORY =====

// Get reminder history (triggered reminders) (must be before /:reminderId)
router.get("/history", (req, res) =>
  reminderController.getReminderHistory(req, res),
);

// Update days before due
router.put("/:reminderId/days", (req, res) =>
  reminderController.updateDaysBeforeDue(req, res),
);

// Snooze reminder
router.put("/:reminderId/snooze", (req, res) =>
  reminderController.snoozeReminder(req, res),
);

// Unsnooze reminder
router.put("/:reminderId/unsnooze", (req, res) =>
  reminderController.unsnoozeReminder(req, res),
);

// Get detailed history for a specific reminder
router.get("/:reminderId/history", (req, res) =>
  reminderController.getReminderDetailedHistory(req, res),
);

// Clear reminder history
router.delete("/history/clear", (req, res) =>
  reminderController.clearReminderHistory(req, res),
);

// ===== ADMIN/DEBUG =====

// Manually trigger reminder check (for testing)
router.post("/trigger-check", (req, res) =>
  reminderController.triggerReminderCheck(req, res),
);

export default router;
