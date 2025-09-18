import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../state/app_state.dart';

enum TaskFilter { all, active, completed }

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  TaskFilter _filter = TaskFilter.active;

  @override
  Widget build(BuildContext context) {
    final AppState appState = context.watch<AppState>();
    final List<Task> tasks = _applyFilter(appState);
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openTaskComposer(context),
        icon: const Icon(Icons.add_task),
        label: const Text('New task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Plan your focus',
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                SegmentedButton<TaskFilter>(
                  segments: const <ButtonSegment<TaskFilter>>[
                    ButtonSegment<TaskFilter>(value: TaskFilter.active, label: Text('Active')),
                    ButtonSegment<TaskFilter>(value: TaskFilter.completed, label: Text('Done')),
                    ButtonSegment<TaskFilter>(value: TaskFilter.all, label: Text('All')),
                  ],
                  selected: <TaskFilter>{_filter},
                  onSelectionChanged: (Set<TaskFilter> selection) {
                    setState(() {
                      _filter = selection.first;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (tasks.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    _emptyLabel(),
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemBuilder: (BuildContext context, int index) {
                    final Task task = tasks[index];
                    return _TaskTile(task: task);
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemCount: tasks.length,
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Task> _applyFilter(AppState state) {
    switch (_filter) {
      case TaskFilter.all:
        return state.tasks.toList();
      case TaskFilter.active:
        return state.activeTasks;
      case TaskFilter.completed:
        return state.completedTasks;
    }
  }

  String _emptyLabel() {
    switch (_filter) {
      case TaskFilter.all:
        return 'No tasks yet. Create one experiment to try today.';
      case TaskFilter.active:
        return 'All tasks are complete! Celebrate and schedule your next focus block.';
      case TaskFilter.completed:
        return 'Once you complete tasks, they will show up here.';
    }
  }

  Future<void> _openTaskComposer(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) => const _TaskComposerSheet(),
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final AppState state = context.read<AppState>();
    final ThemeData theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => state.toggleTaskCompletion(task.id),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Checkbox(
                value: task.isCompleted,
                onChanged: (_) => state.toggleTaskCompletion(task.id),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            task.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: task.priority.color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            task.priority.label,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: task.priority.color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      task.description,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: <Widget>[
                        Icon(Icons.timer_outlined, size: 18, color: theme.colorScheme.primary),
                        const SizedBox(width: 4),
                        Text('${task.focusMinutes}/${task.estimatedMinutes} min'),
                        if (task.dueDate != null) ...<Widget>[
                          const SizedBox(width: 12),
                          Icon(Icons.event, size: 18, color: theme.colorScheme.secondary),
                          const SizedBox(width: 4),
                          Text(
                            _formatDue(task.dueDate!),
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                    if (task.tags.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: task.tags
                            .map(
                              (String tag) => Chip(
                                label: Text('#$tag'),
                                backgroundColor: theme.colorScheme.surfaceVariant,
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDue(DateTime dueDate) {
    final DateTime today = DateUtils.dateOnly(DateTime.now());
    if (DateUtils.isSameDay(today, dueDate)) {
      return 'Due today';
    }
    if (dueDate.isBefore(today)) {
      return 'Overdue';
    }
    return 'Due ${dueDate.month}/${dueDate.day}';
  }
}

class _TaskComposerSheet extends StatefulWidget {
  const _TaskComposerSheet();

  @override
  State<_TaskComposerSheet> createState() => _TaskComposerSheetState();
}

class _TaskComposerSheetState extends State<_TaskComposerSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final TextEditingController _minutesController = TextEditingController(text: '25');
  DateTime? _dueDate;
  TaskPriority _priority = TaskPriority.medium;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Create focus task',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Add a clear title to reduce resistance.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Describe the first action you will take.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      controller: _minutesController,
                      decoration: const InputDecoration(labelText: 'Estimated minutes'),
                      keyboardType: TextInputType.number,
                      validator: (String? value) {
                        final int? minutes = int.tryParse(value ?? '');
                        if (minutes == null || minutes <= 0) {
                          return 'Estimate a realistic focus block.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: _pickDueDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Due date'),
                        child: Text(_dueDate == null
                            ? 'Optional'
                            : '${_dueDate!.month}/${_dueDate!.day}/${_dueDate!.year}'),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<TaskPriority>(
                value: _priority,
                decoration: const InputDecoration(labelText: 'Priority'),
                items: TaskPriority.values
                    .map(
                      (TaskPriority priority) => DropdownMenuItem<TaskPriority>(
                        value: priority,
                        child: Text(priority.label),
                      ),
                    )
                    .toList(),
                onChanged: (TaskPriority? value) {
                  if (value != null) {
                    setState(() {
                      _priority = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags',
                  helperText: 'Separate tags with commas (e.g. planning, writing)',
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.rocket_launch),
                  label: const Text('Start momentum'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDueDate() async {
    final DateTime now = DateTime.now();
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (selected != null) {
      setState(() {
        _dueDate = selected;
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final AppState state = context.read<AppState>();
    final List<String> tags = _tagsController.text
        .split(',')
        .map((String tag) => tag.trim())
        .where((String tag) => tag.isNotEmpty)
        .toList();
    final int minutes = int.tryParse(_minutesController.text) ?? 25;
    state.createTask(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      dueDate: _dueDate,
      tags: tags,
      estimatedMinutes: minutes,
      priority: _priority,
    );
    Navigator.of(context).maybePop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task added. Schedule a focus block to follow through.')),
    );
  }
}
