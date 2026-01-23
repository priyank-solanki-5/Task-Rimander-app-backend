import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../models/member.dart';
import 'api_client.dart';

class MemberService {
  final ApiClient _apiClient = ApiClient();

  /// Get all members
  Future<List<Member>> getAllMembers() async {
    try {
      final response = await _apiClient.get(ApiConfig.members);

      if (response.data['success'] == true && response.data['data'] != null) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => Member.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('❌ Error getting all members: $e');
      return [];
    }
  }

  /// Get member by ID
  Future<Member?> getMemberById(String id) async {
    try {
      final response = await _apiClient.get(ApiConfig.memberById(id));

      if (response.data['success'] == true && response.data['data'] != null) {
        return Member.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting member by ID: $e');
      return null;
    }
  }

  /// Create a new member
  Future<Member?> createMember(Member member) async {
    try {
      final response = await _apiClient.post(
        ApiConfig.members,
        data: member.toJson(),
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return Member.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error creating member: $e');
      return null;
    }
  }

  /// Update an existing member
  Future<Member?> updateMember(String id, Member member) async {
    try {
      final response = await _apiClient.put(
        ApiConfig.memberById(id),
        data: member.toJson(),
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return Member.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error updating member: $e');
      return null;
    }
  }

  /// Delete a member
  Future<bool> deleteMember(String id) async {
    try {
      final response = await _apiClient.delete(ApiConfig.memberById(id));
      return response.data['success'] == true;
    } catch (e) {
      debugPrint('❌ Error deleting member: $e');
      return false;
    }
  }

  /// Get member count
  Future<int> getMemberCount() async {
    try {
      // Use the stats endpoint for efficiency
      try {
        final response = await _apiClient.get(ApiConfig.memberStats);
        if (response.data['success'] == true && response.data['data'] != null) {
          // If totalMembers is available in stats
          if (response.data['data']['totalMembers'] != null) {
            return response.data['data']['totalMembers'] as int;
          }
          // Some backends might return it differently, checking response structure would be ideal
          // But for now fall back to list logic if key implies something else
        }
      } catch (e) {
        debugPrint('⚠️ Stats endpoint failed, falling back to list count: $e');
      }

      // Fallback: Get all members and count
      final members = await getAllMembers();
      return members.length;
    } catch (e) {
      debugPrint('❌ Error getting member count: $e');
      return 0;
    }
  }

  /// Search members
  Future<List<Member>> searchMembers(String query) async {
    try {
      final response = await _apiClient.get(
        ApiConfig.searchMembers,
        queryParameters: {'q': query},
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => Member.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('❌ Error searching members: $e');
      return [];
    }
  }
}
