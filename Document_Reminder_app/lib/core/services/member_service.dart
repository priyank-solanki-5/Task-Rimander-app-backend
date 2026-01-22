import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';
import '../models/member.dart';

class MemberService {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final Uuid _uuid = const Uuid();

  /// Get all members
  Future<List<Member>> getAllMembers() async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query('members');
      
      return List.generate(maps.length, (i) {
        return Member.fromJson(_mapFromDb(maps[i]));
      });
    } catch (e) {
      debugPrint('❌ Error getting all members: $e');
      return [];
    }
  }

  /// Get member by ID
  Future<Member?> getMemberById(String id) async {
    try {
      final map = await _dbHelper.queryById('members', 'id', id);
      if (map != null) {
        return Member.fromJson(_mapFromDb(map));
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
      final now = DateTime.now().toIso8601String();
      final String id = _uuid.v4();
      
      final newMember = member.copyWith(
        id: id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final map = newMember.toJson();
      map['_id'] = id; 
      var dbMap = _mapToDb(map);

      await _dbHelper.insert('members', dbMap);
      
      debugPrint('✅ Member created locally: $id');
      return newMember;
    } catch (e) {
      debugPrint('❌ Error creating member: $e');
      return null;
    }
  }

  /// Update an existing member
  Future<Member?> updateMember(String id, Member member) async {
    try {
      final now = DateTime.now().toIso8601String();
      final updatedMember = member.copyWith(
        updatedAt: DateTime.now(),
      );

      final map = updatedMember.toJson();
      var dbMap = _mapToDb(map);
      
      await _dbHelper.update('members', dbMap, 'id', id);
      
      debugPrint('✅ Member updated locally: $id');
      return updatedMember;
    } catch (e) {
      debugPrint('❌ Error updating member: $e');
      return null;
    }
  }

  /// Delete a member
  Future<bool> deleteMember(String id) async {
    try {
      final count = await _dbHelper.delete('members', 'id', id);
      return count > 0;
    } catch (e) {
      debugPrint('❌ Error deleting member: $e');
      return false;
    }
  }

  /// Get member count
  Future<int> getMemberCount() async {
    try {
      final db = await _dbHelper.database;
      return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM members')) ?? 0;
    } catch (e) {
      debugPrint('❌ Error getting member count: $e');
      return 0;
    }
  }

  /// Search members
  Future<List<Member>> searchMembers(String query) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'members',
        where: 'name LIKE ?',
        whereArgs: ['%$query%'],
      );
      
      return List.generate(maps.length, (i) {
        return Member.fromJson(_mapFromDb(maps[i]));
      });
    } catch (e) {
      debugPrint('❌ Error searching members: $e');
      return [];
    }
  }

  Map<String, dynamic> _mapFromDb(Map<String, dynamic> dbMap) {
    var map = Map<String, dynamic>.from(dbMap);
    if (map['id'] != null) {
      map['_id'] = map['id'];
    }
    return map;
  }
  
  Map<String, dynamic> _mapToDb(Map<String, dynamic> jsonMap) {
    var map = Map<String, dynamic>.from(jsonMap);
    if (map['_id'] != null) {
      map['id'] = map['_id'];
      map.remove('_id');
    }
    return map;
  }
}
