import 'package:flutter/material.dart';

import '../models/habit.dart';

class HabitCalendar extends StatelessWidget {
  const HabitCalendar({
    required this.habit,
    super.key,
    this.daysToShow = 30,
  });

  final Habit habit;
  final int daysToShow;

  @override
  Widget build(BuildContext context) {
    final DateTime today = DateTime.now();
    final List<DateTime> days = List<DateTime>.generate(
      daysToShow,
      (int index) => today.subtract(Duration(days: daysToShow - 1 - index)),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Last $daysToShow Days',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: days.map((DateTime day) {
            final bool isCompleted = habit.isCompletedOn(day);
            final bool isToday = day.day == today.day &&
                day.month == today.month &&
                day.year == today.year;

            return Tooltip(
              message: '${_formatDate(day)}\n${isCompleted ? 'Completed' : 'Not completed'}',
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? habit.color
                      : habit.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: isToday
                      ? Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        )
                      : null,
                ),
                child: Center(
                  child: isCompleted
                      ? Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        )
                      : Text(
                          '${day.day}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.3),
                          ),
                        ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            _buildLegendItem(
              context,
              'Completed',
              habit.color,
            ),
            const SizedBox(width: 16),
            _buildLegendItem(
              context,
              'Incomplete',
              habit.color.withOpacity(0.1),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final List<String> months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
