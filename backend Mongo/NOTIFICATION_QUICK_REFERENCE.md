# 🔔 Notification System - Quick Reference

## What's New?

Your backend now has **automatic notifications** with a daily scheduler that checks for upcoming/overdue tasks.

---

## 🚀 Quick Start

### 1. Server Running?
✅ Scheduler starts automatically when server boots

```
🔔 Initializing notification scheduler...
📅 Scheduled: Notification check - every 6 hours
📅 Scheduled: Daily overdue check - every day at 8 AM
✅ Notification scheduler initialized successfully
```

### 2. Create Your First Rule

```bash
curl -X POST http://localhost:3000/api/notifications/rules \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "taskId": 1,
    "type": "in-app",
    "triggerType": "on_due_date"
  }'
```

### 3. View Your Notifications

```bash
curl -X GET http://localhost:3000/api/notifications \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### 4. Mark as Read

```bash
curl -X PUT http://localhost:3000/api/notifications/1/read \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

## 📋 API Endpoints (All Require JWT)

### Notification Rules

| Method | Endpoint | Purpose |
|--------|----------|---------|
| `POST` | `/api/notifications/rules` | Create rule |
| `GET` | `/api/notifications/rules` | Get all user rules |
| `GET` | `/api/notifications/rules/task/:taskId` | Get task rules |
| `GET` | `/api/notifications/rules/:ruleId` | Get single rule |
| `PUT` | `/api/notifications/rules/:ruleId` | Update rule |
| `DELETE` | `/api/notifications/rules/:ruleId` | Delete rule |

### Notifications

| Method | Endpoint | Purpose |
|--------|----------|---------|
| `GET` | `/api/notifications` | Get all notifications |
| `GET` | `/api/notifications/unread-count` | Get unread count |
| `GET` | `/api/notifications/upcoming-tasks` | Get tasks due in 7 days |
| `PUT` | `/api/notifications/:id/read` | Mark as read |
| `PUT` | `/api/notifications/mark-all-read` | Mark all as read |
| `DELETE` | `/api/notifications/:id` | Delete notification |
| `POST` | `/api/notifications/trigger-check` | Manual check (testing) |

---

## 🎯 Trigger Types

```javascript
{
  "triggerType": "on_due_date"        // Send ON due date
  "triggerType": "before_due_date"    // Send X hours before (set hoursBeforeDue)
  "triggerType": "after_due_date"     // Send when overdue
  "triggerType": "on_completion"      // Send when marked complete
}
```

---

## 📊 Database Tables

### NotificationRule
Stores notification preferences

```javascript
{
  id, taskId, userId, type, triggerType, hoursBeforeDue, isActive
}
```

### Notification
Stores individual notifications

```javascript
{
  id, userId, taskId, type, message, isRead, status, sentAt, 
  readAt, errorMessage, metadata, createdAt, updatedAt
}
```

---

## ⏰ Scheduler

### Automatic Jobs

| Job | Schedule | What It Does |
|-----|----------|-------------|
| Notification Check | Every 6 hours (0,6,12,18) | Find upcoming tasks, create notifications |
| Daily Overdue Check | Every day at 8 AM | Check for overdue tasks |

### Cron Expressions
```
0 0 * * *        - Every day at midnight
0 8 * * *        - Every day at 8 AM
0 0,6,12,18 * *  - Every 6 hours (0, 6, 12, 18)
*/15 * * * *     - Every 15 minutes
```

---

## 🔗 Relationships

```
User 1:M NotificationRule
User 1:M Notification
Task 1:M NotificationRule
Task 1:M Notification
```

---

## 📱 Example: Task Due Tomorrow

### Setup
```bash
# Create task
POST /api/tasks
{
  "title": "Buy groceries",
  "dueDate": "2026-01-16T10:00:00",
  "categoryId": 1
}
# Returns: taskId = 1

# Create rule (24 hours before)
POST /api/notifications/rules
{
  "taskId": 1,
  "type": "in-app",
  "triggerType": "before_due_date",
  "hoursBeforeDue": 24
}
```

### What Happens
1. **2026-01-15 10:00 AM** - Scheduler runs
2. Finds rule with 24-hour trigger
3. Checks: Is 24 hours before due date? YES
4. Creates notification with message: "⏰ Task \"Buy groceries\" is due in 24 hours"
5. Status = `pending`

### User Interaction
```bash
# Get unread count
GET /api/notifications/unread-count
# Returns: { "unreadCount": 1 }

# Get notifications
GET /api/notifications?isRead=false
# Returns: notification with message, task details, timestamp

# Mark as read
PUT /api/notifications/123/read

# Get count again
GET /api/notifications/unread-count
# Returns: { "unreadCount": 0 }
```

---

## 🧪 Testing

### Manual Trigger (Don't Wait 6 Hours!)
```bash
curl -X POST http://localhost:3000/api/notifications/trigger-check \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

Response:
```json
{
  "success": true,
  "message": "Notification check completed",
  "result": {
    "success": true,
    "notificationsCreated": 3,
    "timestamp": "2026-01-15T10:30:00Z"
  }
}
```

---

## 🔍 Filtering Notifications

### Get Unread Only
```bash
GET /api/notifications?isRead=false
```

### Get Pending (Not Sent Yet)
```bash
GET /api/notifications?status=pending
```

### Get Sent
```bash
GET /api/notifications?status=sent
```

### Get By Type
```bash
GET /api/notifications?type=in-app
```

### Combine Filters
```bash
GET /api/notifications?isRead=false&status=pending&type=in-app
```

---

## 💾 What Gets Stored

When notification is created, metadata captures:

```json
{
  "taskTitle": "Buy groceries",
  "dueDate": "2026-01-16T10:00:00",
  "category": "Shopping",
  "priority": "High",
  "description": "Milk, eggs, bread, cheese"
}
```

This allows displaying notification details even if task is deleted later.

---

## 🛠️ File Changes

### New Files (7)
- `models/Notification.js`
- `models/NotificationRule.js`
- `services/notification.service.js`
- `services/scheduler.service.js`
- `dao/notificationDao.js`
- `controller/notification.controller.js`
- `routes/notification.routes.js`

### Updated Files (2)
- `package.json` (added node-cron)
- `server.js` (added notification imports, routes, scheduler init)

---

## 📦 Dependencies Added

```json
{
  "node-cron": "^3.0.3"  // For scheduler
}
```

---

## 🎓 Architecture

```
┌─────────────────────────────────────┐
│         API Request                 │
│   (Create rule, get notifications)  │
└──────────────┬──────────────────────┘
               │
        ┌──────▼────────┐
        │  Routes       │
        │ (notification │
        │   .routes.js) │
        └──────┬────────┘
               │
        ┌──────▼────────────┐
        │  Controller       │
        │  (handles HTTP)   │
        └──────┬────────────┘
               │
        ┌──────▼────────────┐
        │  Service          │
        │  (business logic) │
        └──────┬────────────┘
               │
        ┌──────▼────────────┐
        │  DAO              │
        │  (database ops)   │
        └──────┬────────────┘
               │
        ┌──────▼────────────┐
        │  Model            │
        │  (Sequelize ORM)  │
        └──────┬────────────┘
               │
        ┌──────▼────────────┐
        │  MySQL Database   │
        │  (tables created) │
        └───────────────────┘

⏰ Scheduler (Separate Process)
   │
   ├─ Every 6 hours
   │  └─ checkAndCreateNotifications()
   │     └─ Find tasks with rules
   │        └─ Create notifications in DB
   │
   └─ Every day at 8 AM
      └─ checkAndCreateNotifications()
         └─ Focus on overdue tasks
```

---

## 🚨 Common Issues

### Notifications Not Being Created?

1. **Check scheduler is running**
   ```
   Log should show: "✅ Notification scheduler initialized"
   ```

2. **Create a rule first**
   ```bash
   POST /api/notifications/rules
   ```

3. **Task must have dueDate**
   ```javascript
   {
     "dueDate": "2026-01-20"  // Required!
   }
   ```

4. **Manually trigger check**
   ```bash
   POST /api/notifications/trigger-check
   ```

5. **Check database**
   ```sql
   SELECT * FROM NotificationRules WHERE userId = 5;
   SELECT * FROM Notifications WHERE userId = 5;
   ```

---

## 🔐 Security

- ✅ All endpoints require JWT authentication
- ✅ Users can only access their own notifications
- ✅ Rules are user-specific
- ✅ No cross-user data leakage

---

## 🔄 Extension Points

### Add Email Notifications
```javascript
// notification.service.js
async sendEmail(notification) {
  // Use nodemailer
}
```

### Add Push Notifications
```javascript
// Use Firebase Cloud Messaging
```

### Add SMS Notifications
```javascript
// Use Twilio or AWS SNS
```

### Add Webhooks
```javascript
// Call external services when notification created
```

---

## 📊 Key Methods

| Method | Location | Purpose |
|--------|----------|---------|
| `checkAndCreateNotifications()` | notification.service.js | Run by scheduler |
| `shouldSendNotification()` | notification.service.js | Check if notification should be sent |
| `generateNotificationMessage()` | notification.service.js | Create message text |
| `onTaskCompleted()` | notification.service.js | Handle task completion |
| `initializeScheduler()` | scheduler.service.js | Start all cron jobs |
| `scheduleNotificationCheck()` | scheduler.service.js | 6-hour check job |
| `scheduleDailyOverdueCheck()` | scheduler.service.js | 8 AM daily check |

---

## 🎉 You're All Set!

Your notification system is:
- ✅ Fully functional
- ✅ Automatically running
- ✅ Database backed
- ✅ API accessible
- ✅ Production ready

Start creating notification rules and let the scheduler do the work! 🚀
