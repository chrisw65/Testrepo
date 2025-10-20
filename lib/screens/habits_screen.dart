import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/habit.dart';
import '../state/app_state.dart';
import '../widgets/gradient_card.dart';

class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Habits'),
        elevation: 0,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => _showAddHabitDialog(context),
            tooltip: 'Add new habit',
          ),
        ],
      ),
      body: Consumer<AppState>(
        builder: (BuildContext context, AppState state, Widget? child) {
          final List<Habit> activeHabits = state.activeHabits;

          if (activeHabits.isEmpty) {
            return _buildEmptyState(context);
          }

          final int completedToday = state.habitsCompletedToday;
          final int totalActive = activeHabits.length;
          final double completionRate = state.todayHabitCompletionRate;

          return CustomScrollView(
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _buildProgressCard(
                        context,
                        completedToday,
                        totalActive,
                        completionRate,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Today\'s Habits',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Build momentum one habit at a time',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6),
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      final Habit habit = activeHabits[index];
                      return _buildHabitCard(context, habit, state);
                    },
                    childCount: activeHabits.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 80),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.star_outline,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Start Building Habits',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Create your first habit to begin tracking your progress and building momentum.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => _showAddHabitDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Your First Habit'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(
    BuildContext context,
    int completed,
    int total,
    double rate,
  ) {
    return GradientCard(
      gradient: LinearGradient(
        colors: <Color>[
          Theme.of(context).colorScheme.primary,
          Theme.of(context).colorScheme.tertiary,
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Today\'s Progress',
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$completed of $total habits completed',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                    ),
                  ],
                ),
              ),
              CircularProgressIndicator(
                value: rate,
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 6,
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: rate,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 12),
          Text(
            rate == 1.0
                ? 'Perfect! All habits completed today! 🎉'
                : rate >= 0.5
                    ? 'Great progress! Keep going! 💪'
                    : 'You\'ve got this! Start small.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.95),
                  fontStyle: FontStyle.italic,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitCard(BuildContext context, Habit habit, AppState state) {
    final bool isCompleted = habit.isCompletedToday;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isCompleted ? 1 : 2,
      child: InkWell(
        onTap: () => _showHabitDetails(context, habit),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: <Widget>[
              // Checkbox
              GestureDetector(
                onTap: () => state.toggleHabitCompletion(habit.id),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? habit.color
                        : habit.color.withOpacity(0.1),
                    border: Border.all(
                      color: habit.color,
                      width: 2,
                    ),
                  ),
                  child: isCompleted
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 20,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              // Habit info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Icon(
                          habit.icon,
                          size: 20,
                          color: habit.color,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            habit.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  decoration: isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: isCompleted
                                      ? colorScheme.onSurface.withOpacity(0.5)
                                      : null,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      habit.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: <Widget>[
                        if (habit.currentStreak > 0) ...<Widget>[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const Icon(
                                  Icons.local_fire_department,
                                  size: 14,
                                  color: Colors.orange,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${habit.currentStreak} day${habit.currentStreak != 1 ? 's' : ''}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        _buildFrequencyBadge(habit),
                      ],
                    ),
                  ],
                ),
              ),
              // Arrow icon
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurface.withOpacity(0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFrequencyBadge(Habit habit) {
    final String text = habit.frequency == HabitFrequency.daily
        ? 'Daily'
        : '${habit.targetDaysPerWeek}x/week';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: habit.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: habit.color,
        ),
      ),
    );
  }

  void _showHabitDetails(BuildContext context, Habit habit) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(24),
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: habit.color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                habit.icon,
                                color: habit.color,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    habit.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  Text(
                                    habit.description,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.6),
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        _buildStatRow(
                          context,
                          'Current Streak',
                          '${habit.currentStreak} days',
                          Icons.local_fire_department,
                          Colors.orange,
                        ),
                        _buildStatRow(
                          context,
                          'Longest Streak',
                          '${habit.longestStreak} days',
                          Icons.emoji_events,
                          Colors.amber,
                        ),
                        _buildStatRow(
                          context,
                          'Total Completions',
                          '${habit.totalCompletions}',
                          Icons.check_circle,
                          Colors.green,
                        ),
                        _buildStatRow(
                          context,
                          'This Week',
                          '${habit.completionsThisWeek} times',
                          Icons.calendar_today,
                          Colors.blue,
                        ),
                        _buildStatRow(
                          context,
                          'This Month',
                          '${habit.completionsThisMonth} times',
                          Icons.calendar_month,
                          Colors.purple,
                        ),
                        _buildStatRow(
                          context,
                          'Completion Rate',
                          '${(habit.completionRate * 100).toStringAsFixed(0)}%',
                          Icons.trending_up,
                          Colors.teal,
                        ),
                        const SizedBox(height: 24),
                        if (habit.notes != null && habit.notes!.isNotEmpty) ...<Widget>[
                          Text(
                            'Notes',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            habit.notes!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 24),
                        ],
                        FilledButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            context
                                .read<AppState>()
                                .toggleHabitCompletion(habit.id);
                          },
                          icon: Icon(
                            habit.isCompletedToday ? Icons.undo : Icons.check,
                          ),
                          label: Text(
                            habit.isCompletedToday
                                ? 'Mark as Incomplete'
                                : 'Mark as Complete',
                          ),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _showDeleteConfirmation(context, habit);
                          },
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Delete Habit'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  void _showAddHabitDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    HabitCategory selectedCategory = HabitCategory.productivity;
    IconData selectedIcon = Icons.check_circle;
    Color selectedColor = Colors.blue;

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Add New Habit'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Habit Name',
                        hintText: 'e.g., Morning Exercise',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Brief description of your habit',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<HabitCategory>(
                      value: selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: HabitCategory.values.map((HabitCategory category) {
                        return DropdownMenuItem<HabitCategory>(
                          value: category,
                          child: Text(_getCategoryName(category)),
                        );
                      }).toList(),
                      onChanged: (HabitCategory? value) {
                        if (value != null) {
                          setState(() {
                            selectedCategory = value;
                            selectedIcon = _getCategoryIcon(value);
                            selectedColor = _getCategoryColor(value);
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: selectedColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(selectedIcon, color: selectedColor),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Preview',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    if (nameController.text.trim().isNotEmpty &&
                        descriptionController.text.trim().isNotEmpty) {
                      context.read<AppState>().createHabit(
                            name: nameController.text.trim(),
                            description: descriptionController.text.trim(),
                            category: selectedCategory,
                            icon: selectedIcon,
                            color: selectedColor,
                          );
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Add Habit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, Habit habit) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Habit?'),
          content: Text(
            'Are you sure you want to delete "${habit.name}"? This action cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                context.read<AppState>().deleteHabit(habit.id);
                Navigator.of(context).pop();
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  String _getCategoryName(HabitCategory category) {
    switch (category) {
      case HabitCategory.health:
        return 'Health';
      case HabitCategory.productivity:
        return 'Productivity';
      case HabitCategory.learning:
        return 'Learning';
      case HabitCategory.mindfulness:
        return 'Mindfulness';
      case HabitCategory.social:
        return 'Social';
      case HabitCategory.creative:
        return 'Creative';
      case HabitCategory.fitness:
        return 'Fitness';
      case HabitCategory.other:
        return 'Other';
    }
  }

  IconData _getCategoryIcon(HabitCategory category) {
    switch (category) {
      case HabitCategory.health:
        return Icons.favorite;
      case HabitCategory.productivity:
        return Icons.rocket_launch;
      case HabitCategory.learning:
        return Icons.school;
      case HabitCategory.mindfulness:
        return Icons.spa;
      case HabitCategory.social:
        return Icons.people;
      case HabitCategory.creative:
        return Icons.palette;
      case HabitCategory.fitness:
        return Icons.fitness_center;
      case HabitCategory.other:
        return Icons.star;
    }
  }

  Color _getCategoryColor(HabitCategory category) {
    switch (category) {
      case HabitCategory.health:
        return Colors.red;
      case HabitCategory.productivity:
        return Colors.blue;
      case HabitCategory.learning:
        return Colors.purple;
      case HabitCategory.mindfulness:
        return Colors.green;
      case HabitCategory.social:
        return Colors.orange;
      case HabitCategory.creative:
        return Colors.pink;
      case HabitCategory.fitness:
        return Colors.teal;
      case HabitCategory.other:
        return Colors.grey;
    }
  }
}
