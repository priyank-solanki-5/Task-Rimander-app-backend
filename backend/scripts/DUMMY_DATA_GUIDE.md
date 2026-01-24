# Dummy Data Setup Guide

This guide explains how to populate the database with dummy data for testing and development purposes.

## What's Included

The dummy data initialization script creates:

### **Users (3 accounts)**
- **John Doe**
  - Email: `john.doe@example.com`
  - Password: `password123`
  - Mobile: +1234567890

- **Jane Smith**
  - Email: `jane.smith@example.com`
  - Password: `password123`
  - Mobile: +1234567891

- **Admin User**
  - Email: `admin@example.com`
  - Password: `password123`
  - Mobile: +1234567892

### **Categories (5 predefined)**
- Work (Work-related tasks)
- Personal (Personal tasks)
- Health (Health and wellness)
- Finance (Financial tasks)
- Education (Educational tasks)

### **Tasks (10 tasks)**
- **Pending Tasks**: 7 tasks with various due dates
- **Completed Tasks**: 3 tasks already marked as done
- **Recurring Tasks**: 5 tasks with monthly, quarterly, or yearly recurrence
- **Categories**: Tasks distributed across all categories

### **Documents (8 files)**
- PDF documents (project proposals, bills, reports)
- Office documents (Word, Excel)
- Images (certificates, photos)
- Archives (ZIP files)
- All linked to specific tasks

### **Notifications (12 notifications)**
- **Types**: In-app, Email, Push, SMS
- **Status**: Mix of sent, pending, and read notifications
- **Content**: Task reminders, completion notices, upcoming events
- All linked to users and their respective tasks

## How to Run

### Method 1: Using the Batch Script (Windows)
```batch
cd backend\scripts
addDummyData.bat
```

### Method 2: Using Node.js
```bash
cd backend
node scripts/initializeDatabase.js
```

### Method 3: Using npm (if script added to package.json)
```bash
cd backend
npm run init-db
```

## Important Notes

⚠️ **Data Safety**
- The script checks if data already exists before adding dummy data
- If users already exist in the database, dummy data creation will be skipped
- To reset and add fresh dummy data, clear the database first

⚠️ **Prerequisites**
- MongoDB connection must be configured in `.env` file
- The `MongoDB_URL` environment variable must be set correctly
- All required npm packages must be installed (`bcryptjs`, `mongoose`, etc.)

## Testing the Dummy Data

After running the initialization script:

1. **Login to Admin Panel**
   - Use any of the test accounts listed above
   - Password for all accounts: `password123`

2. **Check Tasks**
   - Navigate to Tasks section
   - You should see 10 tasks with various statuses and due dates

3. **Check Documents**
   - Navigate to Documents section
   - You should see 8 documents linked to tasks

4. **Check Notifications**
   - Navigate to Notifications section
   - You should see 12 notifications with different types and statuses

## Clearing Dummy Data

To remove all dummy data and start fresh:

```javascript
// Connect to MongoDB
use your-database-name

// Drop all collections
db.users.deleteMany({})
db.tasks.deleteMany({})
db.documents.deleteMany({})
db.notifications.deleteMany({})
db.categories.deleteMany({})
```

Or use a MongoDB client like MongoDB Compass or Studio 3T to clear collections manually.

## Customizing Dummy Data

To customize the dummy data, edit the `createDummyData()` function in:
```
backend/scripts/initializeDatabase.js
```

You can modify:
- User credentials and details
- Number of tasks, documents, and notifications
- Task properties (titles, descriptions, due dates)
- Document types and sizes
- Notification content and types

## Troubleshooting

### Issue: "MongoDB_URL is not defined"
**Solution**: Create or update your `.env` file with the MongoDB connection string:
```
MongoDB_URL=mongodb+srv://username:password@cluster.mongodb.net/database?appName=reminder-app
```

### Issue: "Data already exists"
**Solution**: This is normal behavior. The script prevents duplicate data. If you want fresh data, clear the database first.

### Issue: "Connection timeout"
**Solution**: Check your internet connection and MongoDB Atlas network access settings.

### Issue: bcrypt errors
**Solution**: Reinstall bcryptjs:
```bash
npm uninstall bcryptjs
npm install bcryptjs
```

## Need Help?

If you encounter any issues:
1. Check the console output for specific error messages
2. Verify MongoDB connection string is correct
3. Ensure all dependencies are installed
4. Check MongoDB Atlas network access whitelist

---

**Last Updated**: January 24, 2026
