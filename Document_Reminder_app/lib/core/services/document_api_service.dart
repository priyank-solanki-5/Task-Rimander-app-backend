import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../models/document.dart';
import '../utils/api_exception.dart';
import 'api_client.dart';

class DocumentApiService {
  final ApiClient _apiClient = ApiClient();

  /// Get all documents
  Future<List<Document>> getDocuments({String? userId}) async {
    try {
      final response = await _apiClient.get(
        ApiConfig.documents,
        queryParameters: {if (userId != null) 'userId': userId},
      );
      final List<dynamic> data = response.data['data'] as List<dynamic>;
      return data.map((json) => Document.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch documents: $e');
    }
  }

  /// Get document by ID
  Future<Document?> getDocumentById(String documentId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConfig.documents}/$documentId',
      );
      return Document.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to fetch document: $e');
    }
  }

  /// Upload a document
  Future<Map<String, dynamic>> uploadDocument({
    String? filePath,
    List<int>? fileBytes,
    String? fileName,
    String? taskId,
    String? memberId,
    required String userId, // Kept for consistency but not sent in body
    void Function(int, int)? onProgress,
  }) async {
    try {
      // Prepare form data
      // Note: userId is inferred from token by backend, so we don't send it in body
      final Map<String, dynamic> data = {};

      if (taskId != null) data['taskId'] = taskId;
      if (memberId != null && memberId != 'myself') data['memberId'] = memberId;

      /*
       * Call ApiClient's uploadFile method.
       */
      final response = await _apiClient.uploadFile(
        ApiConfig.documentsUpload,
        filePath,
        'document', // Field name for the file
        fileBytes: fileBytes,
        fileName: fileName,
        data: data,
        onSendProgress: onProgress,
      );

      return {'success': true, 'data': response.data};
    } on ApiException {
      // If it's an API exception, rethrow it so provider can handle message
      rethrow;
    } catch (e) {
      if (e is DioException) {
        debugPrint('Upload error response: ${e.response?.data}');
        debugPrint('Upload error status: ${e.response?.statusCode}');
      }
      throw Exception('Failed to upload document: $e');
    }
  }

  /// Download a document
  Future<bool> downloadDocument(String documentId, String savePath) async {
    try {
      await _apiClient.downloadFile(
        '${ApiConfig.documents}/$documentId/download',
        savePath,
      );
      return true;
    } catch (e) {
      throw Exception('Failed to download document: $e');
    }
  }

  /// Delete a document
  Future<bool> deleteDocument(String documentId) async {
    try {
      await _apiClient.delete('${ApiConfig.documents}/$documentId');
      return true;
    } catch (e) {
      throw Exception('Failed to delete document: $e');
    }
  }
}
