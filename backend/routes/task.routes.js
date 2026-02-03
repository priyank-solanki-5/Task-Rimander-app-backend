import express from "express";
import taskController from "../controller/task.controller.js";
import authMiddleware from "../utils/authMiddleware.js";
import { apiLimiter, searchLimiter } from "../utils/rateLimitMiddleware.js";
import { verifyTaskOwnership } from "../utils/ownershipMiddleware.js";
import {
  validateTaskCreation,
  validateTaskUpdate,
  validateIdParam,
  validateSearchQuery,
  validateFilterQuery,
} from "../utils/validationMiddleware.js";

const router = express.Router();

// Apply authentication and rate limiting to all task routes
router.use(authMiddleware);
router.use(apiLimiter);

// ===== SEARCH & FILTER =====

// Search tasks by name
// GET /api/tasks/search?q=searchTerm
router.get("/search", searchLimiter, validateSearchQuery, (req, res) =>
  taskController.searchTasks(req, res),
);

// Filter tasks by category/status/date
// GET /api/tasks/filter?status=Pending&categoryId=1&startDate=2026-01-01
router.get("/filter", searchLimiter, validateFilterQuery, (req, res) =>
  taskController.filterTasks(req, res),
);

// Combined search and filter
// GET /api/tasks/search-filter?q=searchTerm&status=Pending&categoryId=1
router.get("/search-filter", searchLimiter, (req, res) =>
  taskController.searchAndFilter(req, res),
);

// ===== TASK MANAGEMENT =====

// Create task
router.post("/", validateTaskCreation, (req, res) =>
  taskController.createTask(req, res),
);

// Get all tasks for authenticated user (with optional filters)
router.get("/", (req, res) => taskController.getAllTasks(req, res));

// Get overdue tasks (must be before /:id)
router.get("/overdue", (req, res) => taskController.getOverdueTasks(req, res));

// Get upcoming tasks (default 7 days) (must be before /:id)
router.get("/upcoming", (req, res) =>
  taskController.getUpcomingTasks(req, res),
);

// Get recurring tasks (must be before /:id)
router.get("/recurring", (req, res) =>
  taskController.getRecurringTasks(req, res),
);

// Get task by ID (with ownership verification)
router.get("/:id", validateIdParam, verifyTaskOwnership, (req, res) =>
  taskController.getTaskById(req, res),
);

// Update task (with ownership verification)
router.put("/:id", validateTaskUpdate, verifyTaskOwnership, (req, res) =>
  taskController.updateTask(req, res),
);

// Delete task (with ownership verification)
router.delete("/:id", validateIdParam, verifyTaskOwnership, (req, res) =>
  taskController.deleteTask(req, res),
);

// Mark task as complete (with ownership verification)
router.patch(
  "/:id/complete",
  validateIdParam,
  verifyTaskOwnership,
  (req, res) => taskController.markTaskComplete(req, res),
);

// Mark task as pending (with ownership verification)
router.patch("/:id/pending", validateIdParam, verifyTaskOwnership, (req, res) =>
  taskController.markTaskPending(req, res),
);

// Stop recurrence for a task
router.patch("/:id/stop-recurrence", (req, res) =>
  taskController.stopRecurrence(req, res),
);

// Process all recurring tasks (admin/cron)
router.post("/process-recurring", (req, res) =>
  taskController.processRecurringTasks(req, res),
);

export default router;
