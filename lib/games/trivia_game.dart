import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/game_service.dart';

class TriviaGame extends StatefulWidget {
  const TriviaGame({super.key});

  @override
  State<TriviaGame> createState() => _TriviaGameState();
}

class _TriviaGameState extends State<TriviaGame> {
  String _question = '';
  List<String> _answers = [];
  String _correctAnswer = '';
  bool _loading = false;
  int _score = 0;
  bool _gameStarted = false;
  bool _answered = false;
  String? _selectedAnswer;

  Future<void> _fetchQuestion() async {
    setState(() {
      _loading = true;
      _answered = false;
      _selectedAnswer = null;
    });
    try {
      final response = await http.get(Uri.parse('https://opentdb.com/api.php?amount=1&type=multiple'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final result = data['results'][0];
        final correct = _decodeHtml(result['correct_answer']);
        final incorrect = (result['incorrect_answers'] as List).map((a) => _decodeHtml(a)).toList();
        final allAnswers = [...incorrect, correct]..shuffle();
        
        setState(() {
          _question = _decodeHtml(result['question']);
          _correctAnswer = correct;
          _answers = allAnswers;
          _loading = false;
        });
      }
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  String _decodeHtml(String text) {
    return text
        .replaceAll('&quot;', '"')
        .replaceAll('&#039;', "'")
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>');
  }

  void _startGame() {
    setState(() {
      _gameStarted = true;
      _score = 0;
    });
    _fetchQuestion();
  }

  void _checkAnswer(String answer) {
    setState(() {
      _answered = true;
      _selectedAnswer = answer;
      if (answer == _correctAnswer) _score++;
    });
  }

  void _nextQuestion() {
    _fetchQuestion();
  }

  void _endGame() {
    if (_score > 0) GameService().saveGameScore('Trivia Master', _score);
    setState(() => _gameStarted = false);
  }

  @override
  void dispose() {
    if (_gameStarted && _score > 0 && mounted) {
      GameService().saveGameScore('Trivia Master', _score);
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
            colors: [Color(0xFFD32F2F), Color(0xFFEF5350)],
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
                        '🧩 Trivia Master',
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
                    child: Text('Score: $_score', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
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
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(_question, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  ),
                                  const SizedBox(height: 30),
                                  ..._answers.map((answer) {
                                    final isCorrect = answer == _correctAnswer;
                                    final isSelected = answer == _selectedAnswer;
                                    Color? bgColor;
                                    if (_answered) {
                                      if (isCorrect) bgColor = Colors.green;
                                      else if (isSelected) bgColor = Colors.red;
                                    }
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: ElevatedButton(
                                        onPressed: _answered ? null : () => _checkAnswer(answer),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: bgColor ?? Colors.white,
                                          foregroundColor: bgColor != null ? Colors.white : const Color(0xFFD32F2F),
                                          padding: const EdgeInsets.all(16),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          minimumSize: const Size(double.infinity, 50),
                                        ),
                                        child: Text(answer, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14)),
                                      ),
                                    );
                                  }).toList(),
                                  if (_answered) ...[
                                    const SizedBox(height: 20),
                                    ElevatedButton(
                                      onPressed: _nextQuestion,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: const Color(0xFFD32F2F),
                                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                      ),
                                      child: const Text('Next Question', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    ),
                                    const SizedBox(height: 12),
                                    TextButton(
                                      onPressed: _endGame,
                                      child: const Text('End Game', style: TextStyle(color: Colors.white70)),
                                    ),
                                  ],
                                ],
                              ),
                            )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('🎯', style: TextStyle(fontSize: 64)),
                              const SizedBox(height: 20),
                              const Text('Test your knowledge\nwith trivia questions!', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: Colors.white70)),
                              const SizedBox(height: 40),
                              ElevatedButton(
                                onPressed: _startGame,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFFD32F2F),
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                ),
                                child: const Text('Start Game', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
