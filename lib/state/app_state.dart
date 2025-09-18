import 'dart:collection';

import 'package:flutter/material.dart';

import '../models/focus_session.dart';
import '../models/task.dart';

class AppState extends ChangeNotifier {
  AppState() {
    _seedTasks();
  }

  final List<Task> _tasks = <Task>[];
  final List<FocusSession> _sessions = <FocusSession>[];
  DateTime? _lastCompletionDate;
  int _streak = 0;

  UnmodifiableListView<Task> get tasks => UnmodifiableListView<Task>(_tasks);
  UnmodifiableListView<FocusSession> get sessions => UnmodifiableListView<FocusSession>(_sessions);

  int get streak => _streak;

  double get completionRate {
    if (_tasks.isEmpty) {
      return 0;
    }
    final int completedCount = _tasks.where((Task task) => task.isCompleted).length;
    return completedCount / _tasks.length;
  }

  int get completedToday {
    final DateTime today = DateUtils.dateOnly(DateTime.now());
    return _tasks
        .where((Task task) =>
            task.completedAt != null && DateUtils.isSameDay(task.completedAt, today))
        .length;
  }

  int get focusMinutesThisWeek {
    if (_sessions.isEmpty) {
      return 0;
    }
    final DateTime now = DateTime.now();
    final DateTime startOfWeek = DateUtils.dateOnly(now.subtract(Duration(days: now.weekday - 1)));
    return _sessions
        .where((FocusSession session) =>
            !session.startedAt.isBefore(startOfWeek) && session.completed)
        .fold<int>(0, (int sum, FocusSession session) => sum + session.durationMinutes);
  }

  int get totalPlannedMinutes => _tasks
      .where((Task task) => !task.isCompleted)
      .fold<int>(0, (int sum, Task task) => sum + task.estimatedMinutes);

  int get totalFocusMinutes => _sessions.fold<int>(
        0,
        (int sum, FocusSession session) => sum + session.durationMinutes,
      );

  List<Task> get activeTasks =>
      _tasks.where((Task task) => !task.isCompleted).toList(growable: false);

  List<Task> get completedTasks =>
      _tasks.where((Task task) => task.isCompleted).toList(growable: false);

  List<Task> get dueSoon {
    final List<Task> upcoming = _tasks
        .where((Task task) =>
            !task.isCompleted && task.dueDate != null &&
            task.dueDate!.isBefore(DateTime.now().add(const Duration(days: 3))))
        .toList();
    upcoming.sort((Task a, Task b) => a.dueDate!.compareTo(b.dueDate!));
    return upcoming.take(5).toList();
  }

  Map<String, double> get tagDistribution {
    final Map<String, int> counts = <String, int>{};
    for (final Task task in _tasks) {
      for (final String tag in task.tags) {
        counts.update(tag, (int value) => value + 1, ifAbsent: () => 1);
      }
    }
    if (counts.isEmpty) {
      return <String, double>{};
    }
    final int total = counts.values.fold<int>(0, (int sum, int count) => sum + count);
    return counts.map<String, double>((String key, int value) {
      return MapEntry<String, double>(key, value / total);
    });
  }

  List<FocusSession> get recentSessions {
    final List<FocusSession> recent = List<FocusSession>.from(_sessions);
    recent.sort((FocusSession a, FocusSession b) => b.startedAt.compareTo(a.startedAt));
    return recent.take(10).toList();
  }

  void addTask(Task task) {
    _tasks.add(task);
    notifyListeners();
  }

  void createTask({
    required String title,
    required String description,
    DateTime? dueDate,
    List<String> tags = const <String>[],
    int estimatedMinutes = 25,
    TaskPriority priority = TaskPriority.medium,
  }) {
    final Task task = Task(
      id: _generateId(),
      title: title,
      description: description,
      dueDate: dueDate,
      tags: List<String>.from(tags),
      estimatedMinutes: estimatedMinutes,
      priority: priority,
    );
    addTask(task);
  }

  void toggleTaskCompletion(String taskId) {
    final int index = _tasks.indexWhere((Task task) => task.id == taskId);
    if (index == -1) {
      return;
    }
    final Task current = _tasks[index];
    final bool nextCompletedState = !current.isCompleted;
    final Task updated = current.copyWith(
      isCompleted: nextCompletedState,
      completedAt: nextCompletedState ? DateTime.now() : null,
    );
    _tasks[index] = updated;
    if (nextCompletedState) {
      _updateStreak(DateTime.now());
    }
    notifyListeners();
  }

  void addFocusSession({
    required String taskId,
    required Duration duration,
    bool completed = true,
    String? note,
  }) {
    final FocusSession session = FocusSession(
      id: _generateId(),
      taskId: taskId,
      startedAt: DateTime.now(),
      durationMinutes: duration.inMinutes,
      completed: completed,
      note: note,
    );
    _sessions.add(session);
    final int taskIndex = _tasks.indexWhere((Task task) => task.id == taskId);
    if (taskIndex != -1) {
      final Task task = _tasks[taskIndex];
      _tasks[taskIndex] = task.copyWith(
        focusMinutes: task.focusMinutes + duration.inMinutes,
      );
    }
    if (completed) {
      _updateStreak(DateTime.now());
    }
    notifyListeners();
  }

  void _seedTasks() {
    if (_tasks.isNotEmpty) {
      return;
    }
    final DateTime today = DateUtils.dateOnly(DateTime.now());
    addTask(
      Task(
        id: _generateId(),
        title: 'Break down your next milestone',
        description:
            'Outline the smallest actionable steps needed for your next milestone so it feels less intimidating.',
        dueDate: today,
        estimatedMinutes: 35,
        tags: const <String>['planning', 'clarity'],
        priority: TaskPriority.high,
      ),
    );
    addTask(
      Task(
        id: _generateId(),
        title: 'Schedule focus blocks',
        description:
            'Block out two 25-minute focus sessions on your calendar and protect them from interruptions.',
        dueDate: today.add(const Duration(days: 1)),
        estimatedMinutes: 15,
        tags: const <String>['routine'],
        priority: TaskPriority.medium,
      ),
    );
    addTask(
      Task(
        id: _generateId(),
        title: 'Reflect on progress',
        description:
            'Write down one win, one challenge, and one experiment you will try tomorrow to keep momentum.',
        dueDate: today.add(const Duration(days: 2)),
        estimatedMinutes: 20,
        tags: const <String>['reflection'],
        priority: TaskPriority.low,
      ),
    );
  }

  void _updateStreak(DateTime completionDateTime) {
    final DateTime completionDay = DateUtils.dateOnly(completionDateTime);
    if (_lastCompletionDate == null) {
      _streak = 1;
    } else {
      final int difference = completionDay.difference(_lastCompletionDate!).inDays;
      if (difference == 0) {
        // Same day completion keeps the streak as-is.
      } else if (difference == 1) {
        _streak += 1;
      } else if (difference > 1) {
        _streak = 1;
      }
    }
    _lastCompletionDate = completionDay;
  }

  String _generateId() => DateTime.now().microsecondsSinceEpoch.toString();
}
