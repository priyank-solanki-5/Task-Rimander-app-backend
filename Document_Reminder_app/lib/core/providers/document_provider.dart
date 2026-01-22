import 'package:flutter/foundation.dart';
import '../models/document.dart';
import '../services/document_service.dart';

enum SortType { alphabetical, uploadDate }

class DocumentProvider extends ChangeNotifier {
  final DocumentService _documentService = DocumentService();

  List<Document> _documents = [];
  String? _selectedTaskId;
  SortType _sortType = SortType.uploadDate;
  bool _isLoading = false;
  String? _errorMessage;

  List<Document> get documents => _documents;
  String? get selectedTaskId => _selectedTaskId;
  SortType get sortType => _sortType;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Get filtered and sorted documents
  List<Document> get filteredDocuments {
    List<Document> filtered = _documents;

    // Filter by task if selected
    if (_selectedTaskId != null) {
      filtered =
          filtered.where((doc) => doc.taskId == _selectedTaskId).toList();
    }

    // Sort
    if (_sortType == SortType.alphabetical) {
      filtered.sort(
        (a, b) =>
            a.originalName.toLowerCase().compareTo(b.originalName.toLowerCase()),
      );
    } else {
      // Sort by creation date (newest first)
      filtered.sort((a, b) {
        if (a.createdAt == null && b.createdAt == null) return 0;
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return b.createdAt!.compareTo(a.createdAt!);
      });
    }

    return filtered;
  }

  // Set task filter
  void setTaskFilter(String? taskId) {
    _selectedTaskId = taskId;
    notifyListeners();
  }

  // Set sort type
  void setSortType(SortType type) {
    _sortType = type;
    notifyListeners();
  }

  // Load all documents from API
  Future<void> loadDocuments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _documents = await _documentService.getAllDocuments();
      debugPrint('✅ Loaded ${_documents.length} documents from local DB');
    } catch (e) {
      _errorMessage = 'Failed to load documents: $e';
      debugPrint('❌ Error loading documents: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load documents by task
  Future<void> loadDocumentsByTask(String taskId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _documents = await _documentService.getDocumentsByTask(taskId);
      _selectedTaskId = taskId;
      debugPrint('✅ Loaded ${_documents.length} documents for task $taskId');
    } catch (e) {
      _errorMessage = 'Failed to load documents: $e';
      debugPrint('❌ Error loading documents by task: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Upload document
  Future<Document?> uploadDocument({
    required String filePath,
    required String taskId,
    void Function(int, int)? onProgress,
  }) async {
    try {
      final document = await _documentService.uploadDocument(
        filePath: filePath,
        taskId: taskId,
        onProgress: onProgress,
      );

      if (document != null) {
        _documents.add(document);
        notifyListeners();
        debugPrint('✅ Document uploaded successfully: ${document.id}');
        return document;
      }
      return null;
    } catch (e) {
      _errorMessage = 'Failed to upload document: $e';
      debugPrint('❌ Error uploading document: $e');
      return null;
    }
  }

  // Download document
  Future<bool> downloadDocument({
    required String documentId,
    required String savePath,
    void Function(int, int)? onProgress,
  }) async {
    try {
      final success = await _documentService.downloadDocument(
        documentId: documentId,
        savePath: savePath,
        onProgress: onProgress,
      );

      if (success) {
        debugPrint('✅ Document downloaded successfully');
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Failed to download document: $e';
      debugPrint('❌ Error downloading document: $e');
      return false;
    }
  }

  // Delete document
  Future<bool> deleteDocument(String id) async {
    try {
      final success = await _documentService.deleteDocument(id);
      if (success) {
        _documents.removeWhere((d) => d.id == id);
        notifyListeners();
        debugPrint('✅ Document deleted successfully');
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Failed to delete document: $e';
      debugPrint('❌ Error deleting document: $e');
      return false;
    }
  }

  // Get document count
  int getDocumentCount() {
    return _documents.length;
  }

  // Refresh documents
  Future<void> refreshDocuments() async {
    await loadDocuments();
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Member filter support (for backward compatibility)
  String? _selectedMemberId;
  
  String? get selectedMemberId => _selectedMemberId;

  void setMemberFilter(String? memberId) {
    _selectedMemberId = memberId;
    notifyListeners();
  }

  // Get member name (placeholder - returns empty string as member data is not in document provider)
  String getMemberName(String? memberId) {
    // This is a placeholder. In a real implementation, you'd fetch member data
    // from a MemberProvider or API service
    return '';
  }

  // Add document (alias for uploadDocument for backward compatibility)
  Future<Document?> addDocument(Document document) async {
    // Since we need to upload a file, this is a simplified version
    // In practice, you'd need the file path from the document
    try {
      _documents.add(document);
      notifyListeners();
      debugPrint('✅ Document added: ${document.id}');
      return document;
    } catch (e) {
      _errorMessage = 'Failed to add document: $e';
      debugPrint('❌ Error adding document: $e');
      return null;
    }
  }
}
