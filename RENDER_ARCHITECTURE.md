# Render Deployment Architecture

## Production Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         Internet Users                           │
│                    (Flutter App / Web Browser)                   │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                    HTTPS (Port 443)
                           │
                           ▼
        ┌──────────────────────────────────────┐
        │      Render Web Service (Free)       │
        │   task-reminder-api.onrender.com     │
        │                                      │
        │  ┌────────────────────────────────┐ │
        │  │   Node.js Express Server       │ │
        │  │   (0.5 GB RAM)                 │ │
        │  │                                │ │
        │  │  - User Routes                 │ │
        │  │  - Task Routes                 │ │
        │  │  - Category Routes             │ │
        │  │  - Document Routes             │ │
        │  │  - JWT Authentication          │ │
        │  │  - File Upload Handling        │ │
        │  └────────────────────────────────┘ │
        │                                      │
        │  Status: Running                     │
        │  Uptime: Always On                   │
        │  SSL: Auto-renewed                   │
        └────────────────┬─────────────────────┘
                         │
                 Internal Network
                         │
                         ▼
        ┌──────────────────────────────────┐
        │  Render PostgreSQL (Free)        │
        │  task-reminder-db               │
        │                                  │
        │  ┌──────────────────────────┐   │
        │  │   Database Tables:       │   │
        │  │                          │   │
        │  │  ✓ users                 │   │
        │  │  ✓ categories            │   │
        │  │  ✓ tasks                 │   │
        │  │  ✓ documents             │   │
        │  │                          │   │
        │  │  Storage: 256 MB         │   │
        │  │  Connections: Limited    │   │
        │  │  Backups: Daily          │   │
        │  └──────────────────────────┘   │
        │                                  │
        │  Status: Running                 │
        │  Internal URL: postgres://...    │
        └──────────────────────────────────┘
```

---

## Data Flow

```
┌──────────────────────────┐
│   Flutter App / Client   │
│  (Android/iOS/Web)       │
└──────────────┬───────────┘
               │
               │ 1. POST /api/users/login
               │    + email & password
               │
               ▼
┌──────────────────────────────────────────┐
│   Render Web Service                     │
│                                          │
│  1. Validate credentials                 │
│  2. Query database for user              │
│  3. Check password hash                  │
│  4. Generate JWT token                   │
└──────────┬───────────────────────────────┘
           │
           │ 2. Response with JWT token
           │    {
           │      "token": "eyJhbGc...",
           │      "user": { ... }
           │    }
           │
           ▼
┌──────────────────────────┐
│   Flutter App            │
│  Save token securely     │
│  (flutter_secure_storage)│
└──────────┬───────────────┘
           │
           │ 3. GET /api/tasks
           │    Header: Authorization: Bearer eyJhbGc...
           │
           ▼
┌──────────────────────────────────────────┐
│   Render Web Service                     │
│                                          │
│  1. Verify JWT token                     │
│  2. Extract user ID from token           │
│  3. Query all tasks for that user        │
│  4. Return tasks as JSON                 │
└──────────┬───────────────────────────────┘
           │
           │ 4. Response with tasks
           │    {
           │      "data": [
           │        { "id": 1, "title": "...", ... },
           │        ...
           │      ]
           │    }
           │
           ▼
┌──────────────────────────┐
│   Flutter App            │
│  Display tasks in UI     │
└──────────────────────────┘
```

---

## Request Flow with Authentication

```
Client Request
    │
    ├─ No Token → ❌ Unauthorized
    │                (401)
    │
    ├─ Invalid Token → ❌ Token Invalid
    │                  (401)
    │
    ├─ Expired Token → ❌ Token Expired
    │                 (401)
    │
    └─ Valid Token → ✅ Proceed
                     Extract User ID
                        │
                        ▼
                  Query Database
                        │
                        ├─ User Not Found → ❌ 404
                        │
                        ├─ Access Denied → ❌ 403
                        │
                        └─ Success → ✅ 200
                                    Return Data
```

---

## File Upload Flow

```
┌────────────────────────────┐
│   Flutter App              │
│                            │
│  SELECT FILE → UPLOAD      │
│  (PDF/Image)               │
└────────────────┬───────────┘
                 │
                 │ multipart/form-data
                 │ - file
                 │ - taskId
                 │ - JWT token
                 │
                 ▼
┌──────────────────────────────────────────┐
│   Render Web Service                     │
│   /api/documents/upload                  │
│                                          │
│  1. Validate JWT token                   │
│  2. Check file type (PDF/JPEG/PNG/etc)   │
│  3. Check file size (max 10MB)           │
│  4. Generate unique filename             │
│  5. Save to: /uploads/1705076400000_abc  │
│  6. Store metadata in database           │
│  7. Link to task & user                  │
└──────────┬───────────────────────────────┘
           │
           ▼
┌──────────────────────────────────┐
│  PostgreSQL Database             │
│                                  │
│  documents table:                │
│  ├─ id: 1                        │
│  ├─ filename: "1705076400000_..." │
│  ├─ originalName: "invoice.pdf"  │
│  ├─ mimeType: "application/pdf"  │
│  ├─ fileSize: 245600             │
│  ├─ filePath: "/uploads/..."     │
│  ├─ taskId: 5                    │
│  ├─ userId: 2                    │
│  └─ createdAt: "2026-01-13..."   │
└──────────────────────────────────┘
```

---

## Deployment Timeline

```
T=0min    Push code to GitHub
   │
   ├─ GitHub notifies Render
   │
T=1min ▼ Render starts build process
   │
   ├─ Clone repository
   ├─ Install dependencies (npm install)
   ├─ Build application
   │
T=3min ▼ Render starts web service
   │
   ├─ Connect to PostgreSQL
   ├─ Run migrations
   ├─ Seed initial data
   │
T=5min ▼ Service goes LIVE ✅
   │
   ├─ API available at: https://task-reminder-api.onrender.com
   ├─ Health check: /health
   ├─ API endpoints: /api/users, /api/tasks, /api/documents, etc.
   │
T=10min ▼ Monitor logs
    │
    └─ Check for errors
       Watch performance
       Monitor database connections
```

---

## Technology Stack on Render

```
┌─────────────────────────────────────────┐
│           RENDER CLOUD PLATFORM         │
├─────────────────────────────────────────┤
│                                         │
│  ┌─────────────────────────────────┐   │
│  │   Web Service Runtime           │   │
│  │                                 │   │
│  │  Node.js 18.x (Alpine Linux)    │   │
│  │  ├─ Express.js 4.18             │   │
│  │  ├─ Sequelize ORM 6.35          │   │
│  │  ├─ Multer (File Upload)        │   │
│  │  ├─ JWT (Authentication)        │   │
│  │  └─ Body Parser (JSON)          │   │
│  │                                 │   │
│  │  Memory: 512 MB                 │   │
│  │  CPU: Shared                    │   │
│  │  Disk: 0.5 GB                   │   │
│  │                                 │   │
│  └─────────────────────────────────┘   │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │   Database Instance             │   │
│  │                                 │   │
│  │  PostgreSQL 15.x                │   │
│  │  ├─ Users Table                 │   │
│  │  ├─ Categories Table            │   │
│  │  ├─ Tasks Table                 │   │
│  │  ├─ Documents Table             │   │
│  │  └─ Indexes & Constraints       │   │
│  │                                 │   │
│  │  Memory: 256 MB                 │   │
│  │  Storage: 10 GB                 │   │
│  │  Backup: Daily                  │   │
│  │                                 │   │
│  └─────────────────────────────────┘   │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │   Network & Security            │   │
│  │                                 │   │
│  │  ✓ Auto SSL Certificate         │   │
│  │  ✓ HTTPS Enabled                │   │
│  │  ✓ Internal Network             │   │
│  │  ✓ DDoS Protection              │   │
│  │                                 │   │
│  └─────────────────────────────────┘   │
│                                         │
└─────────────────────────────────────────┘
```

---

## Scaling Considerations

### Current (Free Tier)
- 1 Web Service instance
- 1 PostgreSQL database instance
- 0.5 GB RAM for app
- 256 MB RAM for database
- 100 GB bandwidth/month

### When to Upgrade
- Users: 100+
- Requests: 1000+/day
- Database size: >1 GB

### Upgrade Options
- **Starter ($7/month):** 2 GB RAM, better performance
- **Standard ($12/month):** 4 GB RAM, production-ready
- **Pro ($69/month):** Dedicated resources, auto-scaling

---

## Multi-Region Deployment (Future)

```
┌──────────────────────────┐
│   Global Users           │
│                          │
│   ├─ USA                 │
│   ├─ Europe              │
│   ├─ Asia                │
│   └─ Oceania             │
└───────────┬──────────────┘
            │
            ├─── Route to nearest server
            │
    ┌───────┼────────┬─────────┐
    │       │        │         │
    ▼       ▼        ▼         ▼
  [USA]  [EU]   [Asia]    [AU]
   API    API     API       API
    │       │        │         │
    └───────┼────────┼─────────┘
            │        │
            └─► Central DB ◄─┘
                  (Replicated)
```

---

## Estimated Costs

### Free Tier (Recommended for launch)
- Web Service: $0
- PostgreSQL: $0
- Total: **$0/month** ✅

### After Scaling (when needed)
- Starter Web Service: $7/month
- Starter PostgreSQL: $7/month
- Total: **$14/month**

### Production (High Traffic)
- Pro Web Service: $29/month
- Standard PostgreSQL: $15/month
- Total: **$44/month**

---

## Monitoring & Maintenance

```
Daily Tasks
├─ Check error logs
├─ Monitor API response times
├─ Review user count
└─ Check database storage

Weekly Tasks
├─ Review performance metrics
├─ Check SSL certificate renewal
├─ Monitor bandwidth usage
└─ Check for security issues

Monthly Tasks
├─ Review and optimize queries
├─ Update dependencies
├─ Clean up old logs
├─ Plan for scaling
└─ Review costs
```

---

This architecture provides:
- ✅ High availability
- ✅ Auto-scaling (with upgrade)
- ✅ Secure authentication
- ✅ Data persistence
- ✅ File storage
- ✅ Multi-device sync
- ✅ Production-ready setup
