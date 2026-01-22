class Category {
  final String? id;
  final String name;
  final String? description;
  final String? icon;
  final String? color;
  final bool isPredefined;
  final String? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Category({
    this.id,
    required this.name,
    this.description,
    this.icon,
    this.color,
    this.isPredefined = false,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  /// Create Category from JSON (API response)
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      isPredefined: json['isPredefined'] as bool? ?? false,
      userId: json['userId'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Convert Category to JSON (for API requests)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'name': name,
      if (description != null) 'description': description,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      'isPredefined': isPredefined,
      if (userId != null) 'userId': userId,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  /// Create a copy with modified fields
  Category copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    String? color,
    bool? isPredefined,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isPredefined: isPredefined ?? this.isPredefined,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
