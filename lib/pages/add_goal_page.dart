import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/goal_model.dart';

class AddGoalPage extends StatefulWidget {
  const AddGoalPage({super.key});

  @override
  State<AddGoalPage> createState() => _AddGoalPageState();
}

class _AddGoalPageState extends State<AddGoalPage> {
  final _formKey = GlobalKey<FormState>();
  final _emojiController = TextEditingController(text: '🎯');
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _noteController = TextEditingController();
  int _targetDays = 30;

  @override
  void dispose() {
    _emojiController.dispose();
    _titleController.dispose();
    _descController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      final goal = Goal(
        id: const Uuid().v4(),
        emoji: _emojiController.text.trim().isEmpty ? '🎯' : _emojiController.text.trim(),
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        targetDays: _targetDays,
        note: _noteController.text.trim(),
      );
      Navigator.of(context).pop(goal);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(title: const Text('Create Goal')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text('Emoji', style: TextStyle(fontWeight: FontWeight.w600)),
                        const Spacer(),
                        SizedBox(
                          width: 80,
                          child: TextFormField(
                            controller: _emojiController,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(border: InputBorder.none),
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a title' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descController,
                      decoration: const InputDecoration(labelText: 'Short description'),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('Target days:', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Slider(
                            value: _targetDays.toDouble(),
                            min: 1,
                            max: 365,
                            divisions: 364,
                            label: '$_targetDays',
                            activeColor: primary,
                            onChanged: (v) => setState(() => _targetDays = v.round()),
                          ),
                        ),
                        Text('$_targetDays'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _noteController,
                      decoration: const InputDecoration(labelText: 'Note (optional)'),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: ElevatedButton(onPressed: _save, child: const Text('Save'))),
                        const SizedBox(width: 12),
                        Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
