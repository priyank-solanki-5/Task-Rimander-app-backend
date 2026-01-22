import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/mongo_service.dart';

/// Database helper for MongoDB
/// This replaces the SQLite database with MongoDB for better scalability
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static MongoService? _mongoService;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  /// Initialize the database connection
  Future<void> initialize() async {
    try {
      _mongoService = MongoService();
      await _mongoService!.connect();
      debugPrint('✅ Database initialized with MongoDB');
    } catch (e) {
      debugPrint('❌ Failed to initialize database: $e');
      rethrow;
    }
  }

  /// Get MongoDB service instance
  MongoService get mongoService {
    if (_mongoService == null) {
      throw StateError('Database not initialized. Call initialize() first.');
    }
    return _mongoService!;
  }

  /// Close the database connection
  Future<void> close() async {
    try {
      await _mongoService?.disconnect();
      debugPrint('✅ Database disconnected');
    } catch (e) {
      debugPrint('❌ Failed to close database: $e');
    }
  }

  /// Check if database is connected
  bool get isConnected {
    return _mongoService != null;
  }
}
