import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'document_reminder.db');
    
    debugPrint('📂 Database Path: $path');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    debugPrint('🛠️ Creating Database Tables...');

    // TASKS TABLE
    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        status TEXT NOT NULL,
        dueDate TEXT,
        isRecurring INTEGER NOT NULL DEFAULT 0,
        recurrenceType TEXT,
        nextOccurrence TEXT,
        userId TEXT NOT NULL,
        categoryId TEXT,
        createdAt TEXT,
        updatedAt TEXT
      )
    ''');

    // CATEGORIES TABLE
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        icon TEXT,
        color TEXT,
        isPredefined INTEGER NOT NULL DEFAULT 0,
        userId TEXT,
        createdAt TEXT,
        updatedAt TEXT
      )
    ''');
    
    // Seed predefined categories
    await _seedCategories(db);

    // DOCUMENTS TABLE
    await db.execute('''
      CREATE TABLE documents (
        id TEXT PRIMARY KEY,
        filename TEXT NOT NULL,
        originalName TEXT NOT NULL,
        filePath TEXT NOT NULL,
        fileSize INTEGER NOT NULL,
        mimeType TEXT NOT NULL,
        userId TEXT NOT NULL,
        taskId TEXT NOT NULL,
        createdAt TEXT,
        updatedAt TEXT
      )
    ''');

    // MEMBERS TABLE
    await db.execute('''
      CREATE TABLE members (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        photoPath TEXT,
        createdAt TEXT,
        updatedAt TEXT
      )
    ''');
    
    debugPrint('✅ Database Tables Created');
  }

  Future<void> _seedCategories(Database db) async {
    final now = DateTime.now().toIso8601String();
    // Example predefined categories
    List<Map<String, dynamic>> categories = [
      {
        'id': 'cat_personal',
        'name': 'Personal',
        'icon': 'person',
        'color': '#2196F3',
        'isPredefined': 1,
        'createdAt': now,
        'updatedAt': now
      },
      {
        'id': 'cat_work',
        'name': 'Work',
        'icon': 'work',
        'color': '#4CAF50',
        'isPredefined': 1,
        'createdAt': now,
        'updatedAt': now
      },
      {
        'id': 'cat_health',
        'name': 'Health',
        'icon': 'favorite',
        'color': '#F44336',
        'isPredefined': 1,
        'createdAt': now,
        'updatedAt': now
      },
      {
        'id': 'cat_finance',
        'name': 'Finance',
        'icon': 'attach_money',
        'color': '#FFC107',
        'isPredefined': 1,
        'createdAt': now,
        'updatedAt': now
      },
    ];

    for (var cat in categories) {
      await db.insert('categories', cat);
    }
    debugPrint('🌱 Seeded ${categories.length} predefined categories');
  }

  // Helper Methods

  // Insert
  Future<int> insert(String table, Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert(table, row, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Update
  Future<int> update(String table, Map<String, dynamic> row, String idColumn, String idValue) async {
    Database db = await database;
    return await db.update(table, row, where: '$idColumn = ?', whereArgs: [idValue]);
  }

  // Delete
  Future<int> delete(String table, String idColumn, String idValue) async {
    Database db = await database;
    return await db.delete(table, where: '$idColumn = ?', whereArgs: [idValue]);
  }

  // Query All
  Future<List<Map<String, dynamic>>> queryAll(String table, {String? where, List<Object?>? whereArgs, String? orderBy}) async {
    Database db = await database;
    return await db.query(table, where: where, whereArgs: whereArgs, orderBy: orderBy);
  }

  // Query by ID
  Future<Map<String, dynamic>?> queryById(String table, String idColumn, String idValue) async {
    Database db = await database;
    List<Map<String, dynamic>> results = await db.query(
      table,
      where: '$idColumn = ?',
      whereArgs: [idValue],
      limit: 1,
    );
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }
}
