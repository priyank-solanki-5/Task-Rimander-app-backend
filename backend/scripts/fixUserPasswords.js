import dotenv from "dotenv";
import mongoose from "mongoose";
import bcrypt from "bcryptjs";
import User from "../models/User.js";

dotenv.config();

// Fix all users with plain text passwords
async function fixUserPasswords() {
  try {
    const mongodbUrl = process.env.MongoDB_URL;

    if (!mongodbUrl) {
      throw new Error("MongoDB_URL is not defined in .env file");
    }

    console.log("🔍 Connecting to MongoDB...");
    await mongoose.connect(mongodbUrl);
    console.log("✅ MongoDB connection successful!\n");

    // Get all users
    const users = await User.find({});
    console.log(`📊 Found ${users.length} users in database\n`);

    let fixedCount = 0;

    for (const user of users) {
      // Check if password is already hashed (bcrypt hashes start with $2a$ or $2b$)
      const isHashed =
        user.password.startsWith("$2a$") || user.password.startsWith("$2b$");

      if (!isHashed) {
        console.log(`🔧 Fixing password for user: ${user.email}`);
        const salt = await bcrypt.genSalt(10);
        user.password = await bcrypt.hash(user.password, salt);
        await user.save();
        fixedCount++;
      } else {
        console.log(`✓ Password already hashed for user: ${user.email}`);
      }
    }

    console.log(`\n✅ Fixed ${fixedCount} user passwords`);
    console.log(
      `✓ ${users.length - fixedCount} passwords were already hashed\n`,
    );

    await mongoose.connection.close();
    console.log("🎉 Password fix completed!\n");
    process.exit(0);
  } catch (error) {
    console.error("❌ Password fix failed:", error.message);
    process.exit(1);
  }
}

fixUserPasswords();
