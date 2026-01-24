import dotenv from "dotenv";
import mongoose from "mongoose";

dotenv.config();

// Clear all collections and prepare for fresh data
async function clearDatabase() {
  try {
    const mongodbUrl = process.env.MongoDB_URL;

    if (!mongodbUrl) {
      throw new Error("MongoDB_URL is not defined in .env file");
    }

    console.log("⚠️  WARNING: This will delete ALL data from the database!");
    console.log("🔍 Connecting to MongoDB...");

    await mongoose.connect(mongodbUrl, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });

    console.log("✅ Connected to MongoDB");

    const connection = mongoose.connection;
    const collections = await connection.db.listCollections().toArray();

    console.log(`\n📁 Found ${collections.length} collections`);

    let deletedCount = 0;
    for (const collection of collections) {
      const result = await connection.db
        .collection(collection.name)
        .deleteMany({});
      console.log(
        `   🗑️  Cleared ${collection.name}: ${result.deletedCount} documents`,
      );
      deletedCount += result.deletedCount;
    }

    await mongoose.connection.close();

    console.log(
      `\n✅ Successfully cleared ${deletedCount} documents from ${collections.length} collections`,
    );
    console.log(
      "💡 You can now run 'npm run add-dummy-data' to add fresh dummy data\n",
    );

    return true;
  } catch (error) {
    console.error("❌ Error clearing database:", error.message);
    return false;
  }
}

// Run clear operation
clearDatabase().then((success) => {
  process.exit(success ? 0 : 1);
});
