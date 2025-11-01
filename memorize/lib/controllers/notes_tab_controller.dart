import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notes_provider.dart';
import '../../services/notification_service.dart';

class NotesTabController with ChangeNotifier {
  bool _isLoading = true;
  bool _isSearching = false;
  final TextEditingController searchController = TextEditingController();
  
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  
  void init(BuildContext context) {
    _fetchNotes(context);
    searchController.addListener(() {
      _onSearchChanged(context);
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(BuildContext context) {
    try {
      Provider.of<NotesProvider>(context, listen: false).searchNotes(searchController.text);
    } catch (e) {
      print("Error searching notes (mungkin provider ter-dispose): $e");
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void toggleSearch(BuildContext context) {
    _isSearching = !_isSearching;
    if (!_isSearching) {
      searchController.clear();
    }
    notifyListeners();
  }

  Future<void> _fetchNotes(BuildContext context) async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    final notesProvider = Provider.of<NotesProvider>(context, listen: false);

    searchController.clear();
    notesProvider.searchNotes('');
    
    if (token != null) {
      try {
        await notesProvider.fetchNotes(token);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal memuat notes: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
    if (context.mounted) {
      _setLoading(false);
    }
  }

  Future<void> deleteNote(BuildContext context, int noteId) async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sesi habis, silakan login ulang.'), backgroundColor: Colors.red),
      );
      return;
    }
    
    try {
      await NotificationService().cancelNotification(noteId);
      await Provider.of<NotesProvider>(context, listen: false).deleteNote(token, noteId);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus note: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}