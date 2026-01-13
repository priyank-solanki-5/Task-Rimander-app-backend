import { Sequelize } from "sequelize";
import dotenv from "dotenv";

dotenv.config();

let sequelize;

// Check if using PostgreSQL (Render) or MariaDB (local/PlanetScale)
const dbUrl = process.env.DATABASE_URL;
const dbHost = process.env.DB_HOST;

if (dbUrl) {
  // PostgreSQL mode (Render)
  console.log("📊 Using PostgreSQL database...");
  sequelize = new Sequelize(dbUrl, {
    dialect: "postgres",
    logging: false,
    pool: {
      max: 5,
      min: 0,
      acquire: 30000,
      idle: 10000,
    },
    dialectOptions: {
      ssl: {
        require: true,
        rejectUnauthorized: false,
      },
    },
  });
} else {
  // MariaDB mode (Local or PlanetScale)
  console.log("📊 Using MariaDB database...");
  sequelize = new Sequelize(
    process.env.DB_NAME || "task_management_db",
    process.env.DB_USER || "root",
    process.env.DB_PASSWORD || "Priyank@123",
    {
      host: process.env.DB_HOST || "localhost",
      port: process.env.DB_PORT || 3306,
      dialect: "mariadb",
      logging: false,
      pool: {
        max: 5,
        min: 0,
        acquire: 30000,
        idle: 10000,
      },
    }
  );
}

// Test database connection
sequelize
  .authenticate()
  .then(() => {
    console.log("✅ Database connection established successfully");
  })
  .catch((err) => {
    console.error("❌ Unable to connect to the database:", err.message);

    if (dbUrl) {
      console.error("\n📝 PostgreSQL connection issue:");
      console.error("   1. Verify DATABASE_URL is set correctly");
      console.error("   2. Check database is accessible from Render");
      console.error(
        "   3. DATABASE_URL format: postgres://user:password@host:port/database"
      );
    } else {
      console.error("\n📝 MariaDB connection issue:");
      console.error("   1. Make sure MariaDB is running");
      console.error("   2. Check .env file has correct credentials:");
      console.error(`      DB_HOST=${process.env.DB_HOST || "localhost"}`);
      console.error(`      DB_PORT=${process.env.DB_PORT || 3306}`);
      console.error(`      DB_USER=${process.env.DB_USER || "root"}`);
      console.error(
        `      DB_NAME=${process.env.DB_NAME || "task_management_db"}`
      );
    }
  });

export default sequelize;
