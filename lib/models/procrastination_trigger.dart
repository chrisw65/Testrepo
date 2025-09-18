import 'package:flutter/material.dart';

/// Categories of friction that often cause procrastination.
enum TriggerCategory {
  overwhelm,
  perfectionism,
  unclearNextStep,
  distractions,
  lowEnergy,
}

extension TriggerCategoryX on TriggerCategory {
  String get label {
    switch (this) {
      case TriggerCategory.overwhelm:
        return 'Overwhelm';
      case TriggerCategory.perfectionism:
        return 'Perfectionism';
      case TriggerCategory.unclearNextStep:
        return 'Clarity';
      case TriggerCategory.distractions:
        return 'Distractions';
      case TriggerCategory.lowEnergy:
        return 'Low energy';
    }
  }

  IconData get icon {
    switch (this) {
      case TriggerCategory.overwhelm:
        return Icons.layers_rounded;
      case TriggerCategory.perfectionism:
        return Icons.auto_fix_high_rounded;
      case TriggerCategory.unclearNextStep:
        return Icons.map_rounded;
      case TriggerCategory.distractions:
        return Icons.waves_rounded;
      case TriggerCategory.lowEnergy:
        return Icons.bedtime_rounded;
    }
  }

  Color get color {
    switch (this) {
      case TriggerCategory.overwhelm:
        return Colors.deepPurpleAccent.shade200;
      case TriggerCategory.perfectionism:
        return Colors.indigoAccent.shade100;
      case TriggerCategory.unclearNextStep:
        return Colors.tealAccent.shade200;
      case TriggerCategory.distractions:
        return Colors.orangeAccent.shade200;
      case TriggerCategory.lowEnergy:
        return Colors.blueGrey.shade200;
    }
  }
}

/// Represents a procrastination pattern with antidotes and micro-steps.
class ProcrastinationTrigger {
  ProcrastinationTrigger({
    required this.id,
    required this.category,
    required this.headline,
    required this.description,
    this.antidotes = const <String>[],
    this.microSteps = const <String>[],
    this.supportingQuestions = const <String>[],
  });

  final String id;
  final TriggerCategory category;
  final String headline;
  final String description;
  final List<String> antidotes;
  final List<String> microSteps;
  final List<String> supportingQuestions;
}
