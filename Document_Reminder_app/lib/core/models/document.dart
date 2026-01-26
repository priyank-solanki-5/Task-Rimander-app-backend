class Document {
  final String? id;
  final String filename; // Stored filename on server
  final String originalName; // Original filename from user
  final String filePath;
  final int fileSize;
  final String mimeType;
  final String userId;
  final String? memberId;
  final String? taskId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Document({
    this.id,
    required this.filename,
    required this.originalName,
    required this.filePath,
    required this.fileSize,
    required this.mimeType,
    required this.userId,
    this.memberId,
    this.taskId,
    this.createdAt,
    this.updatedAt,
  });

  /// Create Document from JSON (API response)
  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['_id'] as String?,
      filename: json['filename'] as String,
      originalName: json['originalName'] as String,
      filePath: json['filePath'] as String,
      fileSize: json['fileSize'] as int,
      mimeType: json['mimeType'] as String,
      userId: json['userId'] is Map
          ? (json['userId']['_id'] as String)
          : json['userId'] as String,
      memberId: json['memberId'] is Map
          ? (json['memberId']['_id'] as String?)
          : json['memberId'] as String?,
      taskId: json['taskId'] is Map
          ? (json['taskId']['_id'] as String?)
          : json['taskId'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Convert Document to JSON (for API requests)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'filename': filename,
      'originalName': originalName,
      'filePath': filePath,
      'fileSize': fileSize,
      'mimeType': mimeType,
      'userId': userId,
      if (memberId != null) 'memberId': memberId,
      if (taskId != null) 'taskId': taskId,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  /// Create a copy with modified fields
  Document copyWith({
    String? id,
    String? filename,
    String? originalName,
    String? filePath,
    int? fileSize,
    String? mimeType,
    String? userId,
    String? memberId,
    String? taskId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Document(
      id: id ?? this.id,
      filename: filename ?? this.filename,
      originalName: originalName ?? this.originalName,
      filePath: filePath ?? this.filePath,
      fileSize: fileSize ?? this.fileSize,
      mimeType: mimeType ?? this.mimeType,
      userId: userId ?? this.userId,
      memberId: memberId ?? this.memberId,
      taskId: taskId ?? this.taskId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get file size in human-readable format
  String get fileSizeDisplay {
    if (fileSize < 1024) {
      return '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(2)} KB';
    } else if (fileSize < 1024 * 1024 * 1024) {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }

  /// Get file extension
  String get fileExtension {
    final parts = originalName.split('.');
    return parts.length > 1 ? parts.last.toUpperCase() : '';
  }
}
