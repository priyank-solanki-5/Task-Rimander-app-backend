import 'dart:convert';
import 'package:flutter/foundation.dart';

enum TaskType { oneTime, recurring }

class Task {
  final int? id;
  final String title;
  final int memberId;
  final String? description;
  final List<int> documentIds;
  final DateTime dueDate;
  final int? reminderDaysBefore;
  final TaskType taskType;
  final bool isCompleted;
  final bool isNotificationEnabled;
  final DateTime? createdAt;

  Task({
    this.id,
    required this.title,
    required this.memberId,
    this.description,
    this.documentIds = const [],
    required this.dueDate,
    this.reminderDaysBefore,
    required this.taskType,
    this.isCompleted = false,
    this.isNotificationEnabled = true,
    this.createdAt,
  });

  // Convert Task to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'member_id': memberId,
      'description': description,
      'documents': jsonEncode(documentIds),
      'due_date': dueDate.toIso8601String(),
      'reminder_days_before': reminderDaysBefore,
      'task_type': taskType == TaskType.oneTime ? 'one-time' : 'recurring',
      'is_completed': isCompleted ? 1 : 0,
      'is_notification_enabled': isNotificationEnabled ? 1 : 0,
      'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
    };
  }

  // Create Task from Map (SQLite)
  factory Task.fromMap(Map<String, dynamic> map) {
    List<int> docIds = [];
    try {
      final docString = map['documents'] as String?;
      if (docString != null && docString.isNotEmpty) {
        final decoded = jsonDecode(docString);
        docIds = List<int>.from(decoded);
      }
    } catch (e) {
      debugPrint('Error parsing document IDs: $e');
    }

    return Task(
      id: map['id'] as int?,
      title: map['title'] as String,
      memberId: map['member_id'] as int,
      description: map['description'] as String?,
      documentIds: docIds,
      dueDate: DateTime.parse(map['due_date'] as String),
      reminderDaysBefore: map['reminder_days_before'] as int?,
      taskType: map['task_type'] == 'one-time'
          ? TaskType.oneTime
          : TaskType.recurring,
      isCompleted: map['is_completed'] == 1,
      isNotificationEnabled: map['is_notification_enabled'] == 1,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );
  }

  // Create a copy with modified fields
  Task copyWith({
    int? id,
    String? title,
    int? memberId,
    String? description,
    List<int>? documentIds,
    DateTime? dueDate,
    int? reminderDaysBefore,
    TaskType? taskType,
    bool? isCompleted,
    bool? isNotificationEnabled,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      memberId: memberId ?? this.memberId,
      description: description ?? this.description,
      documentIds: documentIds ?? this.documentIds,
      dueDate: dueDate ?? this.dueDate,
      reminderDaysBefore: reminderDaysBefore ?? this.reminderDaysBefore,
      taskType: taskType ?? this.taskType,
      isCompleted: isCompleted ?? this.isCompleted,
      isNotificationEnabled:
          isNotificationEnabled ?? this.isNotificationEnabled,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Check if task is overdue
  bool get isOverdue {
    return !isCompleted && dueDate.isBefore(DateTime.now());
  }

  // Check if task is due today
  bool get isDueToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return !isCompleted && taskDate.isAtSameMomentAs(today);
  }

  // Check if task is upcoming (within next 10 days)
  bool get isUpcoming {
    final now = DateTime.now();
    final tenDaysLater = now.add(const Duration(days: 10));
    return !isCompleted &&
        dueDate.isAfter(now) &&
        dueDate.isBefore(tenDaysLater);
  }

  // Get task type display string
  String get taskTypeDisplay {
    return taskType == TaskType.oneTime ? 'One-time' : 'Recurring';
  }
}
