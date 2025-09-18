import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../state/app_state.dart';

class FocusTimerScreen extends StatefulWidget {
  const FocusTimerScreen({super.key});

  @override
  State<FocusTimerScreen> createState() => _FocusTimerScreenState();
}

class _FocusTimerScreenState extends State<FocusTimerScreen> {
  Timer? _timer;
  Duration _selectedDuration = const Duration(minutes: 25);
  Duration _remaining = const Duration(minutes: 25);
  bool _isRunning = false;
  String? _selectedTaskId;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'Focus timer',
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            'Pick a task, choose your sprint length, and start a distraction-free block.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          _buildTaskPicker(state),
          const SizedBox(height: 24),
          _buildDurationSelector(context),
          const SizedBox(height: 24),
          Expanded(
            child: Center(
              child: _buildTimer(theme),
            ),
          ),
          const SizedBox(height: 24),
          _buildControls(theme),
          const SizedBox(height: 12),
          _buildSessionTips(theme),
        ],
      ),
    );
  }

  Widget _buildTaskPicker(AppState state) {
    final List<Task> tasks = state.activeTasks;
    return DropdownButtonFormField<String>(
      value: _selectedTaskId,
      hint: const Text('Select focus task'),
      items: tasks
          .map(
            (Task task) => DropdownMenuItem<String>(
              value: task.id,
              child: Text(task.title),
            ),
          )
          .toList(),
      onChanged: (String? value) {
        setState(() {
          _selectedTaskId = value;
        });
      },
    );
  }

  Widget _buildDurationSelector(BuildContext context) {
    final List<Widget> chips = _presetDurations
        .map((int minutes) => ChoiceChip(
              label: Text('$minutes min'),
              selected: _selectedDuration.inMinutes == minutes,
              onSelected: (bool selected) {
                if (!selected) {
                  return;
                }
                setState(() {
                  _selectedDuration = Duration(minutes: minutes);
                  _remaining = _selectedDuration;
                });
              },
            ))
        .toList();
    chips.add(
      ChoiceChip(
        label: const Text('Custom'),
        selected: !_presetDurations.contains(_selectedDuration.inMinutes),
        onSelected: (_) async {
          final int? customMinutes = await _askForCustomDuration(context);
          if (customMinutes != null) {
            setState(() {
              _selectedDuration = Duration(minutes: customMinutes);
              _remaining = _selectedDuration;
            });
          }
        },
      ),
    );
    return Wrap(
      spacing: 12,
      children: chips,
    );
  }

  Widget _buildTimer(ThemeData theme) {
    final int totalSeconds = _selectedDuration.inSeconds;
    final double progress = totalSeconds == 0
        ? 0
        : 1 - (_remaining.inSeconds / totalSeconds).clamp(0.0, 1.0);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 260,
      height: 260,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            theme.colorScheme.primary.withOpacity(0.15),
            theme.colorScheme.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(200),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          SizedBox(
            width: 220,
            height: 220,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 12,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                _formatDuration(_remaining),
                style: theme.textTheme.displaySmall?.copyWith(
                  fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 8),
              Text(_isRunning ? 'You are in the zone' : 'Ready when you are'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControls(ThemeData theme) {
    final bool hasSelection = _selectedTaskId != null;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ElevatedButton.icon(
          onPressed: hasSelection ? (_isRunning ? _pause : _start) : _promptForTask,
          icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
          label: Text(_isRunning ? 'Pause' : 'Start focus'),
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: _isRunning ? () => _completeSession(auto: false) : _reset,
          icon: Icon(_isRunning ? Icons.flag : Icons.restart_alt),
          label: Text(_isRunning ? 'Finish early' : 'Reset'),
        ),
      ],
    );
  }

  Widget _buildSessionTips(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const <Widget>[
          Text(
            'Micro-commitment tip',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 6),
          Text(
            'Silence notifications, write down your starting action, and promise yourself a break when the timer ends.',
          ),
        ],
      ),
    );
  }

  void _start() {
    setState(() {
      _isRunning = true;
      _remaining = _selectedDuration;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (_remaining.inSeconds <= 1) {
        timer.cancel();
        _completeSession(auto: true);
      } else {
        setState(() {
          _remaining -= const Duration(seconds: 1);
        });
      }
    });
  }

  void _pause() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _remaining = _selectedDuration;
    });
  }

  void _completeSession({required bool auto}) {
    _timer?.cancel();
    final String? taskId = _selectedTaskId;
    if (taskId == null) {
      _reset();
      return;
    }
    final int loggedMinutes = auto
        ? _selectedDuration.inMinutes
        : (_selectedDuration - _remaining).inMinutes;
    final int safeMinutes = loggedMinutes <= 0 ? 1 : loggedMinutes;
    final AppState state = context.read<AppState>();
    state.addFocusSession(
      taskId: taskId,
      duration: Duration(minutes: safeMinutes),
      completed: auto,
      note: auto ? 'Completed focus block' : 'Stopped early',
    );
    setState(() {
      _isRunning = false;
      _remaining = _selectedDuration;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          auto
              ? 'Nice work! Log a quick win before moving on.'
              : 'Session saved. Consider adjusting the duration next time.',
        ),
      ),
    );
  }

  void _promptForTask() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Select a task to stay intentional.')),
    );
  }

  String _formatDuration(Duration duration) {
    final String minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final String seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (duration.inHours > 0) {
      return '${duration.inHours.toString().padLeft(2, '0')}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  List<int> get _presetDurations => const <int>[15, 25, 45];

  Future<int?> _askForCustomDuration(BuildContext context) async {
    final TextEditingController controller =
        TextEditingController(text: _selectedDuration.inMinutes.toString());
    final int? result = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Custom duration'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'Minutes'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final int? value = int.tryParse(controller.text);
                if (value == null || value <= 0) {
                  return;
                }
                Navigator.of(context).pop(value);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    return result;
  }
}
