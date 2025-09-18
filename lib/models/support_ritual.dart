import 'package:flutter/material.dart';

/// Represents a repeatable ritual that supports focus and momentum.
class SupportRitual {
  SupportRitual({
    required this.id,
    required this.moment,
    required this.title,
    required this.description,
    this.steps = const <String>[],
    this.affirmation,
    this.icon,
  });

  final String id;
  final RitualMoment moment;
  final String title;
  final String description;
  final List<String> steps;
  final String? affirmation;
  final IconData? icon;
}

/// The moment in the day when a ritual is most helpful.
enum RitualMoment {
  morning,
  preFocus,
  reset,
}

extension RitualMomentX on RitualMoment {
  String get label {
    switch (this) {
      case RitualMoment.morning:
        return 'Morning';
      case RitualMoment.preFocus:
        return 'Pre-focus';
      case RitualMoment.reset:
        return 'Reset';
    }
  }

  Color get color {
    switch (this) {
      case RitualMoment.morning:
        return Colors.amberAccent.shade200;
      case RitualMoment.preFocus:
        return Colors.lightBlueAccent.shade200;
      case RitualMoment.reset:
        return Colors.pinkAccent.shade100;
    }
  }
}
