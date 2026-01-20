class Member {
  final int? id;
  final String name;
  final String? photoPath;
  final DateTime? createdAt;

  Member({
    this.id,
    required this.name,
    this.photoPath,
    this.createdAt,
  });

  // Convert Member to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'photo_path': photoPath,
      'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
    };
  }

  // Create Member from Map (SQLite)
  factory Member.fromMap(Map<String, dynamic> map) {
    return Member(
      id: map['id'] as int?,
      name: map['name'] as String,
      photoPath: map['photo_path'] as String?,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'] as String) : null,
    );
  }

  // Create a copy with modified fields
  Member copyWith({
    int? id,
    String? name,
    String? photoPath,
    DateTime? createdAt,
  }) {
    return Member(
      id: id ?? this.id,
      name: name ?? this.name,
      photoPath: photoPath ?? this.photoPath,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Get initials for avatar
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }
}
