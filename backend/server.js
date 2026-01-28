import express from "express";
import bodyParser from "body-parser";
import cors from "cors";
import dotenv from "dotenv";
import path from "path";
import { fileURLToPath } from "url";
import connectDB from "./config/mongodb.js";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
import userRoutes from "./routes/user.routes.js";
import categoryRoutes from "./routes/category.routes.js";
import taskRoutes from "./routes/task.routes.js";
import documentRoutes from "./routes/document.routes.js";
import notificationRoutes from "./routes/notification.routes.js";
import reminderRoutes from "./routes/reminder.routes.js";
import dashboardRoutes from "./routes/dashboard.routes.js";
import adminRoutes from "./routes/admin.routes.js";
import memberRoutes from "./routes/member.routes.js";
import categoryService from "./services/category.service.js";
import schedulerService from "./services/scheduler.service.js";
import "./models/User.js";
import "./models/Task.js";
import "./models/Category.js";
import "./models/Document.js";
import "./models/Notification.js";
import "./models/NotificationRule.js";
import "./models/Reminder.js";
import "./models/Member.js";
import Document from "./models/Document.js";
import fs from "fs";

// Load environment variables
dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Enhanced document file serving with fallback lookup
app.get("/uploads/documents/:filename", async (req, res) => {
  try {
    const requestedFilename = req.params.filename;
    const uploadsDir = path.join(__dirname, "uploads", "documents");
    const filePath = path.join(uploadsDir, requestedFilename);

    // Security check - ensure requested file is within uploads/documents
    const normalizedPath = path.normalize(filePath);
    const normalizedUploadsDir = path.normalize(uploadsDir);

    if (!normalizedPath.startsWith(normalizedUploadsDir)) {
      return res.status(403).json({ error: "Access denied" });
    }

    // Check if file exists with the requested name
    if (fs.existsSync(filePath)) {
      res.setHeader(
        "Content-Type",
        req.query.type || "application/octet-stream",
      );
      return res.sendFile(filePath);
    }

    // Fallback: Search for the document in database by original name
    const decodedFilename = decodeURIComponent(requestedFilename);
    const document = await Document.findOne({
      originalName: decodedFilename,
    }).lean();

    if (!document) {
      console.log(
        `File not found: ${requestedFilename} (decoded: ${decodedFilename})`,
      );
      return res.status(404).json({
        error: "File not found",
        requested: requestedFilename,
      });
    }

    // Serve the file using the stored generated filename
    const actualFilePath = path.join(uploadsDir, document.filename);

    if (!fs.existsSync(actualFilePath)) {
      console.log(`Document record exists but file missing: ${actualFilePath}`);
      return res.status(404).json({
        error: "File not found on server",
        details: "Document record exists but file is missing",
      });
    }

    res.setHeader(
      "Content-Type",
      document.mimeType || "application/octet-stream",
    );
    res.setHeader(
      "Content-Disposition",
      `inline; filename="${document.originalName || document.filename}"`,
    );
    res.sendFile(actualFilePath);
  } catch (error) {
    console.error("Error serving document:", error);
    res.status(500).json({ error: "Failed to serve document" });
  }
});

// Serve uploaded files statically so admin can view/download
// When running from backend/, the uploads folder is relative to this directory
app.use(
  "/uploads",
  express.static(path.join(__dirname, "uploads"), {
    maxAge: "1d",
    etag: false,
    setHeaders: (res, filePath) => {
      // Set appropriate MIME types
      if (filePath.endsWith(".pdf")) {
        res.setHeader("Content-Type", "application/pdf");
      } else if (filePath.match(/\.(jpg|jpeg|png|gif|webp)$/i)) {
        res.setHeader("Content-Type", "image/*");
      }
    },
  }),
);

// Routes
app.use("/api/users", userRoutes);
app.use("/api/categories", categoryRoutes);
app.use("/api/tasks", taskRoutes);
app.use("/api/documents", documentRoutes);
app.use("/api/notifications", notificationRoutes);
app.use("/api/reminders", reminderRoutes);
app.use("/api/dashboard", dashboardRoutes);
app.use("/api/members", memberRoutes);
app.use("/api/admin", adminRoutes);

// Health check route
app.get("/health", (req, res) => {
  res.status(200).json({
    status: "OK",
    message: "Server is running",
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
  });
});

// Keep-alive endpoint for preventing Render sleep
app.get("/keep-alive", (req, res) => {
  res.status(200).json({
    status: "alive",
    message: "Service is active",
    timestamp: new Date().toISOString(),
  });
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
      console.log(`   Members:      http://localhost:${PORT}/api/members`);
      console.log(`   Dashboard:    http://localhost:${PORT}/api/dashboard`);
      console.log(`   Uploads:      http://localhost:${PORT}/uploads`);
      console.log(`   Health Check: http://localhost:${PORT}/health\n`);
    });
  })
  .catch((err) => {
    console.error("❌ Unable to connect to MongoDB:", err);
  });
