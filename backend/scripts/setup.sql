-- Create database if not exists
CREATE DATABASE IF NOT EXISTS `task_management_db`;

-- Use the database
USE `task_management_db`;

-- Create users table
CREATE TABLE IF NOT EXISTS `users` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `username` VARCHAR(255) NOT NULL UNIQUE,
  `email` VARCHAR(255) NOT NULL UNIQUE,
  `mobilenumber` VARCHAR(10) NOT NULL UNIQUE,
  `password` VARCHAR(255) NOT NULL,
  `createdAt` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create categories table
CREATE TABLE IF NOT EXISTS `categories` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(255) NOT NULL,
  `isPredefined` BOOLEAN DEFAULT FALSE,
  `description` TEXT,
  `createdAt` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create tasks table
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

-- Create documents table
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

COMMIT;
