import 'package:shared_preferences/shared_preferences.dart';
import '../models/goal_model.dart';

class GoalsRepository {
  static const String _kKey = 'goals_list';

  Future<List<Goal>> loadGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_kKey) ?? [];
    return raw.map((s) => Goal.fromJson(s)).toList();
  }

  Future<void> saveGoals(List<Goal> goals) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = goals.map((g) => g.toJson()).toList();
    await prefs.setStringList(_kKey, encoded);
  }
}
