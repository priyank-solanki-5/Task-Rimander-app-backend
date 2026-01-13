# 📋 Complete Render Deployment Checklist

## ✅ Pre-Deployment (Local Testing)

- [ ] Backend runs locally: `npm run dev`
- [ ] Server starts on port 3000
- [ ] Database connects successfully
- [ ] All endpoints respond correctly
- [ ] User registration works
- [ ] User login works and returns token
- [ ] Can create tasks with JWT token
- [ ] Can upload documents
- [ ] File validation works
- [ ] All error handling works
- [ ] `.env` file has all required variables
- [ ] `.env` is in `.gitignore`

---

## ✅ GitHub Repository Setup

- [ ] Code pushed to GitHub
- [ ] Repository is public or Render has access
- [ ] Main branch is clean (no uncommitted changes)
- [ ] `backend/` folder exists in root
- [ ] `backend/package.json` exists
- [ ] `backend/server.js` exists
- [ ] `.gitignore` includes:
  - [ ] `backend/node_modules/`
  - [ ] `backend/.env`
  - [ ] `backend/uploads/`
  - [ ] `.env.local`
- [ ] All new Render files committed:
  - [ ] `Dockerfile`
  - [ ] `.dockerignore`
  - [ ] `render.yaml`
  - [ ] `RENDER_QUICK_START.md`
  - [ ] `RENDER_DEPLOYMENT.md`
  - [ ] `RENDER_ARCHITECTURE.md`
  - [ ] `.env.example`

---

## ✅ Render Account Setup

- [ ] Created Render.com account
- [ ] Email verified
- [ ] GitHub connected to Render
- [ ] Render authorized to access GitHub

---

## ✅ PostgreSQL Database Creation

- [ ] Clicked **New** → **PostgreSQL**
- [ ] Filled in database details:
  - [ ] Name: `task-reminder-db`
  - [ ] Database: `task_management_db`
  - [ ] User: `postgres`
  - [ ] Region: (selected appropriate region)
  - [ ] Instance: Free tier selected
- [ ] Database created (wait 2-3 minutes)
- [ ] **Internal Database URL** copied
  - Format: `postgres://user:password@host:5432/database`

---

## ✅ Web Service Deployment

### Service Configuration
- [ ] Clicked **New** → **Web Service**
- [ ] GitHub repository selected
- [ ] Correct branch selected (main/master)
- [ ] Service name: `task-reminder-api` (or your choice)
- [ ] Environment: `Node`
- [ ] Build command: `cd backend && npm install`
- [ ] Start command: `cd backend && node server.js`
- [ ] Instance type: Free tier selected

### Environment Variables
- [ ] Clicked **Advanced** or **Environment**
- [ ] Added all variables:
  - [ ] `DATABASE_URL` = (pasted from PostgreSQL)
  - [ ] `JWT_SECRET` = (generated random string)
  - [ ] `NODE_ENV` = `production`
  - [ ] `PORT` = `3000` (optional, Render sets this)

### Additional Settings
- [ ] Auto-deploy: Enabled (default)
- [ ] Health check: Enabled (default)
- [ ] Disk: Default size sufficient

---

## ✅ Deployment Monitoring

### During Build (3-5 minutes)
- [ ] Build shows: `Starting build...`
- [ ] Sees: `npm install` running
- [ ] Sees: Dependencies installing
- [ ] Sees: Build succeeding
- [ ] Final status: `Build succeeded`

### After Deployment
- [ ] Service status shows: **Running**
- [ ] URL generated: `https://task-reminder-api.onrender.com`
- [ ] Logs show no errors
- [ ] Database connected message visible

---

## ✅ API Endpoint Testing

### Health Check (Test Server is Running)
```bash
curl https://your-service.onrender.com/health
```
- [ ] Returns: `{"message":"Server is running"}`
- [ ] Status: 200 OK

### User Registration (Test Database Connection)
```bash
curl -X POST https://your-service.onrender.com/api/users/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com",
    "mobilenumber": "9876543210",
    "password": "password123"
  }'
```
- [ ] Returns: 201 Created
- [ ] Response contains user data
- [ ] User ID is present

### User Login (Test Authentication)
```bash
curl -X POST https://your-service.onrender.com/api/users/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```
- [ ] Returns: 200 OK
- [ ] Response contains JWT token
- [ ] Token starts with: `eyJhbGc`

### Get Categories (Test JWT Token)
```bash
curl https://your-service.onrender.com/api/categories \
  -H "Authorization: Bearer <token_from_login>"
```
- [ ] Returns: 200 OK
- [ ] Response contains 4 predefined categories
- [ ] Categories: House, Vehicle, Financial, Personal

### Create Task (Test Task Creation)
```bash
curl -X POST https://your-service.onrender.com/api/tasks \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token_from_login>" \
  -d '{
    "title": "Test Task",
    "description": "This is a test",
    "dueDate": "2026-02-15",
    "categoryId": 1,
    "status": "Pending"
  }'
```
- [ ] Returns: 201 Created
- [ ] Task created with ID
- [ ] Task linked to user

### Get Tasks (Test Task Retrieval)
```bash
curl https://your-service.onrender.com/api/tasks \
  -H "Authorization: Bearer <token_from_login>"
```
- [ ] Returns: 200 OK
- [ ] Contains previously created task

---

## ✅ Flutter App Configuration

### Update API Base URL
In your Flutter app, update:
```dart
const String baseUrl = 'https://task-reminder-api.onrender.com/api';
```
- [ ] Changed from `localhost:3000` to Render URL
- [ ] Using `https://` (not `http://`)
- [ ] Correct service name used

### Test Flutter Connection
- [ ] User registration works from app
- [ ] User login works from app
- [ ] Can view tasks in app
- [ ] Can create new task from app
- [ ] Can upload document from app
- [ ] Can see all user's data on different device

---

## ✅ Production Verification

### Security Checks
- [ ] HTTPS is working (lock icon in browser)
- [ ] JWT_SECRET is a random, strong string
- [ ] No sensitive data in logs
- [ ] Database URL not exposed in code
- [ ] API requires authentication (except register/login)

### Performance Checks
- [ ] First request completes in <5 seconds
- [ ] Subsequent requests complete in <1 second
- [ ] Database queries are optimized
- [ ] No N+1 query problems
- [ ] File uploads work under 10MB

### Data Integrity Checks
- [ ] User data persists after restart
- [ ] Tasks are linked to correct user
- [ ] Documents are accessible after upload
- [ ] Relationships maintained correctly
- [ ] No data loss or duplication

### Error Handling Checks
- [ ] Invalid token returns 401
- [ ] Missing token returns 401
- [ ] Invalid data returns 400
- [ ] Non-existent resource returns 404
- [ ] Database errors handled gracefully

---

## ✅ Monitoring & Logs

### Check Render Dashboard
- [ ] Go to service page
- [ ] Click **Logs** tab
- [ ] Look for:
  - [ ] ✅ Database connection message
  - [ ] ✅ Server running on port 3000
  - [ ] ❌ No error messages
  - [ ] ❌ No connection refused errors

### Monitor Errors
- [ ] Set up error notifications (optional)
- [ ] Review logs daily
- [ ] Watch for:
  - [ ] Database connection issues
  - [ ] Memory problems
  - [ ] Unhandled exceptions
  - [ ] Failed requests

---

## ✅ Maintenance & Updates

### Daily
- [ ] Check logs for errors
- [ ] Monitor API response times
- [ ] Check free tier quotas

### Weekly
- [ ] Review error patterns
- [ ] Check database size
- [ ] Monitor bandwidth usage
- [ ] Test critical endpoints

### Monthly
- [ ] Review performance metrics
- [ ] Update dependencies (if needed)
- [ ] Plan for scaling (if needed)
- [ ] Review costs
- [ ] Backup database

---

## ✅ Common Issues Resolution

### Issue: "Cannot find module"
- [ ] ✓ Build command is correct
- [ ] ✓ `cd backend` is included
- [ ] ✓ `npm install` runs before start
- [ ] ✓ Rebuild service

### Issue: "Database connection refused"
- [ ] ✓ PostgreSQL database created
- [ ] ✓ DATABASE_URL environment variable set
- [ ] ✓ Format is correct: `postgres://...`
- [ ] ✓ Both services in same region
- [ ] ✓ Rebuild service

### Issue: "Unknown database"
- [ ] ✓ Using PostgreSQL (not MariaDB)
- [ ] ✓ DATABASE_URL set (not individual DB_HOST, DB_USER, etc.)
- [ ] ✓ Database name in URL matches Render setting

### Issue: "Unauthorized 401"
- [ ] ✓ JWT_SECRET environment variable set
- [ ] ✓ Token includes `Authorization: Bearer` header
- [ ] ✓ Token format is correct
- [ ] ✓ Token not expired

### Issue: "Service keeps crashing"
- [ ] ✓ Check logs for specific error
- [ ] ✓ Verify all environment variables set
- [ ] ✓ Database is accessible
- [ ] ✓ Node version compatible
- [ ] ✓ Rebuild service

---

## ✅ Go-Live Checklist

### Final Preparations
- [ ] All tests passing
- [ ] API responding correctly
- [ ] Flutter app connects successfully
- [ ] Database queries optimized
- [ ] Error messages user-friendly
- [ ] Logs reviewed for errors
- [ ] Performance acceptable

### Communication
- [ ] Users informed of new URL
- [ ] Documentation updated
- [ ] API documentation shared with team
- [ ] Support contacts provided

### Backup Plan
- [ ] Database backups configured
- [ ] Can rollback if needed
- [ ] Old backend still accessible (if needed)
- [ ] Backup procedures documented

### Go Live!
- [ ] Announce new backend URL
- [ ] Update Flutter app in store
- [ ] Announce to users
- [ ] Monitor closely first day

---

## ✅ Post-Deployment

### Day 1
- [ ] Monitor all user activities
- [ ] Check logs for errors
- [ ] Verify no data issues
- [ ] Check performance metrics
- [ ] Be ready for quick fixes

### Week 1
- [ ] Gather user feedback
- [ ] Fix any issues
- [ ] Optimize if needed
- [ ] Document lessons learned
- [ ] Update runbooks

### Month 1
- [ ] Review performance
- [ ] Optimize queries if needed
- [ ] Consider scaling if needed
- [ ] Plan next features
- [ ] Review costs

---

## 📊 Deployment Summary Template

**Project:** Task Reminder App
**Date:** January 13, 2026
**Backend URL:** `https://task-reminder-api.onrender.com`
**Database:** PostgreSQL on Render
**Status:** ✅ Live

**Tests Passed:**
- ✅ Health check: 200 OK
- ✅ User registration: 201 Created
- ✅ User login: 200 OK (token received)
- ✅ Category retrieval: 200 OK (4 categories)
- ✅ Task creation: 201 Created
- ✅ Task retrieval: 200 OK
- ✅ Authentication required: 401 Unauthorized (without token)

**Performance:**
- First response time: ~3 seconds
- Average response time: ~200-300ms
- Database queries: Optimized
- File uploads: Working (tested 5MB PDF)

**Next Steps:**
1. Connect Flutter app to new URL
2. Release app update to stores
3. Monitor for issues
4. Gather user feedback
5. Plan scaling if needed

---

**Deployment Complete! 🎉**

Your backend is now live on Render and ready for production!
