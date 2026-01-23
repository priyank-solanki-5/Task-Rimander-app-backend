import '../models/member.dart';

class MemberService {
  // Placeholder service since there is no Member API yet

  /// Get all members
  Future<List<Member>> getAllMembers() async {
    // Return empty list immediately
    return [];
  }

  /// Get member by ID
  Future<Member?> getMemberById(String id) async {
    return null;
  }

  /// Create a new member
  Future<Member?> createMember(Member member) async {
    return member;
  }

  /// Update an existing member
  Future<Member?> updateMember(String id, Member member) async {
    return member;
  }

  /// Delete a member
  Future<bool> deleteMember(String id) async {
    return true;
  }

  /// Get member count
  Future<int> getMemberCount() async {
    return 0;
  }

  /// Search members
  Future<List<Member>> searchMembers(String query) async {
    return [];
  }
}
