// Database table names and column definitions
class Tables {
  // Table names
  static const String tasks = 'tasks';
  static const String documents = 'documents';
  static const String members = 'members';

  // Tasks table columns
  static const String taskId = 'id';
  static const String taskTitle = 'title';
  static const String taskMemberId = 'member_id';
  static const String taskDescription = 'description';
  static const String taskDocuments = 'documents'; // JSON array
  static const String taskDueDate = 'due_date';
  static const String taskReminderDaysBefore = 'reminder_days_before';
  static const String taskType = 'task_type';
  static const String taskIsCompleted = 'is_completed';
  static const String taskIsNotificationEnabled = 'is_notification_enabled';
  static const String taskCreatedAt = 'created_at';

  // Documents table columns
  static const String documentId = 'id';
  static const String documentName = 'name';
  static const String documentMemberId = 'member_id';
  static const String documentFilePath = 'file_path';
  static const String documentUploadDate = 'upload_date';
  static const String documentCreatedAt = 'created_at';

  // Members table columns
  static const String memberId = 'id';
  static const String memberName = 'name';
  static const String memberPhotoPath = 'photo_path';
  static const String memberCreatedAt = 'created_at';

  // Create table SQL statements
  static const String createTasksTable = '''
    CREATE TABLE $tasks (
      $taskId INTEGER PRIMARY KEY AUTOINCREMENT,
      $taskTitle TEXT NOT NULL,
      $taskMemberId INTEGER NOT NULL,
      $taskDescription TEXT,
      $taskDocuments TEXT,
      $taskDueDate TEXT NOT NULL,
      $taskReminderDaysBefore INTEGER,
      $taskType TEXT NOT NULL,
      $taskIsCompleted INTEGER DEFAULT 0,
      $taskIsNotificationEnabled INTEGER DEFAULT 1,
      $taskCreatedAt TEXT NOT NULL,
      FOREIGN KEY ($taskMemberId) REFERENCES $members($memberId) ON DELETE CASCADE
    )
  ''';

  static const String createDocumentsTable = '''
    CREATE TABLE $documents (
      $documentId INTEGER PRIMARY KEY AUTOINCREMENT,
      $documentName TEXT NOT NULL,
      $documentMemberId INTEGER NOT NULL,
      $documentFilePath TEXT NOT NULL,
      $documentUploadDate TEXT NOT NULL,
      $documentCreatedAt TEXT NOT NULL,
      FOREIGN KEY ($documentMemberId) REFERENCES $members($memberId) ON DELETE CASCADE
    )
  ''';

  static const String createMembersTable = '''
    CREATE TABLE $members (
      $memberId INTEGER PRIMARY KEY AUTOINCREMENT,
      $memberName TEXT NOT NULL,
      $memberPhotoPath TEXT,
      $memberCreatedAt TEXT NOT NULL
    )
  ''';
}
