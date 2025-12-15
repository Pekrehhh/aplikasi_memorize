import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:memorize/models/note.dart';
import 'package:memorize/providers/auth_provider.dart';

class NotesProvider with ChangeNotifier {
  final Box<Note> _notesBox = Hive.box<Note>('notes');
  AuthProvider? _authProvider;
  
  String get activeUserEmail => _authProvider?.email ?? '';

  NotesProvider(this._authProvider) {
    if (_authProvider != null) {
      _loadNotes();
    }
  }

  void updateAuth(AuthProvider? auth) {
    _authProvider = auth;
    refreshNotes();
  }

  List<Note> _notes = [];
  List<Note> _filteredNotes = [];
  bool _isLoading = false;
  String _currentQuery = '';

  List<Note> get notes {
    if (_currentQuery.isEmpty) {
      return _notes;
    } else {
      return _filteredNotes;
    }
  }

  bool get isLoading => _isLoading;
  
  String get _activeUserEmail => _authProvider?.email ?? '';

  void _loadNotes() {
    if (_authProvider == null) return;
    _isLoading = true;
    notifyListeners();
    
    _notes = _notesBox.values
        .where((note) => note.userEmail == _activeUserEmail)
        .toList();
    _notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    if (_currentQuery.isNotEmpty) {
      final lowerQuery = _currentQuery.toLowerCase();
      _filteredNotes = _notes.where((note) {
        return note.title.toLowerCase().contains(lowerQuery) || note.content.toLowerCase().contains(lowerQuery);
      }).toList();
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<Note?> addNote(String title, String content, String color, DateTime? reminderAt) async {
    if (_activeUserEmail.isEmpty) {
      debugPrint('NotesProvider.addNote: active user email is empty, cannot save');
      return null;
    }

    _isLoading = true;
    notifyListeners();
    Note? newNote;
    try {
      newNote = Note(
        id: 0,
        title: title,
        content: content,
        color: color,
        createdAt: DateTime.now(),
        reminderAt: reminderAt,
        userEmail: _activeUserEmail,
      );

      final key = await _notesBox.add(newNote);
      newNote.id = key;
      await newNote.save();

      try {
        debugPrint('Notes box keys: ${_notesBox.keys.toList()}');
        debugPrint('Stored note id: $key');
      } catch (_) {}

      refreshNotes();
      return newNote;
    } catch (e, st) {
      debugPrint('NotesProvider.addNote error: $e');
      debugPrint(st.toString());
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteNote(int id) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (_notesBox.containsKey(id)) {
        await _notesBox.delete(id);
        _loadNotes();
      }
    } catch (e) {
      //
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void searchNotes(String query) {
    _currentQuery = query;
    _loadNotes();
  }
  
  void refreshNotes() {
    _currentQuery = '';
    _loadNotes();
  }
}