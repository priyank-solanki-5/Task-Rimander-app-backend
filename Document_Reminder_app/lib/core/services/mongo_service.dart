import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter/foundation.dart';

class MongoService {
  static final MongoService _instance = MongoService._internal();
  factory MongoService() => _instance;
  MongoService._internal();

  Db? _db;
  static const String _connectionString =
      'mongodb://localhost:27017/document_reminder';

  Future<void> connect() async {
    try {
      _db = Db(_connectionString);
      await _db!.open();
      debugPrint('✅ Connected to MongoDB');
    } catch (e) {
      debugPrint('❌ Failed to connect to MongoDB: $e');
      rethrow;
    }
  }

  Future<void> disconnect() async {
    if (_db != null && _db!.isConnected) {
      await _db!.close();
      debugPrint('✅ Disconnected from MongoDB');
    }
  }

  Db get database {
    if (_db == null || !_db!.isConnected) {
      throw StateError('Database not connected. Call connect() first.');
    }
    return _db!;
  }

  // Generic CRUD operations
  Future<List<Map<String, dynamic>>> findAll(
    String collectionName, {
    Map<String, dynamic>? query,
    Map<String, dynamic>? sort,
    int? limit,
  }) async {
    try {
      final collection = database.collection(collectionName);
      final queryMap = query ?? {};

      // Create a cursor and convert to list
      var list = await collection.find(queryMap).toList();

      // Apply sorting if provided
      if (sort != null && list.isNotEmpty) {
        for (var key in sort.keys) {
          final sortOrder = sort[key];
          if (sortOrder == 1) {
            list.sort((a, b) {
              final valA = a[key];
              final valB = b[key];
              if (valA == null) return 1;
              if (valB == null) return -1;
              if (valA is Comparable && valB is Comparable) {
                return valA.compareTo(valB);
              }
              return 0;
            });
          } else if (sortOrder == -1) {
            list.sort((a, b) {
              final valA = a[key];
              final valB = b[key];
              if (valA == null) return -1;
              if (valB == null) return 1;
              if (valA is Comparable && valB is Comparable) {
                return valB.compareTo(valA);
              }
              return 0;
            });
          }
        }
      }

      // Apply limit if provided
      if (limit != null && list.length > limit) {
        list = list.sublist(0, limit);
      }

      return list;
    } catch (e) {
      debugPrint('❌ Error finding documents in $collectionName: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> findById(
    String collectionName,
    String id,
  ) async {
    try {
      final collection = database.collection(collectionName);
      final result = await collection.findOne(
        where.eq('_id', ObjectId.parse(id)),
      );
      return result;
    } catch (e) {
      debugPrint('❌ Error finding document by ID in $collectionName: $e');
      return null;
    }
  }

  Future<String> insertOne(
    String collectionName,
    Map<String, dynamic> data,
  ) async {
    try {
      final collection = database.collection(collectionName);
      final result = await collection.insertOne(data);
      debugPrint('✅ Inserted document into $collectionName: ${result.id}');
      return result.id!.oid;
    } catch (e) {
      debugPrint('❌ Error inserting document into $collectionName: $e');
      rethrow;
    }
  }

  Future<void> updateOne(
    String collectionName,
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final collection = database.collection(collectionName);
      final updateData = <String, dynamic>{'\$set': data};
      await collection.updateOne(
        where.eq('_id', ObjectId.parse(id)),
        updateData,
      );
      debugPrint('✅ Updated document in $collectionName: $id');
    } catch (e) {
      debugPrint('❌ Error updating document in $collectionName: $e');
      rethrow;
    }
  }

  Future<void> deleteOne(String collectionName, String id) async {
    try {
      final collection = database.collection(collectionName);
      await collection.deleteOne(where.eq('_id', ObjectId.parse(id)));
      debugPrint('✅ Deleted document from $collectionName: $id');
    } catch (e) {
      debugPrint('❌ Error deleting document from $collectionName: $e');
      rethrow;
    }
  }

  Future<int> count(
    String collectionName, {
    Map<String, dynamic>? query,
  }) async {
    try {
      final collection = database.collection(collectionName);
      return await collection.count(query ?? {});
    } catch (e) {
      debugPrint('❌ Error counting documents in $collectionName: $e');
      return 0;
    }
  }
}
