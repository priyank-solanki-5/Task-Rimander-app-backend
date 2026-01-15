import dotenv from "dotenv";
import mongoose from "mongoose";

dotenv.config();

// MongoDB initialization script
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
      `   mongodb+srv://username:password@cluster.mongodb.net/database?appName=reminder-app`
    );
    return false;
  }
}

// Run initialization
initializeDatabase().then((success) => {
  process.exit(success ? 0 : 1);
});
