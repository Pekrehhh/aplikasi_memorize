import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/api_service.dart';

class NotesProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Note> _notes = [];
  final bool _isLoading = false;

  List<Note> get notes => _notes;
  bool get isLoading => _isLoading;

  Future<void> fetchNotes(String token) async {
    try {
      _notes = await _apiService.getNotes(token);
    } catch (e) {
      print(e); 
      _notes = []; 
    }

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

      _notes.insert(0, newNote);
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
        _notes.removeWhere((note) => note.id == noteId);
        notifyListeners();
      }
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}