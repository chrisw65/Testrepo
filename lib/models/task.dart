import 'package:flutter/material.dart';

/// Priority levels that help the user understand the urgency of a task.
enum TaskPriority { low, medium, high }

extension TaskPriorityExtension on TaskPriority {
  String get label {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
    }
  }

  Color get color {
    switch (this) {
      case TaskPriority.low:
        return Colors.green.shade300;
      case TaskPriority.medium:
        return Colors.orange.shade400;
      case TaskPriority.high:
        return Colors.red.shade400;
    }
  }
}

/// Representation of a focus task that the user wants to progress on.
class Task {
  Task({
    required this.id,
    required this.title,
    required this.description,
    this.dueDate,
    this.tags = const <String>[],
    this.estimatedMinutes = 25,
    this.focusMinutes = 0,
    this.priority = TaskPriority.medium,
    this.isCompleted = false,
    this.completedAt,
  });

  final String id;
  final String title;
  final String description;
  final DateTime? dueDate;
  final List<String> tags;
  final int estimatedMinutes;
  final int focusMinutes;
  final TaskPriority priority;
  final bool isCompleted;
  final DateTime? completedAt;

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    List<String>? tags,
    int? estimatedMinutes,
    int? focusMinutes,
    TaskPriority? priority,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      tags: tags ?? this.tags,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      focusMinutes: focusMinutes ?? this.focusMinutes,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  bool get isOverdue {
    if (dueDate == null) {
      return false;
    }
    final DateTime now = DateUtils.dateOnly(DateTime.now());
    return dueDate!.isBefore(now) && !isCompleted;
  }

  bool get isDueToday {
    if (dueDate == null) {
      return false;
    }
    return DateUtils.isSameDay(dueDate, DateTime.now());
  }

  double get focusProgress {
    if (estimatedMinutes <= 0) {
      return 0;
    }
    return (focusMinutes / estimatedMinutes).clamp(0, 1).toDouble();
  }
}
