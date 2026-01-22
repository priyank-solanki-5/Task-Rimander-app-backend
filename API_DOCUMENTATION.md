# Task Rimander Backend — API Reference

A complete reference for all routes exposed by the Task Rimander backend. This README documents the live base URL and the routes as implemented in source.

## Base URL
- Production: https://task-rimander-app-backend-1.onrender.com

Unless specified, all API routes are prefixed with `/api`. A health probe is available at `/health`.

## Authentication
- Scheme: JWT Bearer token.
- Header: `Authorization: Bearer <token>`.
- Obtain token via `POST /api/users/login`.

Rate limiting is enabled:
- Auth endpoints: 5 requests / 15 minutes per IP.
- Search: 50 requests / 15 minutes per IP.
- General API: 100 requests / 15 minutes per IP.
- File upload: 10 uploads / hour per IP.

## Health
- GET `/health` — simple liveness check; returns `{ status: "OK" }`.

## Users
Base path: `/api/users`

- POST `/register` — Register a user
  - Body: `{ username, mobilenumber, email, password }`
  - Rate limit: auth-limited
  - Auth: not required

- POST `/login` — Login and get JWT
  - Body: `{ email, password }`
  - Returns: `{ message, data: <user>, token }`
  - Rate limit: auth-limited
  - Auth: not required

- PUT `/change-password` — Change password using email + mobile verification
  - Body: `{ email, mobilenumber, newPassword }`
  - Rate limit: auth-limited
  - Auth: not required

- GET `/profile` — Get authenticated user profile
  - Auth: required

- GET `/notification-preferences` — Get notification preferences
  - Auth: required

- PUT `/notification-preferences` — Update notification preferences
  - Body (any subset): `{ email?, push?, sms?, inApp?, remindersBefore?, overdueNotifications?, completionNotifications?, recurringNotifications? }`
  - Auth: required

- GET `/settings` — Get user settings
  - Auth: required

- PUT `/settings` — Update user settings
  - Body (any subset): `{ theme?, language?, timezone?, dateFormat?, timeFormat?, weekStartsOn? }`
  - Auth: required

- PUT `/metadata` — Update user metadata (free-form object)
  - Body: arbitrary JSON object
  - Auth: required

## Categories
Base path: `/api/categories`

- GET `/` — List all categories (predefined + custom)
- GET `/predefined` — List predefined categories
- GET `/custom` — List custom categories
- GET `/:id` — Get category by id
- POST `/` — Create custom category
  - Body: `{ name, description? }`
- PUT `/:id` — Update category
  - Body: `{ name?, description? }`
- DELETE `/:id` — Delete category

Note: Category routes do not apply `authMiddleware` at the router level.

## Tasks
Base path: `/api/tasks` (all routes require auth)

Search and filter
- GET `/search` — Search by name
  - Query: `q`
  - Rate limit: search-limited
- GET `/filter` — Filter by fields
  - Query: `status?` (`Pending|Completed`), `categoryId?`, `startDate?`, `endDate?`, `isRecurring?` (`true|false`)
  - Rate limit: search-limited
- GET `/search-filter` — Combined search and filter
  - Query: `q?`, `status?`, `categoryId?`, `startDate?`, `endDate?`

CRUD and state
- POST `/` — Create task
  - Body: `{ title, description?, status? (Pending|Completed), dueDate?, categoryId?, isRecurring?, recurrenceType? (Monthly|Every 3 months|Every 6 months|Yearly) }`
- GET `/` — List tasks (optionally `status`, `categoryId` filters)
- GET `/:id` — Get task by id
- PUT `/:id` — Update task (same fields as create, all optional)
- DELETE `/:id` — Delete task
- PATCH `/:id/complete` — Mark complete
- PATCH `/:id/pending` — Mark pending

Utilities
- GET `/overdue` — Overdue tasks
- GET `/upcoming` — Upcoming tasks (default next 7 days; `days?` query)
- GET `/recurring` — Recurring tasks
- PATCH `/:id/stop-recurrence` — Stop recurrence for a task
- POST `/process-recurring` — Process all recurring tasks (admin/cron use)

## Documents
Base path: `/api/documents` (all routes require auth)

- POST `/upload` — Upload a document for a task
  - Content-Type: `multipart/form-data`
  - File field: `document` (PDF/JPEG/PNG/GIF/WEBP; max 10MB)
  - Body fields: `taskId` (required)
  - Rate limit: upload-limited
- GET `/` — List documents for authenticated user
- GET `/task/:taskId` — List documents for a task
- GET `/:id` — Get a document’s metadata
- GET `/:id/download` — Download a document file
- DELETE `/:id` — Delete a document

## Notifications
Base path: `/api/notifications` (all routes require auth)

Rules
- POST `/rules` — Create notification rule
  - Body: `{ taskId, type?, triggerType?, hoursBeforeDue? }`
- GET `/rules` — List rules for user
- GET `/rules/task/:taskId` — List rules for a task
- GET `/rules/:ruleId` — Get a rule
- PUT `/rules/:ruleId` — Update a rule (partial)
- DELETE `/rules/:ruleId` — Delete a rule

Notifications
- GET `/` — List notifications
  - Query: `isRead?` (`true|false`), `status?`, `type?`
- GET `/unread-count` — Count unread notifications
- GET `/upcoming-tasks` — Upcoming tasks (next `days?` days; default 7)
- PUT `/:notificationId/read` — Mark single notification as read
- PUT `/mark-all-read` — Mark all as read
- DELETE `/:notificationId` — Delete a notification

Admin/debug
- POST `/trigger-check` — Manually trigger notification check

## Reminders
Base path: `/api/reminders` (all routes require auth)

Create & delete
- POST `/` — Create reminder
  - Body: `{ taskId, daysBeforeDue? (default 1), type? (email|sms|push|in-app) }`
- DELETE `/:reminderId` — Delete reminder

Read
- GET `/` — List reminders for user
- GET `/task/:taskId` — Get reminder for a task
- GET `/:reminderId` — Get reminder by id
- GET `/active` — Active (upcoming) reminders
- GET `/upcoming` — Upcoming reminders (next `days?`, default 7)

Update
- PUT `/:reminderId` — Update reminder (partial)
- PUT `/:reminderId/days` — Update `daysBeforeDue`
- PUT `/:reminderId/snooze` — Snooze reminder
- PUT `/:reminderId/unsnooze` — Unsnooze reminder

History
- GET `/history` — Reminder history (triggered reminders)
- GET `/:reminderId/history` — Detailed history for a reminder
- DELETE `/history/clear` — Clear reminder history

Admin/debug
- POST `/trigger-check` — Manually trigger reminder processing

## Dashboard
Base path: `/api/dashboard` (all routes require auth)

- GET `/` — Comprehensive dashboard
  - Query: `preview?` — number of upcoming/overdue items to include
- GET `/statistics` — Counts: upcoming, completed, overdue, total, pending
- GET `/status-breakdown` — Status breakdown (pending/completed)
- GET `/upcoming/count` — Upcoming tasks count
- GET `/completed/count` — Completed tasks count
- GET `/overdue/count` — Overdue tasks count
- GET `/upcoming` — Upcoming tasks (query: `limit?`)
- GET `/overdue` — Overdue tasks (query: `limit?`)

## Admin
Base path: `/api/admin` (secured via `x-admin-key` header)

Header: `x-admin-key: <ADMIN_API_KEY>`

Users
- GET `/users` — List users
- GET `/users/:id` — Get user
- PUT `/users/:id` — Update user `{ username?, email?, mobile?, isActive? }`
- DELETE `/users/:id` — Delete user (and related data)

Tasks
- GET `/tasks` — List tasks (populated)
- GET `/tasks/:id` — Get task
- PUT `/tasks/:id/status` — Update task status `{ status }`
- DELETE `/tasks/:id` — Delete task (and related reminders)

Notifications
- GET `/notifications` — List notifications
- DELETE `/notifications/:id` — Delete notification

Stats & System
- GET `/dashboard/stats` — Aggregated statistics
- GET `/system/info` — DB and server info

## Quick Examples

Below examples assume production base URL `https://task-rimander-app-backend-1.onrender.com` and use `Authorization: Bearer <token>` where required.

### Register and Login

Register
```bash
curl -X POST \
  https://task-rimander-app-backend-1.onrender.com/api/users/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "alice",
    "mobilenumber": "9876543210",
    "email": "alice@example.com",
    "password": "secret123"
  }'
```

Login
```bash
curl -X POST \
  https://task-rimander-app-backend-1.onrender.com/api/users/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "alice@example.com",
    "password": "secret123"
  }'
```
Example response
```json
{
  "message": "Login successful",
  "data": { "id": 1, "username": "alice", "email": "alice@example.com" },
  "token": "<JWT>"
}
```

### Create a Task
```bash
curl -X POST \
  https://task-rimander-app-backend-1.onrender.com/api/tasks \
  -H "Authorization: Bearer <JWT>" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Pay electricity bill",
    "description": "Before due date",
    "dueDate": "2026-02-01",
    "categoryId": 1,
    "isRecurring": true,
    "recurrenceType": "Monthly"
  }'
```

### Upload a Document for a Task
```bash
curl -X POST \
  https://task-rimander-app-backend-1.onrender.com/api/documents/upload \
  -H "Authorization: Bearer <JWT>" \
  -F "document=@/path/to/file.pdf" \
  -F "taskId=123"
```

### Set a Reminder for a Task
```bash
curl -X POST \
  https://task-rimander-app-backend-1.onrender.com/api/reminders \
  -H "Authorization: Bearer <JWT>" \
  -H "Content-Type: application/json" \
  -d '{
    "taskId": 123,
    "daysBeforeDue": 2,
    "type": "in-app"
  }'
```

### Search and Filter Tasks

Search by name
```bash
curl "https://task-rimander-app-backend-1.onrender.com/api/tasks/search?q=bill" \
  -H "Authorization: Bearer <JWT>"
```

Filter by status/category/date range
```bash
curl "https://task-rimander-app-backend-1.onrender.com/api/tasks/filter?status=Pending&categoryId=1&startDate=2026-01-01&endDate=2026-12-31" \
  -H "Authorization: Bearer <JWT>"
```

Combined search + filter
```bash
curl "https://task-rimander-app-backend-1.onrender.com/api/tasks/search-filter?q=bill&status=Pending&categoryId=1" \
  -H "Authorization: Bearer <JWT>"
```

### Dashboard Stats

Comprehensive dashboard
```bash
curl "https://task-rimander-app-backend-1.onrender.com/api/dashboard?preview=5" \
  -H "Authorization: Bearer <JWT>"
```

Counts and breakdowns
```bash
curl -H "Authorization: Bearer <JWT>" https://task-rimander-app-backend-1.onrender.com/api/dashboard/statistics
curl -H "Authorization: Bearer <JWT>" https://task-rimander-app-backend-1.onrender.com/api/dashboard/status-breakdown
curl -H "Authorization: Bearer <JWT>" https://task-rimander-app-backend-1.onrender.com/api/dashboard/upcoming/count
curl -H "Authorization: Bearer <JWT>" https://task-rimander-app-backend-1.onrender.com/api/dashboard/completed/count
curl -H "Authorization: Bearer <JWT>" https://task-rimander-app-backend-1.onrender.com/api/dashboard/overdue/count
```

Upcoming/Overdue lists
```bash
curl -H "Authorization: Bearer <JWT>" "https://task-rimander-app-backend-1.onrender.com/api/dashboard/upcoming?limit=10"
curl -H "Authorization: Bearer <JWT>" "https://task-rimander-app-backend-1.onrender.com/api/dashboard/overdue?limit=10"
```

### Admin Endpoints

Headers: `x-admin-key: <ADMIN_API_KEY>`

List users
```bash
curl -H "x-admin-key: <ADMIN_API_KEY>" \
  https://task-rimander-app-backend-1.onrender.com/api/admin/users
```

Update user
```bash
curl -X PUT \
  https://task-rimander-app-backend-1.onrender.com/api/admin/users/USER_ID \
  -H "x-admin-key: <ADMIN_API_KEY>" \
  -H "Content-Type: application/json" \
  -d '{ "isActive": true }'
```

System info
```bash
curl -H "x-admin-key: <ADMIN_API_KEY>" \
  https://task-rimander-app-backend-1.onrender.com/api/admin/system/info
```

## Environment
Create a `.env` in the backend directory with at least:
- `PORT=3000`
- `MongoDB_URL=<your mongodb connection string>`
- `JWT_SECRET=<your jwt secret>`
- `ADMIN_API_KEY=<admin key for /api/admin>`

## Run Locally

Install dependencies and start the server:

```bash
cd backend
npm install
npm run dev # or: npm start
```

Seed predefined categories and start in dev:

```bash
npm run dev-with-init
```

The server logs will print convenient endpoint URLs upon start. File uploads are stored in `./uploads/`.
