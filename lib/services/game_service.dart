import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_history_model.dart';
import 'package:uuid/uuid.dart';

class GameService {
  static const _historyKey = 'game_history';
  static const _milestonesKey = 'milestones';

  Future<void> saveGameScore(String gameName, int score) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getGameHistory();
    
    history.add(GameHistory(
      id: const Uuid().v4(),
      gameName: gameName,
      score: score,
      playedAt: DateTime.now(),
    ));
    
    await prefs.setStringList(_historyKey, history.map((h) => h.toJson()).toList());
    await _updateMilestones();
  }

  Future<List<GameHistory>> getGameHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_historyKey) ?? [];
    return raw.map((s) => GameHistory.fromJson(s)).toList();
  }

  Future<int> getHighScore(String gameName) async {
    final history = await getGameHistory();
    final gameScores = history.where((h) => h.gameName == gameName).map((h) => h.score);
    return gameScores.isEmpty ? 0 : gameScores.reduce((a, b) => a > b ? a : b);
  }

  Future<Map<String, int>> getAllHighScores() async {
    final games = ['Speed Tap', 'Memory', 'Breathe', 'Color Match', 'Quote Master', 'Trivia Master'];
    final scores = <String, int>{};
    for (var game in games) {
      scores[game] = await getHighScore(game);
    }
    return scores;
  }

  Future<List<Milestone>> getMilestones() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_milestonesKey);
    
    if (raw == null) {
      final defaults = _getDefaultMilestones();
      await prefs.setStringList(_milestonesKey, defaults.map((m) => m.toJson()).toList());
      return defaults;
    }
    
    return raw.map((s) => Milestone.fromJson(s)).toList();
  }

  List<Milestone> _getDefaultMilestones() => [
    Milestone(id: 'game_1', title: '1st Game', description: 'Play your first game', category: 'Games', targetValue: 1),
    Milestone(id: 'game_3', title: '3 Games', description: 'Play 3 games total', category: 'Games', targetValue: 3),
    Milestone(id: 'game_5', title: '5 Games', description: 'Play 5 games total', category: 'Games', targetValue: 5),
    Milestone(id: 'game_10', title: '10 Games', description: 'Play 10 games total', category: 'Games', targetValue: 10),
    Milestone(id: 'game_25', title: '25 Games', description: 'Play 25 games total', category: 'Games', targetValue: 25),
    Milestone(id: 'game_50', title: '50 Games', description: 'Play 50 games total', category: 'Games', targetValue: 50),
    Milestone(id: 'score_50', title: 'Score 50+', description: 'Get 50+ points in any game', category: 'Games', targetValue: 50),
    Milestone(id: 'score_100', title: 'Score 100+', description: 'Get 100+ points in any game', category: 'Games', targetValue: 100),
    
    Milestone(id: 'health_5', title: '5 Minutes', description: 'Heart rate starts to drop', category: 'Health', targetValue: 5),
    Milestone(id: 'health_20', title: '20 Minutes', description: 'Heart rate and blood pressure normalize', category: 'Health', targetValue: 20),
    Milestone(id: 'health_60', title: '1 Hour', description: 'Oxygen levels increase', category: 'Health', targetValue: 60),
    Milestone(id: 'health_480', title: '8 Hours', description: 'Nicotine levels drop by 93%', category: 'Health', targetValue: 480),
    Milestone(id: 'health_720', title: '12 Hours', description: 'Carbon monoxide normalizes', category: 'Health', targetValue: 720),
    Milestone(id: 'health_1440', title: '24 Hours', description: 'Heart attack risk begins to drop', category: 'Health', targetValue: 1440),
    Milestone(id: 'health_2880', title: '48 Hours', description: 'Nerve endings start regrowing', category: 'Health', targetValue: 2880),
    Milestone(id: 'health_4320', title: '72 Hours', description: 'Breathing becomes easier', category: 'Health', targetValue: 4320),
    
    Milestone(id: 'money_5', title: '\$5 Saved', description: 'Your first savings milestone', category: 'Money', targetValue: 5),
    Milestone(id: 'money_10', title: '\$10 Saved', description: 'Enough for a nice meal', category: 'Money', targetValue: 10),
    Milestone(id: 'money_25', title: '\$25 Saved', description: 'A quarter of a hundred', category: 'Money', targetValue: 25),
    Milestone(id: 'money_50', title: '\$50 Saved', description: 'Halfway to 100', category: 'Money', targetValue: 50),
    Milestone(id: 'money_100', title: '\$100 Saved', description: 'First hundred dollars saved', category: 'Money', targetValue: 100),
    Milestone(id: 'money_250', title: '\$250 Saved', description: 'Significant savings achieved', category: 'Money', targetValue: 250),
    Milestone(id: 'money_500', title: '\$500 Saved', description: 'Half a thousand dollars', category: 'Money', targetValue: 500),
    Milestone(id: 'money_1000', title: '\$1000 Saved', description: 'One thousand dollars milestone', category: 'Money', targetValue: 1000),
  ];

  Future<void> _updateMilestones() async {
    final prefs = await SharedPreferences.getInstance();
    final milestones = await getMilestones();
    final history = await getGameHistory();
    final totalGames = history.length;
    final maxScore = history.isEmpty ? 0 : history.map((h) => h.score).reduce((a, b) => a > b ? a : b);

    for (var m in milestones) {
      if (m.category == 'Games') {
        if (m.id.startsWith('score_')) {
          m.currentValue = maxScore;
        } else {
          m.currentValue = totalGames;
        }
        m.isAchieved = m.currentValue >= m.targetValue;
      }
    }

    await prefs.setStringList(_milestonesKey, milestones.map((m) => m.toJson()).toList());
  }

  Future<void> updateMilestonesFromStats(int minutesSmokeFree, double moneySaved) async {
    final prefs = await SharedPreferences.getInstance();
    final milestones = await getMilestones();

    for (var m in milestones) {
      if (m.category == 'Health') {
        m.currentValue = minutesSmokeFree;
        m.isAchieved = m.currentValue >= m.targetValue;
      } else if (m.category == 'Money') {
        m.currentValue = moneySaved.floor();
        m.isAchieved = m.currentValue >= m.targetValue;
      }
    }

    await prefs.setStringList(_milestonesKey, milestones.map((m) => m.toJson()).toList());
  }
}
