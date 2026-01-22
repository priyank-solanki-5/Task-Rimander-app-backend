import express from "express";
import bodyParser from "body-parser";
import cors from "cors";
import dotenv from "dotenv";
import connectDB from "./config/mongodb.js";
import userRoutes from "./routes/user.routes.js";
import categoryRoutes from "./routes/category.routes.js";
import taskRoutes from "./routes/task.routes.js";
import documentRoutes from "./routes/document.routes.js";
import notificationRoutes from "./routes/notification.routes.js";
import reminderRoutes from "./routes/reminder.routes.js";
import dashboardRoutes from "./routes/dashboard.routes.js";
import adminRoutes from "./routes/admin.routes.js";
import categoryService from "./services/category.service.js";
import schedulerService from "./services/scheduler.service.js";
import "./models/User.js";
import "./models/Task.js";
import "./models/Category.js";
import "./models/Document.js";
import "./models/Notification.js";
import "./models/NotificationRule.js";
import "./models/Reminder.js";

// Load environment variables
dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Routes
app.use("/api/users", userRoutes);
app.use("/api/categories", categoryRoutes);
app.use("/api/tasks", taskRoutes);
app.use("/api/documents", documentRoutes);
app.use("/api/notifications", notificationRoutes);
app.use("/api/reminders", reminderRoutes);
app.use("/api/dashboard", dashboardRoutes);
app.use("/api/admin", adminRoutes);

// Health check route
app.get("/health", (req, res) => {
  res.status(200).json({ status: "OK", message: "Server is running" });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: "Something went wrong!" });
});

// Connect to MongoDB and start server
connectDB()
  .then(async () => {
    // Seed predefined categories
    await categoryService.seedPredefinedCategories();
    console.log("✅ Predefined categories seeded successfully");

    // Initialize notification scheduler
    schedulerService.initializeScheduler();

    app.listen(PORT, () => {
      console.log(`\n🚀 Server is running on port ${PORT}`);
      console.log(`\n🔔 API Endpoints:`);
      console.log(`   Users:        http://localhost:${PORT}/api/users`);
      console.log(`   Categories:   http://localhost:${PORT}/api/categories`);
      console.log(`   Tasks:        http://localhost:${PORT}/api/tasks`);
      console.log(`   Documents:    http://localhost:${PORT}/api/documents`);
      console.log(
        `   Notifications: http://localhost:${PORT}/api/notifications`,
      );
      console.log(`   Reminders:    http://localhost:${PORT}/api/reminders`);
      console.log(`   Dashboard:    http://localhost:${PORT}/api/dashboard`);
      console.log(`   Health Check: http://localhost:${PORT}/health\n`);
    });
  })
  .catch((err) => {
    console.error("❌ Unable to connect to MongoDB:", err);
  });
