# MongoDB Quick Reference

## What Changed?

### ❌ REMOVED
- Sequelize ORM
- MariaDB driver
- MySQL driver
- PostgreSQL driver
- All SQL-based database operations

### ✅ ADDED
- Mongoose ODM
- MongoDB connection
- Schema validations via Mongoose
- Automatic timestamps
- Database indexes

---

## Connection

**Old (Sequelize):**
```javascript
import sequelize from "./config/database.js";
await sequelize.authenticate();
```

**New (Mongoose):**
```javascript
import connectDB from "./config/mongodb.js";
await connectDB();
```

---

## Common Operations

### Create
```javascript
// Old
const user = await User.create({ email: "test@example.com" });

// New
const user = new User({ email: "test@example.com" });
await user.save();
```

### Find One
```javascript
// Old
const user = await User.findOne({ where: { email } });

// New
const user = await User.findOne({ email });
```

### Find All
```javascript
// Old
const tasks = await Task.findAll({ where: { userId } });

// New
const tasks = await Task.find({ userId });
```

### Update
```javascript
// Old
await task.update({ status: "Completed" });

// New
task.status = "Completed";
await task.save();
// OR
await Task.findByIdAndUpdate(taskId, { status: "Completed" });
```

### Delete
```javascript
// Old
await Task.destroy({ where: { id } });

// New
await Task.findByIdAndDelete(id);
```

### Count
```javascript
// Old
const count = await Task.count({ where: { userId } });

// New
const count = await Task.countDocuments({ userId });
```

---

## Filtering & Queries

### Conditions
```javascript
// Equality
{ status: "Pending" }

// Greater than
{ dueDate: { $gt: date } }

// Less than
{ dueDate: { $lt: date } }

// Range
{ dueDate: { $gte: startDate, $lte: endDate } }

// Text search
{ title: { $regex: "search", $options: "i" } }

// Array contains
{ type: { $in: ["email", "sms"] } }
```

### Sorting
```javascript
// Ascending
.sort({ createdAt: 1 })

// Descending
.sort({ createdAt: -1 })

// Multiple
.sort({ dueDate: 1, createdAt: -1 })
```

### Pagination
```javascript
.skip(10)
.limit(20)
```

### Population (Joins)
```javascript
await Task.find({ userId })
  .populate("categoryId", "name isPredefined")
  .populate("userId", "username email")
```

---

## Model Structure

All models follow this pattern:

```javascript
import mongoose from "mongoose";

const schemaName = new mongoose.Schema({
  fieldName: {
    type: String,
    required: true,
    unique: false,
  },
  referenceField: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "ModelName",
    required: true,
  },
}, { timestamps: true }); // Auto adds createdAt, updatedAt

// Add indexes for performance
schemaName.index({ userId: 1, status: 1 });

const ModelName = mongoose.model("ModelName", schemaName);
export default ModelName;
```

---

## Database Schema

### User
```javascript
{
  username: String,
  mobilenumber: String,
  email: String (unique),
  password: String,
  notificationPreferences: Object,
  settings: Object,
  metadata: Object,
  lastLogin: Date,
  isActive: Boolean,
  createdAt: Date,
  updatedAt: Date,
}
```

### Task
```javascript
{
  title: String,
  description: String,
  status: "Pending" | "Completed",
  dueDate: Date,
  isRecurring: Boolean,
  recurrenceType: String,
  nextOccurrence: Date,
  userId: ObjectId (ref: User),
  categoryId: ObjectId (ref: Category),
  createdAt: Date,
  updatedAt: Date,
}
```

### Reminder
```javascript
{
  taskId: ObjectId (ref: Task, unique),
  userId: ObjectId (ref: User),
  daysBeforeDue: Number,
  reminderDate: Date,
  isTriggered: Boolean,
  isActive: Boolean,
  triggeredAt: Date,
  metadata: Object,
  history: [{ triggeredAt, status }],
  type: "email" | "sms" | "push" | "in-app",
  createdAt: Date,
  updatedAt: Date,
}
```

### Notification
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
  updatedAt: Date,
}
```

---

## Error Handling

```javascript
try {
  const user = await User.findById(userId);
  if (!user) {
    throw new Error("User not found");
  }
  return user;
} catch (error) {
  console.error("Error fetching user:", error.message);
  throw error;
}
```

---

## Validation

Mongoose provides built-in validation:

```javascript
const taskSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true,
    minlength: 3,
    maxlength: 200,
  },
  status: {
    type: String,
    enum: ["Pending", "Completed"],
    default: "Pending",
  },
  dueDate: {
    type: Date,
    validate: {
      validator: function(v) {
        return !v || v > new Date();
      },
      message: "Due date must be in the future",
    },
  },
});
```

---

## Performance Tips

1. **Use Indexes** for frequently queried fields:
   ```javascript
   userSchema.index({ email: 1 }, { unique: true });
   taskSchema.index({ userId: 1, status: 1 });
   ```

2. **Projection** - Select only needed fields:
   ```javascript
   await User.findById(id).select("username email -password");
   ```

3. **Lean** - Get plain JavaScript objects (faster):
   ```javascript
   await Task.find({ userId }).lean();
   ```

4. **Batch Operations**:
   ```javascript
   await Notification.updateMany(
     { userId, isRead: false },
     { isRead: true }
   );
   ```

---

## Environment Variables

```env
# MongoDB
MongoDB_URL=mongodb+srv://username:password@cluster.mongodb.net/database?appName=reminder-app

# Server
PORT=3000
NODE_ENV=development

# JWT
JWT_SECRET=your-secure-key-here
```

---

## Resources

- [Mongoose Documentation](https://mongoosejs.com)
- [MongoDB Query Language](https://docs.mongodb.com/manual/reference/operator/query)
- [MongoDB Atlas](https://www.mongodb.com/cloud/atlas)

---

**Last Updated:** January 15, 2026  
**Migration Status:** ✅ Complete
