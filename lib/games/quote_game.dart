import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/game_service.dart';

class QuoteGame extends StatefulWidget {
  const QuoteGame({super.key});

  @override
  State<QuoteGame> createState() => _QuoteGameState();
}

class _QuoteGameState extends State<QuoteGame> {
  String _quote = '';
  String _author = '';
  bool _loading = false;
  int _score = 0;
  bool _gameStarted = false;

  Future<void> _fetchQuote() async {
    setState(() => _loading = true);
    try {
      final response = await http.get(Uri.parse('https://api.quotable.io/random?tags=inspirational'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _quote = data['content'];
          _author = data['author'];
          _score++;
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _quote = 'Stay strong! Every moment smoke-free is a victory.';
        _author = 'QuitSmart';
        _loading = false;
      });
    }
  }

  void _startGame() {
    setState(() {
      _gameStarted = true;
      _score = 0;
    });
    _fetchQuote();
  }

  void _endGame() {
    if (_score > 0) GameService().saveGameScore('Quote Master', _score);
    setState(() => _gameStarted = false);
  }

  @override
  void dispose() {
    if (_gameStarted && _score > 0 && mounted) {
      GameService().saveGameScore('Quote Master', _score);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF6A1B9A), Color(0xFFAB47BC)],
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
                        '💬 Quote Master',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 20),
                if (_gameStarted)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('Quotes Read: $_score', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                const SizedBox(height: 40),
                Expanded(
                  child: _gameStarted
                      ? _loading
                          ? const Center(child: CircularProgressIndicator(color: Colors.white))
                          : SingleChildScrollView(
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Column(
                                      children: [
                                        const Icon(Icons.format_quote, size: 40, color: Color(0xFF6A1B9A)),
                                        const SizedBox(height: 16),
                                        Text(_quote, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, height: 1.5)),
                                        const SizedBox(height: 16),
                                        Text('- $_author', style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 30),
                                  ElevatedButton(
                                    onPressed: _fetchQuote,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: const Color(0xFF6A1B9A),
                                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                    ),
                                    child: const Text('Next Quote', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  ),
                                  const SizedBox(height: 16),
                                  TextButton(
                                    onPressed: _endGame,
                                    child: const Text('End Session', style: TextStyle(color: Colors.white70)),
                                  ),
                                ],
                              ),
                            )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('📖', style: TextStyle(fontSize: 64)),
                              const SizedBox(height: 20),
                              const Text('Read inspirational quotes\nto stay motivated!', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: Colors.white70)),
                              const SizedBox(height: 40),
                              ElevatedButton(
                                onPressed: _startGame,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF6A1B9A),
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                ),
                                child: const Text('Start Reading', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
}
