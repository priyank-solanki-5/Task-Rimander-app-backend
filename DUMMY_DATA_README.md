# Dummy Data Setup - Quick Start Guide

## 🎯 Overview
Dummy data has been successfully configured for your Task Reminder App admin panel. This includes realistic sample data for **tasks**, **documents**, and **notifications**.

---

## 📦 What Was Added

### 1. **Enhanced Database Initialization Script**
   - **Location**: `backend/scripts/initializeDatabase.js`
   - **Features**:
     - Creates 3 test users with secure passwords
     - Adds 5 predefined categories
     - Generates 10 diverse tasks (pending & completed)
     - Creates 8 sample documents linked to tasks
     - Adds 12 notifications with various statuses

### 2. **Quick Launch Scripts**
   - **Batch File**: `backend/scripts/addDummyData.bat` (Windows)
   - **NPM Script**: `npm run add-dummy-data`

### 3. **Documentation**
   - **Guide**: `backend/scripts/DUMMY_DATA_GUIDE.md`
   - Complete instructions and troubleshooting

---

## 🚀 How to Run

### Option 1: Using NPM (Recommended)
```bash
cd backend
npm install bcryptjs  # First time only
npm run add-dummy-data
```

### Option 2: Using Batch File (Windows)
```bash
cd backend\scripts
addDummyData.bat
```

### Option 3: Direct Node Command
```bash
cd backend
node scripts/initializeDatabase.js
```

---

## 🔐 Test Credentials

After running the script, you can log in with:

| Email | Password | Role |
|-------|----------|------|
| john.doe@example.com | password123 | User |
| jane.smith@example.com | password123 | User |
| admin@example.com | password123 | Admin |

---

## 📊 Dummy Data Summary

### Users
- **3 users** with complete profiles
- Active accounts with login history

### Categories
- Work, Personal, Health, Finance, Education
- All predefined and ready to use

### Tasks (10 total)
- ✅ **7 Pending Tasks**: Various due dates (tomorrow, next week, next month)
- ✅ **3 Completed Tasks**: Already marked as done
- ✅ **5 Recurring Tasks**: Monthly, quarterly, and yearly schedules
- ✅ Distributed across all categories

### Documents (8 files)
- 📄 PDFs (proposals, bills, reports)
- 📝 Office docs (Word, Excel)
- 🖼️ Images (certificates)
- 📦 Archives (ZIP files)
- All linked to specific tasks

### Notifications (12 total)
- 🔔 **Types**: In-app, Email, Push, SMS
- 📨 **Status Mix**: Sent, pending, and read
- ⏰ **Content**: Reminders, completions, upcoming events
- 👤 Distributed across all users

---

## ⚠️ Important Notes

1. **Safety First**: The script checks for existing data and won't duplicate
2. **Fresh Start**: To reset, clear the database before running again
3. **Prerequisites**: 
   - MongoDB connection configured in `.env`
   - bcryptjs package installed
   - Active internet connection

---

## 🧪 Testing Your Admin Panel

After adding dummy data:

1. **Login** with any test account (password123)
2. **Navigate to Tasks** → See 10 tasks with various statuses
3. **Check Documents** → View 8 attached files
4. **Open Notifications** → See 12 notifications

---

## 🛠️ Next Steps

1. **Install bcryptjs** (if not already installed):
   ```bash
   cd backend
   npm install bcryptjs
   ```

2. **Run the initialization**:
   ```bash
   npm run add-dummy-data
   ```

3. **Start your server**:
   ```bash
   npm start
   ```

4. **Access admin panel** and login with test credentials

---

## 📝 Customization

To modify dummy data, edit:
```
backend/scripts/initializeDatabase.js
```

Look for the `createDummyData()` function and adjust:
- User details and credentials
- Task titles, descriptions, due dates
- Document properties
- Notification messages and types

---

## 🐛 Troubleshooting

### "MongoDB_URL is not defined"
→ Add to `.env`: `MongoDB_URL=your_connection_string`

### "bcryptjs not found"
→ Run: `npm install bcryptjs`

### "Data already exists"
→ This is normal! Clear database if you want fresh data

### Connection errors
→ Check internet and MongoDB Atlas settings

---

## 📞 Support

For detailed information, see:
- `backend/scripts/DUMMY_DATA_GUIDE.md` (comprehensive guide)
- Check console output for specific errors
- Verify `.env` configuration

---

**Created**: January 24, 2026  
**Status**: ✅ Ready to use

Happy Testing! 🎉
