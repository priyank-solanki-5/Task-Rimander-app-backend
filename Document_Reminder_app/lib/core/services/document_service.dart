import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../models/document.dart';
import 'api_client.dart';

/// Document service wired to the backend API.
class DocumentService {
  final ApiClient _apiClient = ApiClient();

  /// Get documents for the current user. Backend derives user from token, but
  /// a userId query parameter is supported for clarity when available.
  Future<List<Document>> getDocuments({String? userId}) async {
    try {
      final response = await _apiClient.get(
        ApiConfig.documents,
        queryParameters: {if (userId != null) 'userId': userId},
      );

      final List<dynamic> data = response.data['data'] as List<dynamic>? ?? [];
      return data.map((json) => Document.fromJson(json)).toList();
    } catch (e) {
      debugPrint('❌ Error fetching documents: $e');
      rethrow;
    }
  }

  /// Upload a document for a task with progress tracking.
  Future<Map<String, dynamic>> uploadDocument({
    required String filePath,
    required String taskId,
    required String userId,
    Function(int, int)? onProgress,
  }) async {
    try {
      debugPrint('📁 Document upload initiated for task: $taskId');

      final response = await _apiClient.uploadFile(
        ApiConfig.documentsUpload,
        filePath,
        'document',
        data: {'taskId': taskId},
        onSendProgress: onProgress,
      );

      debugPrint('✅ Document uploaded successfully');
      return {
        'success': true,
        'message': response.data['message'] ?? 'Document uploaded successfully',
        'data': response.data['data'],
      };
    } catch (e) {
      debugPrint('❌ Error during document upload: $e');
      return {'success': false, 'message': 'Failed to upload document: $e'};
    }
  }

  /// Get documents for a specific task.
  Future<List<Document>> getDocumentsForTask(String taskId) async {
    try {
      final response = await _apiClient.get(ApiConfig.documentsForTask(taskId));

      final List<dynamic> data = response.data['data'] as List<dynamic>? ?? [];
      return data.map((json) => Document.fromJson(json)).toList();
    } catch (e) {
      debugPrint('❌ Error fetching documents for task: $e');
      rethrow;
    }
  }

  /// Download a document by id to the specified save path.
  Future<bool> downloadDocument(String documentId, String savePath) async {
    try {
      await _apiClient.downloadFile(
        ApiConfig.documentDownload(documentId),
        savePath,
      );
      debugPrint('✅ Document downloaded successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Error downloading document: $e');
      return false;
    }
  }

  /// Delete a document by id.
  Future<bool> deleteDocument(String documentId) async {
    try {
      await _apiClient.delete('${ApiConfig.documents}/$documentId');
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting document: $e');
      return false;
    }
  }
}
