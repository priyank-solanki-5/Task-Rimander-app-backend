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
import "./models/NotificationPreferences.js";
import "./models/Reminder.js";
import "./models/Member.js";

dotenv.config();

const app = express();
const PORT = process.env.PORT;

const allowedOrigins = (process.env.CORS_ORIGINS || "")
  .split(",")
  .map((origin) => origin.trim())
  .filter(Boolean);

const corsOptions = {
  origin: (origin, callback) => {
    if (
      !origin ||
      allowedOrigins.length === 0 ||
      allowedOrigins.includes(origin)
    ) {
      return callback(null, true);
    }
    return callback(new Error("Not allowed by CORS"));
  },
  credentials: true,
  methods: ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
  allowedHeaders: ["Content-Type", "Authorization"],
};

app.use(cors(corsOptions));
app.options("*", cors(corsOptions));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

app.use(
  "/uploads",
  express.static(path.join(__dirname, "uploads"), {
    maxAge: "1d",
    etag: false,
    setHeaders: (res, filePath) => {
      if (filePath.endsWith(".pdf")) {
        res.setHeader("Content-Type", "application/pdf");
        res.setHeader("Content-Disposition", "inline");
      } else if (filePath.match(/\.(jpg|jpeg|png|gif|webp)$/i)) {
        // Avoid /* in string to keep some editors from mis-highlighting the line
        res.setHeader("Content-Type", "image/" + "*");
        res.setHeader("Content-Disposition", "inline");
      } else {
        res.setHeader("Content-Disposition", "attachment");
      }

      res.setHeader("Cache-Control", "public, max-age=86400");
    },
  }),
);

app.get("/uploads/documents/:filename", (req, res, next) => {
  const decoded = decodeURIComponent(req.params.filename);
  const filePath = path.join(__dirname, "uploads", "documents", decoded);
  res.sendFile(filePath, (err) => {
    if (err) {
      return next();
    }
  });
});

app.use("/api/users", userRoutes);
app.use("/api/categories", categoryRoutes);
app.use("/api/tasks", taskRoutes);
app.use("/api/documents", documentRoutes);
app.use("/api/notifications", notificationRoutes);
app.use("/api/reminders", reminderRoutes);
app.use("/api/dashboard", dashboardRoutes);
app.use("/api/members", memberRoutes);
app.use("/api/admin", adminRoutes);

app.get("/health", (req, res) => {
  res.status(200).json({
    status: "OK",
    message: "Server is running",
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
  });
});

app.get("/keep-alive", (req, res) => {
  res.status(200).json({
    status: "alive",
    message: "Service is active",
    timestamp: new Date().toISOString(),
  });
});

app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: "Something went wrong!" });
});

connectDB()
  .then(async () => {
    await categoryService.seedPredefinedCategories();
    console.log("✅ Predefined categories seeded successfully");

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
