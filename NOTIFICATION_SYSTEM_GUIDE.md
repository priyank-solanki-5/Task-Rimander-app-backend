# 🔔 Notification System - Complete Guide

## Overview

The Task Reminder app now has a **comprehensive notification system** with:

- ✅ **In-app notifications** - Real-time notifications within the app
- ✅ **Push notifications** - Mobile push via Firebase Cloud Messaging (FCM)
- ✅ **Notification preferences** - User-configurable notification settings
- ✅ **Notification rules** - Task-based notification triggers
- ✅ **Scheduled notifications** - Automatic reminders based on due dates
- ✅ **Quiet hours** - Do not disturb mode
- ✅ **Multiple channels** - Support for push, email, SMS (extensible)

---

## 📁 System Architecture

```
Notification System
├── Models
│   ├── Notification.js          - Notification records
│   ├── NotificationRule.js      - User-defined rules
│   └── NotificationPreferences.js - User settings
├── Services
│   ├── notification.service.js  - Core notification logic
│   ├── pushNotification.service.js - FCM integration
│   └── scheduler.service.js     - Automated scheduling
├── Controllers
│   └── notification.controller.js - API handlers
├── Routes
│   └── notification.routes.js   - Endpoint definitions
└── DAO
    └── notificationDao.js       - Database operations
```

---

## 🎯 Key Features

### 1. Notification Types
- **in-app**: Displayed within the application
- **push**: Mobile push notifications (FCM)
- **email**: Email notifications (extensible)
- **sms**: SMS notifications (extensible)

### 2. Trigger Types
- **on_due_date**: Notify on the task due date
- **before_due_date**: Notify X hours before due
- **after_due_date**: Notify if task is overdue
- **on_completion**: Notify when task is completed

### 3. User Preferences
- Enable/disable notification channels
- Quiet hours (do not disturb)
- Per-category notification settings
- Daily/weekly digest options
- Push token management

---

## 📡 API Endpoints

### Notification Management

#### Get All Notifications
```http
GET /api/notifications
Authorization: Bearer <token>
Query Parameters:
  - isRead: boolean (filter by read status)
  - status: string (pending|sent|failed)
  - type: string (in-app|push|email|sms)
```

**Response:**
```json
{
  "success": true,
  "count": 5,
  "notifications": [
    {
      "_id": "507f1f77bcf86cd799439011",
      "userId": "507f1f77bcf86cd799439010",
      "taskId": {
        "_id": "507f1f77bcf86cd799439012",
        "title": "Complete project report"
      },
      "type": "in-app",
      "message": "⏰ Task 'Complete project report' is due today",
      "isRead": false,
      "status": "sent",
      "sentAt": "2024-01-28T10:00:00Z",
      "createdAt": "2024-01-28T10:00:00Z"
    }
  ]
}
```

#### Get Unread Count
```http
GET /api/notifications/unread-count
Authorization: Bearer <token>
```

**Response:**
```json
{
  "success": true,
  "unreadCount": 3
}
```

#### Mark as Read
```http
PUT /api/notifications/:notificationId/read
Authorization: Bearer <token>
```

**Response:**
```json
{
  "success": true,
  "message": "Notification marked as read"
}
```

#### Mark All as Read
```http
PUT /api/notifications/mark-all-read
Authorization: Bearer <token>
```

**Response:**
```json
{
  "success": true,
  "message": "All notifications marked as read"
}
```

#### Delete Notification
```http
DELETE /api/notifications/:notificationId
Authorization: Bearer <token>
```

---

### Notification Rules

#### Create Rule
```http
POST /api/notifications/rules
Authorization: Bearer <token>
Content-Type: application/json

{
  "taskId": "507f1f77bcf86cd799439012",
  "type": "push",
  "triggerType": "before_due_date",
  "hoursBeforeDue": 24
}
```

**Response:**
```json
{
  "success": true,
  "message": "Notification rule created successfully",
  "rule": {
    "_id": "507f1f77bcf86cd799439013",
    "userId": "507f1f77bcf86cd799439010",
    "taskId": "507f1f77bcf86cd799439012",
    "type": "push",
    "triggerType": "before_due_date",
    "hoursBeforeDue": 24,
    "isActive": true
  }
}
```

#### Get User Rules
```http
GET /api/notifications/rules
Authorization: Bearer <token>
```

#### Get Task Rules
```http
GET /api/notifications/rules/task/:taskId
Authorization: Bearer <token>
```

#### Update Rule
```http
PUT /api/notifications/rules/:ruleId
Authorization: Bearer <token>
Content-Type: application/json

{
  "hoursBeforeDue": 48,
  "isActive": true
}
```

#### Delete Rule
```http
DELETE /api/notifications/rules/:ruleId
Authorization: Bearer <token>
```

---

### Notification Preferences

#### Get Preferences
```http
GET /api/notifications/preferences
Authorization: Bearer <token>
```

**Response:**
```json
{
  "success": true,
  "preferences": {
    "_id": "507f1f77bcf86cd799439014",
    "userId": "507f1f77bcf86cd799439010",
    "pushEnabled": true,
    "pushToken": "ExponentPushToken[...]",
    "emailEnabled": true,
    "smsEnabled": false,
    "inAppEnabled": true,
    "quietHoursEnabled": true,
    "quietHoursStart": "22:00",
    "quietHoursEnd": "08:00",
    "taskDueReminders": true,
    "taskOverdueReminders": true,
    "taskCompletionNotifications": true,
    "dailyDigest": false,
    "weeklyDigest": false
  }
}
```

#### Update Preferences
```http
PUT /api/notifications/preferences
Authorization: Bearer <token>
Content-Type: application/json

{
  "pushEnabled": true,
  "quietHoursEnabled": true,
  "quietHoursStart": "22:00",
  "quietHoursEnd": "07:00",
  "taskDueReminders": true
}
```

**Response:**
```json
{
  "success": true,
  "message": "Preferences updated successfully",
  "preferences": { ... }
}
```

#### Update Push Token
```http
POST /api/notifications/push-token
Authorization: Bearer <token>
Content-Type: application/json

{
  "pushToken": "ExponentPushToken[xxxxxxxxxxxxxxxxxxxxxx]"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Push token updated successfully",
  "preferences": { ... }
}
```

#### Test Push Notification
```http
POST /api/notifications/test-push
Authorization: Bearer <token>
Content-Type: application/json

{
  "title": "Test Notification",
  "message": "This is a test push notification"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Test notification sent",
  "result": {
    "success": true,
    "channels": {
      "inApp": true,
      "push": true,
      "email": false,
      "sms": false
    }
  }
}
```

---

### Utility Endpoints

#### Get Upcoming Tasks
```http
GET /api/notifications/upcoming-tasks?days=7
Authorization: Bearer <token>
```

**Response:**
```json
{
  "success": true,
  "count": 3,
  "tasks": [
    {
      "_id": "507f1f77bcf86cd799439012",
      "title": "Complete project report",
      "dueDate": "2024-01-30T09:00:00Z",
      "status": "Pending"
    }
  ]
}
```

#### Trigger Notification Check (Testing)
```http
POST /api/notifications/trigger-check
Authorization: Bearer <token>
```

---

## 🔧 Setup Instructions

### 1. Firebase Cloud Messaging (FCM) Setup

#### Step 1: Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a new project or select existing
3. Enable **Cloud Messaging**

#### Step 2: Get Service Account Key
1. Go to Project Settings → Service Accounts
2. Click "Generate new private key"
3. Download `serviceAccountKey.json`
4. Save to `backend/config/firebaseServiceAccount.json`

#### Step 3: Configure Environment
Add to `.env`:
```env
FIREBASE_SERVICE_ACCOUNT_PATH=./config/firebaseServiceAccount.json
```

#### Step 4: Client Setup (Flutter/React Native)

**Flutter:**
```yaml
# pubspec.yaml
dependencies:
  firebase_messaging: ^14.7.0
```

```dart
// Initialize
await Firebase.initializeApp();
final fcmToken = await FirebaseMessaging.instance.getToken();

// Send token to backend
await http.post(
  Uri.parse('$API_URL/api/notifications/push-token'),
  headers: {'Authorization': 'Bearer $token'},
  body: json.encode({'pushToken': fcmToken}),
);
```

**React Native (Expo):**
```javascript
import * as Notifications from 'expo-notifications';

// Get token
const token = (await Notifications.getExpoPushTokenAsync()).data;

// Send to backend
await fetch(`${API_URL}/api/notifications/push-token`, {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${authToken}`,
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({ pushToken: token }),
});
```

---

## 🎯 Usage Examples

### 1. Create Notification Rule for Task

```javascript
// Create rule: notify 24 hours before due date
const response = await fetch('/api/notifications/rules', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    taskId: '507f1f77bcf86cd799439012',
    type: 'push',
    triggerType: 'before_due_date',
    hoursBeforeDue: 24,
  }),
});
```

### 2. Enable Quiet Hours

```javascript
// Set quiet hours from 10 PM to 8 AM
const response = await fetch('/api/notifications/preferences', {
  method: 'PUT',
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    quietHoursEnabled: true,
    quietHoursStart: '22:00',
    quietHoursEnd: '08:00',
  }),
});
```

### 3. Get Unread Notifications

```javascript
const response = await fetch('/api/notifications?isRead=false', {
  headers: {
    'Authorization': `Bearer ${token}`,
  },
});

const data = await response.json();
console.log(`You have ${data.count} unread notifications`);
```

### 4. Register Push Token

```javascript
// After getting FCM token from device
const response = await fetch('/api/notifications/push-token', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    pushToken: devicePushToken,
  }),
});
```

---

## 📊 Database Schema

### Notification Model
```javascript
{
  userId: ObjectId (ref: User),
  taskId: ObjectId (ref: Task),
  type: "email" | "sms" | "push" | "in-app",
  message: String,
  isRead: Boolean,
  status: "pending" | "sent" | "failed",
  sentAt: Date,
  errorMessage: String,
  readAt: Date,
  metadata: Object,
  createdAt: Date,
  updatedAt: Date
}
```

### NotificationRule Model
```javascript
{
  taskId: ObjectId (ref: Task),
  userId: ObjectId (ref: User),
  type: "email" | "sms" | "push" | "in-app",
  triggerType: "on_due_date" | "before_due_date" | "after_due_date" | "on_completion",
  hoursBeforeDue: Number,
  isActive: Boolean,
  createdAt: Date,
  updatedAt: Date
}
```

### NotificationPreferences Model
```javascript
{
  userId: ObjectId (ref: User, unique),
  pushEnabled: Boolean,
  pushToken: String,
  pushTokenUpdatedAt: Date,
  emailEnabled: Boolean,
  emailAddress: String,
  smsEnabled: Boolean,
  phoneNumber: String,
  inAppEnabled: Boolean,
  quietHoursEnabled: Boolean,
  quietHoursStart: String, // "HH:MM"
  quietHoursEnd: String,   // "HH:MM"
  taskDueReminders: Boolean,
  taskOverdueReminders: Boolean,
  taskCompletionNotifications: Boolean,
  taskAssignmentNotifications: Boolean,
  dailyDigest: Boolean,
  dailyDigestTime: String, // "HH:MM"
  weeklyDigest: Boolean,
  weeklyDigestDay: "monday" | "tuesday" | ...,
  createdAt: Date,
  updatedAt: Date
}
```

---

## ⏰ Automated Notifications

The system runs scheduled jobs:

### Notification Check (Every 6 hours)
- Runs at: 12:00 AM, 6:00 AM, 12:00 PM, 6:00 PM
- Checks all active notification rules
- Creates notifications for tasks matching criteria
- Sends via configured channels

### Daily Overdue Check (8:00 AM)
- Checks for overdue tasks
- Sends reminders for incomplete tasks past due date

### Keep-Alive (Every 10 minutes)
- Prevents service from sleeping (Render.com)

---

## 🔔 Notification Flow

```
1. User creates task with due date
         ↓
2. User creates notification rule
   (e.g., notify 24 hours before due)
         ↓
3. Scheduler runs every 6 hours
         ↓
4. Checks if notification should be sent
   - Is current time within trigger window?
   - Is task still pending?
   - Has notification already been sent?
         ↓
5. Create notification in database
         ↓
6. Check user preferences
   - Is notification type enabled?
   - Is it quiet hours?
         ↓
7. Send via enabled channels
   - In-app: Create notification record
   - Push: Send via FCM
   - Email: Send email (if configured)
   - SMS: Send SMS (if configured)
         ↓
8. User receives notification
         ↓
9. User marks as read or takes action
```

---

## 🧪 Testing

### Test Push Notification
```bash
curl -X POST http://localhost:3000/api/notifications/test-push \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Notification",
    "message": "Testing push notifications!"
  }'
```

### Trigger Manual Check
```bash
curl -X POST http://localhost:3000/api/notifications/trigger-check \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Get Notifications
```bash
curl http://localhost:3000/api/notifications \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

## 🎨 Frontend Integration

### React Native Example
```javascript
import * as Notifications from 'expo-notifications';

// Configure notifications
Notifications.setNotificationHandler({
  handleNotification: async () => ({
    shouldShowAlert: true,
    shouldPlaySound: true,
    shouldSetBadge: true,
  }),
});

// Register for push notifications
async function registerForPushNotifications() {
  const { status } = await Notifications.requestPermissionsAsync();
  
  if (status !== 'granted') {
    alert('Failed to get push token!');
    return;
  }
  
  const token = (await Notifications.getExpoPushTokenAsync()).data;
  
  // Send token to backend
  await fetch(`${API_URL}/api/notifications/push-token`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${authToken}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ pushToken: token }),
  });
}

// Listen for notifications
Notifications.addNotificationReceivedListener(notification => {
  console.log('Notification received:', notification);
});

Notifications.addNotificationResponseReceivedListener(response => {
  console.log('Notification tapped:', response);
  // Navigate to task detail
});
```

---

## 📝 Summary

### ✅ What's Implemented

- [x] In-app notification storage and retrieval
- [x] Push notification via FCM
- [x] User notification preferences
- [x] Notification rules per task
- [x] Automated scheduled notifications
- [x] Quiet hours support
- [x] Multiple notification channels
- [x] Unread count tracking
- [x] Mark as read functionality
- [x] Notification testing endpoints
- [x] Push token management

### 🚀 Ready for Production

The notification system is fully functional and production-ready with:
- ✅ Comprehensive API
- ✅ Database models
- ✅ Scheduled jobs
- ✅ Push notification support
- ✅ User preferences
- ✅ Testing endpoints

### 📱 Next Steps

1. **Set up Firebase** - Add serviceAccountKey.json
2. **Configure mobile app** - Integrate FCM in Flutter/React Native
3. **Test notifications** - Use test endpoints
4. **Deploy** - Deploy to production
5. **Monitor** - Check logs for notification delivery

---

**Your notification system is ready to use!** 🎉

