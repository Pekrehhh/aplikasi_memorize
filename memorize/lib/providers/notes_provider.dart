import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/api_service.dart';

class NotesProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Note> _masterNotes = []; // Daftar asli dari API
  String _searchQuery = '';     // Query pencarian saat ini
  
  bool _isLoading = false; // Ini untuk add/delete, bukan fetch awal

  bool get isLoading => _isLoading;

  // --- PERUBAHAN DI SINI ---
  // Getter 'notes' sekarang akan mengembalikan daftar yang sudah difilter
  List<Note> get notes {
    if (_searchQuery.isEmpty) {
      return _masterNotes; // Jika tidak ada pencarian, tampilkan semua
    } else {
      // Jika ada pencarian, filter berdasarkan JUDUL (title)
      return _masterNotes
          .where((note) =>
              note.title.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
  }
  // --- BATAS PERUBAHAN ---


  Future<void> fetchNotes(String token) async {
    try {
      _masterNotes = await _apiService.getNotes(token);
      _searchQuery = ''; // Reset pencarian setiap kali fetch
    } catch (e) {
      print(e);
      _masterNotes = [];
    }
    notifyListeners();
  }

  // --- FUNGSI BARU UNTUK SEARCH ---
  void searchNotes(String query) {
    _searchQuery = query;
    notifyListeners(); // Beri tahu UI untuk update list
  }
  // --- BATAS FUNGSI BARU ---

  Future<void> addNote(
    String token,
    String title,
    String content, // <-- Pastikan ini String, BUKAN contentJson
    String color,
    DateTime? reminderAt,
  ) async {
    try {
      final newNote = await _apiService.createNote(
        token,
        title,
        content, // <-- Kirim sebagai String
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
    // (Fungsi ini tidak berubah)
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