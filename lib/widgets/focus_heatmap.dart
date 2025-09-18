import 'dart:math';

import 'package:flutter/material.dart';

class FocusHeatmap extends StatelessWidget {
  const FocusHeatmap({super.key, required this.focusMinutesByDay});

  final Map<DateTime, int> focusMinutesByDay;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final DateTime today = DateUtils.dateOnly(DateTime.now());
    final List<DateTime> days = List<DateTime>.generate(
      14,
      (int index) => today.subtract(Duration(days: 13 - index)),
    );
    final int maxMinutes = days.fold<int>(1, (int value, DateTime day) {
      return max(value, focusMinutesByDay[day] ?? 0);
    });

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        const double spacing = 8;
        final double availableWidth = (constraints.hasBoundedWidth && constraints.maxWidth.isFinite)
            ? constraints.maxWidth
            : 7 * 24;
        final double width = availableWidth < 7 * 24 ? 7 * 24 : availableWidth;
        final double squareSize = (width - spacing * 6) / 7;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: days.map((DateTime day) {
            final int minutes = focusMinutesByDay[day] ?? 0;
            final double t = maxMinutes == 0 ? 0 : minutes / maxMinutes;
            final Color base = theme.colorScheme.primary;
            final Color color = Color.alphaBlend(
              base.withOpacity(t.clamp(0.1, 1.0)),
              theme.colorScheme.surfaceVariant,
            );
            final String label = MaterialLocalizations.of(context).formatMediumDate(day);
            return Tooltip(
              message: '$label\n$minutes minute${minutes == 1 ? '' : 's'} of focus',
              child: Container(
                height: squareSize,
                width: squareSize,
                decoration: BoxDecoration(
                  color: minutes == 0 ? theme.colorScheme.surfaceVariant : color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withOpacity(0.4),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  minutes == 0 ? '' : minutes.toString(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
