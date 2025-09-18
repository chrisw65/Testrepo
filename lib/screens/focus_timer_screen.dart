import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/support_ritual.dart';
import '../models/task.dart';
import '../state/app_state.dart';

class FocusTimerScreen extends StatefulWidget {
  const FocusTimerScreen({super.key});

  @override
  State<FocusTimerScreen> createState() => _FocusTimerScreenState();
}

class _FocusTimerScreenState extends State<FocusTimerScreen> {
  FocusMode _mode = FocusMode.deepWork;
  double _duration = FocusMode.deepWork.defaultMinutes.toDouble();
  Task? _selectedTask;
  bool _logIntention = true;
  final TextEditingController _intentionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _intentionController.text = _mode.defaultIntention;
  }

  @override
  void dispose() {
    _intentionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (BuildContext context, AppState state, Widget? _) {
        final ThemeData theme = Theme.of(context);
        final List<Task> activeTasks = state.activeTasks;
        if (_selectedTask != null &&
            activeTasks.every((Task task) => task.id != _selectedTask!.id)) {
          _selectedTask = null;
        }
        _selectedTask ??= activeTasks.isNotEmpty ? activeTasks.first : null;
        final List<SupportRitual> rituals =
            state.ritualsForMoment(RitualMoment.preFocus);
        final List<String> warmups = state.warmupPrompts;
        final List<String> decompression = state.decompressionIdeas;

        return ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
          children: <Widget>[
            _buildModeSelector(theme),
            const SizedBox(height: 24),
            _buildSessionDesigner(theme, state, activeTasks),
            const SizedBox(height: 24),
            _buildRituals(theme, rituals, warmups, decompression),
            const SizedBox(height: 24),
            _buildSessionHistory(theme, state),
          ],
        );
      },
    );
  }

  Widget _buildModeSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Choose your focus mode',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        SegmentedButton<FocusMode>(
          style: SegmentedButton.styleFrom(
            backgroundColor: theme.colorScheme.surfaceVariant,
            selectedBackgroundColor: theme.colorScheme.primary,
            selectedForegroundColor: theme.colorScheme.onPrimary,
          ),
          segments: FocusMode.values
              .map(
                (FocusMode mode) => ButtonSegment<FocusMode>(
                  value: mode,
                  label: Text(mode.label),
                  icon: Icon(mode.icon),
                ),
              )
              .toList(),
          selected: <FocusMode>{_mode},
          onSelectionChanged: (Set<FocusMode> selection) {
            setState(() {
              _mode = selection.first;
              _duration = _mode.defaultMinutes.toDouble();
              if (_intentionController.text.isEmpty) {
                _intentionController.text = _mode.defaultIntention;
              }
            });
          },
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[
                _mode.color.withOpacity(0.9),
                _mode.color.withOpacity(0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                _mode.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _mode.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onPrimary.withOpacity(0.85),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _mode.guidelines
                    .map(
                      (String guideline) => Chip(
                        label: Text(guideline),
                        backgroundColor:
                            theme.colorScheme.surface.withOpacity(0.2),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSessionDesigner(
    ThemeData theme,
    AppState state,
    List<Task> activeTasks,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Design your next session',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Task>(
              value: _selectedTask,
              items: activeTasks
                  .map(
                    (Task task) => DropdownMenuItem<Task>(
                      value: task,
                      child: Text(task.title),
                    ),
                  )
                  .toList(),
              decoration: const InputDecoration(
                labelText: 'Focus task',
                border: OutlineInputBorder(),
              ),
              onChanged: (Task? value) {
                setState(() {
                  _selectedTask = value;
                });
              },
            ),
            if (activeTasks.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  'No active tasks yet. Capture a quick win from the dashboard to get started.',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            const SizedBox(height: 16),
            Text('Session length: ${_duration.round()} minutes'),
            Slider(
              value: _duration,
              min: 10,
              max: 90,
              divisions: 16,
              label: _duration.round().toString(),
              onChanged: (double value) {
                setState(() {
                  _duration = value;
                });
              },
            ),
            SwitchListTile.adaptive(
              value: _logIntention,
              onChanged: (bool value) {
                setState(() {
                  _logIntention = value;
                });
              },
              title: const Text('Log an intention note for future you'),
              subtitle: const Text('Capture why this matters and how you will start.'),
            ),
            if (_logIntention)
              TextField(
                controller: _intentionController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Intention',
                  hintText: 'Example: Draft intro paragraph and note open questions.',
                ),
              ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _selectedTask == null
                  ? null
                  : () {
                      state.addFocusSession(
                        taskId: _selectedTask!.id,
                        duration: Duration(minutes: _duration.round()),
                        note: _logIntention ? _intentionController.text.trim() : null,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Logged a ${_duration.round()} minute session on ${_selectedTask!.title}.',
                          ),
                        ),
                      );
                    },
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Start focus block'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRituals(
    ThemeData theme,
    List<SupportRitual> rituals,
    List<String> warmups,
    List<String> decompression,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Prime your environment',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Warm-up prompts',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: warmups
                      .map(
                        (String prompt) => Chip(
                          avatar: const Icon(Icons.bolt_rounded),
                          label: Text(prompt),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 20),
                Text(
                  'Pre-focus ritual',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                if (rituals.isEmpty)
                  Text(
                    "Build a ritual that tells your brain it's time to create. Try pairing scent, sound, or movement.",
                    style: theme.textTheme.bodyMedium,
                  )
                else
                  Column(
                    children: rituals
                        .map(
                          (SupportRitual ritual) => ListTile(
                            leading: CircleAvatar(
                              backgroundColor: ritual.moment.color.withOpacity(0.3),
                              child: Icon(ritual.icon ?? Icons.emoji_objects_rounded),
                            ),
                            title: Text(ritual.title),
                            subtitle: Text(ritual.steps.join('\n')),
                          ),
                        )
                        .toList(),
                  ),
                const SizedBox(height: 20),
                Text(
                  'Cooldown ideas',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: decompression
                      .map(
                        (String idea) => Chip(
                          avatar: const Icon(Icons.self_improvement_rounded),
                          label: Text(idea),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSessionHistory(ThemeData theme, AppState state) {
    final sessions = state.recentSessions;
    if (sessions.isEmpty) {
      return const SizedBox();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Recent focus sessions',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: sessions.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (BuildContext context, int index) {
              final session = sessions[index];
              final String date = MaterialLocalizations.of(context)
                  .formatMediumDate(session.startedAt);
              final String time = MaterialLocalizations.of(context)
                  .formatTimeOfDay(TimeOfDay.fromDateTime(session.startedAt));
              final Task? task = state.tasks
                  .firstWhere((Task task) => task.id == session.taskId, orElse: () => Task(
                        id: session.taskId,
                        title: 'Archived task',
                        description: '',
                      ));
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text('${session.durationMinutes}'),
                ),
                title: Text(task.title),
                subtitle: Text('$date · $time'),
                trailing: Icon(
                  session.completed ? Icons.check_circle : Icons.schedule,
                  color: session.completed
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

enum FocusMode { deepWork, momentum, recovery }

extension FocusModeX on FocusMode {
  String get label {
    switch (this) {
      case FocusMode.deepWork:
        return 'Deep work';
      case FocusMode.momentum:
        return 'Momentum';
      case FocusMode.recovery:
        return 'Recovery';
    }
  }

  String get title {
    switch (this) {
      case FocusMode.deepWork:
        return 'Immersive creation';
      case FocusMode.momentum:
        return 'Momentum booster';
      case FocusMode.recovery:
        return 'Gentle reset';
    }
  }

  String get description {
    switch (this) {
      case FocusMode.deepWork:
        return 'Protect 45-60 minutes for your most cognitively demanding work. Remove distractions and set a bold intention.';
      case FocusMode.momentum:
        return 'Build traction with a 25-minute sprint. Perfect for finishing a slice or revisiting a quick win.';
      case FocusMode.recovery:
        return 'Recharge with a 15-minute reflective block. Tie up loose ends, celebrate, and prepare for tomorrow.';
    }
  }

  List<String> get guidelines {
    switch (this) {
      case FocusMode.deepWork:
        return const <String>[
          'Silence notifications',
          'Define success for this block',
          'Schedule a micro celebration',
        ];
      case FocusMode.momentum:
        return const <String>[
          'Start with the tiniest action',
          'Use a timer and commit to just one round',
          'Switch contexts intentionally',
        ];
      case FocusMode.recovery:
        return const <String>[
          'Summarize a lesson learned',
          'Capture gratitude for progress',
          'Prime tomorrow with a note',
        ];
    }
  }

  IconData get icon {
    switch (this) {
      case FocusMode.deepWork:
        return Icons.bolt_rounded;
      case FocusMode.momentum:
        return Icons.trending_up_rounded;
      case FocusMode.recovery:
        return Icons.self_improvement_rounded;
    }
  }

  Color get color {
    switch (this) {
      case FocusMode.deepWork:
        return Colors.deepPurpleAccent;
      case FocusMode.momentum:
        return Colors.tealAccent;
      case FocusMode.recovery:
        return Colors.orangeAccent;
    }
  }

  int get defaultMinutes {
    switch (this) {
      case FocusMode.deepWork:
        return 50;
      case FocusMode.momentum:
        return 25;
      case FocusMode.recovery:
        return 15;
    }
  }

  String get defaultIntention {
    switch (this) {
      case FocusMode.deepWork:
        return 'Ship a bold, imperfect draft to unblock progress.';
      case FocusMode.momentum:
        return 'Complete one micro-step and capture the next.';
      case FocusMode.recovery:
        return "Reflect on wins and stage tomorrow's launch point.";
    }
  }
}
