import express from "express";
import dashboardController from "../controller/dashboard.controller.js";
import authMiddleware from "../utils/authMiddleware.js";

const router = express.Router();

// All routes require authentication
router.use(authMiddleware);

// ===== COMPREHENSIVE DASHBOARD =====

/**
 * Get comprehensive dashboard
 * Returns statistics + preview of upcoming and overdue tasks
 * GET /api/dashboard?preview=5
 */
router.get("/", (req, res) =>
  dashboardController.getComprehensiveDashboard(req, res)
);

// ===== STATISTICS =====

/**
 * Get all task statistics (counts only)
 * Returns: upcoming, completed, overdue, total, pending counts
 * GET /api/dashboard/statistics
 */
router.get("/statistics", (req, res) =>
  dashboardController.getDashboardStatistics(req, res)
);

/**
 * Get task breakdown by status
 * Returns: pending and completed counts
 * GET /api/dashboard/status-breakdown
 */
router.get("/status-breakdown", (req, res) =>
  dashboardController.getTasksByStatus(req, res)
);

// ===== INDIVIDUAL COUNTS =====

/**
 * Get upcoming tasks count
 * GET /api/dashboard/upcoming/count
 */
router.get("/upcoming/count", (req, res) =>
  dashboardController.getUpcomingCount(req, res)
);

/**
 * Get completed tasks count
 * GET /api/dashboard/completed/count
 */
router.get("/completed/count", (req, res) =>
  dashboardController.getCompletedCount(req, res)
);

/**
 * Get overdue tasks count
 * GET /api/dashboard/overdue/count
 */
router.get("/overdue/count", (req, res) =>
  dashboardController.getOverdueCount(req, res)
);

// ===== TASK LISTS =====

/**
 * Get upcoming tasks with details
 * GET /api/dashboard/upcoming?limit=10
 */
router.get("/upcoming", (req, res) =>
  dashboardController.getUpcomingTasks(req, res)
);

/**
 * Get overdue tasks with details
 * GET /api/dashboard/overdue?limit=10
 */
router.get("/overdue", (req, res) =>
  dashboardController.getOverdueTasks(req, res)
);

export default router;
