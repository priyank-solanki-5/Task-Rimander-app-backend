import { Sequelize } from "sequelize";
import dotenv from "dotenv";

// Load environment variables
dotenv.config();

const sequelize = new Sequelize(
  process.env.DB_NAME,
  process.env.DB_USER,
  process.env.DB_PASSWORD,
  {
    host: process.env.DB_HOST,
    port: process.env.DB_PORT || 3306,
    dialect: "mariadb",
    logging: false, // Set to console.log to see SQL queries
    pool: {
      max: 5,
      min: 0,
      acquire: 30000,
      idle: 10000,
    },
  }
);

// Test database connection
sequelize
  .authenticate()
  .then(() => {
    console.log("✅ Database connection established successfully");
  })
  .catch((err) => {
    console.error("❌ Unable to connect to the database:", err.message);
    console.error("\n📝 To fix this issue, run: npm run init-db");
    console.error("\nMake sure:");
    console.error("1. MariaDB is running");
    console.error("2. Your .env file has correct credentials:");
    console.error(`   DB_HOST=${process.env.DB_HOST || "localhost"}`);
    console.error(`   DB_PORT=${process.env.DB_PORT || 3306}`);
    console.error(`   DB_USER=${process.env.DB_USER || "root"}`);
    console.error(`   DB_NAME=${process.env.DB_NAME || "task_management_db"}`);
  });

export default sequelize;
