import '../config/api_config.dart';
import '../models/member.dart';
import 'api_client.dart';

class MemberApiService {
  final ApiClient _apiClient = ApiClient();

  /// Get all members
  Future<List<Member>> getAllMembers() async {
    try {
      final response = await _apiClient.get(ApiConfig.members);
      final List<dynamic> data = response.data['data'] as List<dynamic>;
      return data.map((json) => Member.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch members: $e');
    }
  }

  /// Get member by ID
  Future<Member?> getMemberById(String memberId) async {
    try {
      final response = await _apiClient.get('${ApiConfig.members}/$memberId');
      return Member.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to fetch member: $e');
    }
  }

  /// Create a new member
  Future<Member?> createMember(Member member) async {
    try {
      final response = await _apiClient.post(
        ApiConfig.members,
        data: member.toJson(),
      );
      return Member.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to create member: $e');
    }
  }

  /// Update a member
  Future<Member?> updateMember(String memberId, Member member) async {
    try {
      final response = await _apiClient.put(
        '${ApiConfig.members}/$memberId',
        data: member.toJson(),
      );
      return Member.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to update member: $e');
    }
  }

  /// Delete a member
  Future<bool> deleteMember(String memberId) async {
    try {
      await _apiClient.delete('${ApiConfig.members}/$memberId');
      return true;
    } catch (e) {
      throw Exception('Failed to delete member: $e');
    }
  }

  /// Search members
  Future<List<Member>> searchMembers(String query) async {
    try {
      final response = await _apiClient.get(
        ApiConfig
            .members, // Assuming search uses same endpoint with scalar params or specific search endpoint
        queryParameters: {'q': query},
      );
      final List<dynamic> data = response.data['data'] as List<dynamic>;
      return data.map((json) => Member.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search members: $e');
    }
  }

  /// Get member count
  Future<int> getMemberCount() async {
    try {
      final response = await _apiClient.get(ApiConfig.members);
      final List<dynamic> data = response.data['data'] as List<dynamic>;
      return data.length;
    } catch (e) {
      return 0;
    }
  }
}
