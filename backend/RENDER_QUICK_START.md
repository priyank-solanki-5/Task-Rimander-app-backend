# 🚀 Deploy to Render - Quick Start Guide

## Prerequisites
- GitHub account with your repository
- Render.com account (free)

---

## Step 1: Create PostgreSQL Database on Render

1. Go to [render.com](https://render.com)
2. Sign in to your account
3. Click **New** button → Select **PostgreSQL**
4. Fill in details:
   - **Name:** `task-reminder-db`
   - **Database:** `task_management_db`
   - **User:** `postgres`
   - **Region:** Choose your region
   - **Instance Type:** Free
5. Click **Create Database**
6. ⏳ Wait for database to create (2-3 minutes)
7. Copy the **Internal Database URL** (looks like: `postgres://user:pass@host:5432/db`)

---

## Step 2: Deploy Web Service

1. Click **New** → **Web Service**
2. Connect your GitHub repository:
   - Select **GitHub** as source
   - Authorize Render to access your GitHub
   - Select your repository
3. Configure service:
   - **Name:** `task-reminder-api`
   - **Environment:** `Node`
   - **Build Command:** 
     ```
     cd backend && npm install
     ```
   - **Start Command:** 
     ```
     cd backend && node server.js
     ```
   - **Instance Type:** Free

4. Click **Advanced** and add environment variables:
   - `NODE_ENV` = `production`
   - `PORT` = `3000`
   - `JWT_SECRET` = (create a random secure string, minimum 32 characters)
   - `DATABASE_URL` = (paste the PostgreSQL internal URL from Step 1)

5. Click **Create Web Service**
6. ⏳ Wait for deployment (3-5 minutes)

---

## Step 3: Verify Deployment

Once deployment is complete, you'll see a URL like: `https://task-reminder-api.onrender.com`

Test the API:

### Health Check
```bash
curl https://task-reminder-api.onrender.com/health
```

Expected response:
```json
{
  "message": "Server is running"
}
```

### Create User
```bash
curl -X POST https://task-reminder-api.onrender.com/api/users/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com",
    "mobilenumber": "9876543210",
    "password": "password123"
  }'
```

Expected response (201 Created):
```json
{
  "message": "User registered successfully",
  "data": {
    "id": 1,
    "username": "testuser",
    "email": "test@example.com",
    "mobilenumber": "9876543210"
  }
}
```

### Login
```bash
curl -X POST https://task-reminder-api.onrender.com/api/users/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

Expected response (200 OK):
```json
{
  "message": "Login successful",
  "data": {
    "id": 1,
    "username": "testuser",
    "email": "test@example.com",
    "mobilenumber": "9876543210"
  },
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

---

## Step 4: Connect Flutter App

Update your Flutter app's API base URL:

```dart
const String baseUrl = 'https://task-reminder-api.onrender.com/api';
```

Replace `task-reminder-api` with your actual service name from Render.

---

## 🔄 Environment Variables Reference

| Variable | Value | Notes |
|----------|-------|-------|
| `NODE_ENV` | `production` | Always set for Render |
| `PORT` | `3000` | Render assigns automatically |
| `DATABASE_URL` | PostgreSQL URL | From Step 1 |
| `JWT_SECRET` | Random string (32+ chars) | Change this in production! |

---

## 📊 View Database

To manage your PostgreSQL database:

1. Go to your Render dashboard
2. Click on **task-reminder-db** (PostgreSQL instance)
3. Scroll to bottom and click **Database Browser**
4. View tables and data

---

## 🐛 Troubleshooting

### Error: "database does not exist"

**Solution:** 
- Make sure `DATABASE_URL` environment variable is set correctly
- Check the PostgreSQL database was created and is running
- Verify the URL format: `postgres://user:password@host:port/database`

### Error: "Connection refused"

**Solution:**
- Make sure both Web Service and PostgreSQL are running
- Check they're in the same region
- Wait a few minutes for services to start

### Error: "Cannot find module"

**Solution:**
- Check build command: `cd backend && npm install`
- Make sure `backend` folder exists in repository
- Check `package.json` is in `backend` folder

### Service keeps crashing

**Check logs:**
1. Go to Render dashboard
2. Click your web service
3. Click **Logs** tab
4. Look for error messages

### Slow initial response

**Normal for free tier:**
- Free tier services go to sleep after 15 minutes
- First request after sleep may take 10-30 seconds
- Upgrade to paid tier for instant responses

---

## 🔐 Security Notes

1. **Change JWT_SECRET:** 
   - Generate a strong random string
   - Example: `openssl rand -base64 32`

2. **Use HTTPS:** 
   - Render provides free HTTPS
   - Always use https:// in your URLs

3. **Protect Database URL:**
   - Don't commit `.env` files to GitHub
   - Use Render's environment variables

4. **Monitor Logs:**
   - Check logs regularly for errors
   - Set up alerts in Render dashboard

---

## 📈 Next Steps

1. ✅ Database is set up
2. ✅ Backend is deployed
3. ⬜ Connect your Flutter frontend
4. ⬜ Test all API endpoints
5. ⬜ Monitor performance in Render dashboard
6. ⬜ Set up custom domain (optional)

---

## 💡 Tips

- **Free tier includes:**
  - 0.5 GB RAM for web service
  - 256 MB RAM for PostgreSQL
  - 100 GB bandwidth/month
  - Auto-SSL certificate

- **Upgrade when needed:**
  - Starter ($7/month) for production
  - Better performance and reliability

- **Custom domain:**
  - Go to service settings
  - Add custom domain
  - Update DNS records at domain provider

---

## 📞 Support

If you have issues:
1. Check [Render documentation](https://render.com/docs)
2. View service logs in Render dashboard
3. Contact Render support through dashboard

---

## 📝 Deployment Checklist

- [ ] GitHub repository is public/authorized
- [ ] PostgreSQL database created on Render
- [ ] Internal Database URL copied
- [ ] Web service created on Render
- [ ] All environment variables set
- [ ] Build command is correct
- [ ] Start command is correct
- [ ] Deployment completed successfully
- [ ] Health endpoint responds
- [ ] User registration works
- [ ] Login works and returns token
- [ ] Flutter app can connect to API

---

**Deployment Date:** January 13, 2026

**API URL:** `https://your-service-name.onrender.com/api`

**Status:** 🟢 Live and Running
