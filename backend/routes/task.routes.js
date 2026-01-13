import express from "express";
import taskController from "../controller/task.controller.js";

const router = express.Router();

// Create task
router.post("/", (req, res) => taskController.createTask(req, res));

// Get all tasks for a user (with optional filters)
router.get("/user/:userId", (req, res) => taskController.getAllTasks(req, res));

// Get task by ID
router.get("/:id", (req, res) => taskController.getTaskById(req, res));

// Update task
router.put("/:id", (req, res) => taskController.updateTask(req, res));

// Delete task
router.delete("/:id", (req, res) => taskController.deleteTask(req, res));

// Mark task as complete
router.patch("/:id/complete", (req, res) =>
  taskController.markTaskComplete(req, res)
);

// Mark task as pending
router.patch("/:id/pending", (req, res) =>
  taskController.markTaskPending(req, res)
);

// Get overdue tasks
router.get("/user/:userId/overdue", (req, res) =>
  taskController.getOverdueTasks(req, res)
);

// Get upcoming tasks (default 7 days)
router.get("/user/:userId/upcoming", (req, res) =>
  taskController.getUpcomingTasks(req, res)
);

// Get recurring tasks
router.get("/user/:userId/recurring", (req, res) =>
  taskController.getRecurringTasks(req, res)
);

// Stop recurrence for a task
router.patch("/:id/stop-recurrence", (req, res) =>
  taskController.stopRecurrence(req, res)
);

// Process all recurring tasks (admin/cron)
router.post("/process-recurring", (req, res) =>
  taskController.processRecurringTasks(req, res)
);

export default router;
