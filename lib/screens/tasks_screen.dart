import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../state/app_state.dart';

enum TaskView { active, today, upcoming, completed }

extension TaskViewX on TaskView {
  String get label {
    switch (this) {
      case TaskView.active:
        return 'Active';
      case TaskView.today:
        return 'Today';
      case TaskView.upcoming:
        return 'Upcoming';
      case TaskView.completed:
        return 'Completed';
    }
  }

  String get description {
    switch (this) {
      case TaskView.active:
        return 'View everything currently in motion and decide your next focus.';
      case TaskView.today:
        return 'Prioritise items due soon or needing attention today.';
      case TaskView.upcoming:
        return 'Plan ahead for what is approaching in the next few days.';
      case TaskView.completed:
        return 'Celebrate wins and note lessons learned from completed work.';
    }
  }

  IconData get icon {
    switch (this) {
      case TaskView.active:
        return Icons.all_inclusive;
      case TaskView.today:
        return Icons.wb_sunny_outlined;
      case TaskView.upcoming:
        return Icons.calendar_month;
      case TaskView.completed:
        return Icons.celebration;
    }
  }

  IconData get emptyIcon {
    switch (this) {
      case TaskView.active:
        return Icons.auto_awesome;
      case TaskView.today:
        return Icons.flag_circle;
      case TaskView.upcoming:
        return Icons.explore;
      case TaskView.completed:
        return Icons.emoji_events;
    }
  }

  String get emptyTitle {
    switch (this) {
      case TaskView.active:
        return 'Your slate is clear';
      case TaskView.today:
        return 'Nothing urgent today';
      case TaskView.upcoming:
        return 'No upcoming tasks yet';
      case TaskView.completed:
        return 'No completed tasks logged';
    }
  }

  String get emptyDescription {
    switch (this) {
      case TaskView.active:
        return 'Capture a micro task or revisit your rituals to keep momentum flowing.';
      case TaskView.today:
        return 'Consider scheduling a focus block or scouting the next milestone.';
      case TaskView.upcoming:
        return 'Use the planner to set due dates and avoid future friction.';
      case TaskView.completed:
        return 'Mark tasks complete to celebrate progress and fuel your streak.';
    }
  }
}

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  TaskView _view = TaskView.active;
  final Set<TaskPriority> _priorityFilter = TaskPriority.values.toSet();
  String _tagQuery = '';

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (BuildContext context, AppState state, Widget? _) {
        final ThemeData theme = Theme.of(context);
        final List<Task> tasks = _applyFilters(state);
        final List<Task> quickWins = state.quickWins;
        final List<Task> reflectionTasks = state.reflectionFriendlyTasks;

        return ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
          children: <Widget>[
            _buildViewSelector(theme),
            const SizedBox(height: 16),
            _buildFilterBar(theme),
            if (_view == TaskView.active && quickWins.isNotEmpty) ...<Widget>[
              const SizedBox(height: 16),
              _QuickWinsCarousel(tasks: quickWins),
            ],
            if (_view == TaskView.active && reflectionTasks.isNotEmpty) ...<Widget>[
              const SizedBox(height: 16),
              _ReflectionPrompt(tasks: reflectionTasks),
            ],
            const SizedBox(height: 16),
            if (tasks.isEmpty)
              _EmptyState(view: _view)
            else
              ...tasks.map((Task task) => _TaskCard(task: task)).toList(),
          ],
        );
      },
    );
  }

  Widget _buildViewSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Orchestrate your pipeline',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        SegmentedButton<TaskView>(
          segments: TaskView.values
              .map(
                (TaskView view) => ButtonSegment<TaskView>(
                  value: view,
                  icon: Icon(view.icon),
                  label: Text(view.label),
                ),
              )
              .toList(),
          selected: <TaskView>{_view},
          onSelectionChanged: (Set<TaskView> selection) {
            setState(() {
              _view = selection.first;
            });
          },
        ),
        const SizedBox(height: 8),
        Text(
          _view.description,
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildFilterBar(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextField(
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            labelText: 'Filter by tag or keyword',
          ),
          onChanged: (String value) {
            setState(() {
              _tagQuery = value.trim().toLowerCase();
            });
          },
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          children: TaskPriority.values.map((TaskPriority priority) {
            final bool selected = _priorityFilter.contains(priority);
            return FilterChip(
              label: Text(priority.label),
              selected: selected,
              onSelected: (bool value) {
                setState(() {
                  if (value) {
                    _priorityFilter.add(priority);
                  } else {
                    _priorityFilter.remove(priority);
                  }
                  if (_priorityFilter.isEmpty) {
                    _priorityFilter.addAll(TaskPriority.values);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  List<Task> _applyFilters(AppState state) {
    Iterable<Task> source;
    switch (_view) {
      case TaskView.active:
        source = state.activeTasks;
        break;
      case TaskView.today:
        source = state.activeTasks
            .where((Task task) => task.isDueToday || task.isOverdue);
        break;
      case TaskView.upcoming:
        source = state.dueSoon;
        break;
      case TaskView.completed:
        source = state.completedTasks;
        break;
    }

    return source
        .where((Task task) => _priorityFilter.contains(task.priority))
        .where((Task task) {
          if (_tagQuery.isEmpty) {
            return true;
          }
          final String lowerTitle = task.title.toLowerCase();
          final String lowerDescription = task.description.toLowerCase();
          final bool tagMatch =
              task.tags.any((String tag) => tag.toLowerCase().contains(_tagQuery));
          return lowerTitle.contains(_tagQuery) ||
              lowerDescription.contains(_tagQuery) ||
              tagMatch;
        })
        .toList();
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppState state = context.read<AppState>();
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: task.priority.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    task.priority == TaskPriority.high
                        ? Icons.whatshot
                        : task.priority == TaskPriority.medium
                            ? Icons.brightness_medium
                            : Icons.weekend,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        task.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        task.description,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: <Widget>[
                          Chip(
                            avatar: const Icon(Icons.timer_outlined),
                            label: Text('${task.estimatedMinutes} min plan'),
                          ),
                          if (task.dueDate != null)
                            Chip(
                              avatar: const Icon(Icons.event),
                              label: Text(
                                MaterialLocalizations.of(context)
                                    .formatMediumDate(task.dueDate!),
                              ),
                            ),
                          ...task.tags
                              .map((String tag) => Chip(label: Text(tag)))
                              .toList(),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: task.focusProgress,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${task.focusMinutes} of ${task.estimatedMinutes} minute goal logged',
                        style: theme.textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => state.toggleTaskCompletion(task.id),
                  icon: Icon(
                    task.isCompleted
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: task.isCompleted
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (task.isOverdue)
              Text(
                'Overdue — break it into a scout mission or swap with a lighter lift.',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    task.isCompleted
                        ? 'Completed ${task.completedAt != null ? MaterialLocalizations.of(context).formatShortDate(task.completedAt!) : ''}'
                        : 'Tap the checkmark when the next slice is complete.',
                    style: theme.textTheme.labelMedium,
                  ),
                ),
                FilledButton.tonalIcon(
                  onPressed: () => state.addFocusSession(
                    taskId: task.id,
                    duration: const Duration(minutes: 15),
                    note: 'Logged from task planner for accountability.',
                  ),
                  icon: const Icon(Icons.timelapse),
                  label: const Text('Log 15 min'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickWinsCarousel extends StatelessWidget {
  const _QuickWinsCarousel({required this.tasks});

  final List<Task> tasks;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Quick wins to build momentum',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: tasks.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (BuildContext context, int index) {
              final Task task = tasks[index];
              return Container(
                width: 220,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      task.title,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      task.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                    const Spacer(),
                    Text(
                      '${task.estimatedMinutes} min',
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ReflectionPrompt extends StatelessWidget {
  const _ReflectionPrompt({required this.tasks});

  final List<Task> tasks;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Reflection-friendly tasks',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            ...tasks.map(
              (Task task) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.menu_book_rounded),
                title: Text(task.title),
                subtitle: Text(task.description),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.view});

  final TaskView view;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(view.emptyIcon, size: 32, color: theme.colorScheme.primary),
          const SizedBox(height: 12),
          Text(
            view.emptyTitle,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            view.emptyDescription,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
