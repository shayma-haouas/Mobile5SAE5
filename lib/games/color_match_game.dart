import 'package:flutter/material.dart';
import 'dart:math';

class ColorMatchGame extends StatefulWidget {
  const ColorMatchGame({super.key});

  @override
  State<ColorMatchGame> createState() => _ColorMatchGameState();
}

class _ColorMatchGameState extends State<ColorMatchGame> with TickerProviderStateMixin {
  final List<Color> _colors = [
    const Color(0xFFE53E3E),
    const Color(0xFF3182CE),
    const Color(0xFF38A169),
    const Color(0xFFD69E2E),
    const Color(0xFF9F7AEA),
    const Color(0xFFED8936),
  ];
  
  final List<String> _colorNames = ['Red', 'Blue', 'Green', 'Yellow', 'Purple', 'Orange'];
  final List<String> _colorEmojis = ['🔴', '🔵', '🟢', '🟡', '🟣', '🟠'];
  
  int _targetColorIndex = 0;
  int _score = 0;
  bool _gameStarted = false;
  late AnimationController _successController;
  late Animation<double> _successAnimation;

  @override
  void initState() {
    super.initState();
    _successController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _successAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _successController, curve: Curves.elasticOut),
    );
  }

  void _startGame() {
    setState(() {
      _score = 0;
      _gameStarted = true;
      _targetColorIndex = Random().nextInt(_colors.length);
    });
  }

  void _onColorTapped(int index) {
    if (!_gameStarted) return;
    
    if (index == _targetColorIndex) {
      setState(() {
        _score++;
        _targetColorIndex = Random().nextInt(_colors.length);
      });
      _successController.forward().then((_) => _successController.reverse());
    } else {
      setState(() => _gameStarted = false);
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
            colors: [Color(0xFF8BC34A), Color(0xFFAED581)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                    ),
                    const Expanded(
                      child: Text(
                        '🎨 Color Match',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Score: $_score',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      if (_gameStarted)
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
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
                              child: Column(
                                children: [
                                  const Text(
                                    'Tap this color:',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  AnimatedBuilder(
                                    animation: _successAnimation,
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale: _successAnimation.value,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              _colorEmojis[_targetColorIndex],
                                              style: const TextStyle(fontSize: 32),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              _colorNames[_targetColorIndex],
                                              style: TextStyle(
                                                fontSize: 28,
                                                fontWeight: FontWeight.bold,
                                                color: _colors[_targetColorIndex],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 40),
                            GridView.count(
                              shrinkWrap: true,
                              crossAxisCount: 3,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              children: List.generate(_colors.length, (index) {
                                return GestureDetector(
                                  onTap: () => _onColorTapped(index),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: _colors[index],
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        _colorEmojis[index],
                                        style: const TextStyle(fontSize: 32),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],
                        )
                      else if (_score > 0)
                        Column(
                          children: [
                            const Text(
                              '🎉',
                              style: TextStyle(fontSize: 64),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Game Over!',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Final Score: $_score',
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 40),
                            ElevatedButton(
                              onPressed: _startGame,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF8BC34A),
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: const Text(
                                'Play Again',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        )
                      else
                        Column(
                          children: [
                            const Text(
                              '🌈',
                              style: TextStyle(fontSize: 64),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Match the colors as fast as you can!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 40),
                            ElevatedButton(
                              onPressed: _startGame,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF8BC34A),
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: const Text(
                                'Start Game',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _successController.dispose();
    super.dispose();
  }
}