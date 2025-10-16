// lib/pages/goal_detail_page.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as services; // <<-- prefixed import
import 'package:shared_preferences/shared_preferences.dart';
import '../models/goal_model.dart';

class GoalDetailPage extends StatefulWidget {
  final Goal goal;
  const GoalDetailPage({required this.goal, super.key});

  @override
  State<GoalDetailPage> createState() => _GoalDetailPageState();
}

class _GoalDetailPageState extends State<GoalDetailPage> with WidgetsBindingObserver {
  late Goal _goal;

  DateTime? _startTime;
  bool _running = false;

  late final StreamSubscription<void> _tickerSub;

  @override
  void initState() {
    super.initState();
    _goal = widget.goal;

    WidgetsBinding.instance.addObserver(this);

    _tickerSub = Stream.periodic(const Duration(milliseconds: 300)).listen((_) {
      if (_running && mounted) {
        setState(() {});
      }
    });

    _loadStateAndCorrectTime();
  }

  /// Load persisted seconds and lastSaved, then add time passed while app was closed.
  Future<void> _loadStateAndCorrectTime() async {
    final prefs = await SharedPreferences.getInstance();
    final goalId = _goal.id;

    // Load previously saved session total
    final savedSeconds = prefs.getInt('goal_${goalId}_sessionSeconds') ?? 0;
    _goal.sessionSeconds = savedSeconds;

    // If we saved a timestamp, compute how much time passed since then
    final lastSavedString = prefs.getString('goal_${goalId}_lastSaved');
    if (lastSavedString != null) {
      try {
        final lastSavedTime = DateTime.parse(lastSavedString);
        final timePassedSinceSave = DateTime.now().difference(lastSavedTime);
        if (timePassedSinceSave.inSeconds > 0) {
          _goal.sessionSeconds += timePassedSinceSave.inSeconds;
        }
      } catch (_) {
        // ignore parse errors
      }
    }

    // Optionally start running automatically; comment out if you prefer manual start
    // _startStopwatch();
    setState(() {});
  }

  Future<void> _saveState() async {
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    final goalId = _goal.id;

    // Persist any running delta into sessionSeconds
    if (_running && _startTime != null) {
      final delta = DateTime.now().difference(_startTime!);
      _goal.sessionSeconds += delta.inSeconds;
      _startTime = DateTime.now(); // rebase to avoid double-count
    }

    await prefs.setInt('goal_${goalId}_sessionSeconds', _goal.sessionSeconds);
    await prefs.setString('goal_${goalId}_lastSaved', DateTime.now().toIso8601String());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      _saveState();
    }
  }

  int _runningDeltaSeconds() {
    if (!_running || _startTime == null) return 0;
    return DateTime.now().difference(_startTime!).inSeconds;
  }

  int _computeTotalElapsedSeconds() {
    return _goal.sessionSeconds + _runningDeltaSeconds();
  }

  String _formatElapsed(int s) {
    final hours = s ~/ 3600;
    final mins = (s % 3600) ~/ 60;
    final secs = s % 60;
    return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _startStopwatch() {
    if (!mounted) return;
    setState(() {
      _running = true;
      _startTime = DateTime.now();
    });
  }

  void _resetStopwatch() {
    setState(() {
      _goal.sessionSeconds = 0;
      _startTime = DateTime.now();
      if (!_running) _running = true;
    });
    _saveState();
  }

  void _addDay() {
    setState(() {
      if (_goal.completedDays == 0) {
        _goal.streakStarted ??= DateTime.now();
      }
      _goal.completedDays += 1;
      _goal.sessionSeconds += 24 * 3600;
      // keep running behavior smooth
      if (_running) _startTime = DateTime.now();
    });
  }

  Future<void> _resetProgress() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset progress?'),
        content: const Text('This will reset completed days, streak and session timer. Continue?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Reset')),
        ],
      ),
    );
    if (ok == true) {
      setState(() {
        _goal.completedDays = 0;
        _goal.streakStarted = null;
        _resetStopwatch();
      });
    }
  }

  Future<void> _deleteGoal() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Goal'),
        content: const Text('This will permanently delete the goal. Continue?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('goal_${_goal.id}_lastSaved');
      await prefs.remove('goal_${_goal.id}_sessionSeconds');
      if (!mounted) return;
      Navigator.of(context).pop(Goal(
        id: _goal.id,
        emoji: _goal.emoji,
        title: '_deleted',
        description: '',
        targetDays: _goal.targetDays,
      ));
    }
  }

  Future<void> _copyShare() async {
    final elapsed = _computeTotalElapsedSeconds();
    final text =
        '${_goal.emoji} ${_goal.title}\n${_goal.description}\nProgress: ${_goal.completedDays}/${_goal.targetDays}\nTimer: ${_formatElapsed(elapsed)}';

    // use the prefixed services import to avoid name collisions
    await services.Clipboard.setData(services.ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Goal copied to clipboard')));
  }

  @override
  void dispose() {
    _saveState();
    WidgetsBinding.instance.removeObserver(this);
    _tickerSub.cancel();
    super.dispose();
  }

  Widget _metaRow(String label, String value) {
    return Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(color: Colors.black54))),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final elapsed = _computeTotalElapsedSeconds();
    final primary = Theme.of(context).colorScheme.primary;
    final percent = _goal.progressPercent().clamp(0.0, 1.0);
    final streakDate = _goal.streakStarted != null ? _goal.streakStarted!.toLocal().toString().split(' ')[0] : '—';

    return WillPopScope(
      onWillPop: () async {
        await _saveState();
        if (mounted) {
          Navigator.of(context).pop(_goal);
        }
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Goal'),
          actions: [
            IconButton(onPressed: _copyShare, icon: const Icon(Icons.share)),
            IconButton(
              onPressed: () async {
                await _saveState();
                if (mounted) {
                  Navigator.of(context).pop(_goal);
                }
              },
              icon: const Icon(Icons.check),
            ),
          ],
        ),
        backgroundColor: Colors.grey.shade50,
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // summary card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.grey.shade100,
                            child: Text(_goal.emoji, style: const TextStyle(fontSize: 26))),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_goal.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              Text(_goal.description, style: TextStyle(color: Colors.grey.shade700)),
                            ],
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: percent,
                        minHeight: 12,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation(_goal.isCompleted ? Colors.green : primary),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${(percent * 100).toStringAsFixed(0)}% Completed',
                            style: TextStyle(color: Colors.grey.shade600)),
                        Text('${_goal.completedDays} / ${_goal.targetDays} days',
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Timer card
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.timer_outlined),
                        SizedBox(width: 10),
                        Text('Session Timer', style: TextStyle(fontWeight: FontWeight.bold))
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(_formatElapsed(elapsed), style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: LinearProgressIndicator(
                        value: (_goal.targetDays > 0)
                            ? (_computeTotalElapsedSeconds() / (24 * 3600 * _goal.targetDays)).clamp(0.0, 1.0)
                            : 0.0,
                        minHeight: 12,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation(primary),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _resetStopwatch,
                            icon: const Icon(Icons.restart_alt),
                            label: const Text('Reset Timer'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('This timer runs continuously for this goal.',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Meta card
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  children: [
                    _metaRow('Created on', _goal.createdAt.toLocal().toString().split(' ')[0]),
                    const Divider(),
                    _metaRow('Streak', '${_goal.streakDays()} day(s) • Started $streakDate'),
                    const Divider(),
                    _metaRow('Note', _goal.note.isEmpty ? '—' : _goal.note),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _addDay,
                    icon: const Icon(Icons.exposure_plus_1),
                    label: const Text('+1 Add Day'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: OutlinedButton(onPressed: _resetProgress, child: const Text('Reset All'))),
              ],
            ),

            const SizedBox(height: 8),
            TextButton(
              onPressed: _deleteGoal,
              child: const Text('Delete Goal', style: TextStyle(color: Colors.red)),
            ),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}
