class FocusSession {
  FocusSession({
    required this.id,
    required this.taskId,
    required this.startedAt,
    required this.durationMinutes,
    this.completed = true,
    this.note,
  });

  final String id;
  final String taskId;
  final DateTime startedAt;
  final int durationMinutes;
  final bool completed;
  final String? note;
}
