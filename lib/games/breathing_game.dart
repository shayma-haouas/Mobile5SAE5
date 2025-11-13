import 'package:flutter/material.dart';
import '../services/game_service.dart';

class BreathingGame extends StatefulWidget {
  const BreathingGame({super.key});

  @override
  State<BreathingGame> createState() => _BreathingGameState();
}

class _BreathingGameState extends State<BreathingGame> with TickerProviderStateMixin {
  late AnimationController _breathController;
  late AnimationController _rippleController;
  late Animation<double> _breathAnimation;
  late Animation<double> _rippleAnimation;
  bool _isBreathing = false;
  String _instruction = 'Tap to start breathing exercise';
  String _phase = 'ready';
  int _breathCount = 0;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _rippleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _breathAnimation = Tween<double>(begin: 0.8, end: 1.4).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );
    
    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );
    
    _rippleController.repeat();
  }

  void _startBreathing() {
    setState(() {
      _isBreathing = true;
      _phase = 'inhale';
      _breathCount = 0;
    });
    _breatheCycle();
  }

  void _stopBreathing() {
    if (_breathCount > 0) GameService().saveGameScore('Breathe', _breathCount);
    setState(() {
      _isBreathing = false;
      _instruction = 'Tap to start breathing exercise';
      _phase = 'ready';
    });
    _breathController.stop();
    _breathController.reset();
  }

  void _breatheCycle() async {
    if (!_isBreathing || !mounted) return;
    
    // Inhale
    if (mounted) {
      setState(() {
        _instruction = 'Breathe In... 🌬️';
        _phase = 'inhale';
      });
    }
    await _breathController.forward();
    
    if (!_isBreathing || !mounted) return;
    
    // Hold
    if (mounted) {
      setState(() {
        _instruction = 'Hold... ⏸️';
        _phase = 'hold';
      });
    }
    await Future.delayed(const Duration(seconds: 2));
    
    if (!_isBreathing || !mounted) return;
    
    // Exhale
    if (mounted) {
      setState(() {
        _instruction = 'Breathe Out... 💨';
        _phase = 'exhale';
      });
    }
    await _breathController.reverse();
    
    
    if (!_isBreathing || !mounted) return;
    
    // Brief pause
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (_isBreathing && mounted) {
      setState(() => _breathCount++);
      _breatheCycle();
    }
  }

  Color _getPhaseColor() {
    switch (_phase) {
      case 'inhale':
        return const Color(0xFF4CAF50);
      case 'hold':
        return const Color(0xFFFF9800);
      case 'exhale':
        return const Color(0xFF2196F3);
      default:
        return const Color(0xFF00BCD4);
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
            colors: [Color(0xFF00BCD4), Color(0xFF4DD0E1)],
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
                        '🌬️ Breathing Exercise',
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
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      Text(
                        _instruction,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Ripple effect
                          if (!_isBreathing)
                            AnimatedBuilder(
                              animation: _rippleAnimation,
                              builder: (context, child) {
                                return Container(
                                  width: 100 + (_rippleAnimation.value * 200),
                                  height: 100 + (_rippleAnimation.value * 200),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withOpacity(1 - _rippleAnimation.value),
                                      width: 2,
                                    ),
                                  ),
                                );
                              },
                            ),
                          // Main breathing circle
                          AnimatedBuilder(
                            animation: _breathAnimation,
                            builder: (context, child) {
                              return Container(
                                width: 150 * _breathAnimation.value,
                                height: 150 * _breathAnimation.value,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _getPhaseColor().withOpacity(0.3),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _getPhaseColor().withOpacity(0.3),
                                      blurRadius: 30,
                                      spreadRadius: 10,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    _isBreathing ? '🧘‍♀️' : '🌸',
                                    style: const TextStyle(fontSize: 48),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _isBreathing ? 'Breathing in progress...' : 'Ready to relax',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _isBreathing ? _stopBreathing : _startBreathing,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF00BCD4),
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Text(
                          _isBreathing ? 'Stop' : 'Start',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
    if (_breathCount > 0 && mounted) {
      GameService().saveGameScore('Breathe', _breathCount);
    }
    _breathController.dispose();
    _rippleController.dispose();
    super.dispose();
  }
}