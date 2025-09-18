import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../state/app_state.dart';
import 'dashboard_screen.dart';
import 'focus_timer_screen.dart';
import 'insights_screen.dart';
import 'tasks_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  final List<Widget> _pages = const <Widget>[
    DashboardScreen(),
    TasksScreen(),
    FocusTimerScreen(),
    InsightsScreen(),
  ];

  final Map<int, String> _titles = <int, String>{
    0: 'Momentum cockpit',
    1: 'Focus planner',
    2: 'Guided deep work',
    3: 'Insight studio',
  };

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool useRail = constraints.maxWidth > 950;
        final Widget content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildHeader(theme),
            const SizedBox(height: 12),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: KeyedSubtree(
                  key: ValueKey<int>(_index),
                  child: _pages[_index],
                ),
              ),
            ),
          ],
        );

        if (useRail) {
          return Scaffold(
            body: SafeArea(
              child: Row(
                children: <Widget>[
                  NavigationRail(
                    extended: constraints.maxWidth > 1280,
                    selectedIndex: _index,
                    onDestinationSelected: (int index) {
                      setState(() {
                        _index = index;
                      });
                    },
                    destinations: const <NavigationRailDestination>[
                      NavigationRailDestination(
                        icon: Icon(Icons.dashboard_customize_outlined),
                        selectedIcon: Icon(Icons.dashboard_customize_rounded),
                        label: Text('Dashboard'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.task_alt_outlined),
                        selectedIcon: Icon(Icons.task_alt),
                        label: Text('Tasks'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.self_improvement_outlined),
                        selectedIcon: Icon(Icons.self_improvement),
                        label: Text('Focus'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.auto_graph_outlined),
                        selectedIcon: Icon(Icons.auto_graph),
                        label: Text('Insights'),
                      ),
                    ],
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(child: content),
                ],
              ),
            ),
            floatingActionButton: _QuickAddButton(onPressed: _openQuickAdd),
            backgroundColor: theme.colorScheme.surface,
          );
        }

        return Scaffold(
          body: SafeArea(child: content),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (int newIndex) {
              setState(() {
                _index = newIndex;
              });
            },
            destinations: const <NavigationDestination>[
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              NavigationDestination(
                icon: Icon(Icons.checklist_rtl),
                selectedIcon: Icon(Icons.checklist),
                label: 'Tasks',
              ),
              NavigationDestination(
                icon: Icon(Icons.hourglass_empty),
                selectedIcon: Icon(Icons.hourglass_full),
                label: 'Focus',
              ),
              NavigationDestination(
                icon: Icon(Icons.insights_outlined),
                selectedIcon: Icon(Icons.insights),
                label: 'Insights',
              ),
            ],
          ),
          floatingActionButton: _QuickAddButton(onPressed: _openQuickAdd),
          backgroundColor: theme.colorScheme.surface,
        );
      },
    );
  }

  Widget _buildHeader(ThemeData theme) {
    final String title = _titles[_index] ?? 'Focus Flow';
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _index == 0
                ? 'Design your day, defuse friction, and celebrate traction.'
                : _index == 1
                    ? 'Sequence your next breakthroughs into approachable steps.'
                    : _index == 2
                        ? 'Prime your rituals, pick a focus mode, and log intentional sessions.'
                        : 'Review insights, unlock antidotes, and tweak your momentum system.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openQuickAdd() async {
    final AppState state = context.read<AppState>();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController tagsController = TextEditingController();
    int estimatedMinutes = 25;
    TaskPriority priority = TaskPriority.medium;
    DateTime? dueDate = DateTime.now();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        'Capture a quick win',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Task title',
                          hintText: 'What is the next micro-action?',
                        ),
                        validator: (String? value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Give the task a name to anchor it.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Supportive detail',
                          hintText: 'Context, why it matters, or how it should feel.',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const Text('Energy lift'),
                                DropdownButton<TaskPriority>(
                                  value: priority,
                                  isExpanded: true,
                                  items: TaskPriority.values
                                      .map(
                                        (TaskPriority level) => DropdownMenuItem<TaskPriority>(
                                          value: level,
                                          child: Text(level.label),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (TaskPriority? value) {
                                    if (value != null) {
                                      setModalState(() {
                                        priority = value;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const Text('Due date'),
                                TextButton.icon(
                                  onPressed: () async {
                                    final DateTime now = DateTime.now();
                                    final DateTime firstDate = DateTime(now.year - 1);
                                    final DateTime lastDate = DateTime(now.year + 2);
                                    final DateTime? picked = await showDatePicker(
                                      context: context,
                                      initialDate: dueDate ?? now,
                                      firstDate: firstDate,
                                      lastDate: lastDate,
                                    );
                                    if (picked != null) {
                                      setModalState(() {
                                        dueDate = DateUtils.dateOnly(picked);
                                      });
                                    }
                                  },
                                  icon: const Icon(Icons.calendar_today),
                                  label: Text(
                                    dueDate == null
                                        ? 'No due date'
                                        : MaterialLocalizations.of(context).formatMediumDate(dueDate!),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('Estimated focus minutes: $estimatedMinutes'),
                      Slider(
                        value: estimatedMinutes.toDouble(),
                        min: 5,
                        max: 90,
                        divisions: 17,
                        label: '$estimatedMinutes',
                        onChanged: (double value) {
                          setModalState(() {
                            estimatedMinutes = value.round();
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: tagsController,
                        decoration: const InputDecoration(
                          labelText: 'Tags',
                          hintText: 'Separate tags with commas (e.g. clarity, quick win)',
                        ),
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: () {
                          if (formKey.currentState?.validate() ?? false) {
                            final List<String> tags = tagsController.text
                                .split(',')
                                .map((String tag) => tag.trim())
                                .where((String tag) => tag.isNotEmpty)
                                .toList();
                            state.createTask(
                              title: titleController.text.trim(),
                              description: descriptionController.text.trim(),
                              dueDate: dueDate,
                              tags: tags,
                              estimatedMinutes: estimatedMinutes,
                              priority: priority,
                            );
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              const SnackBar(content: Text('Task added to your momentum plan.')),
                            );
                          }
                        },
                        icon: const Icon(Icons.flight_takeoff_rounded),
                        label: const Text('Add to plan'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );

    titleController.dispose();
    descriptionController.dispose();
    tagsController.dispose();
  }
}

class _QuickAddButton extends StatelessWidget {
  const _QuickAddButton({required this.onPressed});

  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      icon: const Icon(Icons.bolt_rounded),
      label: const Text('Quick win'),
    );
  }
}
