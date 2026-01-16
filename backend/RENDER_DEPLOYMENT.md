# Deploying Task Reminder App Backend to Render

## ⚠️ Problem: MariaDB Not Available on Render

Render doesn't provide built-in MariaDB. You need either:
1. **Option A:** Use PostgreSQL (Recommended - Free on Render)
2. **Option B:** Use external MariaDB service (PlanetScale, AWS RDS)

---

## 🎯 Option A: Migrate to PostgreSQL (RECOMMENDED)

### Step 1: Create PostgreSQL Database on Render

1. Log in to [Render.com](https://render.com)
2. Click **New** → **PostgreSQL**
3. Choose:
   - **Name:** `task-reminder-db`
   - **Region:** Your preferred region
   - **PostgreSQL Version:** Latest
   - **Instance Type:** Free tier
4. Click **Create Database**
5. Copy the **Internal Database URL** - you'll need it

### Step 2: Add PostgreSQL Driver

Update `package.json`:

```bash
npm install pg pg-hstore
npm uninstall mariadb
```

### Step 3: Update Database Configuration

Create new file `config/database.js`:

```javascript
import { Sequelize } from "sequelize";
import dotenv from "dotenv";

dotenv.config();

const sequelize = new Sequelize(
  process.env.DATABASE_URL || "postgres://user:password@localhost:5432/task_management_db",
  {
    dialect: "postgres",
    logging: false,
    pool: {
      max: 5,
      min: 0,
      acquire: 30000,
      idle: 10000,
    },
  }
);

sequelize
  .authenticate()
  .then(() => {
    console.log("✅ PostgreSQL connection established successfully");
  })
  .catch((err) => {
    console.error("❌ Unable to connect to PostgreSQL:", err.message);
    console.error("\n📝 Make sure DATABASE_URL is set in .env file");
    console.error("   Example: DATABASE_URL=postgres://user:pass@host:5432/dbname");
  });

export default sequelize;
```

### Step 4: Update `.env` for Render

In your Render dashboard, add environment variables:

```
DATABASE_URL=<copy from Render PostgreSQL internal URL>
PORT=3000
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
NODE_ENV=production
```

### Step 5: Update Models (If needed)

PostgreSQL uses different data types. Check your models for ENUM syntax:

**Old (MariaDB):**
```javascript
status: {
  type: DataTypes.ENUM('Pending', 'Completed'),
  defaultValue: 'Pending'
}
```

**New (PostgreSQL):**
```javascript
status: {
  type: DataTypes.ENUM('Pending', 'Completed'),
  defaultValue: 'Pending',
  // PostgreSQL automatically creates enum type
}
```

---

## 🟡 Option B: Use External MariaDB (PlanetScale)

### Step 1: Create PlanetScale Account

1. Go to [PlanetScale.com](https://planetscale.com)
2. Sign up and create account
3. Create new database: `task-management-db`

### Step 2: Get Connection String

From PlanetScale dashboard:
- Click your database
- Click **Connect**
- Copy the connection string

### Step 3: Update `.env` on Render

```
DB_HOST=<planetscale-host>
DB_PORT=3306
DB_USER=<username>
DB_PASSWORD=<password>
DB_NAME=task_management_db
PORT=3000
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
NODE_ENV=production
```

### Step 4: Deploy (No code changes needed)

Your existing MariaDB code will work with PlanetScale.

---

## 🚀 Complete Render Deployment Steps

### 1. Connect GitHub Repository

1. Go to [Render.com](https://render.com)
2. Click **New** → **Web Service**
3. Choose **GitHub** as source
4. Select your repository
5. Choose branch: `main` or `master`

### 2. Configure Service

- **Name:** `task-reminder-api`
- **Environment:** `Node`
- **Build Command:** `cd backend && npm install`
- **Start Command:** `cd backend && node server.js`
- **Instance Type:** Free tier

### 3. Add Environment Variables

Click **Environment** and add:

```
DATABASE_URL=<your-postgres-url>
PORT=3000
JWT_SECRET=<random-secret-key>
NODE_ENV=production
```

### 4. Create PostgreSQL Database

In same Render account:
1. Click **New** → **PostgreSQL**
2. Fill in details
3. Copy **Internal Database URL**
4. Paste as `DATABASE_URL` environment variable

### 5. Deploy

Click **Create Web Service** - Render will automatically deploy!

---

## 📝 File Structure After Setup

```
backend/
├── config/
│   └── database.js          (Updated for PostgreSQL)
├── models/
│   ├── User.js
│   ├── Category.js
│   ├── Task.js
│   └── Document.js
├── routes/
├── services/
├── controllers/
├── utils/
├── scripts/
│   └── initializeDatabase.js (May not be needed for Render)
├── .env                      (Environment variables)
├── package.json              (Updated with pg driver)
├── server.js
└── README.md
```

---

## 🔧 Environment Variables Checklist

For Render, your `.env` should have:

```
# Database (PostgreSQL)
DATABASE_URL=postgres://user:password@host:5432/database

# Or (MariaDB - PlanetScale)
# DB_HOST=
# DB_PORT=
# DB_USER=
# DB_PASSWORD=
# DB_NAME=

# Server
PORT=3000
NODE_ENV=production

# JWT
JWT_SECRET=your-secret-key-minimum-32-characters-recommended
```

---

## ✅ Verify Deployment

After deployment, test endpoints:

```bash
# Health check
curl https://your-app.onrender.com/health

# Register user
curl -X POST https://your-app.onrender.com/api/users/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com",
    "mobilenumber": "9876543210",
    "password": "password123"
  }'

# Login
curl -X POST https://your-app.onrender.com/api/users/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

---

## 🐛 Common Issues & Solutions

### Error: DATABASE_URL not found

**Solution:** Make sure environment variable is set in Render dashboard
- Go to Service Settings
- Add `DATABASE_URL` in Environment tab

### Error: relation "users" does not exist

**Solution:** Sequelize needs to sync tables
- Add to `server.js` before listening:
  ```javascript
  await sequelize.sync();
  ```

### Error: Connection timeout

**Solution:** PostgreSQL connection string issue
- Verify `DATABASE_URL` format: `postgres://user:password@host:port/database`
- Check Render PostgreSQL is in same region as web service

### Cold start takes long time

**Solution:** This is normal for free tier
- Database and web service may be on different free instances
- Consider upgrading to paid tier for production

---

## 📦 Recommended: Docker Setup

For more reliability on Render, use Docker:

Create `Dockerfile`:

```dockerfile
FROM node:18-alpine

WORKDIR /app

COPY backend/package*.json ./

RUN npm ci --only=production

COPY backend/ .

EXPOSE 3000

CMD ["node", "server.js"]
```

Create `.dockerignore`:

```
node_modules
npm-debug.log
.git
.env
uploads/
```

---

## 💡 Quick Migration Checklist

- [ ] Choose PostgreSQL or external MariaDB
- [ ] Create database on chosen service
- [ ] Copy connection string/credentials
- [ ] Update `package.json` (add pg, remove mariadb if switching)
- [ ] Update `config/database.js` for new database
- [ ] Add environment variables to Render
- [ ] Push code to GitHub
- [ ] Connect GitHub to Render
- [ ] Deploy service
- [ ] Test endpoints
- [ ] Monitor logs for errors

---

## 🎉 Next Steps

1. **Choose Option A (PostgreSQL) or Option B (PlanetScale)**
2. **Follow the setup steps above**
3. **Push code to GitHub**
4. **Deploy to Render**

Need help with any specific step? Let me know!
