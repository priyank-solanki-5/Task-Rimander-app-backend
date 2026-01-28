import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../models/document.dart';
import '../services/document_api_service.dart';

enum SortType { alphabetical, uploadDate }

class DocumentProvider extends ChangeNotifier {
  final DocumentApiService _documentService = DocumentApiService();

  List<Document> _documents = [];
  String? _selectedTaskId;
  String? _selectedMemberId = 'myself'; // Default to "Myself"
  SortType _sortType = SortType.uploadDate;
  bool _isLoading = false;
  String? _errorMessage;

  List<Document> get documents => _documents;
  String? get selectedTaskId => _selectedTaskId;
  String? get selectedMemberId => _selectedMemberId;
  SortType get sortType => _sortType;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Get filtered and sorted documents
  List<Document> get filteredDocuments {
    List<Document> filtered = _documents;

    // Filter by task if selected (overrides member filter usually, or works in tandem)
    if (_selectedTaskId != null) {
      filtered = filtered
          .where((doc) => doc.taskId == _selectedTaskId)
          .toList();
    } else {
      // Filter by Member (only if task not selected)
      if (_selectedMemberId == 'myself') {
        // Show docs where memberId is NULL (meaning it belongs to the user strictly, or unassigned)
        filtered = filtered.where((doc) => doc.memberId == null).toList();
      } else if (_selectedMemberId != null && _selectedMemberId != 'all') {
        // Show docs for specific member
        filtered = filtered
            .where((doc) => doc.memberId == _selectedMemberId)
            .toList();
      }
      // If 'all', do nothing (show all)
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

  // Set member filter
  void setMemberFilter(String? memberId) {
    _selectedMemberId = memberId;
    _selectedTaskId = null; // Clear task filter when filtering by member
    notifyListeners();
  }

  // Set sort type
  void setSortType(SortType type) {
    _sortType = type;
    notifyListeners();
  }

  // Load all documents from API
  Future<void> loadDocuments({bool forceRefresh = false}) async {
    if (_documents.isNotEmpty && !forceRefresh) {
      // Ensure we reset filters if we are just reloading/entering the screen
      _selectedTaskId = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    _selectedTaskId = null; // Reset task filter when loading all docs
    notifyListeners();

    try {
      _documents = await _documentService.getDocuments();
      debugPrint('✅ Loaded ${_documents.length} documents');
    } catch (e) {
      _errorMessage = 'Failed to load documents: $e';
      debugPrint('❌ Error loading documents: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load documents for a specific user (current logged-in user on dashboard)
  Future<void> loadDocumentsForUser(
    String userId, {
    bool forceRefresh = false,
  }) async {
    if (_documents.isNotEmpty && !forceRefresh) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _documents = await _documentService.getDocuments(userId: userId);
      debugPrint('✅ Loaded ${_documents.length} documents for user $userId');
    } catch (e) {
      _errorMessage = 'Failed to load documents: $e';
      debugPrint('❌ Error loading documents for user: $e');
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

  // View Document (Download to Temp & Open)
  Future<void> viewDocument(Document document) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Get Temp Directory
      final tempDir = await getTemporaryDirectory();

      // 2. Construct path (Overwrite strategy: Always use same filename base)
      // We keep the extension so the OS knows what app to open.
      final extension = document.fileExtension.toLowerCase();
      final filePath = '${tempDir.path}/temp_view_file.$extension';
      final file = File(filePath);

      // 3. Delete old file if exists (to be sure of overwrite)
      if (await file.exists()) {
        await file.delete();
      }

      // 4. Download content
      debugPrint('📥 Downloading document to temp: $filePath');
      final success = await _documentService.downloadDocument(
        document.id!,
        filePath,
      );

      _isLoading = false;
      notifyListeners();

      if (success) {
        // 5. Open with external app
        debugPrint('👀 Opening document...');
        final result = await OpenFile.open(filePath);
        if (result.type != ResultType.done) {
          _errorMessage = 'Could not open file: ${result.message}';
          notifyListeners();
        }
      } else {
        _errorMessage = 'Failed to download document for viewing';
        notifyListeners();
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error opening document: $e';
      notifyListeners();
      debugPrint('❌ Error viewing document: $e');
    }
  }

  // Upload document
  Future<bool> uploadDocument({
    String? filePath,
    List<int>? fileBytes,
    String? fileName,
    String? taskId,
    String? memberId,
    required String userId,
    void Function(int, int)? onProgress,
  }) async {
    try {
      final result = await _documentService.uploadDocument(
        filePath: filePath,
        fileBytes: fileBytes,
        fileName: fileName,
        taskId: taskId,
        memberId: memberId,
        userId: userId,
        onProgress: onProgress,
      );

      if (result['success']) {
        try {
          // Parse the new document from the response and add it to the list
          final newDocData = result['data']['data'];
          if (newDocData != null) {
            final newDoc = Document.fromJson(newDocData);
            _documents.insert(0, newDoc); // Add to top of list
            notifyListeners();
          }
        } catch (e) {
          debugPrint('⚠️ Error parsing new document response: $e');
          // Still return true as upload was successful, just UI update failed
          // Optionally trigger a full reload here as fallback
          loadDocuments(forceRefresh: true);
        }

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

  // Get document count
  int getDocumentCount() {
    return _documents.length;
  }
}
