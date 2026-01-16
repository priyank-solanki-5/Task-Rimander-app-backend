# Database Setup Guide

## Option 1: Automatic Setup (Recommended)

Run this command from the backend folder:

```bash
npm run init-db
npm run dev
```

This will automatically create the database and start the server.

---

## Option 2: Manual Setup with SQL File

If the automatic setup doesn't work, follow these steps:

### Step 1: Open MySQL/MariaDB Command Line

```bash
mysql -h localhost -u root -p
```

Enter your MariaDB password when prompted.

### Step 2: Execute the Setup Script

```bash
source scripts/setup.sql;
```

Or manually paste the contents of `scripts/setup.sql` into MariaDB CLI.

### Step 3: Verify Database Creation

```bash
SHOW DATABASES;
USE task_management_db;
SHOW TABLES;
```

### Step 4: Start the Server

```bash
npm run dev
```

---

## Option 3: Manual Setup (Step by Step)

If you prefer to create the database manually:

### Step 1: Create Database

```sql
CREATE DATABASE IF NOT EXISTS `task_management_db`;
```

### Step 2: Use Database

```sql
USE `task_management_db`;
```

### Step 3: Create Tables

```sql
-- Users table
CREATE TABLE IF NOT EXISTS `users` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `username` VARCHAR(255) NOT NULL UNIQUE,
  `email` VARCHAR(255) NOT NULL UNIQUE,
  `mobilenumber` VARCHAR(10) NOT NULL UNIQUE,
  `password` VARCHAR(255) NOT NULL,
  `createdAt` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Categories table
CREATE TABLE IF NOT EXISTS `categories` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(255) NOT NULL,
  `isPredefined` BOOLEAN DEFAULT FALSE,
  `description` TEXT,
  `createdAt` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tasks table
CREATE TABLE IF NOT EXISTS `tasks` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `title` VARCHAR(255) NOT NULL,
  `description` TEXT,
  `status` ENUM('Pending', 'Completed') DEFAULT 'Pending',
  `dueDate` DATE,
  `categoryId` INT,
  `userId` INT NOT NULL,
  `isRecurring` BOOLEAN DEFAULT FALSE,
  `recurrenceType` ENUM('Monthly', 'Every 3 months', 'Every 6 months', 'Yearly'),
  `nextOccurrence` DATE,
  `createdAt` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`categoryId`) REFERENCES `categories` (`id`) ON DELETE SET NULL,
  FOREIGN KEY (`userId`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  INDEX (`userId`),
  INDEX (`categoryId`),
  INDEX (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Documents table
CREATE TABLE IF NOT EXISTS `documents` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `filename` VARCHAR(255) NOT NULL UNIQUE,
  `originalName` VARCHAR(255) NOT NULL,
  `mimeType` VARCHAR(100),
  `fileSize` INT,
  `filePath` VARCHAR(500) NOT NULL,
  `taskId` INT NOT NULL,
  `userId` INT NOT NULL,
  `createdAt` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`taskId`) REFERENCES `tasks` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`userId`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  INDEX (`userId`),
  INDEX (`taskId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert predefined categories
INSERT IGNORE INTO `categories` (`name`, `isPredefined`, `description`) VALUES
('House', 1, 'Household tasks and maintenance'),
('Vehicle', 1, 'Vehicle maintenance and repairs'),
('Financial', 1, 'Financial tasks and payments'),
('Personal', 1, 'Personal development and health');
```

### Step 4: Verify Tables

```sql
SHOW TABLES;
SELECT * FROM categories;
```

---

## Troubleshooting

### Error: Unknown database 'task_management_db'

**Solution:** Run the database setup script:
```bash
npm run init-db
```

### Error: Access denied for user 'root'@'localhost'

**Solution:** Check your `.env` file credentials:
```
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=Priyank@123
DB_NAME=task_management_db
```

### Error: Can't connect to MariaDB server

**Solution:** Make sure MariaDB is running:

On Windows:
```bash
# Check if MariaDB service is running
Get-Service MariaDB
# If not running, start it
Start-Service MariaDB
```

On macOS:
```bash
brew services start mariadb
```

On Linux:
```bash
sudo systemctl start mariadb
```

---

## Starting the Application

After successful database setup, run:

```bash
npm install    # Install dependencies (first time only)
npm run dev    # Start development server with auto-initialization
```

The server will start on `http://localhost:3000`

---

## API Endpoints

Once the server is running, you can access:

- **User Registration:** `POST /api/users/register`
- **User Login:** `POST /api/users/login`
- **Get Tasks:** `GET /api/tasks` (requires JWT token)
- **Create Task:** `POST /api/tasks` (requires JWT token)
- **Categories:** `GET /api/categories` (requires JWT token)
- **Documents:** `POST /api/documents/upload` (requires JWT token)

See `FLUTTER_API_DOCUMENTATION.md` for complete API documentation.
