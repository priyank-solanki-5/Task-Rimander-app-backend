import express from "express";
import authMiddleware from "../utils/authMiddleware.js";
import User from "../models/User.js";
import Task from "../models/Task.js";
import Notification from "../models/Notification.js";
import Category from "../models/Category.js";
import Reminder from "../models/Reminder.js";
import Document from "../models/Document.js";

const router = express.Router();

// Apply JWT authentication middleware to all admin routes
router.use(authMiddleware);

// ===== USER MANAGEMENT =====

// Get all users
router.get("/users", async (req, res) => {
  try {
    const users = await User.find({})
      .select("-password")
      .sort({ createdAt: -1 })
      .lean();

    res.status(200).json({
      success: true,
      data: users,
      count: users.length,
    });
  } catch (error) {
    console.error("Admin get users error:", error);
    res.status(500).json({ error: "Failed to fetch users" });
  }
});

// Get user by ID
router.get("/users/:id", async (req, res) => {
  try {
    const user = await User.findById(req.params.id).select("-password").lean();

    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    res.status(200).json({ success: true, data: user });
  } catch (error) {
    console.error("Admin get user error:", error);
    res.status(500).json({ error: "Failed to fetch user" });
  }
});

// Update user
router.put("/users/:id", async (req, res) => {
  try {
    const { username, email, mobile, isActive } = req.body;

    const user = await User.findByIdAndUpdate(
      req.params.id,
      { username, email, mobile, isActive },
      { new: true, runValidators: true },
    ).select("-password");

    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    res.status(200).json({ success: true, data: user });
  } catch (error) {
    console.error("Admin update user error:", error);
    res.status(500).json({ error: "Failed to update user" });
  }
});

// Delete user
router.delete("/users/:id", async (req, res) => {
  try {
    const user = await User.findByIdAndDelete(req.params.id);

    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    // Also delete user's tasks, notifications, etc.
    await Task.deleteMany({ userId: req.params.id });
    await Notification.deleteMany({ userId: req.params.id });
    await Reminder.deleteMany({ userId: req.params.id });

    res.status(200).json({
      success: true,
      message: "User and associated data deleted",
    });
  } catch (error) {
    console.error("Admin delete user error:", error);
    res.status(500).json({ error: "Failed to delete user" });
  }
});

// ===== TASK MANAGEMENT =====

// Get all tasks
router.get("/tasks", async (req, res) => {
  try {
    const tasks = await Task.find({})
      .populate("userId", "username email")
      .populate("categoryId", "name color")
      .sort({ createdAt: -1 })
      .lean();

    res.status(200).json({
      success: true,
      data: tasks,
      count: tasks.length,
    });
  } catch (error) {
    console.error("Admin get tasks error:", error);
    res.status(500).json({ error: "Failed to fetch tasks" });
  }
});

// Get task by ID
router.get("/tasks/:id", async (req, res) => {
  try {
    const task = await Task.findById(req.params.id)
      .populate("userId", "username email")
      .populate("categoryId", "name color")
      .lean();

    if (!task) {
      return res.status(404).json({ error: "Task not found" });
    }

    res.status(200).json({ success: true, data: task });
  } catch (error) {
    console.error("Admin get task error:", error);
    res.status(500).json({ error: "Failed to fetch task" });
  }
});

// Update task status
router.put("/tasks/:id/status", async (req, res) => {
  try {
    const { status } = req.body;

    const task = await Task.findByIdAndUpdate(
      req.params.id,
      { status },
      { new: true },
    )
      .populate("userId", "username email")
      .populate("categoryId", "name color");

    if (!task) {
      return res.status(404).json({ error: "Task not found" });
    }

    res.status(200).json({ success: true, data: task });
  } catch (error) {
    console.error("Admin update task error:", error);
    res.status(500).json({ error: "Failed to update task" });
  }
});

// Delete task
router.delete("/tasks/:id", async (req, res) => {
  try {
    const task = await Task.findByIdAndDelete(req.params.id);

    if (!task) {
      return res.status(404).json({ error: "Task not found" });
    }

    // Also delete related reminders
    await Reminder.deleteMany({ taskId: req.params.id });

    res.status(200).json({
      success: true,
      message: "Task and related reminders deleted",
    });
  } catch (error) {
    console.error("Admin delete task error:", error);
    res.status(500).json({ error: "Failed to delete task" });
  }
});

// ===== NOTIFICATION MANAGEMENT =====

// Get all notifications
router.get("/notifications", async (req, res) => {
  try {
    const notifications = await Notification.find({})
      .populate("userId", "username email")
      .sort({ createdAt: -1 })
      .lean();

    res.status(200).json({
      success: true,
      data: notifications,
      count: notifications.length,
    });
  } catch (error) {
    console.error("Admin get notifications error:", error);
    res.status(500).json({ error: "Failed to fetch notifications" });
  }
});

// Delete notification
router.delete("/notifications/:id", async (req, res) => {
  try {
    const notification = await Notification.findByIdAndDelete(req.params.id);

    if (!notification) {
      return res.status(404).json({ error: "Notification not found" });
    }

    res.status(200).json({
      success: true,
      message: "Notification deleted",
    });
  } catch (error) {
    console.error("Admin delete notification error:", error);
    res.status(500).json({ error: "Failed to delete notification" });
  }
});

// ===== DOCUMENT MANAGEMENT =====

// Get all documents
router.get("/documents", async (req, res) => {
  try {
    const documents = await Document.find({})
      .populate("userId", "username email")
      .populate("taskId", "title")
      .sort({ createdAt: -1 })
      .lean();

    res.status(200).json({
      success: true,
      data: documents,
      count: documents.length,
    });
  } catch (error) {
    console.error("Admin get documents error:", error);
    res.status(500).json({ error: "Failed to fetch documents" });
  }
});

// Get document by ID
router.get("/documents/:id", async (req, res) => {
  try {
    const document = await Document.findById(req.params.id)
      .populate("userId", "username email")
      .populate("taskId", "title")
      .lean();

    if (!document) {
      return res.status(404).json({ error: "Document not found" });
    }

    res.status(200).json({ success: true, data: document });
  } catch (error) {
    console.error("Admin get document error:", error);
    res.status(500).json({ error: "Failed to fetch document" });
  }
});

// Delete document
router.delete("/documents/:id", async (req, res) => {
  try {
    const document = await Document.findByIdAndDelete(req.params.id);

    if (!document) {
      return res.status(404).json({ error: "Document not found" });
    }

    res.status(200).json({
      success: true,
      message: "Document deleted",
    });
  } catch (error) {
    console.error("Admin delete document error:", error);
    res.status(500).json({ error: "Failed to delete document" });
  }
});

// ===== DASHBOARD STATISTICS =====

// Get dashboard statistics
router.get("/dashboard/stats", async (req, res) => {
  try {
    const [
      userCount,
      taskCount,
      notificationCount,
      categoryCount,
      documentCount,
    ] = await Promise.all([
      User.countDocuments(),
      Task.countDocuments(),
      Notification.countDocuments(),
      Category.countDocuments(),
      Document.countDocuments(),
    ]);

    const tasks = await Task.find({}).lean();

    const stats = {
      totalUsers: userCount,
      activeUsers: await User.countDocuments({ isActive: { $ne: false } }),
      totalTasks: taskCount,
      completedTasks: tasks.filter((t) => t.status === "Completed").length,
      pendingTasks: tasks.filter((t) => t.status === "Pending").length,
      inProgressTasks: tasks.filter((t) => t.status === "In Progress").length,
      overdueTasks: tasks.filter((t) => {
        if (t.status === "Completed") return false;
        return t.dueDate && new Date(t.dueDate) < new Date();
      }).length,
      totalNotifications: notificationCount,
      totalCategories: categoryCount,
      totalDocuments: documentCount,
    };

    res.status(200).json({ success: true, data: stats });
  } catch (error) {
    console.error("Admin dashboard stats error:", error);
    res.status(500).json({ error: "Failed to fetch dashboard stats" });
  }
});

// Get system information
router.get("/system/info", async (req, res) => {
  try {
    const dbStats = await User.db.db.stats();

    const info = {
      database: {
        name: User.db.db.databaseName,
        collections: dbStats.collections,
        dataSize: (dbStats.dataSize / 1024 / 1024).toFixed(2) + " MB",
        indexSize: (dbStats.indexSize / 1024 / 1024).toFixed(2) + " MB",
      },
      server: {
        nodeVersion: process.version,
        platform: process.platform,
        uptime: process.uptime(),
        memoryUsage: {
          heapUsed:
            (process.memoryUsage().heapUsed / 1024 / 1024).toFixed(2) + " MB",
          heapTotal:
            (process.memoryUsage().heapTotal / 1024 / 1024).toFixed(2) + " MB",
        },
      },
    };

    res.status(200).json({ success: true, data: info });
  } catch (error) {
    console.error("Admin system info error:", error);
    res.status(500).json({ error: "Failed to fetch system info" });
  }
});

export default router;
