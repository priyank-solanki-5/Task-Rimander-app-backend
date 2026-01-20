# Document Reminder App

A Flutter-based Android mobile application for managing tasks and documents with smart reminders.

## 🏗️ Architecture

**State Management:** Provider  
**Database:** SQLite (sqflite)  
**Pattern:** Clean Architecture with Repository Pattern  
**Theme:** Material 3 with Light/Dark mode support

## 📁 Project Structure

```
lib/
├── core/
│   ├── database/          # SQLite database setup and schemas
│   ├── models/            # Data models (Task, Document, Member, User)
│   ├── repositories/      # Data access layer
│   ├── providers/         # State management (Provider)
│   └── services/          # Business logic (Auth)
├── features/
│   ├── auth/              # Authentication screens (Login, Register, Forgot Password)
│   ├── dashboard/         # Dashboard with task management
│   ├── documents/         # Document management with filtering
│   ├── members/           # Member CRUD operations
│   └── profile/           # User profile and statistics
├── widgets/               # Reusable widgets
├── app/                   # App configuration (routes, theme)
└── main.dart              # App entry point
```

## ✨ Features

### 🔐 Authentication
- User registration with local storage
- Login with validation
- Password reset functionality
- Session management

### 📊 Dashboard
- **Due Tasks** - Overdue tasks with visual indicators
- **Today's Tasks** - Tasks due today
- **Upcoming Tasks** - Tasks within next 10 days
- Conditional section rendering (only shows if data exists)
- Task completion tracking with checkboxes
- "Show All" expandable list

### 📄 Documents
- Document list with member association
- Filter by member (dropdown)
- Sort by upload date or alphabetically
- View documents with system apps
- Delete with confirmation

### 👥 Members
- Grid view (3 per row)
- Add, Edit, Delete operations
- Click to filter documents by member
- Cascade delete (removes associated documents and tasks)

### 👤 Profile
- Document count statistics
- Member count statistics
- Clean Material 3 UI

### 🎨 Theme
- Light and Dark mode
- Material 3 design system
- Persistent theme preference
- Auto-detect system theme

## 🗄️ Database Schema

### Tasks
- Task details with member association
- Due dates and reminders
- Task types (one-time/recurring)
- Completion status
- Notification settings

### Documents
- Document metadata
- Member association
- Upload tracking

### Members
- Member information
- Profile photos (optional)

**Foreign Keys:** Cascade delete ensures data integrity

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (^3.8.1)
- Dart SDK (^3.8.1)

### Installation

1. Clone the repository
```bash
git clone <repository-url>
cd Document_Reminder_app
```

2. Install dependencies
```bash
flutter pub get
```

3. Run the app
```bash
flutter run
```

## 📦 Dependencies

```yaml
dependencies:
  provider: ^6.1.1           # State management
  sqflite: ^2.3.0           # SQLite database
  path_provider: ^2.1.1     # File system paths
  intl: ^0.19.0             # Internationalization
  shared_preferences: ^2.2.2 # Local storage
  open_file: ^3.3.2         # Open documents
  image_picker: ^1.0.4      # Image selection
  file_picker: ^6.1.1       # File selection
```

## 🧪 Testing

The app includes seed data for testing:
- 4 sample members
- 4 sample documents
- 6 sample tasks (various states)

### Test Scenarios

1. **Authentication Flow**
   - Register new user
   - Login with credentials
   - Reset password

2. **Task Management**
   - View tasks by category
   - Toggle task completion
   - Expand upcoming tasks

3. **Document Management**
   - Filter by member
   - Sort documents
   - View/Delete documents

4. **Member Management**
   - Add new member
   - Edit member details
   - Delete member (cascade)
   - Navigate to filtered documents

5. **Theme Switching**
   - Toggle light/dark mode
   - Verify persistence

## 🔄 State Management

**Providers:**
- `TaskProvider` - Task state and filtering
- `DocumentProvider` - Document state with sorting
- `MemberProvider` - Member CRUD operations
- `ThemeProvider` - Theme management

**Pattern:**
- Providers consume repositories
- Repositories handle database operations
- UI consumes providers via `Consumer` widgets

## 🎯 Future Enhancements

- [ ] Backend API integration
- [ ] Cloud sync
- [ ] Push notifications
- [ ] Document upload/storage
- [ ] Advanced search
- [ ] Export/Import data
- [ ] Recurring task automation
- [ ] Multi-language support

## 📝 Code Quality

- Clean architecture principles
- Separation of concerns
- Reusable widgets
- Comprehensive error handling
- Material 3 design compliance

## 🤝 Contributing

This is a learning/portfolio project. Feel free to fork and modify.

## 📄 License

This project is for educational purposes.

---

**Built with ❤️ using Flutter**
