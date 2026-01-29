import dotenv from "dotenv";
import mongoose from "mongoose";
import bcrypt from "bcryptjs";
import User from "../models/User.js";

dotenv.config();

// Setup admin user with specified credentials
async function setupAdmin() {
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

    // Admin credentials
    const adminEmail = "test@gmail.com";
    const adminPassword = "test123";
    const adminUsername = "Admin User";
    const adminMobile = "+1234567890";

    // Check if admin already exists
    const existingAdmin = await User.findOne({ email: adminEmail });

    if (existingAdmin) {
      console.log("⚠️  Admin user already exists with email:", adminEmail);
      console.log("🔄 Updating admin credentials...");

      // Update password
      const hashedPassword = await bcrypt.hash(adminPassword, 10);
      existingAdmin.password = hashedPassword;
      existingAdmin.isAdmin = true;
      existingAdmin.username = adminUsername;
      existingAdmin.mobilenumber = adminMobile;
      existingAdmin.isActive = true;

      await existingAdmin.save();
      console.log("✅ Admin credentials updated successfully!");
    } else {
      console.log("👤 Creating new admin user...");

      // Hash password
      const hashedPassword = await bcrypt.hash(adminPassword, 10);

      // Create admin user
      const admin = await User.create({
        username: adminUsername,
        email: adminEmail,
        mobilenumber: adminMobile,
        password: hashedPassword,
        isAdmin: true,
        isActive: true,
        lastLogin: null,
      });

      console.log("✅ Admin user created successfully!");
      console.log("📧 Email:", admin.email);
      console.log("👤 Username:", admin.username);
    }

    console.log("\n🔐 Admin Login Credentials:");
    console.log("   Email: test@gmail.com");
    console.log("   Password: test123");

    await mongoose.connection.close();
    console.log("\n🎉 Admin setup completed successfully!\n");
    process.exit(0);
  } catch (error) {
    console.error("❌ Admin setup failed:", error.message);
    console.error("\n⚠️  To fix this issue:");
    console.error("1. Make sure MongoDB_URL is set in your .env file");
    console.error("2. Check your network connection to MongoDB Atlas");
    console.error("3. Verify MongoDB credentials are correct");
    process.exit(1);
  }
}

setupAdmin();
