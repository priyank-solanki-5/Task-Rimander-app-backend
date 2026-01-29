# Admin Setup Guide

This guide explains how to set up and use the admin account for the Task Reminder App.

## Admin Credentials

The admin account has been configured with the following credentials:

- **Email**: `test@gmail.com`
- **Password**: `test123`

## How to Login

The admin uses the same login endpoint as regular users:

### API Endpoint
```
POST /api/users/login
```

### Request Body
```json
{
  "email": "test@gmail.com",
  "password": "test123"
}
```

### Response
```json
{
  "message": "Login successful",
  "data": {
    "id": "...",
    "username": "Admin User",
    "email": "test@gmail.com",
    "mobilenumber": "+1234567890",
    "isAdmin": true,
    "notificationPreferences": {...},
    "settings": {...}
  },
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

## Admin Features

When logged in as an admin (`isAdmin: true`), you have access to:

1. **User Management** (`/api/admin/users`)
   - View all users
   - Update user details
   - Delete users
   - View user statistics

2. **Task Management** (`/api/admin/tasks`)
   - View all tasks
   - Update tasks
   - Delete tasks
   - View task statistics

3. **Category Management** (`/api/admin/categories`)
   - View all categories
   - Create new categories
   - Update categories
   - Delete categories

4. **Document Management** (`/api/admin/documents`)
   - View all documents
   - Delete documents
   - View document statistics

5. **Notification Management** (`/api/admin/notifications`)
   - View all notifications
   - Delete notifications
   - View notification statistics

6. **Dashboard Statistics** (`/api/admin/dashboard`)
   - System-wide statistics
   - User activity metrics
   - Task completion rates

## Running the Setup Script

If you need to reset or update the admin credentials, run:

### Using Batch File (Windows)
```bash
cd backend/scripts
setupAdmin.bat
```

### Using Node.js Directly
```bash
cd backend
node scripts/setupAdmin.js
```

## Environment Variables

Make sure your `.env` file contains:

```env
MongoDB_URL=your_mongodb_connection_string
JWT_SECRET=your_jwt_secret_key
ADMIN_API_KEY=your_admin_api_key_for_registration
```

## Security Notes

⚠️ **Important Security Considerations:**

1. **Change Default Password**: After first login, change the default password to something more secure
2. **Use Strong Passwords**: Ensure admin passwords meet security best practices
3. **Secure JWT_SECRET**: Keep your JWT secret key secure and never commit it to version control
4. **HTTPS Only**: Always use HTTPS in production to protect credentials in transit
5. **Regular Audits**: Regularly review admin access logs and activities

## Troubleshooting

### Admin Cannot Login

1. Verify the admin user exists in the database:
   ```bash
   node scripts/setupAdmin.js
   ```

2. Check MongoDB connection in `.env` file

3. Verify JWT_SECRET is set correctly

### isAdmin Field Missing

Run the setup script again to ensure the `isAdmin` field is added to the user document.

## Additional Information

- Admin users are identified by the `isAdmin: true` flag in their user document
- All admin routes require JWT authentication
- The admin panel in the frontend will automatically show/hide features based on the `isAdmin` status
- Admin routes are protected and require a valid JWT token with admin privileges

---

For more information, see the API documentation in `API_DOCUMENTATION.md`.
