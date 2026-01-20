import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../database/tables.dart';
import '../models/document.dart';

class DocumentRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Get all documents
  Future<List<Document>> getAllDocuments() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      Tables.documents,
      orderBy: '${Tables.documentUploadDate} DESC',
    );
    return List.generate(maps.length, (i) => Document.fromMap(maps[i]));
  }

  // Get documents by member
  Future<List<Document>> getDocumentsByMember(int memberId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      Tables.documents,
      where: '${Tables.documentMemberId} = ?',
      whereArgs: [memberId],
      orderBy: '${Tables.documentUploadDate} DESC',
    );
    return List.generate(maps.length, (i) => Document.fromMap(maps[i]));
  }

  // Get documents sorted alphabetically
  Future<List<Document>> getDocumentsAlphabetically() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      Tables.documents,
      orderBy: '${Tables.documentName} ASC',
    );
    return List.generate(maps.length, (i) => Document.fromMap(maps[i]));
  }

  // Get documents by member sorted alphabetically
  Future<List<Document>> getDocumentsByMemberAlphabetically(
    int memberId,
  ) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      Tables.documents,
      where: '${Tables.documentMemberId} = ?',
      whereArgs: [memberId],
      orderBy: '${Tables.documentName} ASC',
    );
    return List.generate(maps.length, (i) => Document.fromMap(maps[i]));
  }

  // Get document by ID
  Future<Document?> getDocumentById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      Tables.documents,
      where: '${Tables.documentId} = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return Document.fromMap(maps.first);
  }

  // Insert document
  Future<int> insertDocument(Document document) async {
    final db = await _dbHelper.database;
    return await db.insert(Tables.documents, document.toMap());
  }

  // Update document
  Future<bool> updateDocument(Document document) async {
    try {
      final db = await _dbHelper.database;
      final count = await db.update(
        Tables.documents,
        document.toMap(),
        where: '${Tables.documentId} = ?',
        whereArgs: [document.id],
      );
      return count > 0;
    } catch (e) {
      debugPrint('Error updating document: $e');
      return false;
    }
  }

  // Delete document
  Future<bool> deleteDocument(int id) async {
    try {
      final db = await _dbHelper.database;
      final count = await db.delete(
        Tables.documents,
        where: '${Tables.documentId} = ?',
        whereArgs: [id],
      );
      return count > 0;
    } catch (e) {
      debugPrint('Error deleting document: $e');
      return false;
    }
  }

  // Get document count
  Future<int> getDocumentCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM ${Tables.documents}',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Get document count by member
  Future<int> getDocumentCountByMember(int memberId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM ${Tables.documents} WHERE ${Tables.documentMemberId} = ?',
      [memberId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
