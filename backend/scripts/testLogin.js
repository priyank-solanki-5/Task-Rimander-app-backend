import dotenv from "dotenv";
import mongoose from "mongoose";
import userDao from "../dao/userDao.js";

dotenv.config();

// Test login functionality
async function testLogin() {
  try {
    const mongodbUrl = process.env.MongoDB_URL;

    if (!mongodbUrl) {
      throw new Error("MongoDB_URL is not defined in .env file");
    }

    console.log("🔍 Connecting to MongoDB...");
    await mongoose.connect(mongodbUrl);
    console.log("✅ MongoDB connection successful!\n");

    // Test credentials
    const testEmail = "test@gmail.com";
    const testPassword = "test123";

    console.log("🔐 Testing login with:");
    console.log(`   Email: ${testEmail}`);
    console.log(`   Password: ${testPassword}\n`);

    // Attempt login
    const user = await userDao.findUserByEmailAndPassword(
      testEmail,
      testPassword,
    );

    if (user) {
      console.log("✅ Login successful!");
      console.log("👤 User details:");
      console.log(`   ID: ${user._id}`);
      console.log(`   Username: ${user.username}`);
      console.log(`   Email: ${user.email}`);
      console.log(`   Is Admin: ${user.isAdmin}`);
      console.log(`   Is Active: ${user.isActive}\n`);
    } else {
      console.log("❌ Login failed! Invalid credentials.\n");
    }

    await mongoose.connection.close();
    console.log("🎉 Test completed!\n");
    process.exit(0);
  } catch (error) {
    console.error("❌ Test failed:", error.message);
    process.exit(1);
  }
}

testLogin();
