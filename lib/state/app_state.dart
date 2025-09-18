import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';

import '../models/focus_session.dart';
import '../models/procrastination_trigger.dart';
import '../models/reflection_entry.dart';
import '../models/support_ritual.dart';
import '../models/task.dart';

class AppState extends ChangeNotifier {
  AppState() {
    _seedTasks();
    _seedReflections();
    _seedTriggers();
    _seedRituals();
    _seedSessions();
  }

  final List<Task> _tasks = <Task>[];
  final List<FocusSession> _sessions = <FocusSession>[];
  final List<ReflectionEntry> _reflections = <ReflectionEntry>[];
  final List<ProcrastinationTrigger> _triggers = <ProcrastinationTrigger>[];
  final List<SupportRitual> _rituals = <SupportRitual>[];
  DateTime? _lastCompletionDate;
  int _streak = 0;

  UnmodifiableListView<Task> get tasks => UnmodifiableListView<Task>(_tasks);
  UnmodifiableListView<FocusSession> get sessions =>
      UnmodifiableListView<FocusSession>(_sessions);
  UnmodifiableListView<ReflectionEntry> get reflections =>
      UnmodifiableListView<ReflectionEntry>(_reflections);
  UnmodifiableListView<ProcrastinationTrigger> get triggers =>
      UnmodifiableListView<ProcrastinationTrigger>(_triggers);
  UnmodifiableListView<SupportRitual> get rituals =>
      UnmodifiableListView<SupportRitual>(_rituals);

  int get streak => _streak;

  double get completionRate {
    if (_tasks.isEmpty) {
      return 0;
    }
    final int completedCount =
        _tasks.where((Task task) => task.isCompleted).length;
    return completedCount / _tasks.length;
  }

  int get completedToday {
    final DateTime today = DateUtils.dateOnly(DateTime.now());
    return _tasks
        .where((Task task) =>
            task.completedAt != null &&
            DateUtils.isSameDay(task.completedAt, today))
        .length;
  }

  int get focusMinutesThisWeek {
    if (_sessions.isEmpty) {
      return 0;
    }
    final DateTime now = DateTime.now();
    final DateTime startOfWeek =
        DateUtils.dateOnly(now.subtract(Duration(days: now.weekday - 1)));
    return _sessions
        .where((FocusSession session) =>
            !session.startedAt.isBefore(startOfWeek) && session.completed)
        .fold<int>(0,
            (int sum, FocusSession session) => sum + session.durationMinutes);
  }

  int get totalPlannedMinutes => _tasks
      .where((Task task) => !task.isCompleted)
      .fold<int>(0, (int sum, Task task) => sum + task.estimatedMinutes);

  int get totalFocusMinutes => _sessions.fold<int>(
        0,
        (int sum, FocusSession session) => sum + session.durationMinutes,
      );

  Duration get averageSessionDuration {
    if (_sessions.isEmpty) {
      return Duration.zero;
    }
    final int total = _sessions
        .where((FocusSession session) => session.completed)
        .fold<int>(0, (int sum, FocusSession session) =>
            sum + session.durationMinutes);
    final int completedCount =
        _sessions.where((FocusSession session) => session.completed).length;
    if (completedCount == 0) {
      return Duration.zero;
    }
    return Duration(minutes: (total / completedCount).round());
  }

  List<Task> get activeTasks =>
      _tasks.where((Task task) => !task.isCompleted).toList(growable: false);

  List<Task> get completedTasks =>
      _tasks.where((Task task) => task.isCompleted).toList(growable: false);

  List<Task> get dueSoon {
    final List<Task> upcoming = _tasks
        .where((Task task) =>
            !task.isCompleted &&
            task.dueDate != null &&
            task.dueDate!
                .isBefore(DateTime.now().add(const Duration(days: 3))))
        .toList();
    upcoming.sort((Task a, Task b) => a.dueDate!.compareTo(b.dueDate!));
    return upcoming.take(5).toList();
  }

  List<Task> get quickWins {
    final List<Task> wins = _tasks
        .where((Task task) => !task.isCompleted && task.estimatedMinutes <= 20)
        .toList();
    wins.sort((Task a, Task b) => a.estimatedMinutes.compareTo(b.estimatedMinutes));
    return wins;
  }

  List<Task> get deepFocusCandidates {
    final List<Task> candidates = _tasks
        .where((Task task) =>
            !task.isCompleted && task.priority == TaskPriority.high)
        .toList();
    candidates.sort((Task a, Task b) {
      final DateTime aDate = a.dueDate ?? DateTime.now().add(const Duration(days: 7));
      final DateTime bDate = b.dueDate ?? DateTime.now().add(const Duration(days: 7));
      return aDate.compareTo(bDate);
    });
    return candidates;
  }

  List<Task> get reflectionFriendlyTasks {
    final List<Task> tasksNeedingReview = _tasks
        .where((Task task) =>
            !task.isCompleted &&
            task.tags.any((String tag) => tag.contains('reflect')))
        .toList();
    tasksNeedingReview.sort((Task a, Task b) => a.title.compareTo(b.title));
    return tasksNeedingReview;
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

  Map<DateTime, int> get focusMinutesByDay {
    final Map<DateTime, int> summary = <DateTime, int>{};
    for (final FocusSession session in _sessions) {
      final DateTime key = DateUtils.dateOnly(session.startedAt);
      summary.update(key, (int value) => value + session.durationMinutes,
          ifAbsent: () => session.durationMinutes);
    }
    return summary;
  }

  List<int> get lastSevenDayFocusMinutes {
    final DateTime today = DateUtils.dateOnly(DateTime.now());
    return List<int>.generate(7, (int index) {
      final DateTime day = today.subtract(Duration(days: 6 - index));
      return focusMinutesByDay[day] ?? 0;
    });
  }

  ReflectionEntry? get todayReflection {
    final DateTime today = DateUtils.dateOnly(DateTime.now());
    for (final ReflectionEntry entry in _reflections) {
      if (DateUtils.isSameDay(entry.date, today)) {
        return entry;
      }
    }
    return null;
  }

  ReflectionEntry? get latestReflection =>
      _reflections.isEmpty ? null : _reflections.last;

  List<ReflectionEntry> get recentReflections {
    final List<ReflectionEntry> copy = List<ReflectionEntry>.from(_reflections);
    copy.sort((ReflectionEntry a, ReflectionEntry b) => b.date.compareTo(a.date));
    return copy.take(7).toList();
  }

  double get averageMoodScore => _averageScore(
        _reflections.map((ReflectionEntry entry) => entry.moodScore),
      );

  double get averageEnergyScore => _averageScore(
        _reflections.map((ReflectionEntry entry) => entry.energyScore),
      );

  double get averageFocusScore => _averageScore(
        _reflections.map((ReflectionEntry entry) => entry.focusScore),
      );

  List<SupportRitual> ritualsForMoment(RitualMoment moment) => _rituals
      .where((SupportRitual ritual) => ritual.moment == moment)
      .toList(growable: false);

  List<ProcrastinationTrigger> triggersForCategory(TriggerCategory category) =>
      _triggers
          .where((ProcrastinationTrigger trigger) => trigger.category == category)
          .toList(growable: false);

  List<ProcrastinationTrigger> get recommendedTriggers {
    final Set<TriggerCategory> priorityCategories = <TriggerCategory>{};
    final bool hasHighEffort = activeTasks
        .any((Task task) => task.estimatedMinutes >= 45 || task.tags.contains('deep work'));
    final bool hasClarityTag = activeTasks
        .any((Task task) => task.tags.any((String tag) => tag.contains('clarity')));
    final bool hasEnergyFlag = activeTasks
        .any((Task task) => task.tags.any((String tag) => tag.contains('energy')));

    if (hasHighEffort) {
      priorityCategories.add(TriggerCategory.overwhelm);
    }
    if (hasClarityTag || quickWins.isEmpty) {
      priorityCategories.add(TriggerCategory.unclearNextStep);
    }
    if (hasEnergyFlag || averageEnergyScore < 3) {
      priorityCategories.add(TriggerCategory.lowEnergy);
    }
    if (averageMoodScore >= 3.5 && averageFocusScore < 3.0) {
      priorityCategories.add(TriggerCategory.distractions);
    }
    if (_tasks.any((Task task) =>
        !task.isCompleted && task.priority == TaskPriority.high && task.tags.contains('perfect'))) {
      priorityCategories.add(TriggerCategory.perfectionism);
    }

    if (priorityCategories.isEmpty) {
      priorityCategories.addAll(<TriggerCategory>{
        TriggerCategory.overwhelm,
        TriggerCategory.unclearNextStep,
        TriggerCategory.lowEnergy,
      });
    }

    final List<ProcrastinationTrigger> prioritized = <ProcrastinationTrigger>[];
    for (final TriggerCategory category in priorityCategories) {
      prioritized.addAll(triggersForCategory(category));
    }
    for (final ProcrastinationTrigger trigger in _triggers) {
      if (!prioritized.contains(trigger)) {
        prioritized.add(trigger);
      }
    }
    return prioritized.take(5).toList();
  }

  List<String> get warmupPrompts => const <String>[
        'Name the first 90-second action you can take.',
        'Preview the reward you will gift yourself after the next focus block.',
        'Set a 3-sentence intention: Why this matters, how you will start, how you will celebrate.',
        'Clear one distraction from your environment before you begin.',
      ];

  List<String> get celebrationPrompts => const <String>[
        'Share a progress update with an accountability partner.',
        'Write down two things that felt easier today and why.',
        'Capture one lesson and one experiment to try tomorrow.',
      ];

  List<String> get decompressionIdeas => const <String>[
        'Stretch for one song and notice areas that softened during work.',
        'Sip water away from screens for two minutes.',
        'Take a mindful walk and name five details you notice.',
      ];

  List<FocusSession> get recentSessions {
    final List<FocusSession> recent = List<FocusSession>.from(_sessions);
    recent.sort((FocusSession a, FocusSession b) => b.startedAt.compareTo(a.startedAt));
    return recent.take(12).toList();
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

  void logReflection(ReflectionEntry entry) {
    final int existingIndex = _reflections.indexWhere(
      (ReflectionEntry e) => DateUtils.isSameDay(e.date, entry.date),
    );
    if (existingIndex >= 0) {
      _reflections[existingIndex] = entry;
    } else {
      _reflections.add(entry);
      _reflections.sort((ReflectionEntry a, ReflectionEntry b) => a.date.compareTo(b.date));
    }
    notifyListeners();
  }

  double _averageScore(Iterable<int> scores) {
    final List<int> list = scores.toList();
    if (list.isEmpty) {
      return 0;
    }
    final double total = list.fold<double>(0, (double sum, int score) => sum + score);
    return total / list.length;
  }

  void _seedTasks() {
    if (_tasks.isNotEmpty) {
      return;
    }
    final DateTime today = DateUtils.dateOnly(DateTime.now());
    final DateTime tomorrow = today.add(const Duration(days: 1));
    final DateTime threeDays = today.add(const Duration(days: 3));

    addTask(
      Task(
        id: _generateId(),
        title: 'Design your momentum map',
        description:
            'Translate your next milestone into a ladder of tiny, concrete steps. Prioritise one deep focus block and two momentum builders.',
        dueDate: today,
        estimatedMinutes: 45,
        tags: const <String>['planning', 'clarity', 'deep work'],
        priority: TaskPriority.high,
      ),
    );
    addTask(
      Task(
        id: _generateId(),
        title: 'Warm-up focus playlist',
        description:
            'Curate a 3-song playlist that signals focus mode. This becomes your ritual to slip past resistance.',
        dueDate: tomorrow,
        estimatedMinutes: 15,
        tags: const <String>['ritual', 'energy'],
        priority: TaskPriority.medium,
      ),
    );
    addTask(
      Task(
        id: _generateId(),
        title: 'Prep environment sweep',
        description:
            'Reset your workspace. Remove friction, close unused tabs, and lay out just the tools for the next win.',
        dueDate: today,
        estimatedMinutes: 20,
        tags: const <String>['environment', 'energy'],
        priority: TaskPriority.medium,
      ),
    );
    addTask(
      Task(
        id: _generateId(),
        title: 'Write progress reflection',
        description:
            'Capture a quick reflection: one win, one barrier, and the tiniest experiment you will try next session.',
        dueDate: threeDays,
        estimatedMinutes: 10,
        tags: const <String>['reflection'],
        priority: TaskPriority.low,
      ),
    );
    addTask(
      Task(
        id: _generateId(),
        title: 'Outline tiny next step',
        description:
            'Break the biggest task into a 10-minute scout mission. Define your success metric for just this slice.',
        dueDate: tomorrow,
        estimatedMinutes: 12,
        tags: const <String>['clarity', 'quick win'],
        priority: TaskPriority.high,
      ),
    );
  }

  void _seedReflections() {
    if (_reflections.isNotEmpty) {
      return;
    }
    final DateTime today = DateUtils.dateOnly(DateTime.now());
    for (int i = 0; i < 5; i++) {
      final DateTime date = today.subtract(Duration(days: 4 - i));
      _reflections.add(
        ReflectionEntry(
          date: date,
          moodScore: max(2, 3 + (i.isEven ? 1 : -1)),
          energyScore: max(2, 3 + (i % 3 == 0 ? 1 : 0)),
          focusScore: max(2, 3 + (i % 2 == 0 ? 1 : -1)),
          highlights: <String>['Noticed progress on focus ritual ${i + 1}'],
          intentions: const <String>['Celebrate tiny momentum', 'Protect next focus window'],
          note: i == 4 ? 'Need more variety tomorrow to avoid burnout.' : null,
        ),
      );
    }
  }

  void _seedTriggers() {
    if (_triggers.isNotEmpty) {
      return;
    }
    _triggers
      ..add(
        ProcrastinationTrigger(
          id: _generateId(),
          category: TriggerCategory.overwhelm,
          headline: 'Chunk the mountain into footholds',
          description:
              'Overwhelm often shows up when the next step feels amorphous or too large. Create a scout mission to regain traction.',
          antidotes: const <String>[
            'Limit your planning horizon to the next 15 minutes.',
            'Write the success criteria for completing just the next slice.',
            'Pair a big task with a momentum buddy: a 5-minute starter action.',
          ],
          microSteps: const <String>[
            'List three verbs that describe movement on this task.',
            'Write the first sentence, bullet, or sketch.',
            'Ask “what would make this playful?” and do that version.',
          ],
          supportingQuestions: const <String>[
            'If it had to fit into 10 minutes, what would the win look like?',
            'What signal would tell future-you that momentum has started?',
          ],
        ),
      )
      ..add(
        ProcrastinationTrigger(
          id: _generateId(),
          category: TriggerCategory.unclearNextStep,
          headline: 'Illuminate your very first move',
          description:
              'When clarity is fuzzy, create a scouting step that is so small it cannot fail. Curiosity breaks resistance.',
          antidotes: const <String>[
            'Write the question you need answered to move forward.',
            'Define what a “messy draft” could look like.',
            'Visualize the finish line and work backwards by two steps.',
          ],
          microSteps: const <String>[
            'Set a 5-minute timer to brainstorm scrappy starts.',
            'Ask for a quick gut-check from a collaborator.',
            'Sketch the workflow on paper instead of in your head.',
          ],
          supportingQuestions: const <String>[
            'Which part feels foggy and how can you scout it?',
            'What would a first iteration that is safe to fail look like?',
          ],
        ),
      )
      ..add(
        ProcrastinationTrigger(
          id: _generateId(),
          category: TriggerCategory.perfectionism,
          headline: 'Trade perfect for progress',
          description:
              'Perfectionism steals momentum. Define a playful experiment and collect feedback quickly.',
          antidotes: const <String>[
            'Set a deliberately tiny quality bar for the next draft.',
            'Time-box polishing efforts to 5 minutes.',
            'Identify what “good enough for now” means.',
          ],
          microSteps: const <String>[
            'Ship a 1-sentence update to a partner.',
            'Create a comparison between ideal vs. now version.',
            'Ask “what can I learn by finishing imperfectly today?”',
          ],
          supportingQuestions: const <String>[
            'Where is excellence required versus optional?',
            'What will become easier once a rough version exists?',
          ],
        ),
      )
      ..add(
        ProcrastinationTrigger(
          id: _generateId(),
          category: TriggerCategory.distractions,
          headline: 'Shield the focus bubble',
          description:
              'Design a focus bubble that makes distractions friction-full. Prime your environment before you begin.',
          antidotes: const <String>[
            'Silence notifications and move the phone to a different room.',
            'Use full-screen mode to reduce visual clutter.',
            'Bookmark deep work playlists or ambient noise.',
          ],
          microSteps: const <String>[
            'Close or snooze the top three distracting tabs.',
            'Tell someone you are entering a focus sprint.',
            'Use the Pomodoro method with intention notes.',
          ],
          supportingQuestions: const <String>[
            'What repeatedly steals your attention and how can you pre-empt it?',
            'What does a frictionless focus space look like for you?',
          ],
        ),
      )
      ..add(
        ProcrastinationTrigger(
          id: _generateId(),
          category: TriggerCategory.lowEnergy,
          headline: 'Refuel your energy before you sprint',
          description:
              'Low energy makes tasks feel heavier. Inject micro-rest and nourishing rituals before asking for focus.',
          antidotes: const <String>[
            'Take a micro-break: hydrate, stretch, or breathe for one minute.',
            'Pair your next focus block with uplifting music.',
            'Adjust the next task to a lighter lift while energy recovers.',
          ],
          microSteps: const <String>[
            'Do box breathing for four rounds.',
            'Walk to a window and notice three outdoor details.',
            'Swap to a quick win to rebuild a streak.',
          ],
          supportingQuestions: const <String>[
            'What does your body need before your brain works well again?',
            'How can you make the next action feel restorative?',
          ],
        ),
      );
  }

  void _seedRituals() {
    if (_rituals.isNotEmpty) {
      return;
    }
    _rituals
      ..add(
        SupportRitual(
          id: _generateId(),
          moment: RitualMoment.morning,
          title: 'Morning clarity pulse',
          description: 'Prime your mindset with intention, gratitude, and a tiny win.',
          steps: const <String>[
            'Name the feeling you want to end the day with.',
            'List one bold move and one easy win for today.',
            'Schedule your strongest focus window.',
          ],
          affirmation: 'I move with deliberate ease and momentum.',
          icon: Icons.wb_sunny_rounded,
        ),
      )
      ..add(
        SupportRitual(
          id: _generateId(),
          moment: RitualMoment.preFocus,
          title: 'Focus ignition',
          description: 'Transition from planning to action with a sensory ritual.',
          steps: const <String>[
            'Play your focus playlist.',
            'Write down the opening line of the task.',
            'Remove one distraction before the timer starts.',
          ],
          affirmation: 'My attention is a gift I can direct.',
          icon: Icons.local_fire_department_rounded,
        ),
      )
      ..add(
        SupportRitual(
          id: _generateId(),
          moment: RitualMoment.reset,
          title: 'Momentum reset',
          description: 'Unwind, celebrate, and integrate lessons before closing the day.',
          steps: const <String>[
            'Celebrate one insight or win aloud.',
            'Capture a lesson for tomorrow’s self.',
            'Close the loop: tidy workspace, shut tabs, stretch.',
          ],
          affirmation: 'I close today with pride and replenish for tomorrow.',
          icon: Icons.nightlight_round,
        ),
      );
  }

  void _seedSessions() {
    if (_sessions.isNotEmpty || _tasks.isEmpty) {
      return;
    }
    final DateTime now = DateTime.now();
    final List<Task> snapshot = List<Task>.from(_tasks);
    for (int i = 0; i < snapshot.length; i++) {
      final Task task = snapshot[i];
      final Duration duration = Duration(minutes: 20 + (i * 5));
      final DateTime start = now.subtract(Duration(days: i, hours: i + 1));
      final FocusSession session = FocusSession(
        id: _generateId(),
        taskId: task.id,
        startedAt: start,
        durationMinutes: duration.inMinutes,
        completed: true,
        note: 'Logged during bootstrapped session ${i + 1}.',
      );
      _sessions.add(session);
      final int index = _tasks.indexWhere((Task element) => element.id == task.id);
      if (index != -1) {
        final Task existing = _tasks[index];
        _tasks[index] = existing.copyWith(
          focusMinutes: existing.focusMinutes + duration.inMinutes,
        );
      }
    }
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
