import 'dart:convert';

class Goal {
  String id;
  String emoji;
  String title;
  String description;
  int targetDays;
  int completedDays;
  String note;
  DateTime createdAt;
  DateTime? streakStarted;

  /// persisted total seconds spent on this goal (accumulated)
  int sessionSeconds;

  /// Set of dates (YYYY-MM-DD) when user checked in
  Set<String> checkedInDates;

  Goal({
    required this.id,
    required this.emoji,
    required this.title,
    required this.description,
    required this.targetDays,
    this.completedDays = 0,
    this.note = '',
    DateTime? createdAt,
    this.streakStarted,
    this.sessionSeconds = 0,
    Set<String>? checkedInDates,
  }) : createdAt = createdAt ?? DateTime.now(),
       checkedInDates = checkedInDates ?? {};

  double progressPercent() {
    if (targetDays <= 0) return 0;
    return completedDays / targetDays;
  }

  bool get isCompleted => completedDays >= targetDays && targetDays > 0;

  /// Streak days: **defined as completedDays** per your request (how many days the goal has been done)
  int streakDays() {
    return completedDays;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'emoji': emoji,
      'title': title,
      'description': description,
      'targetDays': targetDays,
      'completedDays': completedDays,
      'createdAt': createdAt.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'] as String,
      emoji: map['emoji'] as String? ?? '🎯',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      targetDays: (map['targetDays'] ?? 0) as int,
      completedDays: (map['completedDays'] ?? 0) as int,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  String toJson() => json.encode(toMap());

  factory Goal.fromJson(String source) => Goal.fromMap(json.decode(source));
}
