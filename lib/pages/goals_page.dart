import 'package:flutter/material.dart';
import '../models/goal_model.dart';
import '../services/goals_repository.dart';
import '../services/api_service.dart';
import 'add_goal_page.dart';
import 'goal_detail_page.dart';

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  final GoalsRepository _repo = GoalsRepository();
  List<Goal> _goals = [];
  bool _loading = true;
  String _motivationalQuote = 'Loading inspiration...';
  String _healthTip = 'Loading health tip...';
  String _weatherMotivation = 'Loading weather info...';

  @override
  void initState() {
    super.initState();
    _load();
    _loadApiData();
  }

  Future<void> _loadApiData() async {
    final quote = await ApiService.getMotivationalQuote();
    final healthData = await ApiService.getHealthTip();
    final weather = await ApiService.getWeatherMotivation('Paris');
    
    setState(() {
      _motivationalQuote = quote;
      _healthTip = healthData['tip'] ?? 'Stay healthy!';
      _weatherMotivation = weather;
    });
  }

  Future<void> _load() async {
    final g = await _repo.loadGoals();
    setState(() {
      _goals = g;
      _loading = false;
    });
  }

  Future<void> _saveAll() async {
    await _repo.saveGoals(_goals);
    setState(() {});
  }

  Future<void> _addGoal(Goal goal) async {
    _goals.add(goal);
    await _saveAll();
  }

  Future<void> _deleteById(String id) async {
    _goals.removeWhere((g) => g.id == id);
    await _saveAll();
  }

  Widget _header(BuildContext c) {
    final primary = Theme.of(c).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [primary, primary.withOpacity(0.75)]),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 28, backgroundColor: Colors.white24, child: Text('🎯', style: TextStyle(fontSize: 26))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Define Your Success', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 6),
                Text('Set targets, track progress, and celebrate victories.', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          IconButton(
            onPressed: () async {
              final newGoal = await Navigator.push<Goal?>(
                context,
                MaterialPageRoute(builder: (_) => const AddGoalPage()),
              );
              if (newGoal != null) _addGoal(newGoal);
            },
            icon: const Icon(Icons.add_circle, color: Colors.white, size: 30),
            tooltip: 'Create goal',
          )
        ],
      ),
    );
  }

  Widget _goalCard(Goal g) {
    final percent = g.progressPercent().clamp(0.0, 1.0);
    final primary = Theme.of(context).colorScheme.primary;
    return InkWell(
      onTap: () async {
        final result = await Navigator.push<Goal?>(
          context,
          MaterialPageRoute(builder: (_) => GoalDetailPage(goal: g)),
        );
        if (result != null) {
          if (result.title == '_deleted') {
            await _deleteById(result.id);
          } else {
            final idx = _goals.indexWhere((x) => x.id == result.id);
            if (idx != -1) {
              _goals[idx] = result;
              await _saveAll();
            }
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
        ),
        child: Row(
          children: [
            CircleAvatar(radius: 26, backgroundColor: Colors.grey.shade50, child: Text(g.emoji, style: const TextStyle(fontSize: 22))),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(g.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 6),
                  Text(g.description, style: TextStyle(color: Colors.grey.shade700)),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: percent,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation(g.isCompleted ? Colors.green : primary),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('${g.completedDays} / ${g.targetDays} days • ${(percent * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 12, color: Colors.black54))
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(g.isCompleted ? Icons.celebration : Icons.flag_outlined, color: g.isCompleted ? Colors.green : Colors.grey)
          ],
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            children: [
              _header(context),
              const SizedBox(height: 14),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.lightbulb, color: Colors.orange),
                                    const SizedBox(width: 8),
                                    const Text('Daily Motivation', style: TextStyle(fontWeight: FontWeight.bold)),
                                    const Spacer(),
                                    IconButton(
                                      icon: const Icon(Icons.refresh, size: 20),
                                      onPressed: _loadApiData,
                                    ),
                                  ],
                                ),
                                Text(_motivationalQuote, style: const TextStyle(fontStyle: FontStyle.italic)),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.health_and_safety, color: Colors.green, size: 16),
                                    const SizedBox(width: 4),
                                    Expanded(child: Text(_healthTip, style: const TextStyle(fontSize: 12))),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.wb_sunny, color: Colors.amber, size: 16),
                                    const SizedBox(width: 4),
                                    Expanded(child: Text(_weatherMotivation, style: const TextStyle(fontSize: 12))),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Goals List
                          Expanded(
                            child: _goals.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text('No goals yet', style: TextStyle(color: Colors.black87)),
                                        const SizedBox(height: 12),
                                        ElevatedButton.icon(
                                          onPressed: () async {
                                            final newGoal = await Navigator.push<Goal?>(
                                              context,
                                              MaterialPageRoute(builder: (_) => const AddGoalPage()),
                                            );
                                            if (newGoal != null) _addGoal(newGoal);
                                          },
                                          icon: const Icon(Icons.add),
                                          label: const Text('Create a goal'),
                                        ),
                                      ],
                                    ),
                                  )
                                : RefreshIndicator(
                                    onRefresh: () async {
                                      await _load();
                                      await _loadApiData();
                                    },
                                    child: ListView.separated(
                                      itemCount: _goals.length,
                                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                                      itemBuilder: (_, i) => _goalCard(_goals[i]),
                                    ),
                                  ),
                          ),
                        ],
                      ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newGoal = await Navigator.push<Goal?>(
            context,
            MaterialPageRoute(builder: (_) => const AddGoalPage()),
          );
          if (newGoal != null) _addGoal(newGoal);
        },
        child: const Icon(Icons.add),
        tooltip: 'New Goal',
      ),
    );
  }
}