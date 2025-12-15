import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notes_provider.dart';
import '../../services/notification_service.dart';

class NotesTabController with ChangeNotifier {
  bool _isLoading = true;
  bool _isSearching = false;
  final TextEditingController searchController = TextEditingController();
  
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  
  void init(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchNotes(context);
    });
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
      // ga boleh kosong
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
    final notesProvider = Provider.of<NotesProvider>(context, listen: false);

    searchController.clear();
    notesProvider.searchNotes('');

    if (context.mounted) {
      _setLoading(false);
    }
  }

  Future<void> deleteNote(BuildContext context, int noteId) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      await NotificationService().cancelNotification(noteId);
      await Provider.of<NotesProvider>(context, listen: false).deleteNote(noteId);
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus note: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}