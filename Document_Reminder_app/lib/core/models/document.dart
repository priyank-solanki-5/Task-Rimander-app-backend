class Document {
  final int? id;
  final String name;
  final int memberId;
  final String filePath;
  final DateTime uploadDate;
  final DateTime? createdAt;

  Document({
    this.id,
    required this.name,
    required this.memberId,
    required this.filePath,
    required this.uploadDate,
    this.createdAt,
  });

  // Convert Document to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'member_id': memberId,
      'file_path': filePath,
      'upload_date': uploadDate.toIso8601String(),
      'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
    };
  }

  // Create Document from Map (SQLite)
  factory Document.fromMap(Map<String, dynamic> map) {
    return Document(
      id: map['id'] as int?,
      name: map['name'] as String,
      memberId: map['member_id'] as int,
      filePath: map['file_path'] as String,
      uploadDate: DateTime.parse(map['upload_date'] as String),
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'] as String) : null,
    );
  }

  // Create a copy with modified fields
  Document copyWith({
    int? id,
    String? name,
    int? memberId,
    String? filePath,
    DateTime? uploadDate,
    DateTime? createdAt,
  }) {
    return Document(
      id: id ?? this.id,
      name: name ?? this.name,
      memberId: memberId ?? this.memberId,
      filePath: filePath ?? this.filePath,
      uploadDate: uploadDate ?? this.uploadDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Get file extension
  String get fileExtension {
    final parts = name.split('.');
    return parts.length > 1 ? parts.last.toUpperCase() : '';
  }
}
