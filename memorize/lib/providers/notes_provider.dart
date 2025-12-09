import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/note.dart';

class NotesProvider with ChangeNotifier {
  List<Note> _masterNotes = [];
  String _searchQuery = '';

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Note> get notes {
    if (_searchQuery.isEmpty) {
      return _masterNotes;
    } else {
      return _masterNotes
          .where((note) =>
              note.title.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
  }

  Future<void> fetchNotes(String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      final box = Hive.box<Note>('notes');
      _masterNotes = box.values.toList();
      // sort by createdAt desc if available
      _masterNotes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _searchQuery = '';
    } catch (e) {
      _masterNotes = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  void searchNotes(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> addNote(
    String token,
    String title,
    String content,
    String color,
    DateTime? reminderAt,
  ) async {
    try {
      final box = Hive.box<Note>('notes');

      // generate id: max existing id + 1 or timestamp
      int nextId = 1;
      if (box.values.isNotEmpty) {
        final ids = box.values.map((e) => e.id).toList();
        nextId = (ids.reduce((a, b) => a > b ? a : b)) + 1;
      }

      final newNote = Note(
        id: nextId,
        title: title,
        content: content,
        color: color,
        createdAt: DateTime.now(),
        reminderAt: reminderAt,
        userEmail: '',
      );

      await box.add(newNote);

      _masterNotes.insert(0, newNote);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteNote(String token, int noteId) async {
    try {
      final box = Hive.box<Note>('notes');
      final Map<dynamic, Note> entries = box.toMap();
      dynamic foundKey;
      entries.forEach((key, value) {
        if (value.id == noteId) foundKey = key;
      });
      if (foundKey != null) {
        await box.delete(foundKey);
        _masterNotes.removeWhere((note) => note.id == noteId);
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }
}