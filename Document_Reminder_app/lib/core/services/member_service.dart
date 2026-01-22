import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/member.dart';
import 'mongo_service.dart';

class MemberService {
  final MongoService _mongoService = MongoService();
  final Uuid _uuid = const Uuid();

  /// Get all members
  Future<List<Member>> getAllMembers() async {
    try {
      final List<Map<String, dynamic>> maps = await _mongoService.findAll('members');
      
      return maps.map((map) => Member.fromJson(map)).toList();
    } catch (e) {
      debugPrint('❌ Error getting all members: $e');
      return [];
    }
  }

  /// Get member by ID
  Future<Member?> getMemberById(String id) async {
    try {
      final map = await _mongoService.findById('members', id);
      if (map != null) {
        return Member.fromJson(map);
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
      final newMember = member.copyWith(
        id: _uuid.v4(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final map = newMember.toJson();
      map.remove('_id'); // Remove _id as MongoDB will generate it
      
      final memberId = await _mongoService.insertOne('members', map);
      
      debugPrint('✅ Member created: $memberId');
      return newMember.copyWith(id: memberId);
    } catch (e) {
      debugPrint('❌ Error creating member: $e');
      return null;
    }
  }

  /// Update an existing member
  Future<Member?> updateMember(String id, Member member) async {
    try {
      final updatedMember = member.copyWith(
        updatedAt: DateTime.now(),
      );

      final map = updatedMember.toJson();
      map.remove('_id'); // Remove _id as it shouldn't be updated
      
      await _mongoService.updateOne('members', id, map);
      
      debugPrint('✅ Member updated: $id');
      return updatedMember.copyWith(id: id);
    } catch (e) {
      debugPrint('❌ Error updating member: $e');
      return null;
    }
  }

  /// Delete a member
  Future<bool> deleteMember(String id) async {
    try {
      await _mongoService.deleteOne('members', id);
      debugPrint('✅ Member deleted: $id');
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting member: $e');
      return false;
    }
  }

  /// Get member count
  Future<int> getMemberCount() async {
    try {
      return await _mongoService.count('members');
    } catch (e) {
      debugPrint('❌ Error getting member count: $e');
      return 0;
    }
  }

  /// Search members
  Future<List<Member>> searchMembers(String query) async {
    try {
      final searchQuery = {
        'name': {'\$regex': query, '\$options': 'i'}
      };
      
      final List<Map<String, dynamic>> maps = await _mongoService.findAll(
        'members',
        query: searchQuery,
      );
      
      return maps.map((map) => Member.fromJson(map)).toList();
    } catch (e) {
      debugPrint('❌ Error searching members: $e');
      return [];
    }
  }
}
