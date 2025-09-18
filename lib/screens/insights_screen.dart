import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/procrastination_trigger.dart';
import '../models/reflection_entry.dart';
import '../state/app_state.dart';
import '../widgets/focus_heatmap.dart';
import '../widgets/sparkline_chart.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (BuildContext context, AppState state, Widget? _) {
        final ThemeData theme = Theme.of(context);
        final List<ReflectionEntry> reflections = state.recentReflections;
        final List<int> focusSeries = state.lastSevenDayFocusMinutes;
        final Map<String, double> tags = state.tagDistribution;
        final List<ProcrastinationTrigger> triggers = state.recommendedTriggers;

        return ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
          children: <Widget>[
            const _SectionHeader(
              title: 'Focus trends',
              subtitle: 'Spot how your attention evolves and celebrate the habits that help.',
            ),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Weekly focus sparkline',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    SparklineChart(values: focusSeries),
                    const SizedBox(height: 20),
                    Text(
                      'Focus heatmap (14 days)',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    FocusHeatmap(focusMinutesByDay: state.focusMinutesByDay),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const _SectionHeader(
              title: 'Wellbeing intelligence',
              subtitle: 'Track mood, energy, and focus to design supportive rituals.',
            ),
            _ReflectionTimeline(reflections: reflections),
            const SizedBox(height: 24),
            const _SectionHeader(
              title: 'Tag balance & energy mix',
              subtitle: 'See where your effort flows and how to rebalance when resistance builds.',
            ),
            _TagDistribution(tags: tags),
            const SizedBox(height: 24),
            const _SectionHeader(
              title: 'Antidote library',
              subtitle: 'Choose antidotes for current friction and capture your favourite micro-steps.',
            ),
            _TriggerBoard(triggers: triggers),
            const SizedBox(height: 24),
            const _SectionHeader(
              title: 'Celebration prompts',
              subtitle: 'Use these reflective prompts to reinforce momentum at the end of the day.',
            ),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: state.celebrationPrompts
                  .map(
                    (String prompt) => Chip(
                      avatar: const Icon(Icons.celebration),
                      label: Text(prompt),
                    ),
                  )
                  .toList(),
            ),
          ],
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _ReflectionTimeline extends StatelessWidget {
  const _ReflectionTimeline({required this.reflections});

  final List<ReflectionEntry> reflections;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    if (reflections.isEmpty) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'Log reflections after each focus block to visualise your wellbeing trends.',
            style: theme.textTheme.bodyMedium,
          ),
        ),
      );
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        itemCount: reflections.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (BuildContext context, int index) {
          final ReflectionEntry entry = reflections[index];
          final String date = MaterialLocalizations.of(context)
              .formatMediumDate(entry.date);
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: entry.accentColor.withOpacity(0.2),
              child: Text('${(entry.wellbeingScore * 100).round()}%'),
            ),
            title: Text(date),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(entry.title),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: entry.highlights
                      .map(
                        (String highlight) => Chip(
                          label: Text(highlight),
                        ),
                      )
                      .toList(),
                ),
                if (entry.note != null) ...<Widget>[
                  const SizedBox(height: 8),
                  Text(entry.note!),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TagDistribution extends StatelessWidget {
  const _TagDistribution({required this.tags});

  final Map<String, double> tags;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    if (tags.isEmpty) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'Add tags to tasks to see how your portfolio of work is distributed.',
            style: theme.textTheme.bodyMedium,
          ),
        ),
      );
    }

    final List<MapEntry<String, double>> entries = tags.entries.toList()
      ..sort((MapEntry<String, double> a, MapEntry<String, double> b) =>
          b.value.compareTo(a.value));

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: entries.map((MapEntry<String, double> entry) {
            final double percentage = entry.value * 100;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(entry.key, style: theme.textTheme.titleSmall),
                      Text('${percentage.toStringAsFixed(0)}%'),
                    ],
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: entry.value,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _TriggerBoard extends StatelessWidget {
  const _TriggerBoard({required this.triggers});

  final List<ProcrastinationTrigger> triggers;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    if (triggers.isEmpty) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'No friction patterns detected yet. Keep logging focus blocks to surface suggestions.',
            style: theme.textTheme.bodyMedium,
          ),
        ),
      );
    }

    return Column(
      children: triggers
          .map(
            (ProcrastinationTrigger trigger) => Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
                                style:
                                    theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              Text(trigger.category.label),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(trigger.description),
                    if (trigger.antidotes.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 12),
                      Text(
                        'Antidotes',
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      ...trigger.antidotes.map((String antidote) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text('• $antidote'),
                          )),
                    ],
                    if (trigger.microSteps.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 12),
                      Text(
                        'Micro-steps to try',
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: trigger.microSteps
                            .map((String step) => Chip(label: Text(step)))
                            .toList(),
                      ),
                    ],
                    if (trigger.supportingQuestions.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 12),
                      Text(
                        'Questions to unblock you',
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      ...trigger.supportingQuestions.map((String question) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text('• $question'),
                          )),
                    ],
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
