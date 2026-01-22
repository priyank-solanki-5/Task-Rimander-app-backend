# Admin Panel Authentication Setup Guide

## Overview
Complete user authentication system with Registration and Login for the Task Reminder Admin Panel.

## Features Implemented

### 1. **Authentication Context (`AuthContext.jsx`)**
- User registration with email/password
- User login with JWT token storage
- Token-based authorization
- Automatic token injection in API requests
- User session management
- Logout functionality

### 2. **Login Screen (`Login.jsx`)**
- Email and password authentication
- Client-side form validation
- Error handling with user-friendly messages
- Loading state during authentication
- Link to registration page
- Beautiful dark-themed UI with Tailwind CSS

### 3. **Registration Screen (`Register.jsx`)**
- User registration with fields:
  - Username (min 3 characters)
  - Email (email format validation)
  - Mobile Number (10-digit validation)
  - Password (min 6 characters)
  - Confirm Password (must match)
- Comprehensive form validation
- Success/error messages
- Auto-redirect to login after successful registration
- Link to login page

### 4. **Protected Routes (`ProtectedRoute.jsx`)**
- Route protection based on authentication status
- Automatic redirect to login if not authenticated

### 5. **Sidebar User Info (`Layout.jsx`)**
- Display logged-in username and email
- Quick logout button
- User context in navigation

### 6. **API Client Configuration (`api.js`)**
- Bearer token injection for authenticated requests
- Backward compatibility with admin key
- Axios-based HTTP client
- Configurable API base URL via environment variables

## Backend Endpoints Used

### User Routes
- **POST /api/users/register** - Register new user
  - Body: `{ username, email, mobilenumber, password }`
  - Response: User data (without password)

- **POST /api/users/login** - Login user
  - Body: `{ email, password }`
  - Response: User data + JWT token

### Protected User Routes
- **GET /api/users/profile** - Get user profile (requires authentication)
- **GET /api/users/settings** - Get user settings
- **PUT /api/users/settings** - Update user settings
- **GET /api/users/notification-preferences** - Get notification preferences
- **PUT /api/users/notification-preferences** - Update notification preferences

## Installation & Setup

### 1. Backend Setup
```bash
cd backend

# Install dependencies (if not already done)
npm install

# Ensure .env has JWT_SECRET configured
# JWT_SECRET=your-super-secret-jwt-key-change-this-in-production

# Start backend server
npm start
# Server runs on http://localhost:3000
```

### 2. Admin Frontend Setup
```bash
cd admin

# Install dependencies (if not already done)
npm install

# Create .env file (if not exists)
# VITE_API_URL=http://localhost:3000/api

# Start development server
npm run dev
# Admin panel runs on http://localhost:5173
```

## Usage Flow

### Registration Flow
1. User navigates to `/register`
2. Fills in registration form with:
   - Username
   - Email
   - Mobile Number
   - Password
   - Confirm Password
3. System validates all fields
4. If valid, sends POST to `/api/users/register`
5. On success, shows success message
6. Auto-redirects to `/login` after 2 seconds

### Login Flow
1. User navigates to `/login` or is redirected from protected route
2. Enters email and password
3. System validates format
4. On submit, sends POST to `/api/users/login`
5. Backend returns user data + JWT token
6. Frontend stores token in localStorage
7. Token is automatically injected in all subsequent API requests
8. User is redirected to `/dashboard`

### Logout Flow
1. User clicks "Logout" button in sidebar
2. Token is cleared from localStorage
3. User context is cleared
4. User is redirected to `/login`

## File Structure

```
admin/
├── src/
│   ├── context/
│   │   └── AuthContext.jsx          # Authentication context & logic
│   ├── components/
│   │   ├── Layout.jsx               # Main layout with user info
│   │   └── ProtectedRoute.jsx       # Route protection wrapper
│   ├── pages/
│   │   ├── Login.jsx                # Login page
│   │   ├── Register.jsx             # Registration page
│   │   ├── Dashboard.jsx            # Main dashboard (protected)
│   │   ├── Users.jsx                # Users management (protected)
│   │   ├── Tasks.jsx                # Tasks management (protected)
│   │   └── Notifications.jsx        # Notifications view (protected)
│   ├── services/
│   │   └── api.js                   # Axios API client with token injection
│   ├── App.jsx                      # Router configuration
│   └── main.jsx                     # App entry point
├── .env                             # Environment variables
├── .env.example                     # Example environment variables
└── package.json                     # Dependencies

backend/
├── routes/
│   ├── user.routes.js               # User registration/login routes
│   └── admin.routes.js              # Admin-only routes
├── controller/
│   └── user.controller.js           # User registration/login logic
├── services/
│   ├── user.service.js              # User business logic
│   ├── auth.service.js              # JWT token generation/verification
│ └── ...other services
├── utils/
│   ├── authMiddleware.js            # JWT verification middleware
│   ├── validationMiddleware.js      # Input validation
│   └── rateLimitMiddleware.js       # Rate limiting
├── models/
│   └── User.js                      # User MongoDB schema
├── dao/
│   └── userDao.js                   # User database operations
├── .env                             # Backend environment variables
└── server.js                        # Express server configuration
```

## Environment Variables

### Backend (.env)
```
PORT=3000
MongoDB_URL=mongodb+srv://...
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
ADMIN_API_KEY=admin-internal-key-2026
```

### Admin Frontend (.env)
```
VITE_API_URL=http://localhost:3000/api
```

## Security Considerations

1. **JWT Tokens**
   - Tokens are stored in localStorage
   - Automatically sent in Authorization header: `Bearer <token>`
   - Token expires in 30 days (configurable in `auth.service.js`)

2. **Password Security**
   - Passwords sent only over HTTPS (in production)
   - Rate limiting on login/register endpoints (authLimiter)
   - No password returned from API

3. **CORS**
   - CORS enabled in backend for frontend origin
   - Credentials included in requests

4. **Validation**
   - Server-side validation on all endpoints
   - Client-side validation for UX
   - Rate limiting to prevent brute force attacks

## Testing

### Test Registration
1. Navigate to `http://localhost:5173/register`
2. Fill in registration form:
   - Username: `testuser`
   - Email: `test@example.com`
   - Mobile: `9876543210`
   - Password: `password123`
   - Confirm: `password123`
3. Click "Create Account"
4. Should see success message
5. Should auto-redirect to login after 2 seconds

### Test Login
1. Navigate to `http://localhost:5173/login`
2. Enter registered email and password
3. Click "Sign In"
4. Should see user logged in
5. Should redirect to dashboard
6. Sidebar should show username and email

### Test Protected Routes
1. After login, verify you can access:
   - `/dashboard`
   - `/users`
   - `/tasks`
   - `/notifications`
   - `/system`

2. Open DevTools → Application → LocalStorage
   - Should see `authToken` with JWT value

3. Try accessing protected route in new incognito window
   - Should redirect to `/login`

### Test Logout
1. Click "Logout" button in sidebar
2. Should redirect to login page
3. `authToken` should be removed from localStorage

## Troubleshooting

### Issue: "Cannot register/login - 404 error"
**Solution:** Ensure backend is running on `http://localhost:3000` and `/api/users` routes are accessible

### Issue: "CORS error when registering"
**Solution:** Ensure backend has CORS enabled and admin frontend URL is allowed

### Issue: "Token not persisting"
**Solution:** Check that localStorage is enabled in browser and not cleared on page refresh

### Issue: "User info not showing in sidebar after login"
**Solution:** Verify JWT token is valid and contains user data (id, email, username)

### Issue: "Password validation fails on backend but not frontend"
**Solution:** Check `validationMiddleware.js` for password requirements

## API Response Formats

### Successful Registration
```json
{
  "message": "User registered successfully",
  "data": {
    "id": "user_id",
    "username": "testuser",
    "email": "test@example.com",
    "mobilenumber": "9876543210"
  }
}
```

### Successful Login
```json
{
  "message": "Login successful",
  "data": {
    "id": "user_id",
    "username": "testuser",
    "email": "test@example.com",
    "mobilenumber": "9876543210"
  },
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

### Error Response
```json
{
  "error": "Invalid credentials"
}
```

## Next Steps

1. **Production Deployment**
   - Use HTTPS only
   - Set secure JWT_SECRET in production
   - Configure CORS for production domain
   - Enable secure cookies for tokens

2. **Enhanced Features**
   - Email verification for new accounts
   - Password reset functionality
   - Two-factor authentication
   - Social login integration
   - Account recovery options

3. **Monitoring**
   - Set up error logging
   - Monitor authentication failures
   - Track user sessions
   - Audit login attempts

---

**Created:** January 22, 2026
**Status:** Ready for Testing
