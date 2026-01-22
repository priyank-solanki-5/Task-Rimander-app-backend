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
      filtered = filtered
          .where((doc) => doc.taskId == _selectedTaskId)
          .toList();
    }

    // Sort
    if (_sortType == SortType.alphabetical) {
      filtered.sort(
        (a, b) => a.originalName.toLowerCase().compareTo(
          b.originalName.toLowerCase(),
        ),
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
      debugPrint('📂 Documents are managed through API services');
      // Documents will be loaded through API calls in task screens
      _documents = [];
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
      debugPrint('📂 Loading documents for task through API: $taskId');
      // Documents will be loaded through API services in task detail screen
      _selectedTaskId = taskId;
      _documents = [];
    } catch (e) {
      _errorMessage = 'Failed to load documents: $e';
      debugPrint('❌ Error loading documents by task: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Upload document
  Future<bool> uploadDocument({
    required String filePath,
    required String taskId,
    required String userId,
    void Function(int, int)? onProgress,
  }) async {
    try {
      final result = await _documentService.uploadDocument(
        filePath: filePath,
        taskId: taskId,
        userId: userId,
        onProgress: onProgress,
      );

      if (result['success']) {
        notifyListeners();
        debugPrint('✅ Document uploaded successfully');
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Failed to upload document: $e';
      debugPrint('❌ Error uploading document: $e');
      return false;
    }
  }

  // Delete document
  Future<bool> deleteDocument(String documentId) async {
    try {
      final success = await _documentService.deleteDocument(documentId);

      if (success) {
        _documents.removeWhere((doc) => doc.id == documentId);
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

  // Get member name (placeholder - returns empty string)
  String getMemberName(String? memberId) {
    return '';
  }

  // Get document count
  int getDocumentCount() {
    return _documents.length;
  }
}
