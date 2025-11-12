import 'package:flutter/material.dart';
import '../games/tap_game.dart';
import '../games/memory_game.dart';
import '../games/breathing_game.dart';
import '../games/color_match_game.dart';

class MiniGamesPage extends StatelessWidget {
  const MiniGamesPage({super.key});

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
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🎮 Mini Games',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Distract yourself with fun games!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                    children: [
                      GameCard(
                        title: 'Speed Tap',
                        emoji: '⚡',
                        description: 'Tap as fast as you can!',
                        color: const Color(0xFFFF5722),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TapGame())),
                      ),
                      GameCard(
                        title: 'Memory',
                        emoji: '🧠',
                        description: 'Test your memory skills',
                        color: const Color(0xFF3F51B5),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MemoryGame())),
                      ),
                      GameCard(
                        title: 'Breathe',
                        emoji: '🌬️',
                        description: 'Relax and breathe',
                        color: const Color(0xFF00BCD4),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BreathingGame())),
                      ),
                      GameCard(
                        title: 'Color Match',
                        emoji: '🎨',
                        description: 'Match the colors!',
                        color: const Color(0xFF8BC34A),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ColorMatchGame())),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GameCard extends StatelessWidget {
  final String title;
  final String emoji;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const GameCard({
    super.key,
    required this.title,
    required this.emoji,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 32),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}