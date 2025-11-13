import 'package:flutter/material.dart';
import '../services/game_service.dart';
import '../models/game_history_model.dart';

class GameHistoryPage extends StatefulWidget {
  const GameHistoryPage({super.key});

  @override
  State<GameHistoryPage> createState() => _GameHistoryPageState();
}

class _GameHistoryPageState extends State<GameHistoryPage> {
  final GameService _service = GameService();
  List<GameHistory> _history = [];
  Map<String, int> _highScores = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final history = await _service.getGameHistory();
    final scores = await _service.getAllHighScores();

    setState(() {
      _history = history..sort((a, b) => b.playedAt.compareTo(a.playedAt));
      _highScores = scores;
    });
  }

  Color _getGameColor(String gameName) {
    switch (gameName) {
      case 'Speed Tap': return const Color(0xFFFF5722);
      case 'Memory': return const Color(0xFF3F51B5);
      case 'Breathe': return const Color(0xFF00BCD4);
      case 'Color Match': return const Color(0xFF8BC34A);
      case 'Quote Master': return const Color(0xFF6A1B9A);
      case 'Trivia Master': return const Color(0xFFD32F2F);
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE91E63), Color(0xFFF06292)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                    ),
                    const Expanded(
                      child: Text(
                        '📊 Game History',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('🏆 High Scores', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 2.5,
                        children: _highScores.entries.map((e) => Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _getGameColor(e.key).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(e.key, style: TextStyle(fontSize: 10, color: _getGameColor(e.key), fontWeight: FontWeight.bold)),
                              Text('${e.value}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _getGameColor(e.key))),
                            ],
                          ),
                        )).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _history.isEmpty
                    ? const Center(child: Text('No games played yet', style: TextStyle(color: Colors.white70)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _history.length,
                        itemBuilder: (context, index) {
                          final h = _history[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: _getGameColor(h.gameName),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(h.gameName, style: TextStyle(fontWeight: FontWeight.bold, color: _getGameColor(h.gameName))),
                                      Text('${h.playedAt.day}/${h.playedAt.month}/${h.playedAt.year} ${h.playedAt.hour}:${h.playedAt.minute.toString().padLeft(2, '0')}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                    ],
                                  ),
                                ),
                                Text('${h.score}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
