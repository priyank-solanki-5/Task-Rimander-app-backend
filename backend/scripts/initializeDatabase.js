import mariadb from "mariadb";
import dotenv from "dotenv";

dotenv.config();

// Create database initialization script
async function initializeDatabase() {
  let connection;

  try {
    // Connect to MariaDB without specifying a database
    connection = await mariadb.createConnection({
      host: process.env.DB_HOST || "localhost",
      port: process.env.DB_PORT || 3306,
      user: process.env.DB_USER || "root",
      password: process.env.DB_PASSWORD || "Priyank@123",
    });

    const dbName = process.env.DB_NAME || "task_management_db";

    console.log(`🔍 Checking if database '${dbName}' exists...`);

    // Check if database exists
    const result = await connection.query(
      `SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = '${dbName}'`
    );

    if (result.length === 0) {
      console.log(`📝 Creating database '${dbName}'...`);

      // Create database if it doesn't exist
      await connection.query(`CREATE DATABASE IF NOT EXISTS \`${dbName}\``);

      console.log(`✅ Database '${dbName}' created successfully!`);
    } else {
      console.log(`✅ Database '${dbName}' already exists!`);
    }

    await connection.end();

    console.log("\n🎉 Database initialization completed successfully!\n");
    return true;
  } catch (error) {
    console.error("❌ Database initialization failed:", error.message);
    console.error(
      "\n⚠️  Make sure MariaDB is running and credentials are correct:"
    );
    console.error(`   Host: ${process.env.DB_HOST || "localhost"}`);
    console.error(`   Port: ${process.env.DB_PORT || 3306}`);
    console.error(`   User: ${process.env.DB_USER || "root"}`);
    console.error(
      `   Database: ${process.env.DB_NAME || "task_management_db"}`
    );
    return false;
  }
}

// Run initialization
initializeDatabase().then((success) => {
  process.exit(success ? 0 : 1);
});
