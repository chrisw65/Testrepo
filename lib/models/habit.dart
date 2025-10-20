import 'package:flutter/material.dart';

enum HabitFrequency {
  daily,
  weekly,
  custom,
}

enum HabitCategory {
  health,
  productivity,
  learning,
  mindfulness,
  social,
  creative,
  fitness,
  other,
}

class Habit {
  const Habit({
    required this.id,
    required this.name,
    required this.description,
    required this.frequency,
    required this.category,
    required this.icon,
    required this.color,
    required this.createdAt,
    this.targetDaysPerWeek = 7,
    this.reminderTime,
    this.completionHistory = const <DateTime>[],
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.isActive = true,
    this.notes,
  });

  final String id;
  final String name;
  final String description;
  final HabitFrequency frequency;
  final HabitCategory category;
  final IconData icon;
  final Color color;
  final DateTime createdAt;
  final int targetDaysPerWeek;
  final TimeOfDay? reminderTime;
  final List<DateTime> completionHistory;
  final int currentStreak;
  final int longestStreak;
  final bool isActive;
  final String? notes;

  bool isCompletedOn(DateTime date) {
    return completionHistory.any((DateTime completion) =>
        completion.year == date.year &&
        completion.month == date.month &&
        completion.day == date.day);
  }

  int get totalCompletions => completionHistory.length;

  double get completionRate {
    final DateTime now = DateTime.now();
    final int daysSinceCreation = now.difference(createdAt).inDays + 1;
    if (daysSinceCreation == 0) {
      return 0;
    }

    final int expectedCompletions = frequency == HabitFrequency.daily
        ? daysSinceCreation
        : (daysSinceCreation / 7 * targetDaysPerWeek).round();

    if (expectedCompletions == 0) {
      return 0;
    }

    return (totalCompletions / expectedCompletions).clamp(0.0, 1.0);
  }

  bool get isCompletedToday {
    final DateTime today = DateTime.now();
    return isCompletedOn(today);
  }

  int get completionsThisWeek {
    final DateTime now = DateTime.now();
    final DateTime startOfWeek =
        now.subtract(Duration(days: now.weekday - 1));
    final DateTime startOfWeekDate = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );

    return completionHistory
        .where((DateTime completion) => !completion.isBefore(startOfWeekDate))
        .length;
  }

  int get completionsThisMonth {
    final DateTime now = DateTime.now();
    final DateTime startOfMonth = DateTime(now.year, now.month, 1);

    return completionHistory
        .where((DateTime completion) => !completion.isBefore(startOfMonth))
        .length;
  }

  List<DateTime> get last30DaysCompletions {
    final DateTime now = DateTime.now();
    final DateTime thirtyDaysAgo = now.subtract(const Duration(days: 30));

    return completionHistory
        .where((DateTime completion) => completion.isAfter(thirtyDaysAgo))
        .toList();
  }

  Habit copyWith({
    String? id,
    String? name,
    String? description,
    HabitFrequency? frequency,
    HabitCategory? category,
    IconData? icon,
    Color? color,
    DateTime? createdAt,
    int? targetDaysPerWeek,
    TimeOfDay? reminderTime,
    List<DateTime>? completionHistory,
    int? currentStreak,
    int? longestStreak,
    bool? isActive,
    String? notes,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      frequency: frequency ?? this.frequency,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      targetDaysPerWeek: targetDaysPerWeek ?? this.targetDaysPerWeek,
      reminderTime: reminderTime ?? this.reminderTime,
      completionHistory: completionHistory ?? this.completionHistory,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      isActive: isActive ?? this.isActive,
      notes: notes ?? this.notes,
    );
  }
}
