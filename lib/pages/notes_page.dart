import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final List<Map<String, String>> _notes = [];
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadNotes();
    _loadTheme();
  }
//CRUD OPERATIONS WITH SHARED PREFERENCES
  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = prefs.getString('notes') ?? '[]';
    final notesList = jsonDecode(notesJson) as List;
    setState(() {
      _notes.clear();
      _notes.addAll(notesList.map((e) => Map<String, String>.from(e)).toList());
    });
  }

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notes', jsonEncode(_notes));
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('darkMode') ?? false;
    });
  }

  Future<void> _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    await prefs.setBool('darkMode', _isDarkMode);
  }

  void _createNote() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditorPage(
          onSave: (title, content) {
            setState(() {
              _notes.insert(0, {'title': title, 'content': content, 'date': _getFormattedDate()});
            });
            _saveNotes();
          },
        ),
      ),
    );
  }

  void _editNote(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditorPage(
          initialTitle: _notes[index]['title'],
          initialContent: _notes[index]['content'],
          onSave: (title, content) {
            setState(() {
              _notes[index] = {'title': title, 'content': content, 'date': _getFormattedDate()};
            });
            _saveNotes();
          },
          onDelete: () {
            setState(() {
              _notes.removeAt(index);
            });
            _saveNotes();
          },
        ),
      ),
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _isDarkMode ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7);
    final textColor = _isDarkMode ? Colors.white : Colors.black;
    final cardColor = _isDarkMode ? const Color(0xFF2C2C2E) : Colors.white;
    final subtextColor = _isDarkMode ? Colors.grey.shade400 : Colors.grey;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Notes',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode, size: 28, color: const Color(0xFFFFCC00)),
                        onPressed: _toggleTheme,
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle, size: 32, color: Color(0xFFFFCC00)),
                        onPressed: _createNote,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                '${_notes.length} ${_notes.length == 1 ? 'Note' : 'Notes'}',
                style: TextStyle(fontSize: 14, color: subtextColor),
              ),
            ),
            Expanded(
              child: _notes.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.note_outlined, size: 80, color: subtextColor),
                          const SizedBox(height: 16),
                          Text(
                            'No Notes',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: subtextColor),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap + to create a note',
                            style: TextStyle(fontSize: 16, color: subtextColor),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _notes.length,
                      itemBuilder: (context, index) {
                        final note = _notes[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Material(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              onTap: () => _editNote(index),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            note['title']!.isEmpty ? 'New Note' : note['title']!,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: textColor,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Icon(Icons.chevron_right, color: subtextColor, size: 20),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      note['date']!,
                                      style: TextStyle(fontSize: 13, color: subtextColor),
                                    ),
                                    if (note['content']!.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        note['content']!,
                                        style: TextStyle(fontSize: 15, color: subtextColor),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ]
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class NoteEditorPage extends StatefulWidget {
  final String? initialTitle;
  final String? initialContent;
  final Function(String title, String content) onSave;
  final VoidCallback? onDelete;

  const NoteEditorPage({
    super.key,
    this.initialTitle,
    this.initialContent,
    required this.onSave,
    this.onDelete,
  });

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    _contentController = TextEditingController(text: widget.initialContent ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _save() {
    widget.onSave(_titleController.text, _contentController.text);
    Navigator.pop(context);
  }

  void _delete() {
    widget.onDelete?.call();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F2F7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFFFCC00)),
          onPressed: _save,
        ),
        actions: [
          if (widget.onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: _delete,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: 'Title',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TextField(
                controller: _contentController,
                style: const TextStyle(fontSize: 17),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  hintText: 'Start typing...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}