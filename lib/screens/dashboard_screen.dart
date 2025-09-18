import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../widgets/progress_ring.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (BuildContext context, AppState state, Widget? _) {
        final ThemeData theme = Theme.of(context);
        return ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Text(
              'Daily momentum',
              style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildStreakCard(context, state),
            const SizedBox(height: 16),
            _buildFocusSummary(context, state),
            const SizedBox(height: 16),
            _buildUpcomingTasks(context, state),
            const SizedBox(height: 16),
            _buildTagDistribution(context, state),
            const SizedBox(height: 16),
            _buildReflectionPrompt(context),
          ],
        );
      },
    );
  }

  Widget _buildStreakCard(BuildContext context, AppState state) {
    final ThemeData theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: <Widget>[
            ProgressRing(
              progress: state.completionRate,
              color: theme.colorScheme.onPrimaryContainer,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    '${(state.completionRate * 100).round()}%',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Done',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Streak: ${state.streak} days',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${state.completedToday} task(s) completed today',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: state.focusMinutesThisWeek == 0
                        ? 0
                        : state.totalFocusMinutes == 0
                            ? 0
                            : state.focusMinutesThisWeek / state.totalFocusMinutes,
                    minHeight: 8,
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Weekly focus: ${state.focusMinutesThisWeek} min',
                    style: theme.textTheme.labelMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFocusSummary(BuildContext context, AppState state) {
    final ThemeData theme = Theme.of(context);
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Focus recommendations',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            if (state.activeTasks.isEmpty)
              Text(
                'You are all caught up! Take a mindful break or reflect on what helped you today.',
                style: theme.textTheme.bodyMedium,
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Try a ${state.activeTasks.first.estimatedMinutes}-minute deep work sprint on:',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  _buildTaskHighlight(theme, state.activeTasks.first.title, state.activeTasks.first.description),
                  if (state.activeTasks.length > 1) ...<Widget>[
                    const SizedBox(height: 12),
                    Text(
                      'Need variety? Rotate with these tasks to keep your momentum fresh:',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: state.activeTasks
                          .skip(1)
                          .take(3)
                          .map((task) => Chip(
                                label: Text(task.title),
                                backgroundColor: theme.colorScheme.surfaceVariant,
                              ))
                          .toList(),
                    ),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskHighlight(ThemeData theme, String title, String description) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingTasks(BuildContext context, AppState state) {
    final ThemeData theme = Theme.of(context);
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Upcoming checkpoints',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            if (state.dueSoon.isEmpty)
              Text(
                'No urgent deadlines. Consider reviewing long-term goals or creating a new experiment.',
                style: theme.textTheme.bodyMedium,
              )
            else
              Column(
                children: state.dueSoon
                    .map((task) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            Icons.flag,
                            color: task.priority.color,
                          ),
                          title: Text(task.title),
                          subtitle: Text(
                            task.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text('${task.estimatedMinutes} min'),
                              if (task.dueDate != null)
                                Text(
                                  _formatDueDate(task.dueDate!),
                                  style: theme.textTheme.labelSmall,
                                ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagDistribution(BuildContext context, AppState state) {
    final ThemeData theme = Theme.of(context);
    final Map<String, double> distribution = state.tagDistribution;
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Energy mix',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            if (distribution.isEmpty)
              Text(
                'Tag your tasks to balance planning, execution, and restoration.',
                style: theme.textTheme.bodyMedium,
              )
            else
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: distribution.entries
                    .map(
                      (MapEntry<String, double> entry) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          SizedBox(
                            width: 80,
                            child: LinearProgressIndicator(
                              value: entry.value,
                              minHeight: 8,
                              borderRadius: const BorderRadius.all(Radius.circular(8)),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(entry.key, style: theme.textTheme.labelMedium),
                          Text('${(entry.value * 100).round()}%',
                              style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReflectionPrompt(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Reflection prompt',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'What helped you start today? Capture it before you forget so future-you has a playbook.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDueDate(DateTime dueDate) {
    if (DateUtils.isSameDay(dueDate, DateTime.now())) {
      return 'Today';
    }
    if (DateUtils.isSameDay(dueDate, DateTime.now().add(const Duration(days: 1)))) {
      return 'Tomorrow';
    }
    return '${dueDate.month}/${dueDate.day}';
  }
}
