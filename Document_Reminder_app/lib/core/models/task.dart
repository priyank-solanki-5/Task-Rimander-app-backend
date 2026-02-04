enum TaskStatus { pending, completed }

enum TaskType { oneTime, recurring }

class Task {
  final String? id;
  final String title;
  final String? description;
  final TaskStatus status;
  final DateTime? dueDate;
  final bool isRecurring;
  final String?
  recurrenceType; // "Monthly", "Every 3 months", "Every 6 months", "Yearly"
  final DateTime? nextOccurrence;
  final String userId;
  final String? memberId;
  final String? categoryId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final TaskType taskType;
  final int? remindMeBeforeDays; // Added field

  Task({
    this.id,
    required this.title,
    this.description,
    this.status = TaskStatus.pending,
    this.dueDate,
    this.isRecurring = false,
    this.recurrenceType,
    this.nextOccurrence,
    required this.userId,
    this.memberId,
    this.categoryId,
    this.createdAt,
    this.updatedAt,
    this.taskType = TaskType.oneTime,
    this.remindMeBeforeDays,
  });

  /// Create Task from JSON (API response)
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['_id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      status: json['status'] == 'Completed'
          ? TaskStatus.completed
          : TaskStatus.pending,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      isRecurring: json['isRecurring'] as bool? ?? false,
      recurrenceType: json['recurrenceType'] as String?,
      nextOccurrence: json['nextOccurrence'] != null
          ? DateTime.parse(json['nextOccurrence'] as String)
          : null,
      userId: json['userId'] as String,
      memberId: json['memberId'] is Map
          ? (json['memberId']['_id'] as String?)
          : json['memberId'] as String?,
      categoryId: json['categoryId'] is Map
          ? (json['categoryId']['_id'] as String?)
          : json['categoryId'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      taskType: json['taskType'] == 'recurring'
          ? TaskType.recurring
          : TaskType.oneTime,
      remindMeBeforeDays: json['remindMeBeforeDays'] as int?,
    );
  }

  /// Convert Task to JSON (for API requests)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'title': title,
      if (description != null) 'description': description,
      'status': status == TaskStatus.completed ? 'Completed' : 'Pending',
      if (dueDate != null) 'dueDate': dueDate!.toIso8601String(),
      'isRecurring': isRecurring,
      if (recurrenceType != null) 'recurrenceType': recurrenceType,
      if (nextOccurrence != null)
        'nextOccurrence': nextOccurrence!.toIso8601String(),
      // 'userId': userId, // Removed: Backend infers user from token
      if (memberId != null) 'memberId': memberId,
      if (categoryId != null) 'categoryId': categoryId,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      'taskType': taskType == TaskType.recurring ? 'recurring' : 'oneTime',
      if (remindMeBeforeDays != null) 'remindMeBeforeDays': remindMeBeforeDays,
    };
  }

  /// Create a copy with modified fields
  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskStatus? status,
    DateTime? dueDate,
    bool? isRecurring,
    String? recurrenceType,
    DateTime? nextOccurrence,
    String? userId,
    String? memberId,
    String? categoryId,
    DateTime? createdAt,
    DateTime? updatedAt,
    TaskType? taskType,
    int? remindMeBeforeDays,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      nextOccurrence: nextOccurrence ?? this.nextOccurrence,
      userId: userId ?? this.userId,
      memberId: memberId ?? this.memberId,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      taskType: taskType ?? this.taskType,
      remindMeBeforeDays: remindMeBeforeDays ?? this.remindMeBeforeDays,
    );
  }

  /// Check if task is completed
  bool get isCompleted => status == TaskStatus.completed;

  /// Check if task is overdue
  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    return dueDate!.isBefore(DateTime.now());
  }

  /// Check if task is due today
  bool get isDueToday {
    if (dueDate == null || isCompleted) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    return taskDate.isAtSameMomentAs(today);
  }

  /// Check if task is upcoming (within next 10 days)
  bool get isUpcoming {
    if (dueDate == null || isCompleted) return false;
    final now = DateTime.now();
    final tenDaysLater = now.add(const Duration(days: 10));
    return dueDate!.isAfter(now) && dueDate!.isBefore(tenDaysLater);
  }

  /// Get days remaining until due date
  int get daysUntilDue {
    if (dueDate == null) return 999;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    return due.difference(today).inDays;
  }

  /// Get task color priority
  /// Returns: 'red' for today/tomorrow, 'orange' for within 3 days, 'yellow' for within 7 days
  String get colorPriority {
    if (isCompleted) return 'gray';
    if (isOverdue || daysUntilDue <= 1) return 'red';
    if (daysUntilDue <= 2) return 'orange';
    if (daysUntilDue <= 7) return 'yellow';
    return 'primary';
  }

  /// Get status display string
  String get statusDisplay {
    return status == TaskStatus.completed ? 'Completed' : 'Pending';
  }

  /// Get recurrence display string
  String? get recurrenceDisplay {
    if (!isRecurring || recurrenceType == null) return null;
    return recurrenceType;
  }

  /// Get task type display string
  String get taskTypeDisplay {
    return taskType == TaskType.recurring ? 'Recurring' : 'One Time';
  }
}
