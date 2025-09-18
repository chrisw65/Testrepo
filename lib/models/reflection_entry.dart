import 'package:flutter/material.dart';

/// Captures an end-of-day reflection including mood, energy, and focus notes.
class ReflectionEntry {
  ReflectionEntry({
    required this.date,
    required this.moodScore,
    required this.energyScore,
    required this.focusScore,
    this.highlights = const <String>[],
    this.intentions = const <String>[],
    this.note,
  })  : assert(moodScore >= 1 && moodScore <= 5),
        assert(energyScore >= 1 && energyScore <= 5),
        assert(focusScore >= 1 && focusScore <= 5);

  final DateTime date;
  final int moodScore;
  final int energyScore;
  final int focusScore;
  final List<String> highlights;
  final List<String> intentions;
  final String? note;

  ReflectionEntry copyWith({
    DateTime? date,
    int? moodScore,
    int? energyScore,
    int? focusScore,
    List<String>? highlights,
    List<String>? intentions,
    String? note,
  }) {
    return ReflectionEntry(
      date: date ?? this.date,
      moodScore: moodScore ?? this.moodScore,
      energyScore: energyScore ?? this.energyScore,
      focusScore: focusScore ?? this.focusScore,
      highlights: highlights ?? this.highlights,
      intentions: intentions ?? this.intentions,
      note: note ?? this.note,
    );
  }

  /// Normalized wellbeing score between 0 and 1.
  double get wellbeingScore => (moodScore + energyScore + focusScore) / 15.0;

  /// Human-friendly title for the reflection.
  String get title => 'Mood $moodScore · Energy $energyScore · Focus $focusScore';

  Color get accentColor {
    final double score = wellbeingScore;
    if (score >= 0.8) {
      return Colors.greenAccent.shade400;
    }
    if (score >= 0.6) {
      return Colors.lightBlueAccent.shade200;
    }
    if (score >= 0.4) {
      return Colors.orangeAccent.shade200;
    }
    return Colors.redAccent.shade200;
  }
}
