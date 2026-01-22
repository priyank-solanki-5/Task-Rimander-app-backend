class Member {
  final String? id;
  final String name;
  final String? photoPath;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Member({
    this.id,
    required this.name,
    this.photoPath,
    this.createdAt,
    this.updatedAt,
  });

  /// Create Member from JSON (API response)
  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['_id'] as String?,
      name: json['name'] as String,
      photoPath: json['photoPath'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Convert Member to JSON (for API requests)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'name': name,
      if (photoPath != null) 'photoPath': photoPath,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  /// Create a copy with modified fields
  Member copyWith({
    String? id,
    String? name,
    String? photoPath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Member(
      id: id ?? this.id,
      name: name ?? this.name,
      photoPath: photoPath ?? this.photoPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get initials for avatar
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }
}
