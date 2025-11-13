import 'dart:convert';

class GameHistory {
  final String id;
  final String gameName;
  final int score;
  final DateTime playedAt;

  GameHistory({
    required this.id,
    required this.gameName,
    required this.score,
    required this.playedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'gameName': gameName,
    'score': score,
    'playedAt': playedAt.toIso8601String(),
  };

  factory GameHistory.fromMap(Map<String, dynamic> map) => GameHistory(
    id: map['id'],
    gameName: map['gameName'],
    score: map['score'],
    playedAt: DateTime.parse(map['playedAt']),
  );

  String toJson() => json.encode(toMap());
  factory GameHistory.fromJson(String source) => GameHistory.fromMap(json.decode(source));
}

class Milestone {
  final String id;
  final String title;
  final String description;
  final String category;
  final int targetValue;
  int currentValue;
  bool isAchieved;

  Milestone({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.targetValue,
    this.currentValue = 0,
    this.isAchieved = false,
  });

  double get progress => targetValue > 0 ? (currentValue / targetValue).clamp(0.0, 1.0) : 0.0;

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'category': category,
    'targetValue': targetValue,
    'currentValue': currentValue,
    'isAchieved': isAchieved,
  };

  factory Milestone.fromMap(Map<String, dynamic> map) => Milestone(
    id: map['id'],
    title: map['title'],
    description: map['description'],
    category: map['category'],
    targetValue: map['targetValue'],
    currentValue: map['currentValue'] ?? 0,
    isAchieved: map['isAchieved'] ?? false,
  );

  String toJson() => json.encode(toMap());
  factory Milestone.fromJson(String source) => Milestone.fromMap(json.decode(source));
}
