import 'package:flutter/foundation.dart';
import '../models/member.dart';
import '../services/member_service.dart';

class MemberProvider extends ChangeNotifier {
  final MemberService _memberService = MemberService();

  List<Member> _members = [];
  bool _isLoading = false;

  List<Member> get members => _members;
  bool get isLoading => _isLoading;

  // Load all members
  Future<void> loadMembers({bool forceRefresh = false}) async {
    if (_members.isNotEmpty && !forceRefresh) return;

    _isLoading = true;
    notifyListeners();

    try {
      _members = await _memberService.getAllMembers();
      debugPrint('Loaded ${_members.length} members');
    } catch (e) {
      debugPrint('Error loading members: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get member by ID
  Member? getMemberById(String id) {
    try {
      return _members.firstWhere((member) => member.id == id);
    } catch (e) {
      return null;
    }
  }

  // Add member
  Future<String?> addMember(Member member) async {
    try {
      final createdMember = await _memberService.createMember(member);
      if (createdMember != null) {
        // Reload all members to get fresh data
        await loadMembers(forceRefresh: true);
        debugPrint('Member added successfully with ID: ${createdMember.id}');
        return createdMember.id;
      }
      return null;
    } catch (e) {
      debugPrint('Error adding member: $e');
      return null;
    }
  }

  // Update member
  Future<bool> updateMember(Member member) async {
    try {
      if (member.id == null) return false;
      final updatedMember = await _memberService.updateMember(
        member.id!,
        member,
      );
      if (updatedMember != null) {
        // Reload all members
        await loadMembers(forceRefresh: true);
        debugPrint('Member updated successfully');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating member: $e');
      return false;
    }
  }

  // Delete member
  Future<bool> deleteMember(String id) async {
    try {
      final success = await _memberService.deleteMember(id);
      if (success) {
        // Reload all members
        await loadMembers(forceRefresh: true);
        debugPrint('Member deleted successfully');
      }
      return success;
    } catch (e) {
      debugPrint('Error deleting member: $e');
      return false;
    }
  }

  // Get member count
  Future<int> getMemberCount() async {
    try {
      return await _memberService.getMemberCount();
    } catch (e) {
      debugPrint('Error getting member count: $e');
      return 0;
    }
  }

  // Search members
  Future<List<Member>> searchMembers(String query) async {
    try {
      return await _memberService.searchMembers(query);
    } catch (e) {
      debugPrint('Error searching members: $e');
      return [];
    }
  }

  // Get member name by ID
  String getMemberName(String? memberId) {
    if (memberId == null) return 'Unknown';
    try {
      final member = _members.firstWhere((member) => member.id == memberId);
      return member.name;
    } catch (e) {
      return 'Unknown';
    }
  }

  // Refresh members
  Future<void> refreshMembers() async {
    await loadMembers();
  }
}
