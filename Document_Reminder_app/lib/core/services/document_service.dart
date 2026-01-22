import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';
import '../models/document.dart';

class DocumentService {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final Uuid _uuid = const Uuid();

  /// Upload document (copy to local storage and save metadata)
  Future<Document?> uploadDocument({
    required String filePath,
    required String taskId,
    Function(int, int)? onProgress, // Progress not really relevant for local copy, but keeping signature
  }) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        debugPrint('❌ File does not exist: $filePath');
        return null;
      }

      // Simulate progress
      if (onProgress != null) onProgress(100, 100);

      final filename = path.basename(filePath);
      final fileSize = await file.length();
      
      // Get app directory to save file
      final appDir = await getApplicationDocumentsDirectory();
      final docsDir = Directory(path.join(appDir.path, 'documents'));
      if (!await docsDir.exists()) {
        await docsDir.create(recursive: true);
      }

      // Generate unique filename to avoid collisions
      final String id = _uuid.v4();
      final String uniqueFilename = '${id}_$filename';
      final String savedPath = path.join(docsDir.path, uniqueFilename);
      
      // Copy file
      await file.copy(savedPath);
      debugPrint('📂 File copied to: $savedPath');

      final now = DateTime.now().toIso8601String();
      
      // Create Document model
      // We need a userId. Assuming we can get it or use placeholder.
      const userId = 'local_user'; // TODO: Get actual userId from TokenStorage
      
      final newDoc = Document(
        id: id,
        filename: uniqueFilename, // Stored name
        originalName: filename,   // Display name
        filePath: savedPath,
        fileSize: fileSize,
        mimeType: _getMimeType(filename), // Helper or dependency
        userId: userId,
        taskId: taskId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final map = newDoc.toJson();
      // Adjust map for DB
      map['_id'] = id; 
      var dbMap = _mapToDb(map);

      await _dbHelper.insert('documents', dbMap);
      
      debugPrint('✅ Document saved locally: $id');
      return newDoc;

    } catch (e) {
      debugPrint('❌ Error uploading document: $e');
      return null;
    }
  }

  /// Get all documents (conceptually for the user)
  Future<List<Document>> getAllDocuments() async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query('documents');
      
      return List.generate(maps.length, (i) {
        return Document.fromJson(_mapFromDb(maps[i]));
      });
    } catch (e) {
      debugPrint('❌ Error getting all documents: $e');
      return [];
    }
  }

  /// Get documents by task ID
  Future<List<Document>> getDocumentsByTask(String taskId) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'documents',
        where: 'taskId = ?',
        whereArgs: [taskId],
      );
      
      return List.generate(maps.length, (i) {
        return Document.fromJson(_mapFromDb(maps[i]));
      });
    } catch (e) {
      debugPrint('❌ Error getting documents by task: $e');
      return [];
    }
  }

  /// Get document by ID
  Future<Document?> getDocumentById(String id) async {
    try {
      final map = await _dbHelper.queryById('documents', 'id', id);
      if (map != null) {
        return Document.fromJson(_mapFromDb(map));
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting document by ID: $e');
      return null;
    }
  }

  /// Download document (copy from local storage to specified path)
  Future<bool> downloadDocument({
    required String documentId,
    required String savePath,
    Function(int, int)? onProgress,
  }) async {
    try {
      final doc = await getDocumentById(documentId);
      if (doc == null) return false;

      final sourceFile = File(doc.filePath);
      if (!await sourceFile.exists()) {
        debugPrint('❌ Source file not found: ${doc.filePath}');
        return false;
      }

      await sourceFile.copy(savePath);
      if (onProgress != null) onProgress(100, 100);
      
      debugPrint('✅ File downloaded (copied) to: $savePath');
      return true;
    } catch (e) {
      debugPrint('❌ Error downloading document: $e');
      return false;
    }
  }

  /// Delete document
  Future<bool> deleteDocument(String id) async {
    try {
      final doc = await getDocumentById(id);
      if (doc != null) {
        // Delete physical file
        final file = File(doc.filePath);
        if (await file.exists()) {
          await file.delete();
        }
      }

      final count = await _dbHelper.delete('documents', 'id', id);
      return count > 0;
    } catch (e) {
      debugPrint('❌ Error deleting document: $e');
      return false;
    }
  }

  // Helper
  String _getMimeType(String filename) {
    // Basic mime type guessing based on extension
    final ext = path.extension(filename).toLowerCase();
    switch (ext) {
      case '.pdf': return 'application/pdf';
      case '.jpg':
      case '.jpeg': return 'image/jpeg';
      case '.png': return 'image/png';
      case '.txt': return 'text/plain';
      default: return 'application/octet-stream';
    }
  }

  Map<String, dynamic> _mapFromDb(Map<String, dynamic> dbMap) {
    var map = Map<String, dynamic>.from(dbMap);
    if (map['id'] != null) {
      map['_id'] = map['id'];
    }
    return map;
  }
  
  Map<String, dynamic> _mapToDb(Map<String, dynamic> jsonMap) {
    var map = Map<String, dynamic>.from(jsonMap);
    if (map['_id'] != null) {
      map['id'] = map['_id'];
      map.remove('_id');
    }
    return map;
  }
}
