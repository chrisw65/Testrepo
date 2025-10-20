import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/habit.dart';
import '../models/procrastination_trigger.dart';
import '../models/reflection_entry.dart';
import '../models/support_ritual.dart';
import '../models/task.dart';
import '../state/app_state.dart';
import '../widgets/focus_heatmap.dart';
import '../widgets/gradient_card.dart';
import '../widgets/progress_ring.dart';
import '../widgets/sparkline_chart.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (BuildContext context, AppState state, Widget? child) {
        return CustomScrollView(
          slivers: <Widget>[
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  <Widget>[
                    _MomentumHero(state: state),
                    const SizedBox(height: 24),
                    _HabitSummary(state: state),
                    const SizedBox(height: 24),
                    _FocusBlueprint(state: state),
                    const SizedBox(height: 24),
                    _RitualStack(state: state),
                    const SizedBox(height: 24),
                    _WellbeingPulse(state: state),
                    const SizedBox(height: 24),
                    _MomentumAnalytics(state: state),
                    const SizedBox(height: 24),
                    _AntidoteShowcase(state: state),
                    const SizedBox(height: 64),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MomentumHero extends StatelessWidget {
  const _MomentumHero({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String today =
        MaterialLocalizations.of(context).formatMediumDate(DateTime.now());
    return GradientCard(
      title: 'Good things build today',
      subtitle:
          "It's $today. Protect your streak and let tiny wins compound.",
      gradient: LinearGradient(
        colors: <Color>[
          theme.colorScheme.primary,
          theme.colorScheme.primary.withOpacity(0.7),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      leading: const Icon(Icons.auto_awesome_rounded, size: 40, color: Colors.white),
      trailing: ProgressRing(
        progress: state.completionRate.clamp(0, 1),
        color: theme.colorScheme.onPrimary,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              '${(state.completionRate * 100).round()}%',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Complete',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        runSpacing: 12,
        children: <Widget>[
          _MetricChip(
            label: 'Focus minutes this week',
            value: '${state.focusMinutesThisWeek}',
            icon: Icons.timer_outlined,
          ),
          _MetricChip(
            label: 'Active streak',
            value: '${state.streak} day${state.streak == 1 ? '' : 's'}',
            icon: Icons.local_fire_department,
          ),
          _MetricChip(
            label: 'Avg. session',
            value: state.averageSessionDuration == Duration.zero
                ? '—'
                : '${state.averageSessionDuration.inMinutes} min',
            icon: Icons.timelapse,
          ),
        ],
      ),
    );
  }
}

class _FocusBlueprint extends StatelessWidget {
  const _FocusBlueprint({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<Task> deepWork = state.deepFocusCandidates.take(2).toList();
    final List<Task> quickWins = state.quickWins.take(3).toList();
    final List<Task> dueSoon = state.dueSoon;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Game plan',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Prime one deep focus block, then chain a quick win.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                if (deepWork.isNotEmpty)
                  _TaskStrip(
                    headline: 'Deep focus candidates',
                    icon: Icons.workspace_premium_outlined,
                    color: theme.colorScheme.primary,
                    tasks: deepWork,
                    emphasizeMinutes: true,
                  ),
                if (quickWins.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 16),
                  _TaskStrip(
                    headline: 'Quick wins for momentum',
                    icon: Icons.flash_on_rounded,
                    color: theme.colorScheme.tertiary,
                    tasks: quickWins,
                  ),
                ],
                if (dueSoon.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 16),
                  _TaskStrip(
                    headline: 'Coming up soon',
                    icon: Icons.upcoming_rounded,
                    color: theme.colorScheme.secondary,
                    tasks: dueSoon,
                    showDueDates: true,
                  ),
                ],
                if (quickWins.isEmpty && deepWork.isEmpty && dueSoon.isEmpty)
                  Text(
                    'You are all caught up! Use this space for a celebration ritual or playful experiment.',
                    style: theme.textTheme.bodyMedium,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RitualStack extends StatelessWidget {
  const _RitualStack({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<SupportRitual> rituals = state.rituals.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Ritual stack',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 360,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (BuildContext context, int index) {
              final SupportRitual ritual = rituals[index];
              return _RitualCard(ritual: ritual);
            },
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemCount: rituals.length,
          ),
        ),
      ],
    );
  }
}

class _WellbeingPulse extends StatelessWidget {
  const _WellbeingPulse({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ReflectionEntry? reflection = state.todayReflection ?? state.latestReflection;
    final List<String> prompts = reflection?.intentions ?? state.warmupPrompts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Wellbeing pulse',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (reflection != null) ...<Widget>[
                  Row(
                    children: <Widget>[
                      Icon(Icons.favorite_rounded, color: reflection.accentColor),
                      const SizedBox(width: 12),
                      Text(
                        reflection.title,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: reflection.highlights
                        .map(
                          (String highlight) => Chip(
                            label: Text(highlight),
                            backgroundColor: reflection.accentColor.withOpacity(0.15),
                          ),
                        )
                        .toList(),
                  ),
                  if (reflection.note != null) ...<Widget>[
                    const SizedBox(height: 12),
                    Text(
                      reflection.note!,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                  const SizedBox(height: 20),
                  Text(
                    'Intentions',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ]
                else ...<Widget>[
                  Text(
                    'Log a quick reflection to see how your energy, mood, and focus trend.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                ],
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: prompts
                      .map((String prompt) => Chip(
                            avatar: const Icon(Icons.edit_note_rounded),
                            label: Text(prompt),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HabitSummary extends StatelessWidget {
  const _HabitSummary({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<Habit> activeHabits = state.activeHabits;
    final int completedToday = state.habitsCompletedToday;
    final double completionRate = state.todayHabitCompletionRate;

    if (activeHabits.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'Today\'s habits',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            TextButton.icon(
              onPressed: () {
                // Navigation will be handled automatically when user clicks the Habits tab
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('View all'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '$completedToday of ${activeHabits.length} completed',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            completionRate == 1.0
                                ? 'Perfect day! All habits completed! 🎉'
                                : completionRate >= 0.7
                                    ? 'Great progress! Keep the momentum!'
                                    : 'You\'ve got this! Every habit counts.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: Stack(
                        fit: StackFit.expand,
                        children: <Widget>[
                          CircularProgressIndicator(
                            value: completionRate,
                            strokeWidth: 8,
                            backgroundColor:
                                theme.colorScheme.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              completionRate >= 0.7
                                  ? Colors.green
                                  : theme.colorScheme.primary,
                            ),
                          ),
                          Center(
                            child: Text(
                              '${(completionRate * 100).round()}%',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Quick check-in',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                ...activeHabits.take(3).map((Habit habit) {
                  final bool isCompleted = habit.isCompletedToday;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? habit.color.withOpacity(0.1)
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCompleted
                            ? habit.color.withOpacity(0.3)
                            : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        GestureDetector(
                          onTap: () => state.toggleHabitCompletion(habit.id),
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isCompleted
                                  ? habit.color
                                  : Colors.transparent,
                              border: Border.all(
                                color: habit.color,
                                width: 2,
                              ),
                            ),
                            child: isCompleted
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 16,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          habit.icon,
                          size: 18,
                          color: habit.color,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            habit.name,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: isCompleted
                                  ? theme.colorScheme.onSurface.withOpacity(0.6)
                                  : null,
                            ),
                          ),
                        ),
                        if (habit.currentStreak > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const Icon(
                                  Icons.local_fire_department,
                                  size: 12,
                                  color: Colors.orange,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${habit.currentStreak}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  );
                }),
                if (activeHabits.length > 3) ...<Widget>[
                  const SizedBox(height: 12),
                  Text(
                    'and ${activeHabits.length - 3} more habit${activeHabits.length - 3 != 1 ? 's' : ''}...',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MomentumAnalytics extends StatelessWidget {
  const _MomentumAnalytics({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Map<String, double> tags = state.tagDistribution;
    final List<int> focusSeries = state.lastSevenDayFocusMinutes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Momentum analytics',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Focus trend (last 7 days)',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                SparklineChart(values: focusSeries),
                const SizedBox(height: 20),
                Text(
                  'Tag distribution',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                if (tags.isEmpty)
                  Text(
                    'Add more tasks with tags to see where your energy is invested.',
                    style: theme.textTheme.bodyMedium,
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: tags.entries
                        .map(
                          (MapEntry<String, double> entry) => Chip(
                            avatar: CircleAvatar(
                              backgroundColor: theme.colorScheme.primaryContainer,
                              child: Text(
                                '${(entry.value * 100).round()}%',
                                style: theme.textTheme.labelSmall,
                              ),
                            ),
                            label: Text(entry.key),
                          ),
                        )
                        .toList(),
                  ),
                const SizedBox(height: 20),
                Text(
                  'Focus heatmap (14 days)',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                FocusHeatmap(focusMinutesByDay: state.focusMinutesByDay),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AntidoteShowcase extends StatelessWidget {
  const _AntidoteShowcase({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<ProcrastinationTrigger> triggers = state.recommendedTriggers;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Antidotes for resistance',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Column(
          children: triggers
              .map((ProcrastinationTrigger trigger) => _TriggerTile(trigger: trigger))
              .toList(),
        ),
      ],
    );
  }
}

class _TriggerTile extends StatelessWidget {
  const _TriggerTile({required this.trigger});

  final ProcrastinationTrigger trigger;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                CircleAvatar(
                  backgroundColor: trigger.category.color.withOpacity(0.2),
                  child: Icon(trigger.category.icon, color: trigger.category.color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        trigger.headline,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        trigger.category.label,
                        style: theme.textTheme.labelLarge,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              trigger.description,
              style: theme.textTheme.bodyMedium,
            ),
            if (trigger.antidotes.isNotEmpty) ...<Widget>[
              const SizedBox(height: 12),
              Text(
                'Try this:',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              _BulletList(items: trigger.antidotes),
            ],
            if (trigger.microSteps.isNotEmpty) ...<Widget>[
              const SizedBox(height: 12),
              Text(
                'Micro-steps:',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              _BulletList(items: trigger.microSteps),
            ],
            if (trigger.supportingQuestions.isNotEmpty) ...<Widget>[
              const SizedBox(height: 12),
              Text(
                'Questions to unlock clarity',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              _BulletList(items: trigger.supportingQuestions),
            ],
          ],
        ),
      ),
    );
  }
}

class _RitualCard extends StatelessWidget {
  const _RitualCard({required this.ritual});

  final SupportRitual ritual;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: ritual.moment.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ritual.moment.color.withOpacity(0.4)),
      ),
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(ritual.icon ?? Icons.auto_awesome, color: ritual.moment.color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ritual.moment.label,
                    style: theme.textTheme.labelLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              ritual.title,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              ritual.description,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            ...ritual.steps
                .map(
                  (String step) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Icon(Icons.check_circle_outline, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            step,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
            if (ritual.affirmation != null)
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '"${ritual.affirmation!}"',
                  style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TaskStrip extends StatelessWidget {
  const _TaskStrip({
    required this.headline,
    required this.icon,
    required this.color,
    required this.tasks,
    this.emphasizeMinutes = false,
    this.showDueDates = false,
  });

  final String headline;
  final IconData icon;
  final Color color;
  final List<Task> tasks;
  final bool emphasizeMinutes;
  final bool showDueDates;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(
              headline,
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...tasks.map((Task task) {
          final String subtitle = showDueDates && task.dueDate != null
              ? 'Due ${MaterialLocalizations.of(context).formatMediumDate(task.dueDate!)}'
              : task.description;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: <Widget>[
                Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      emphasizeMinutes ? '${task.estimatedMinutes}' : task.priority.label[0],
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        task.title,
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      '${task.estimatedMinutes} min',
                      style: theme.textTheme.labelSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      task.tags.join(' · '),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BulletList extends StatelessWidget {
  const _BulletList({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (String item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('• '),
                  Expanded(
                    child: Text(
                      item,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
