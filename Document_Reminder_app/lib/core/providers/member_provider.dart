import 'package:flutter/foundation.dart';
import '../models/member.dart';
import '../repositories/member_repository.dart';

class MemberProvider extends ChangeNotifier {
  final MemberRepository _memberRepository = MemberRepository();

  List<Member> _members = [];
  bool _isLoading = false;

  List<Member> get members => _members;
  bool get isLoading => _isLoading;

  // Load all members
  Future<void> loadMembers() async {
    _isLoading = true;
    notifyListeners();

    try {
      _members = await _memberRepository.getAllMembers();
      print('Loaded ${_members.length} members');
    } catch (e) {
      print('Error loading members: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get member by ID
  Member? getMemberById(int id) {
    try {
      return _members.firstWhere((member) => member.id == id);
    } catch (e) {
      return null;
    }
  }

  // Add member
  Future<int?> addMember(Member member) async {
    try {
      final id = await _memberRepository.insertMember(member);
      if (id != null) {
        // Reload all members to get fresh data
        await loadMembers();
        print('Member added successfully with ID: $id');
      }
      return id;
    } catch (e) {
      print('Error adding member: $e');
      return null;
    }
  }

  // Update member
  Future<bool> updateMember(Member member) async {
    try {
      final success = await _memberRepository.updateMember(member);
      if (success) {
        // Reload all members
        await loadMembers();
        print('Member updated successfully');
      }
      return success;
    } catch (e) {
      print('Error updating member: $e');
      return false;
    }
  }

  // Delete member
  Future<bool> deleteMember(int id) async {
    try {
      final success = await _memberRepository.deleteMember(id);
      if (success) {
        // Reload all members
        await loadMembers();
        print('Member deleted successfully');
      }
      return success;
    } catch (e) {
      print('Error deleting member: $e');
      return false;
    }
  }

  // Get member count
  Future<int> getMemberCount() async {
    try {
      return await _memberRepository.getMemberCount();
    } catch (e) {
      print('Error getting member count: $e');
      return 0;
    }
  }

  // Search members
  Future<List<Member>> searchMembers(String query) async {
    try {
      return await _memberRepository.searchMembers(query);
    } catch (e) {
      print('Error searching members: $e');
      return [];
    }
  }

  // Refresh members
  Future<void> refreshMembers() async {
    await loadMembers();
  }
}
