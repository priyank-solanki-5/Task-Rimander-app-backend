# Task Reminder App - Flutter Developer Guide

## 📱 API Overview

This document provides comprehensive information for Flutter developers integrating with the Task Reminder App Backend.

**Base URL:** `http://your-server-ip:3000/api`

**Current Version:** 1.0.0

---

## 🔐 Authentication

### JWT Token Authentication

All API requests (except login and register) require JWT token in the `Authorization` header.

**Token Format:**
```
Authorization: Bearer <jwt_token>
```

**Token Expiration:** 30 days

---

## 👤 User Management

### 1. Register User

**Endpoint:** `POST /api/users/register`

**Request Body:**
```json
{
  "username": "john_doe",
  "email": "john@example.com",
  "mobilenumber": "9876543210",
  "password": "SecurePassword123"
}
```

**Validation:**
- Username: Required, string
- Email: Valid email format required
- Mobile: 10 digits required
- Password: Minimum 6 characters

**Success Response (201):**
```json
{
  "message": "User registered successfully",
  "data": {
    "id": 1,
    "username": "john_doe",
    "email": "john@example.com",
    "mobilenumber": "9876543210"
  }
}
```

**Error Response (400):**
```json
{
  "error": "Email already exists"
}
```

**Flutter Implementation:**
```dart
Future<void> registerUser() async {
  final response = await http.post(
    Uri.parse('http://your-server-ip:3000/api/users/register'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'username': 'john_doe',
      'email': 'john@example.com',
      'mobilenumber': '9876543210',
      'password': 'SecurePassword123',
    }),
  );

  if (response.statusCode == 201) {
    print('Registration successful');
  } else {
    print('Registration failed: ${response.body}');
  }
}
```

---

### 2. Login User

**Endpoint:** `POST /api/users/login`

**Request Body:**
```json
{
  "email": "john@example.com",
  "password": "SecurePassword123"
}
```

**Success Response (200):**
```json
{
  "message": "Login successful",
  "data": {
    "id": 1,
    "username": "john_doe",
    "email": "john@example.com",
    "mobilenumber": "9876543210"
  },
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Error Response (401):**
```json
{
  "error": "Invalid credentials"
}
```

**Flutter Implementation:**
```dart
Future<String?> loginUser(String email, String password) async {
  final response = await http.post(
    Uri.parse('http://your-server-ip:3000/api/users/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': email,
      'password': password,
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    String token = data['token'];
    
    // Save token to secure storage (use flutter_secure_storage)
    await SecureStorage().saveToken(token);
    
    return token;
  } else {
    print('Login failed: ${response.body}');
    return null;
  }
}
```

---

### 3. Change Password

**Endpoint:** `POST /api/users/change-password`

**Headers:**
```
Authorization: Bearer <jwt_token>
Content-Type: application/json
```

**Request Body:**
```json
{
  "email": "john@example.com",
  "currentPassword": "OldPassword123",
  "newPassword": "NewPassword456"
}
```

**Success Response (200):**
```json
{
  "message": "Password changed successfully"
}
```

**Error Response (400):**
```json
{
  "error": "Current password is incorrect"
}
```

**Flutter Implementation:**
```dart
Future<bool> changePassword(
  String email,
  String currentPassword,
  String newPassword,
) async {
  String? token = await SecureStorage().getToken();
  
  final response = await http.post(
    Uri.parse('http://your-server-ip:3000/api/users/change-password'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({
      'email': email,
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    }),
  );

  return response.statusCode == 200;
}
```

---

## 📂 Categories

### 1. Get All Categories

**Endpoint:** `GET /api/categories`

**Headers:**
```
Authorization: Bearer <jwt_token>
```

**Query Parameters:**
- `type` (optional): `predefined` or `custom`

**Success Response (200):**
```json
{
  "message": "Categories fetched successfully",
  "data": [
    {
      "id": 1,
      "name": "House",
      "isPredefined": true,
      "description": "Household tasks"
    },
    {
      "id": 2,
      "name": "Vehicle",
      "isPredefined": true,
      "description": "Vehicle maintenance"
    },
    {
      "id": 3,
      "name": "Financial",
      "isPredefined": true,
      "description": "Financial tasks"
    },
    {
      "id": 4,
      "name": "Personal",
      "isPredefined": true,
      "description": "Personal development"
    },
    {
      "id": 5,
      "name": "Work",
      "isPredefined": false,
      "description": "Custom work category"
    }
  ]
}
```

**Flutter Implementation:**
```dart
Future<List<Category>> getAllCategories(String token) async {
  final response = await http.get(
    Uri.parse('http://your-server-ip:3000/api/categories'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    List<dynamic> categories = data['data'];
    
    return categories
        .map((cat) => Category.fromJson(cat))
        .toList();
  } else {
    throw Exception('Failed to fetch categories');
  }
}
```

---

### 2. Create Custom Category

**Endpoint:** `POST /api/categories`

**Headers:**
```
Authorization: Bearer <jwt_token>
```

**Request Body:**
```json
{
  "name": "Work Projects",
  "description": "All work-related projects"
}
```

**Success Response (201):**
```json
{
  "message": "Category created successfully",
  "data": {
    "id": 5,
    "name": "Work Projects",
    "isPredefined": false,
    "description": "All work-related projects"
  }
}
```

**Flutter Implementation:**
```dart
Future<Category> createCategory(
  String token,
  String name,
  String description,
) async {
  final response = await http.post(
    Uri.parse('http://your-server-ip:3000/api/categories'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({
      'name': name,
      'description': description,
    }),
  );

  if (response.statusCode == 201) {
    final data = jsonDecode(response.body);
    return Category.fromJson(data['data']);
  } else {
    throw Exception('Failed to create category');
  }
}
```

---

## ✅ Tasks

### 1. Create Task

**Endpoint:** `POST /api/tasks`

**Headers:**
```
Authorization: Bearer <jwt_token>
```

**Request Body:**
```json
{
  "title": "Fix the roof",
  "description": "Repair the leaking roof",
  "dueDate": "2026-02-15",
  "categoryId": 1,
  "status": "Pending",
  "isRecurring": true,
  "recurrenceType": "Yearly"
}
```

**Recurrence Types:**
- `Monthly`
- `Every 3 months`
- `Every 6 months`
- `Yearly`

**Status Types:**
- `Pending`
- `Completed`

**Success Response (201):**
```json
{
  "message": "Task created successfully",
  "data": {
    "id": 1,
    "title": "Fix the roof",
    "description": "Repair the leaking roof",
    "status": "Pending",
    "dueDate": "2026-02-15",
    "categoryId": 1,
    "userId": 1,
    "isRecurring": true,
    "recurrenceType": "Yearly",
    "nextOccurrence": "2027-02-15",
    "createdAt": "2026-01-13T10:30:00Z",
    "updatedAt": "2026-01-13T10:30:00Z"
  }
}
```

**Flutter Implementation:**
```dart
Future<Task> createTask(
  String token, {
  required String title,
  String? description,
  String? dueDate,
  int? categoryId,
  String? status,
  bool isRecurring = false,
  String? recurrenceType,
}) async {
  final response = await http.post(
    Uri.parse('http://your-server-ip:3000/api/tasks'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({
      'title': title,
      if (description != null) 'description': description,
      if (dueDate != null) 'dueDate': dueDate,
      if (categoryId != null) 'categoryId': categoryId,
      if (status != null) 'status': status,
      'isRecurring': isRecurring,
      if (recurrenceType != null) 'recurrenceType': recurrenceType,
    }),
  );

  if (response.statusCode == 201) {
    final data = jsonDecode(response.body);
    return Task.fromJson(data['data']);
  } else {
    throw Exception('Failed to create task');
  }
}
```

---

### 2. Get All Tasks

**Endpoint:** `GET /api/tasks`

**Headers:**
```
Authorization: Bearer <jwt_token>
```

**Query Parameters:**
- `status` (optional): `Pending` or `Completed`
- `categoryId` (optional): Filter by category

**Success Response (200):**
```json
{
  "message": "Tasks fetched successfully",
  "data": [
    {
      "id": 1,
      "title": "Fix the roof",
      "description": "Repair the leaking roof",
      "status": "Pending",
      "dueDate": "2026-02-15",
      "categoryId": 1,
      "userId": 1,
      "isRecurring": true,
      "recurrenceType": "Yearly",
      "nextOccurrence": "2027-02-15",
      "createdAt": "2026-01-13T10:30:00Z",
      "updatedAt": "2026-01-13T10:30:00Z"
    }
  ]
}
```

**Flutter Implementation:**
```dart
Future<List<Task>> getAllTasks(
  String token, {
  String? status,
  int? categoryId,
}) async {
  Uri url = Uri.parse('http://your-server-ip:3000/api/tasks');
  
  if (status != null || categoryId != null) {
    final params = <String, String>{};
    if (status != null) params['status'] = status;
    if (categoryId != null) params['categoryId'] = categoryId.toString();
    url = url.replace(queryParameters: params);
  }

  final response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    List<dynamic> tasks = data['data'];
    return tasks.map((task) => Task.fromJson(task)).toList();
  } else {
    throw Exception('Failed to fetch tasks');
  }
}
```

---

### 3. Get Task by ID

**Endpoint:** `GET /api/tasks/:id`

**Headers:**
```
Authorization: Bearer <jwt_token>
```

**Success Response (200):**
```json
{
  "message": "Task fetched successfully",
  "data": {
    "id": 1,
    "title": "Fix the roof",
    "description": "Repair the leaking roof",
    "status": "Pending",
    "dueDate": "2026-02-15",
    "categoryId": 1,
    "userId": 1,
    "isRecurring": true,
    "recurrenceType": "Yearly",
    "nextOccurrence": "2027-02-15",
    "createdAt": "2026-01-13T10:30:00Z",
    "updatedAt": "2026-01-13T10:30:00Z"
  }
}
```

---

### 4. Update Task

**Endpoint:** `PUT /api/tasks/:id`

**Headers:**
```
Authorization: Bearer <jwt_token>
```

**Request Body:**
```json
{
  "title": "Fix the roof - Updated",
  "description": "Repair the leaking roof with new materials",
  "dueDate": "2026-03-15",
  "status": "In Progress"
}
```

**Success Response (200):**
```json
{
  "message": "Task updated successfully",
  "data": { "id": 1, "title": "Fix the roof - Updated", ... }
}
```

---

### 5. Delete Task

**Endpoint:** `DELETE /api/tasks/:id`

**Headers:**
```
Authorization: Bearer <jwt_token>
```

**Success Response (200):**
```json
{
  "message": "Task deleted successfully"
}
```

---

### 6. Mark Task Complete

**Endpoint:** `PUT /api/tasks/:id/complete`

**Headers:**
```
Authorization: Bearer <jwt_token>
```

**Success Response (200):**
```json
{
  "message": "Task marked as completed",
  "data": { "id": 1, "status": "Completed", ... }
}
```

**Flutter Implementation:**
```dart
Future<Task> markTaskComplete(String token, int taskId) async {
  final response = await http.put(
    Uri.parse('http://your-server-ip:3000/api/tasks/$taskId/complete'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return Task.fromJson(data['data']);
  } else {
    throw Exception('Failed to mark task complete');
  }
}
```

---

### 7. Mark Task Pending

**Endpoint:** `PUT /api/tasks/:id/pending`

**Headers:**
```
Authorization: Bearer <jwt_token>
```

**Success Response (200):**
```json
{
  "message": "Task marked as pending",
  "data": { "id": 1, "status": "Pending", ... }
}
```

---

### 8. Get Overdue Tasks

**Endpoint:** `GET /api/tasks/overdue`

**Headers:**
```
Authorization: Bearer <jwt_token>
```

**Success Response (200):**
```json
{
  "message": "Overdue tasks fetched successfully",
  "data": [
    {
      "id": 1,
      "title": "Fix the roof",
      "status": "Pending",
      "dueDate": "2026-01-10",
      ...
    }
  ]
}
```

---

### 9. Get Upcoming Tasks

**Endpoint:** `GET /api/tasks/upcoming`

**Headers:**
```
Authorization: Bearer <jwt_token>
```

**Query Parameters:**
- `days` (optional): Number of days to look ahead (default: 7)

**Success Response (200):**
```json
{
  "message": "Upcoming tasks fetched successfully",
  "data": [
    {
      "id": 1,
      "title": "Fix the roof",
      "status": "Pending",
      "dueDate": "2026-02-15",
      ...
    }
  ]
}
```

**Flutter Implementation:**
```dart
Future<List<Task>> getUpcomingTasks(String token, {int days = 7}) async {
  final response = await http.get(
    Uri.parse('http://your-server-ip:3000/api/tasks/upcoming')
        .replace(queryParameters: {'days': days.toString()}),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    List<dynamic> tasks = data['data'];
    return tasks.map((task) => Task.fromJson(task)).toList();
  } else {
    throw Exception('Failed to fetch upcoming tasks');
  }
}
```

---

### 10. Get Recurring Tasks

**Endpoint:** `GET /api/tasks/recurring`

**Headers:**
```
Authorization: Bearer <jwt_token>
```

**Success Response (200):**
```json
{
  "message": "Recurring tasks fetched successfully",
  "data": [
    {
      "id": 1,
      "title": "Fix the roof",
      "isRecurring": true,
      "recurrenceType": "Yearly",
      "nextOccurrence": "2027-02-15",
      ...
    }
  ]
}
```

---

### 11. Stop Task Recurrence

**Endpoint:** `PUT /api/tasks/:id/stop-recurrence`

**Headers:**
```
Authorization: Bearer <jwt_token>
```

**Success Response (200):**
```json
{
  "message": "Task recurrence stopped",
  "data": { "id": 1, "isRecurring": false, ... }
}
```

---

## 📄 Documents

### 1. Upload Document

**Endpoint:** `POST /api/documents/upload`

**Headers:**
```
Authorization: Bearer <jwt_token>
Content-Type: multipart/form-data
```

**Form Data:**
- `document` (file): PDF, JPEG, PNG, GIF, or WEBP
- `taskId` (number): Associated task ID

**Supported File Types:**
- PDF (`application/pdf`)
- JPEG (`image/jpeg`, `image/jpg`)
- PNG (`image/png`)
- GIF (`image/gif`)
- WebP (`image/webp`)

**File Size Limit:** 10 MB

**Success Response (201):**
```json
{
  "message": "Document uploaded successfully",
  "data": {
    "id": 1,
    "filename": "1705076400000_abc123.pdf",
    "originalName": "invoice.pdf",
    "mimeType": "application/pdf",
    "fileSize": 245600,
    "filePath": "/uploads/1705076400000_abc123.pdf",
    "taskId": 1,
    "userId": 1,
    "createdAt": "2026-01-13T10:30:00Z"
  }
}
```

**Error Response (413):**
```json
{
  "error": "File size exceeds 10MB limit"
}
```

**Flutter Implementation:**
```dart
Future<Document> uploadDocument(
  String token,
  File file,
  int taskId,
) async {
  final request = http.MultipartRequest(
    'POST',
    Uri.parse('http://your-server-ip:3000/api/documents/upload'),
  );

  request.headers['Authorization'] = 'Bearer $token';
  request.fields['taskId'] = taskId.toString();
  request.files.add(await http.MultipartFile.fromPath('document', file.path));

  final response = await request.send();
  final responseBody = await response.stream.bytesToString();

  if (response.statusCode == 201) {
    final data = jsonDecode(responseBody);
    return Document.fromJson(data['data']);
  } else {
    throw Exception('Failed to upload document');
  }
}
```

---

### 2. Get All Documents

**Endpoint:** `GET /api/documents`

**Headers:**
```
Authorization: Bearer <jwt_token>
```

**Success Response (200):**
```json
{
  "message": "Documents fetched successfully",
  "data": [
    {
      "id": 1,
      "filename": "1705076400000_abc123.pdf",
      "originalName": "invoice.pdf",
      "mimeType": "application/pdf",
      "fileSize": 245600,
      "filePath": "/uploads/1705076400000_abc123.pdf",
      "taskId": 1,
      "userId": 1,
      "createdAt": "2026-01-13T10:30:00Z"
    }
  ]
}
```

---

### 3. Get Documents by Task

**Endpoint:** `GET /api/documents/task/:taskId`

**Headers:**
```
Authorization: Bearer <jwt_token>
```

**Success Response (200):**
```json
{
  "message": "Documents fetched successfully",
  "data": [ ... ]
}
```

---

### 4. Get Document by ID

**Endpoint:** `GET /api/documents/:id`

**Headers:**
```
Authorization: Bearer <jwt_token>
```

**Success Response (200):**
```json
{
  "message": "Document fetched successfully",
  "data": { "id": 1, "filename": "...", ... }
}
```

---

### 5. Download Document

**Endpoint:** `GET /api/documents/:id/download`

**Headers:**
```
Authorization: Bearer <jwt_token>
```

**Success Response (200):**
- File binary data with appropriate content-type header

**Flutter Implementation:**
```dart
Future<void> downloadDocument(String token, int documentId) async {
  final response = await http.get(
    Uri.parse('http://your-server-ip:3000/api/documents/$documentId/download'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/downloaded_file');
    await file.writeAsBytes(response.bodyBytes);
    print('File downloaded to: ${file.path}');
  } else {
    throw Exception('Failed to download document');
  }
}
```

---

### 6. Delete Document

**Endpoint:** `DELETE /api/documents/:id`

**Headers:**
```
Authorization: Bearer <jwt_token>
```

**Success Response (200):**
```json
{
  "message": "Document deleted successfully"
}
```

---

## 🔧 Flutter Setup Guide

### 1. Install Dependencies

Add to `pubspec.yaml`:
```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  flutter_secure_storage: ^9.0.0
  path_provider: ^2.1.0
  intl: ^0.19.0
```

### 2. Create Models

**models/user.dart:**
```dart
class User {
  int id;
  String username;
  String email;
  String mobilenumber;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.mobilenumber,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      mobilenumber: json['mobilenumber'],
    );
  }
}
```

**models/task.dart:**
```dart
class Task {
  int id;
  String title;
  String? description;
  String status;
  DateTime? dueDate;
  int categoryId;
  int userId;
  bool isRecurring;
  String? recurrenceType;
  DateTime? nextOccurrence;
  DateTime createdAt;
  DateTime updatedAt;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    this.dueDate,
    required this.categoryId,
    required this.userId,
    required this.isRecurring,
    this.recurrenceType,
    this.nextOccurrence,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      status: json['status'],
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      categoryId: json['categoryId'],
      userId: json['userId'],
      isRecurring: json['isRecurring'] ?? false,
      recurrenceType: json['recurrenceType'],
      nextOccurrence: json['nextOccurrence'] != null
          ? DateTime.parse(json['nextOccurrence'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
```

### 3. Create API Service

**services/api_service.dart:**
```dart
class ApiService {
  static const String baseUrl = 'http://your-server-ip:3000/api';
  final SecureStorage secureStorage = SecureStorage();

  Future<String?> getToken() async {
    return await secureStorage.getToken();
  }

  Map<String, String> _getHeaders({bool includeAuth = true}) {
    final headers = {'Content-Type': 'application/json'};
    return headers;
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // User endpoints
  Future<Map<String, dynamic>> registerUser({
    required String username,
    required String email,
    required String mobilenumber,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/register'),
      headers: _getHeaders(),
      body: jsonEncode({
        'username': username,
        'email': email,
        'mobilenumber': mobilenumber,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Registration failed: ${response.body}');
    }
  }

  // Task endpoints
  Future<List<Task>> getAllTasks({String? status, int? categoryId}) async {
    final headers = await _getAuthHeaders();
    Uri url = Uri.parse('$baseUrl/tasks');

    if (status != null || categoryId != null) {
      final params = <String, String>{};
      if (status != null) params['status'] = status;
      if (categoryId != null) params['categoryId'] = categoryId.toString();
      url = url.replace(queryParameters: params);
    }

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<dynamic> tasks = data['data'];
      return tasks.map((task) => Task.fromJson(task)).toList();
    } else {
      throw Exception('Failed to fetch tasks');
    }
  }
}
```

### 4. Create Secure Storage Service

**services/secure_storage.dart:**
```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const String _tokenKey = 'auth_token';
  final _secureStorage = const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await _secureStorage.delete(key: _tokenKey);
  }

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null;
  }
}
```

---

## ⚠️ Error Handling

### Common HTTP Status Codes

| Status | Meaning | Action |
|--------|---------|--------|
| 200 | OK | Request successful |
| 201 | Created | Resource created successfully |
| 400 | Bad Request | Invalid request data |
| 401 | Unauthorized | Missing or invalid token |
| 403 | Forbidden | Access denied |
| 404 | Not Found | Resource not found |
| 500 | Server Error | Server error |

### Error Response Format

```json
{
  "error": "Error description"
}
```

### Flutter Error Handling Example

```dart
Future<void> safeApiCall(Future Function() apiCall) async {
  try {
    await apiCall();
  } on SocketException {
    print('No Internet connection');
  } catch (error) {
    if (error.toString().contains('401')) {
      // Token expired, redirect to login
    } else if (error.toString().contains('400')) {
      print('Bad request');
    } else {
      print('Error: $error');
    }
  }
}
```

---

## 🚀 Best Practices

### 1. Token Management
- Store token securely using `flutter_secure_storage`
- Refresh token before expiration (30 days)
- Clear token on logout

### 2. Error Handling
- Always wrap API calls in try-catch
- Show user-friendly error messages
- Log errors for debugging

### 3. Performance
- Implement pagination for large lists
- Cache frequently accessed data
- Use appropriate query parameters to filter data

### 4. Security
- Never store token in SharedPreferences
- Always use HTTPS in production
- Validate all user inputs before sending

### 5. User Experience
- Show loading indicators during API calls
- Implement pull-to-refresh for lists
- Handle offline scenarios gracefully

---

## 📞 Support

For API issues or questions, contact the backend development team.

**Backend Server Configuration:**
- Host: `your-server-ip`
- Port: `3000`
- Database: MariaDB

---

## 📝 Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-01-13 | Initial release with JWT authentication, task management, and document upload |

---

**Last Updated:** January 13, 2026
