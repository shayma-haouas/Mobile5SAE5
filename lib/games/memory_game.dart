import 'package:flutter/material.dart';
import 'dart:math';
import '../services/game_service.dart';

class MemoryGame extends StatefulWidget {
  const MemoryGame({super.key});

  @override
  State<MemoryGame> createState() => _MemoryGameState();
}

class _MemoryGameState extends State<MemoryGame> with TickerProviderStateMixin {
  List<int> _sequence = [];
  List<int> _userSequence = [];
  int _currentStep = 0;
  bool _showingSequence = false;
  bool _gameOver = false;
  late AnimationController _flashController;

  final List<Color> _colors = [
    const Color(0xFFE53E3E),
    const Color(0xFF3182CE),
    const Color(0xFF38A169),
    const Color(0xFFD69E2E),
  ];

  final List<String> _emojis = ['🔴', '🔵', '🟢', '🟡'];

  @override
  void initState() {
    super.initState();
    _flashController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  void _startGame() {
    setState(() {
      _sequence = [Random().nextInt(4)];
      _userSequence = [];
      _currentStep = 0;
      _gameOver = false;
    });
    _showSequence();
  }

  void _showSequence() async {
    if (!mounted) return;
    setState(() => _showingSequence = true);
    await Future.delayed(const Duration(milliseconds: 500));
    
    for (int i = 0; i < _sequence.length; i++) {
      if (!mounted) return;
      setState(() => _currentStep = _sequence[i]);
      _flashController.forward();
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      setState(() => _currentStep = -1);
      _flashController.reverse();
      await Future.delayed(const Duration(milliseconds: 200));
    }
    if (!mounted) return;
    setState(() => _showingSequence = false);
  }

  void _onButtonPressed(int button) {
    if (_showingSequence) return;
    
    _userSequence.add(button);
    
    if (_userSequence[_userSequence.length - 1] != _sequence[_userSequence.length - 1]) {
      setState(() => _gameOver = true);
      GameService().saveGameScore('Memory', _sequence.length);
      return;
    }
    
    if (_userSequence.length == _sequence.length) {
      _sequence.add(Random().nextInt(4));
      _userSequence = [];
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) _showSequence();
      });
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
            colors: [Color(0xFF3F51B5), Color(0xFF7986CB)],
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
                        '🧠 Memory Game',
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
                    'Level: ${_sequence.length}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 60),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_gameOver)
                          Column(
                            children: [
                              const Text(
                                '💥',
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
                                'Level reached: ${_sequence.length}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 40),
                              ElevatedButton(
                                onPressed: _startGame,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF3F51B5),
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
                        else if (_sequence.isEmpty)
                          Column(
                            children: [
                              const Text(
                                '🎯',
                                style: TextStyle(fontSize: 64),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Watch the sequence, then repeat it!',
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
                                  foregroundColor: const Color(0xFF3F51B5),
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
                          )
                        else
                          Column(
                            children: [
                              if (_showingSequence)
                                const Text(
                                  'Watch carefully! 👀',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white70,
                                  ),
                                )
                              else
                                const Text(
                                  'Your turn! Tap the sequence 🎯',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white70,
                                  ),
                                ),
                              const SizedBox(height: 30),
                              SizedBox(
                                height: 180,
                                child: GridView.count(
                                  shrinkWrap: true,
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 1.1,
                                  children: List.generate(4, (index) {
                                  bool isActive = _currentStep == index;
                                  return AnimatedBuilder(
                                    animation: _flashController,
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale: isActive ? 1.0 + (_flashController.value * 0.1) : 1.0,
                                        child: GestureDetector(
                                          onTap: () => _onButtonPressed(index),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: isActive ? Colors.white : _colors[index],
                                              borderRadius: BorderRadius.circular(20),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.2),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 5),
                                                ),
                                              ],
                                            ),
                                            child: Center(
                                              child: Text(
                                                _emojis[index],
                                                style: const TextStyle(fontSize: 48),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                  }),
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
    if (_sequence.isNotEmpty && mounted) {
      GameService().saveGameScore('Memory', _sequence.length);
    }
    _flashController.dispose();
    super.dispose();
  }
}