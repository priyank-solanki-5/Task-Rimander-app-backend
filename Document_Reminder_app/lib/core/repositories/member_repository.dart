import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../database/tables.dart';
import '../models/member.dart';

class MemberRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Get all members
  Future<List<Member>> getAllMembers() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      Tables.members,
      orderBy: '${Tables.memberName} ASC',
    );
    return List.generate(maps.length, (i) => Member.fromMap(maps[i]));
  }

  // Get member by ID
  Future<Member?> getMemberById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      Tables.members,
      where: '${Tables.memberId} = ?',
      whereArgs: [id],
    );
    
    if (maps.isEmpty) return null;
    return Member.fromMap(maps.first);
  }

  // Insert member
  Future<int> insertMember(Member member) async {
    final db = await _dbHelper.database;
    return await db.insert(Tables.members, member.toMap());
  }

  // Update member
  Future<bool> updateMember(Member member) async {
    try {
      final db = await _dbHelper.database;
      final count = await db.update(
        Tables.members,
        member.toMap(),
        where: '${Tables.memberId} = ?',
        whereArgs: [member.id],
      );
      return count > 0;
    } catch (e) {
      print('Error updating member: $e');
      return false;
    }
  }

  // Delete member (will cascade delete documents and tasks)
  Future<bool> deleteMember(int id) async {
    try {
      final db = await _dbHelper.database;
      final count = await db.delete(
        Tables.members,
        where: '${Tables.memberId} = ?',
        whereArgs: [id],
      );
      return count > 0;
    } catch (e) {
      print('Error deleting member: $e');
      return false;
    }
  }

  // Get member count
  Future<int> getMemberCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM ${Tables.members}');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Search members by name
  Future<List<Member>> searchMembers(String query) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      Tables.members,
      where: '${Tables.memberName} LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: '${Tables.memberName} ASC',
    );
    return List.generate(maps.length, (i) => Member.fromMap(maps[i]));
  }
}
