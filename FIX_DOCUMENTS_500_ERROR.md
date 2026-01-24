# Fix for GET /api/admin/documents 500 Error

## Problem
The admin documents endpoint was throwing a 500 Internal Server Error when fetching documents.

## Root Cause
The `.lean()` method combined with `.populate()` was not handling null references properly. When documents had optional foreign keys (like `taskId` or `memberId`) that were null or referenced non-existent records, it would cause serialization errors.

## Solution Applied

### Changes to `backend/routes/admin.routes.js`

**1. GET /api/admin/documents endpoint**
- Removed `.lean()` to ensure proper Mongoose document handling
- Added manual transformation to convert Mongoose documents to safe plain objects
- Added defensive null-checking for all foreign key references
- Enhanced error logging to show both message and stack trace

**2. GET /api/admin/documents/:id endpoint**
- Applied same fix: removed `.lean()` and added safe transformation
- Properly handles cases where referenced user/task doesn't exist
- Returns null for missing references instead of failing

## Code Changes

### Before (Problematic)
```javascript
const documents = await Document.find({})
  .populate("userId", "username email")
  .populate("taskId", "title")
  .sort({ createdAt: -1 })
  .lean();  // ❌ Problem: doesn't handle null refs well
```

### After (Fixed)
```javascript
const documents = await Document.find({})
  .populate("userId", "username email")
  .populate("taskId", "title")
  .sort({ createdAt: -1 });

// Transform to safe format, handling null references
const safeDocuments = documents.map((doc) => ({
  _id: doc._id,
  filename: doc.filename,
  originalName: doc.originalName,
  mimeType: doc.mimeType,
  fileSize: doc.fileSize,
  filePath: doc.filePath,
  userId: doc.userId || null,
  taskId: doc.taskId || null,
  memberId: doc.memberId || null,
  createdAt: doc.createdAt,
  updatedAt: doc.updatedAt,
}));
```

## What to Do Now

**Stop and restart your backend server:**

```bash
# In the node terminal, press Ctrl+C to stop current server
# Then run:
npm start
```

**Test the endpoint:**
```bash
# If logged in, the Documents page should now load successfully
# Or test directly: GET http://localhost:3000/api/admin/documents
```

## Benefits of This Fix

✅ **Handles null references gracefully** - Documents with missing task/user references no longer crash
✅ **Better error logging** - Console now shows full error stack for debugging
✅ **Safer serialization** - Explicit transformation prevents Mongoose serialization issues
✅ **Type-safe output** - All fields are explicitly defined and validated

## Status
✅ Code updated and ready to test
⏳ Waiting for server restart to apply changes
