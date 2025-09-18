import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/focus_session.dart';
import '../models/task.dart';
import '../state/app_state.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (BuildContext context, AppState state, Widget? _) {
        final ThemeData theme = Theme.of(context);
        final List<String> suggestions = _buildSuggestions(state);
        return ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Text(
              'Progress pulse',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildStatHighlights(context, state),
            const SizedBox(height: 16),
            _buildRecentSessions(context, state),
            const SizedBox(height: 16),
            _buildWins(context, state),
            const SizedBox(height: 16),
            _buildSuggestionsCard(context, suggestions),
          ],
        );
      },
    );
  }

  Widget _buildStatHighlights(BuildContext context, AppState state) {
    final ThemeData theme = Theme.of(context);
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: <Widget>[
            Expanded(
              child: _StatTile(
                label: 'Completion rate',
                value: '${(state.completionRate * 100).round()}%',
                contextText: '${state.completedTasks.length}/${state.tasks.length} tasks',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatTile(
                label: 'Weekly focus',
                value: '${state.focusMinutesThisWeek} min',
                contextText: 'Lifetime ${state.totalFocusMinutes} min',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatTile(
                label: 'Momentum streak',
                value: '${state.streak} days',
                contextText: state.streak >= 3
                    ? 'Keep stacking wins'
                    : 'Complete a task tomorrow',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSessions(BuildContext context, AppState state) {
    final ThemeData theme = Theme.of(context);
    final List<FocusSession> sessions = state.recentSessions;
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Recent focus logs',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            if (sessions.isEmpty)
              Text(
                'Start the timer to create a streak of completed focus blocks.',
                style: theme.textTheme.bodyMedium,
              )
            else
              Column(
                children: sessions
                    .map(
                      (FocusSession session) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.self_improvement),
                        title: Text('${session.durationMinutes} minute block'),
                        subtitle: Text(_formatSessionSubtitle(context, session)),
                        trailing: Icon(
                          session.completed ? Icons.check_circle : Icons.flag,
                          color: session.completed
                              ? theme.colorScheme.primary
                              : theme.colorScheme.secondary,
                        ),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWins(BuildContext context, AppState state) {
    final ThemeData theme = Theme.of(context);
    final List<Task> completed = state.completedTasks.take(3).toList();
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Momentum wins',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            if (completed.isEmpty)
              Text(
                'Complete one micro-task today so you can capture it here tomorrow.',
                style: theme.textTheme.bodyMedium,
              )
            else
              Column(
                children: completed
                    .map(
                      (task) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.emoji_events, color: task.priority.color),
                        title: Text(task.title),
                        subtitle: Text(task.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionsCard(BuildContext context, List<String> suggestions) {
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
              'Suggested experiments',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(height: 12),
            for (final String idea in suggestions)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text('• '),
                    Expanded(
                      child: Text(
                        idea,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: theme.colorScheme.onSecondaryContainer),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<String> _buildSuggestions(AppState state) {
    final List<String> suggestions = <String>[];
    if (state.completionRate < 0.5 && state.activeTasks.length >= 3) {
      suggestions.add('Pick your top three priorities tonight so you start tomorrow with clarity.');
    }
    if (state.focusMinutesThisWeek < 60) {
      suggestions.add('Schedule two 25-minute focus sessions and guard them like meetings with yourself.');
    }
    if (state.streak < 3) {
      suggestions.add('Complete one tiny task before noon to rebuild your streak early in the day.');
    } else {
      suggestions.add('Celebrate your streak by noting the rituals that make starting easier.');
    }
    if (suggestions.isEmpty()) {
      suggestions.add('You are building strong habits. Try mentoring a friend or documenting your playbook.');
    }
    return suggestions;
  }

  String _formatSessionSubtitle(BuildContext context, FocusSession session) {
    final DateTime now = DateTime.now();
    final Duration diff = now.difference(session.startedAt);
    final TimeOfDay time = TimeOfDay.fromDateTime(session.startedAt);
    String timeLabel = time.format(context);
    if (diff.inDays == 0) {
      return 'Today • $timeLabel';
    }
    if (diff.inDays == 1) {
      return 'Yesterday • $timeLabel';
    }
    return '${session.startedAt.month}/${session.startedAt.day}/${session.startedAt.year} • $timeLabel';
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.contextText,
  });

  final String label;
  final String value;
  final String contextText;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: theme.textTheme.labelMedium),
        const SizedBox(height: 6),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(contextText, style: theme.textTheme.bodySmall),
      ],
    );
  }
}
