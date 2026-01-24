import dotenv from "dotenv";
import mongoose from "mongoose";
import bcrypt from "bcryptjs";
import User from "../models/User.js";
import Category from "../models/Category.js";
import Task from "../models/Task.js";
import Document from "../models/Document.js";
import Notification from "../models/Notification.js";

dotenv.config();

// MongoDB initialization script with dummy data
async function initializeDatabase() {
  try {
    const mongodbUrl = process.env.MongoDB_URL;

    if (!mongodbUrl) {
      throw new Error("MongoDB_URL is not defined in .env file");
    }

    console.log("🔍 Connecting to MongoDB...");

    await mongoose.connect(mongodbUrl, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });

    console.log("✅ MongoDB connection successful!");
    console.log(`📊 Connected to MongoDB Atlas`);

    // Create indexes for optimal performance
    const connection = mongoose.connection;

    // Get all collections and ensure indexes are created
    const collections = await connection.db.listCollections().toArray();
    console.log(`\n📁 Collections found: ${collections.length}`);

    if (collections.length > 0) {
      collections.forEach((col) => {
        console.log(`   ✓ ${col.name}`);
      });
    }

    // Add dummy data
    console.log("\n📝 Initializing dummy data...");
    await createDummyData();

    await mongoose.connection.close();

    console.log("\n🎉 Database initialization completed successfully!\n");
    return true;
  } catch (error) {
    console.error("❌ Database initialization failed:", error.message);
    console.error("\n⚠️  To fix this issue:");
    console.error("1. Make sure MongoDB_URL is set in your .env file");
    console.error("2. Check your network connection to MongoDB Atlas");
    console.error("3. Verify MongoDB credentials are correct");
    console.error(`4. Example MongoDB_URL format:`);
    console.error(
      `   mongodb+srv://username:password@cluster.mongodb.net/database?appName=reminder-app`,
    );
    return false;
  }
}

// Create dummy data for admin panel
async function createDummyData() {
  try {
    // Check if data already exists
    const userCount = await User.countDocuments();
    if (userCount > 0) {
      console.log("⚠️  Data already exists. Skipping dummy data creation.");
      console.log("💡 To reset and add dummy data, clear the database first.");
      return;
    }

    // Create dummy users
    console.log("👤 Creating dummy users...");
    const hashedPassword = await bcrypt.hash("password123", 10);

    const users = await User.insertMany([
      {
        username: "John Doe",
        email: "john.doe@example.com",
        mobilenumber: "+1234567890",
        password: hashedPassword,
        isActive: true,
        lastLogin: new Date(),
      },
      {
        username: "Jane Smith",
        email: "jane.smith@example.com",
        mobilenumber: "+1234567891",
        password: hashedPassword,
        isActive: true,
        lastLogin: new Date(),
      },
      {
        username: "Admin User",
        email: "admin@example.com",
        mobilenumber: "+1234567892",
        password: hashedPassword,
        isActive: true,
        lastLogin: new Date(),
      },
    ]);
    console.log(`✅ Created ${users.length} users`);

    // Create dummy categories
    console.log("📂 Creating dummy categories...");
    const categories = await Category.insertMany([
      {
        name: "Work",
        isPredefined: true,
        description: "Work-related tasks and reminders",
      },
      {
        name: "Personal",
        isPredefined: true,
        description: "Personal tasks and reminders",
      },
      {
        name: "Health",
        isPredefined: true,
        description: "Health and wellness reminders",
      },
      {
        name: "Finance",
        isPredefined: true,
        description: "Financial tasks and reminders",
      },
      {
        name: "Education",
        isPredefined: true,
        description: "Educational tasks and learning reminders",
      },
    ]);
    console.log(`✅ Created ${categories.length} categories`);

    // Create dummy tasks
    console.log("📋 Creating dummy tasks...");
    const now = new Date();
    const tomorrow = new Date(now.getTime() + 24 * 60 * 60 * 1000);
    const nextWeek = new Date(now.getTime() + 7 * 24 * 60 * 60 * 1000);
    const nextMonth = new Date(now.getTime() + 30 * 24 * 60 * 60 * 1000);

    const tasks = await Task.insertMany([
      {
        title: "Complete Project Proposal",
        description: "Finish the Q1 project proposal for the new client",
        status: "Pending",
        dueDate: tomorrow,
        isRecurring: false,
        userId: users[0]._id,
        categoryId: categories[0]._id,
      },
      {
        title: "Team Meeting",
        description: "Weekly team sync-up meeting",
        status: "Pending",
        dueDate: nextWeek,
        isRecurring: true,
        recurrenceType: "Monthly",
        nextOccurrence: nextWeek,
        userId: users[0]._id,
        categoryId: categories[0]._id,
      },
      {
        title: "Gym Workout",
        description: "Morning workout session at the gym",
        status: "Completed",
        dueDate: now,
        isRecurring: false,
        userId: users[1]._id,
        categoryId: categories[2]._id,
      },
      {
        title: "Pay Electricity Bill",
        description: "Monthly electricity bill payment",
        status: "Pending",
        dueDate: nextMonth,
        isRecurring: true,
        recurrenceType: "Monthly",
        nextOccurrence: nextMonth,
        userId: users[1]._id,
        categoryId: categories[3]._id,
      },
      {
        title: "Doctor Appointment",
        description: "Routine health checkup with Dr. Smith",
        status: "Pending",
        dueDate: nextWeek,
        isRecurring: false,
        userId: users[2]._id,
        categoryId: categories[2]._id,
      },
      {
        title: "Online Course Module",
        description: "Complete Module 3 of JavaScript Advanced Course",
        status: "Pending",
        dueDate: tomorrow,
        isRecurring: false,
        userId: users[2]._id,
        categoryId: categories[4]._id,
      },
      {
        title: "Submit Tax Documents",
        description: "Prepare and submit quarterly tax documents",
        status: "Pending",
        dueDate: nextMonth,
        isRecurring: true,
        recurrenceType: "Every 3 months",
        nextOccurrence: nextMonth,
        userId: users[0]._id,
        categoryId: categories[3]._id,
      },
      {
        title: "Birthday Party Planning",
        description: "Plan and organize birthday celebration",
        status: "Pending",
        dueDate: nextWeek,
        isRecurring: false,
        userId: users[1]._id,
        categoryId: categories[1]._id,
      },
      {
        title: "Code Review",
        description: "Review pull requests for the mobile app project",
        status: "Completed",
        dueDate: now,
        isRecurring: false,
        userId: users[2]._id,
        categoryId: categories[0]._id,
      },
      {
        title: "Insurance Renewal",
        description: "Renew car insurance policy",
        status: "Pending",
        dueDate: nextMonth,
        isRecurring: true,
        recurrenceType: "Yearly",
        nextOccurrence: nextMonth,
        userId: users[0]._id,
        categoryId: categories[3]._id,
      },
    ]);
    console.log(`✅ Created ${tasks.length} tasks`);

    // Create dummy documents
    console.log("📄 Creating dummy documents...");
    const documents = await Document.insertMany([
      {
        filename: "project_proposal_2026.pdf",
        originalName: "Project Proposal 2026.pdf",
        mimeType: "application/pdf",
        fileSize: 245800,
        filePath: "/uploads/project_proposal_2026.pdf",
        taskId: tasks[0]._id,
        userId: users[0]._id,
      },
      {
        filename: "meeting_agenda.docx",
        originalName: "Meeting Agenda.docx",
        mimeType:
          "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
        fileSize: 156400,
        filePath: "/uploads/meeting_agenda.docx",
        taskId: tasks[1]._id,
        userId: users[0]._id,
      },
      {
        filename: "electricity_bill_jan_2026.pdf",
        originalName: "Electricity Bill January 2026.pdf",
        mimeType: "application/pdf",
        fileSize: 89200,
        filePath: "/uploads/electricity_bill_jan_2026.pdf",
        taskId: tasks[3]._id,
        userId: users[1]._id,
      },
      {
        filename: "medical_report.pdf",
        originalName: "Medical Report.pdf",
        mimeType: "application/pdf",
        fileSize: 320500,
        filePath: "/uploads/medical_report.pdf",
        taskId: tasks[4]._id,
        userId: users[2]._id,
      },
      {
        filename: "course_certificate.jpg",
        originalName: "Course Certificate.jpg",
        mimeType: "image/jpeg",
        fileSize: 512000,
        filePath: "/uploads/course_certificate.jpg",
        taskId: tasks[5]._id,
        userId: users[2]._id,
      },
      {
        filename: "tax_documents_q1_2026.zip",
        originalName: "Tax Documents Q1 2026.zip",
        mimeType: "application/zip",
        fileSize: 1024000,
        filePath: "/uploads/tax_documents_q1_2026.zip",
        taskId: tasks[6]._id,
        userId: users[0]._id,
      },
      {
        filename: "party_checklist.xlsx",
        originalName: "Party Checklist.xlsx",
        mimeType:
          "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        fileSize: 45800,
        filePath: "/uploads/party_checklist.xlsx",
        taskId: tasks[7]._id,
        userId: users[1]._id,
      },
      {
        filename: "insurance_policy.pdf",
        originalName: "Insurance Policy Document.pdf",
        mimeType: "application/pdf",
        fileSize: 678900,
        filePath: "/uploads/insurance_policy.pdf",
        taskId: tasks[9]._id,
        userId: users[0]._id,
      },
    ]);
    console.log(`✅ Created ${documents.length} documents`);

    // Create dummy notifications
    console.log("🔔 Creating dummy notifications...");
    const notifications = await Notification.insertMany([
      {
        userId: users[0]._id,
        taskId: tasks[0]._id,
        type: "in-app",
        message: "Reminder: Complete Project Proposal is due tomorrow",
        isRead: false,
        status: "sent",
        sentAt: new Date(),
      },
      {
        userId: users[0]._id,
        taskId: tasks[1]._id,
        type: "email",
        message: "Upcoming: Team Meeting scheduled for next week",
        isRead: false,
        status: "sent",
        sentAt: new Date(),
      },
      {
        userId: users[1]._id,
        taskId: tasks[2]._id,
        type: "in-app",
        message: "Task completed: Gym Workout",
        isRead: true,
        status: "sent",
        sentAt: new Date(now.getTime() - 2 * 60 * 60 * 1000),
        readAt: new Date(now.getTime() - 1 * 60 * 60 * 1000),
      },
      {
        userId: users[1]._id,
        taskId: tasks[3]._id,
        type: "push",
        message: "Reminder: Pay Electricity Bill due in 30 days",
        isRead: false,
        status: "sent",
        sentAt: new Date(),
      },
      {
        userId: users[2]._id,
        taskId: tasks[4]._id,
        type: "email",
        message: "Upcoming: Doctor Appointment scheduled for next week",
        isRead: false,
        status: "sent",
        sentAt: new Date(),
      },
      {
        userId: users[2]._id,
        taskId: tasks[5]._id,
        type: "in-app",
        message: "Reminder: Complete Online Course Module due tomorrow",
        isRead: false,
        status: "sent",
        sentAt: new Date(),
      },
      {
        userId: users[0]._id,
        taskId: tasks[6]._id,
        type: "email",
        message: "Important: Submit Tax Documents due in 30 days",
        isRead: false,
        status: "sent",
        sentAt: new Date(),
      },
      {
        userId: users[1]._id,
        taskId: tasks[7]._id,
        type: "in-app",
        message: "Reminder: Birthday Party Planning due next week",
        isRead: true,
        status: "sent",
        sentAt: new Date(now.getTime() - 3 * 60 * 60 * 1000),
        readAt: new Date(now.getTime() - 2 * 60 * 60 * 1000),
      },
      {
        userId: users[2]._id,
        taskId: tasks[8]._id,
        type: "in-app",
        message: "Task completed: Code Review",
        isRead: true,
        status: "sent",
        sentAt: new Date(now.getTime() - 4 * 60 * 60 * 1000),
        readAt: new Date(now.getTime() - 3 * 60 * 60 * 1000),
      },
      {
        userId: users[0]._id,
        taskId: tasks[9]._id,
        type: "push",
        message: "Reminder: Insurance Renewal due in 30 days",
        isRead: false,
        status: "sent",
        sentAt: new Date(),
      },
      {
        userId: users[0]._id,
        taskId: tasks[0]._id,
        type: "sms",
        message: "Urgent: Complete Project Proposal deadline approaching",
        isRead: false,
        status: "pending",
      },
      {
        userId: users[1]._id,
        taskId: tasks[3]._id,
        type: "in-app",
        message: "Payment reminder: Electricity bill payment pending",
        isRead: false,
        status: "sent",
        sentAt: new Date(),
      },
    ]);
    console.log(`✅ Created ${notifications.length} notifications`);

    console.log("\n✨ Dummy data creation completed successfully!");
    console.log(`\n📊 Summary:`);
    console.log(`   Users: ${users.length}`);
    console.log(`   Categories: ${categories.length}`);
    console.log(`   Tasks: ${tasks.length}`);
    console.log(`   Documents: ${documents.length}`);
    console.log(`   Notifications: ${notifications.length}`);
    console.log(`\n🔐 Test Credentials:`);
    console.log(
      `   Email: john.doe@example.com, jane.smith@example.com, admin@example.com`,
    );
    console.log(`   Password: password123`);
  } catch (error) {
    console.error("❌ Error creating dummy data:", error.message);
    throw error;
  }
}

// Run initialization
initializeDatabase().then((success) => {
  process.exit(success ? 0 : 1);
});
