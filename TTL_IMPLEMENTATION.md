# TTL (Time To Live) Implementation Documentation

## Overview
TTL (Time To Live) is an automatic data cleanup system that removes expired records from the database based on retention policies. This prevents database bloat and ensures compliance with data retention requirements.

---

## Architecture

### Components

#### 1. **TTL Service** (`backend/services/ttl.service.js`)
Core service handling all cleanup operations with configurable retention policies.

**Key Features:**
- Automatic cleanup of notifications, reminders, documents, and tasks
- Customizable retention policies per resource type
- Dry-run statistics to preview deletions
- File cleanup for documents
- Transaction-safe batch operations

**Supported Resources:**
- **Notifications**: Separate retention for read (90 days) vs unread (180 days), absolute max 365 days
- **Reminders**: Triggered/inactive cleanup (180 days), absolute max 365 days
- **Documents**: Unused cleanup (730 days), absolute max 1095 days (3 years)
- **Tasks**: Completed task cleanup (365 days), absolute max 1095 days (3 years)

#### 2. **TTL Scheduler** (`backend/services/scheduler.service.js`)
Integrated with existing notification scheduler to run TTL cleanup automatically.

**Scheduled Jobs:**
- **Notification Check**: Every 6 hours (12 AM, 6 AM, 12 PM, 6 PM)
- **Daily Overdue Check**: Every day at 8 AM
- **TTL Cleanup**: Every day at 2 AM (optimal for database maintenance)

#### 3. **TTL Controller & Routes** (`backend/controller/ttl.controller.js`, `backend/routes/ttl.routes.js`)
REST API endpoints for manual TTL management and administration.

**Base URL:** `http://localhost:3000/api/ttl`

#### 4. **TTL Indexes** (Models)
Database indexes optimized for TTL query performance.

**Indexed Fields:**
- **Notification**: `isRead + readAt`, `isRead + createdAt`, `userId + createdAt`, `status + sentAt`
- **Reminder**: `isActive + updatedAt`, `isTriggered + triggeredAt`, `userId + createdAt`
- **Document**: `updatedAt`, `createdAt`, `userId + createdAt`, `taskId + updatedAt`
- **Task**: `status + updatedAt`, `createdAt`, `userId + status`

---

## Retention Policies

### Default Retention Configuration

```javascript
{
  notification: {
    read: 90,        // Read notifications deleted after 90 days
    unread: 180,     // Unread notifications deleted after 180 days
    all: 365         // Absolute max: 365 days for all notifications
  },
  reminder: {
    triggered: 180,  // Triggered reminders deleted after 180 days
    inactive: 180,   // Inactive reminders deleted after 180 days
    all: 365         // Absolute max: 365 days for all reminders
  },
  document: {
    unused: 730,     // Unused documents deleted after 2 years
    all: 1095        // Absolute max: 3 years for all documents
  },
  task: {
    completed: 365,  // Completed tasks deleted after 1 year
    all: 1095        // Absolute max: 3 years for all tasks
  }
}
```

---

## API Endpoints

### 1. **GET /api/ttl/cleanup**
Manually trigger comprehensive TTL cleanup across all services.

**Authentication:** Required (JWT)
**Rate Limit:** 100 requests/15 minutes

**Response:**
```json
{
  "success": true,
  "message": "TTL cleanup executed successfully",
  "data": {
    "timestamp": "2026-01-15T02:00:00.000Z",
    "status": "success",
    "operations": [
      {
        "service": "Notification Cleanup",
        "deletedCount": 45,
        "retentionDays": { "read": 90, "unread": 180, "absolute": 365 }
      },
      {
        "service": "Reminder Cleanup",
        "deletedCount": 12
      },
      {
        "service": "Document Cleanup",
        "deletedCount": 8,
        "filesDeleted": 8,
        "files": ["/uploads/doc1.pdf", "/uploads/doc2.pdf"]
      },
      {
        "service": "Task Cleanup",
        "deletedCount": 24
      }
    ],
    "summary": {
      "totalDeleted": 89,
      "operationsCompleted": 4
    }
  }
}
```

---

### 2. **GET /api/ttl/statistics**
Get statistics about records eligible for deletion (dry-run).

**Authentication:** Required (JWT)
**Rate Limit:** 100 requests/15 minutes

**Response:**
```json
{
  "success": true,
  "message": "TTL statistics retrieved successfully",
  "data": {
    "timestamp": "2026-01-15T10:30:00.000Z",
    "notifications": {
      "readEligibleForDeletion": 127,
      "unreadEligibleForDeletion": 34
    },
    "reminders": {
      "inactiveEligibleForDeletion": 15
    },
    "documents": {
      "eligibleForDeletion": 3
    },
    "tasks": {
      "completedEligibleForDeletion": 89
    }
  }
}
```

---

### 3. **GET /api/ttl/policies**
Get all retention policies for all resource types.

**Authentication:** Required (JWT)
**Rate Limit:** 100 requests/15 minutes

**Response:**
```json
{
  "success": true,
  "message": "Retention policies retrieved successfully",
  "data": {
    "notification": { "read": 90, "unread": 180, "all": 365 },
    "reminder": { "triggered": 180, "inactive": 180, "all": 365 },
    "document": { "unused": 730, "all": 1095 },
    "task": { "completed": 365, "all": 1095 }
  }
}
```

---

### 4. **GET /api/ttl/policies/:resourceType**
Get retention policy for a specific resource type.

**Parameters:**
- `resourceType` (path): `notification`, `reminder`, `document`, or `task`

**Example:** `GET /api/ttl/policies/notification`

**Response:**
```json
{
  "success": true,
  "message": "Retention policy for notification retrieved successfully",
  "data": {
    "resourceType": "notification",
    "policy": { "read": 90, "unread": 180, "all": 365 }
  }
}
```

---

### 5. **PUT /api/ttl/policies/:resourceType**
Update retention policy for a specific resource type.

**Parameters:**
- `resourceType` (path): `notification`, `reminder`, `document`, or `task`

**Body:**
```json
{
  "read": 60,
  "unread": 120,
  "all": 180
}
```

**Response:**
```json
{
  "success": true,
  "message": "Retention policy for notification updated successfully",
  "data": {
    "resourceType": "notification",
    "policy": { "read": 60, "unread": 120, "all": 180 }
  }
}
```

---

### 6. **POST /api/ttl/cleanup/:resourceType**
Manually trigger cleanup for a specific resource type.

**Parameters:**
- `resourceType` (path): `notification`, `reminder`, `document`, or `task`

**Example:** `POST /api/ttl/cleanup/notification`

**Response:**
```json
{
  "success": true,
  "message": "notification cleanup executed successfully",
  "data": {
    "service": "Notification Cleanup",
    "deletedCount": 45,
    "retentionDays": { "read": 90, "unread": 180, "absolute": 365 }
  }
}
```

---

## Automatic Cleanup Schedule

### Daily at 2 AM (Optimal Time)
```
Cron Expression: 0 2 * * *
```

**What Happens:**
1. Notification cleanup begins
   - Deletes read notifications older than 90 days
   - Deletes unread notifications older than 180 days
   - Deletes all notifications older than 365 days (hard limit)

2. Reminder cleanup begins
   - Deletes triggered/inactive reminders older than 180 days
   - Deletes all reminders older than 365 days (hard limit)

3. Document cleanup begins
   - Deletes unused documents (not accessed for 2 years)
   - Deletes associated files from storage
   - Deletes all documents older than 3 years (hard limit)

4. Task cleanup begins
   - Deletes completed tasks older than 1 year
   - Deletes all tasks older than 3 years (hard limit)

**Console Output:**
```
🧹 Starting comprehensive TTL cleanup operations...

✅ TTL Cleanup Summary:
   Total records deleted: 89
   Operations completed: 4
   Timestamp: 2026-01-15T02:00:00.000Z
```

---

## Implementation Details

### TTL Service Methods

#### Core Cleanup Methods
```javascript
// Clean expired notifications
await ttlService.cleanExpiredNotifications();

// Clean expired reminders
await ttlService.cleanExpiredReminders();

// Clean expired documents (includes file deletion)
await ttlService.cleanExpiredDocuments();

// Clean expired tasks
await ttlService.cleanExpiredTasks();

// Run all cleanups together
await ttlService.cleanExpiredRecords();
```

#### Policy Management Methods
```javascript
// Get specific policy
const policy = ttlService.getRetentionPolicy('notification');

// Get all policies
const allPolicies = ttlService.getAllRetentionPolicies();

// Update policy
ttlService.updateRetentionPolicy('notification', {
  read: 60,
  unread: 120
});
```

#### Preview/Statistics Methods
```javascript
// Get cleanup statistics (dry-run preview)
const stats = await ttlService.getTTLStatistics();
// Returns counts of records eligible for deletion
```

---

## Database Indexes for Performance

### Notification Indexes
```sql
CREATE INDEX idx_notification_read_ttl ON notifications (isRead, readAt);
CREATE INDEX idx_notification_unread_ttl ON notifications (isRead, createdAt);
CREATE INDEX idx_notification_user_created_ttl ON notifications (userId, createdAt);
CREATE INDEX idx_notification_status_sent_ttl ON notifications (status, sentAt);
```

### Reminder Indexes
```sql
CREATE INDEX idx_reminder_inactive_ttl ON reminders (isActive, updatedAt);
CREATE INDEX idx_reminder_triggered_ttl ON reminders (isTriggered, triggeredAt);
CREATE INDEX idx_reminder_user_created_ttl ON reminders (userId, createdAt);
```

### Document Indexes
```sql
CREATE INDEX idx_document_updated_ttl ON documents (updatedAt);
CREATE INDEX idx_document_created_ttl ON documents (createdAt);
CREATE INDEX idx_document_user_created_ttl ON documents (userId, createdAt);
CREATE INDEX idx_document_task_updated_ttl ON documents (taskId, updatedAt);
```

### Task Indexes
```sql
CREATE INDEX idx_task_status_updated_ttl ON tasks (status, updatedAt);
CREATE INDEX idx_task_created_ttl ON tasks (createdAt);
CREATE INDEX idx_task_user_status_ttl ON tasks (userId, status);
```

---

## Usage Examples

### Example 1: Check Cleanup Statistics
```bash
curl -X GET http://localhost:3000/api/ttl/statistics \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Example 2: Manually Trigger Cleanup
```bash
curl -X GET http://localhost:3000/api/ttl/cleanup \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Example 3: Update Notification Retention Policy
```bash
curl -X PUT http://localhost:3000/api/ttl/policies/notification \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "read": 60,
    "unread": 120,
    "all": 180
  }'
```

### Example 4: Cleanup Specific Resource Type
```bash
curl -X POST http://localhost:3000/api/ttl/cleanup/document \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

## Best Practices

### 1. **Schedule TTL During Low-Traffic Hours**
- Currently configured for 2 AM (automatic)
- Adjust cron expression if needed in `scheduler.service.js`

### 2. **Monitor TTL Cleanup**
- Check server logs for cleanup results
- Use `/api/ttl/statistics` to preview before cleanup
- Verify deleted record counts match expectations

### 3. **Adjust Retention Policies Based on Requirements**
```javascript
// Shorter retention for high-volume notifications
ttlService.updateRetentionPolicy('notification', {
  read: 30,        // Delete read notifications after 30 days
  unread: 90       // Delete unread after 90 days
});

// Longer retention for important documents
ttlService.updateRetentionPolicy('document', {
  unused: 1095     // Keep unused documents for 3 years
});
```

### 4. **Backup Before Major Changes**
- Always backup database before changing retention policies
- Test policy changes with `/api/ttl/statistics` first

### 5. **Monitor Database Performance**
- TTL indexes significantly improve cleanup query performance
- Monitor database size over time
- Adjust retention policies if storage grows unexpectedly

---

## Error Handling

### Common Scenarios

**No Cleanup Needed:**
```json
{
  "success": true,
  "data": {
    "operations": [
      { "service": "Notification Cleanup", "deletedCount": 0 }
    ]
  }
}
```

**Invalid Resource Type:**
```json
{
  "success": false,
  "error": "Resource type not found",
  "message": "No cleanup handler found for resource type: invalid_type"
}
```

**Database Error:**
```json
{
  "success": false,
  "error": "Failed to execute TTL cleanup",
  "message": "Database connection timeout"
}
```

---

## Monitoring & Metrics

### Key Metrics to Track

1. **Cleanup Frequency:** How often cleanup runs (daily at 2 AM)
2. **Records Deleted:** Total records removed per cleanup
3. **Storage Freed:** Disk space recovered (especially documents)
4. **Cleanup Duration:** Time taken to complete (normally < 5 minutes)
5. **Error Rate:** Failures during cleanup operations

### Log Messages

```
✅ TTL Cleanup Summary:
   Total records deleted: 89
   Operations completed: 4
   Timestamp: 2026-01-15T02:00:00.000Z

[Notification Cleanup] Deleted 45 records
[Reminder Cleanup] Deleted 12 records
[Document Cleanup] Deleted 8 records + 8 files
[Task Cleanup] Deleted 24 records
```

---

## Future Enhancements

1. **Archive Instead of Delete** - Move old records to archive table
2. **Selective Cleanup** - Clean specific user data
3. **Export Before Delete** - Export records to CSV before deletion
4. **TTL Webhooks** - Send notifications when cleanup completes
5. **Advanced Scheduling** - Per-resource-type cleanup times
6. **Soft Delete Support** - Use `deletedAt` field for recoverable deletes

---

## Troubleshooting

### TTL Cleanup Not Running
1. Check scheduler logs: `📅 Scheduled: TTL cleanup - every day at 2 AM`
2. Verify `node-cron` is installed: `npm list node-cron`
3. Check server time and timezone settings

### High Deletion Counts
1. Review retention policies: `GET /api/ttl/policies`
2. Check statistics before cleanup: `GET /api/ttl/statistics`
3. Adjust policies if deleting too much data

### File Deletion Failures
1. Verify file permissions in `/uploads` directory
2. Check disk space availability
3. Ensure application has write permissions

### Slow Cleanup Performance
1. Verify TTL indexes exist in database
2. Check database server load during cleanup time
3. Consider running cleanup during maintenance window

---

## Summary

✅ **Implemented Features:**
- Automatic daily TTL cleanup at 2 AM
- Configurable retention policies for 4 resource types
- REST API for manual management
- Database indexes for performance
- File storage cleanup for documents
- Statistics/preview before cleanup
- Comprehensive error handling

✅ **Files Created:**
- `backend/services/ttl.service.js` - Core TTL service
- `backend/controller/ttl.controller.js` - TTL API controller
- `backend/routes/ttl.routes.js` - TTL routes (6 endpoints)

✅ **Files Updated:**
- `backend/services/scheduler.service.js` - Added TTL cleanup job
- `backend/models/Notification.js` - Added TTL indexes
- `backend/models/Reminder.js` - Added TTL indexes
- `backend/models/Document.js` - Added TTL indexes
- `backend/models/Task.js` - Added TTL indexes
- `backend/server.js` - Registered TTL routes

✅ **API Endpoints Available:**
- `GET /api/ttl/cleanup` - Manual comprehensive cleanup
- `GET /api/ttl/statistics` - Preview cleanup statistics
- `GET /api/ttl/policies` - Get all policies
- `GET /api/ttl/policies/:resourceType` - Get specific policy
- `PUT /api/ttl/policies/:resourceType` - Update policy
- `POST /api/ttl/cleanup/:resourceType` - Clean specific resource

---

**Status:** ✅ **TTL System Ready for Production**
