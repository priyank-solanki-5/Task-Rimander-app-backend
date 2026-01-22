# Task Rimander API Documentation

## Overview
The Task Rimander App uses a **Hybrid Storage Architecture**:
- **Authentication**: Handled via the backend API (Remote).
- **Data (Tasks, Categories, Documents, Members)**: Stored locally on the device using SQLite (Offline-first).

This documentation covers the Authentication API endpoints.

## Base URL
The base URL for accessing the API is:

```
http://192.168.1.100:3000
```

## Authentication
The API uses token-based authentication. Users must authenticate to access protected routes. A valid token must be included in the `Authorization` header of each request.

### Authentication Endpoints

#### Login
- **POST** `/api/users/login`
  - **Request Body:**
    - `email`: User's email address
    - `password`: User's password
  - **Response:**
    - `token`: JWT token for subsequent requests
    - `user`: User details

#### Register
- **POST** `/api/users/register`
  - **Request Body:**
    - `name`: User's name
    - `email`: User's email address
    - `password`: User's password
  - **Response:**
    - `message`: Success message

#### Profile
- **GET** `/api/users/profile`
  - **Headers:** `Authorization: Bearer <token>`
  - **Response:**
    - `user`: User profile details

## Local Storage
All other data is stored locally in the app's SQLite database.
- **Tasks**: `tasks` table
- **Categories**: `categories` table
- **Documents**: `documents` table
- **Members**: `members` table

## Error Handling
The API returns standard HTTP status codes to indicate the success or failure of a request. Common error responses include:
- **400 Bad Request:** Invalid request parameters.
- **401 Unauthorized:** Authentication failed or token is missing.
- **500 Internal Server Error:** An unexpected error occurred on the server.