# Task Rimander API Documentation

## Overview
The Task Rimander API provides a set of endpoints for managing tasks, reminders, notifications, and user accounts. It is designed to facilitate task management and enhance productivity through a user-friendly interface.

## Base URL
The base URL for accessing the API is:

```
https://task-rimander-app-backend-1.onrender.com
```

## Authentication
The API uses token-based authentication. Users must authenticate to access protected routes. A valid token must be included in the `Authorization` header of each request.

### Authentication Endpoint
- **POST** `/api/auth/login`
  - **Request Body:**
    - `email`: User's email address
    - `password`: User's password
  - **Response:**
    - `token`: JWT token for subsequent requests

## Endpoints

### User Management
- **POST** `/api/users`
  - **Description:** Create a new user.
  - **Request Body:**
    - `name`: User's name
    - `email`: User's email address
    - `password`: User's password
  - **Response:**
    - `user`: Created user object

- **GET** `/api/users/:id`
  - **Description:** Get user details by ID.
  - **Response:**
    - `user`: User object

### Task Management
- **POST** `/api/tasks`
  - **Description:** Create a new task.
  - **Request Body:**
    - `title`: Title of the task
    - `description`: Description of the task
    - `dueDate`: Due date for the task
  - **Response:**
    - `task`: Created task object

- **GET** `/api/tasks`
  - **Description:** Get all tasks for the authenticated user.
  - **Response:**
    - `tasks`: Array of task objects

- **GET** `/api/tasks/:id`
  - **Description:** Get task details by ID.
  - **Response:**
    - `task`: Task object

- **PUT** `/api/tasks/:id`
  - **Description:** Update a task by ID.
  - **Request Body:**
    - `title`: Updated title of the task
    - `description`: Updated description of the task
    - `dueDate`: Updated due date for the task
  - **Response:**
    - `task`: Updated task object

- **DELETE** `/api/tasks/:id`
  - **Description:** Delete a task by ID.
  - **Response:**
    - `message`: Confirmation message

### Reminder Management
- **POST** `/api/reminders`
  - **Description:** Create a new reminder.
  - **Request Body:**
    - `taskId`: ID of the associated task
    - `reminderDate`: Date and time for the reminder
  - **Response:**
    - `reminder`: Created reminder object

- **GET** `/api/reminders`
  - **Description:** Get all reminders for the authenticated user.
  - **Response:**
    - `reminders`: Array of reminder objects

## Error Handling
The API returns standard HTTP status codes to indicate the success or failure of a request. Common error responses include:
- **400 Bad Request:** Invalid request parameters.
- **401 Unauthorized:** Authentication failed or token is missing.
- **404 Not Found:** Resource not found.
- **500 Internal Server Error:** An unexpected error occurred on the server.

## Conclusion
This API provides a comprehensive solution for task management, allowing users to create, update, and delete tasks and reminders efficiently. For further information, please refer to the API documentation or contact support.