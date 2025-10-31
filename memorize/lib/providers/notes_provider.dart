import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/api_service.dart';

class NotesProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

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
    try {
      _masterNotes = await _apiService.getNotes(token);
      _searchQuery = '';
    } catch (e) {
      print(e);
      _masterNotes = [];
    }
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
      final newNote = await _apiService.createNote(
        token,
        title,
        content,
        color,
        reminderAt,
      );

      _masterNotes.insert(0, newNote);
      notifyListeners();
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> deleteNote(String token, int noteId) async {
    try {
      final success = await _apiService.deleteNote(token, noteId);

      if (success) {
        _masterNotes.removeWhere((note) => note.id == noteId);
        notifyListeners();
      }
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}