import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'tables.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('document_reminder.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    // Enable foreign key constraints
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _createDB(Database db, int version) async {
    // Create tables in order (members first due to foreign keys)
    await db.execute(Tables.createMembersTable);
    await db.execute(Tables.createDocumentsTable);
    await db.execute(Tables.createTasksTable);

    // Insert seed data
    await _insertSeedData(db);
  }

  Future<void> _insertSeedData(Database db) async {
    final now = DateTime.now().toIso8601String();

    // Insert sample members
    await db.insert(Tables.members, {
      Tables.memberName: 'John Doe',
      Tables.memberPhotoPath: null,
      Tables.memberCreatedAt: now,
    });

    await db.insert(Tables.members, {
      Tables.memberName: 'Jane Smith',
      Tables.memberPhotoPath: null,
      Tables.memberCreatedAt: now,
    });

    await db.insert(Tables.members, {
      Tables.memberName: 'Bob Johnson',
      Tables.memberPhotoPath: null,
      Tables.memberCreatedAt: now,
    });

    await db.insert(Tables.members, {
      Tables.memberName: 'Alice Williams',
      Tables.memberPhotoPath: null,
      Tables.memberCreatedAt: now,
    });

    // Insert sample documents
    await db.insert(Tables.documents, {
      Tables.documentName: 'Passport.pdf',
      Tables.documentMemberId: 1,
      Tables.documentFilePath: '/documents/passport.pdf',
      Tables.documentUploadDate: DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
      Tables.documentCreatedAt: now,
    });

    await db.insert(Tables.documents, {
      Tables.documentName: 'Drivers License.pdf',
      Tables.documentMemberId: 1,
      Tables.documentFilePath: '/documents/license.pdf',
      Tables.documentUploadDate: DateTime.now().subtract(const Duration(days: 15)).toIso8601String(),
      Tables.documentCreatedAt: now,
    });

    await db.insert(Tables.documents, {
      Tables.documentName: 'Birth Certificate.pdf',
      Tables.documentMemberId: 2,
      Tables.documentFilePath: '/documents/birth_cert.pdf',
      Tables.documentUploadDate: DateTime.now().subtract(const Duration(days: 45)).toIso8601String(),
      Tables.documentCreatedAt: now,
    });

    await db.insert(Tables.documents, {
      Tables.documentName: 'Insurance Policy.pdf',
      Tables.documentMemberId: 3,
      Tables.documentFilePath: '/documents/insurance.pdf',
      Tables.documentUploadDate: DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
      Tables.documentCreatedAt: now,
    });

    // Insert sample tasks
    // Due task (overdue)
    await db.insert(Tables.tasks, {
      Tables.taskTitle: 'Renew Passport',
      Tables.taskMemberId: 1,
      Tables.taskDescription: 'Passport renewal required before expiry',
      Tables.taskDocuments: '[1]', // JSON array of document IDs
      Tables.taskDueDate: DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      Tables.taskReminderDaysBefore: 7,
      Tables.taskType: 'one-time',
      Tables.taskIsCompleted: 0,
      Tables.taskIsNotificationEnabled: 1,
      Tables.taskCreatedAt: now,
    });

    // Current task (today)
    await db.insert(Tables.tasks, {
      Tables.taskTitle: 'Submit Insurance Claim',
      Tables.taskMemberId: 3,
      Tables.taskDescription: 'File insurance claim for medical expenses',
      Tables.taskDocuments: '[4]',
      Tables.taskDueDate: DateTime.now().toIso8601String(),
      Tables.taskReminderDaysBefore: 3,
      Tables.taskType: 'one-time',
      Tables.taskIsCompleted: 0,
      Tables.taskIsNotificationEnabled: 1,
      Tables.taskCreatedAt: now,
    });

    // Upcoming tasks
    await db.insert(Tables.tasks, {
      Tables.taskTitle: 'Update Drivers License',
      Tables.taskMemberId: 1,
      Tables.taskDescription: 'License renewal due next week',
      Tables.taskDocuments: '[2]',
      Tables.taskDueDate: DateTime.now().add(const Duration(days: 5)).toIso8601String(),
      Tables.taskReminderDaysBefore: 5,
      Tables.taskType: 'one-time',
      Tables.taskIsCompleted: 0,
      Tables.taskIsNotificationEnabled: 1,
      Tables.taskCreatedAt: now,
    });

    await db.insert(Tables.tasks, {
      Tables.taskTitle: 'Monthly Health Checkup',
      Tables.taskMemberId: 2,
      Tables.taskDescription: 'Regular monthly health checkup',
      Tables.taskDocuments: '[]',
      Tables.taskDueDate: DateTime.now().add(const Duration(days: 8)).toIso8601String(),
      Tables.taskReminderDaysBefore: 2,
      Tables.taskType: 'recurring',
      Tables.taskIsCompleted: 0,
      Tables.taskIsNotificationEnabled: 1,
      Tables.taskCreatedAt: now,
    });

    await db.insert(Tables.tasks, {
      Tables.taskTitle: 'Tax Document Submission',
      Tables.taskMemberId: 4,
      Tables.taskDescription: 'Submit annual tax documents',
      Tables.taskDocuments: '[]',
      Tables.taskDueDate: DateTime.now().add(const Duration(days: 15)).toIso8601String(),
      Tables.taskReminderDaysBefore: 10,
      Tables.taskType: 'one-time',
      Tables.taskIsCompleted: 0,
      Tables.taskIsNotificationEnabled: 1,
      Tables.taskCreatedAt: now,
    });

    // Completed task (should not show in dashboard)
    await db.insert(Tables.tasks, {
      Tables.taskTitle: 'Completed Task Example',
      Tables.taskMemberId: 2,
      Tables.taskDescription: 'This task is already completed',
      Tables.taskDocuments: '[]',
      Tables.taskDueDate: DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
      Tables.taskReminderDaysBefore: 3,
      Tables.taskType: 'one-time',
      Tables.taskIsCompleted: 1,
      Tables.taskIsNotificationEnabled: 0,
      Tables.taskCreatedAt: now,
    });
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }

  // Clear all data (for testing)
  Future<void> clearDatabase() async {
    final db = await instance.database;
    await db.delete(Tables.tasks);
    await db.delete(Tables.documents);
    await db.delete(Tables.members);
  }

  // Reset database (for testing)
  Future<void> resetDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'document_reminder.db');
    await deleteDatabase(path);
    _database = null;
  }
}
