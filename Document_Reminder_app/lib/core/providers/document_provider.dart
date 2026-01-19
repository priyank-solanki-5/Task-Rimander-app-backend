import 'package:flutter/foundation.dart';
import '../models/document.dart';
import '../models/member.dart';
import '../repositories/document_repository.dart';
import '../repositories/member_repository.dart';

enum SortType { alphabetical, uploadDate }

class DocumentProvider extends ChangeNotifier {
  final DocumentRepository _documentRepository = DocumentRepository();
  final MemberRepository _memberRepository = MemberRepository();

  List<Document> _documents = [];
  Map<int, Member> _membersCache = {};
  int? _selectedMemberId;
  SortType _sortType = SortType.uploadDate;
  bool _isLoading = false;

  List<Document> get documents => _documents;
  int? get selectedMemberId => _selectedMemberId;
  SortType get sortType => _sortType;
  bool get isLoading => _isLoading;

  // Get filtered and sorted documents
  List<Document> get filteredDocuments {
    List<Document> filtered = _documents;

    // Filter by member if selected
    if (_selectedMemberId != null) {
      filtered = filtered.where((doc) => doc.memberId == _selectedMemberId).toList();
    }

    // Sort
    if (_sortType == SortType.alphabetical) {
      filtered.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    } else {
      filtered.sort((a, b) => b.uploadDate.compareTo(a.uploadDate));
    }

    return filtered;
  }

  // Get member name by ID from cache
  String getMemberName(int memberId) {
    return _membersCache[memberId]?.name ?? 'Unknown';
  }

  // Get all members for dropdown
  List<Member> get members => _membersCache.values.toList();

  // Set member filter
  void setMemberFilter(int? memberId) {
    _selectedMemberId = memberId;
    notifyListeners();
  }

  // Set sort type
  void setSortType(SortType type) {
    _sortType = type;
    notifyListeners();
  }

  // Load all documents
  Future<void> loadDocuments() async {
    _isLoading = true;
    notifyListeners();

    try {
      _documents = await _documentRepository.getAllDocuments();
      
      // Load members for cache
      final members = await _memberRepository.getAllMembers();
      _membersCache = {for (var member in members) member.id!: member};
      
      print('Loaded ${_documents.length} documents');
    } catch (e) {
      print('Error loading documents: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add document
  Future<int?> addDocument(Document document) async {
    try {
      final id = await _documentRepository.insertDocument(document);
      if (id != null) {
        // Reload all documents to get fresh data
        await loadDocuments();
        print('Document added successfully with ID: $id');
      }
      return id;
    } catch (e) {
      print('Error adding document: $e');
      return null;
    }
  }

  Future<bool> updateDocument(Document document) async {
    try {
      final success = await _documentRepository.updateDocument(document);
      if (success) {
        // Reload all documents
        await loadDocuments();
        print('Document updated successfully');
      }
      return success;
    } catch (e) {
      print('Error updating document: $e');
      return false;
    }
  }

  Future<bool> deleteDocument(int id) async {
    try {
      final success = await _documentRepository.deleteDocument(id);
      if (success) {
        // Reload all documents
        await loadDocuments();
        print('Document deleted successfully');
      }
      return success;
    } catch (e) {
      print('Error deleting document: $e');
      return false;
    }
  }
  // Get document count
  Future<int> getDocumentCount() async {
    try {
      return await _documentRepository.getDocumentCount();
    } catch (e) {
      print('Error getting document count: $e');
      return 0;
    }
  }

  // Refresh documents
  Future<void> refreshDocuments() async {
    await loadDocuments();
  }
}
