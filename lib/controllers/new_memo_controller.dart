import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:memorize/providers/auth_provider.dart';
import 'package:memorize/providers/notes_provider.dart';
import 'package:memorize/services/notification_service.dart';

class NewMemoController with ChangeNotifier {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  DateTime? _selectedDateTime;
  DateTime? get selectedDateTime => _selectedDateTime;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final Map<String, Color> colorPalette = {
    '#24cccc': Color(0xFF24cccc),
    '#62f4f4': Color(0xFF62f4f4),
    '#065353': Color(0xFF065353),
    '#FFFFFF': Colors.white,
  };

  String _selectedColor = '#24cccc';
  String get selectedColor => _selectedColor;

  void selectColor(String colorHex) {
    _selectedColor = colorHex;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> pickDateTime(BuildContext context) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date == null) return;

    if (!context.mounted) return;
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime ?? DateTime.now()),
    );
    if (time == null) return;

    _selectedDateTime = DateTime(
      date.year, date.month, date.day,
      time.hour, time.minute,
    );
    notifyListeners();
  }

  void clearDateTime() {
    _selectedDateTime = null;
    notifyListeners();
  }

  Future<void> saveMemo(BuildContext context) async {
    final title = titleController.text;
    final content = contentController.text;

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Judul tidak boleh kosong'), backgroundColor: Colors.red),
      );
      return;
    }

    _setLoading(true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    debugPrint('NewMemoController.saveMemo: auth email=${authProvider.email}, isAuth=${authProvider.isAuth}');

    if (!authProvider.isAuth) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sesi tidak valid, silakan login ulang.'), backgroundColor: Colors.red),
        );
      }
      _setLoading(false);
      return;
    }

    try {
      final notesProvider = Provider.of<NotesProvider>(context, listen: false);
      notesProvider.updateAuth(authProvider);
      debugPrint('NewMemoController.saveMemo: notesProvider activeUserEmail=${notesProvider.activeUserEmail}');

      final createdNote = await notesProvider.addNote(
          title,
          content,
          _selectedColor,
          _selectedDateTime,
        );

        if (createdNote != null && _selectedDateTime != null && _selectedDateTime!.isAfter(DateTime.now())) {
          NotificationService().scheduleNotification(
            id: createdNote.id,
            title: createdNote.title,
            body: createdNote.content,
            scheduledTime: _selectedDateTime!,
          );
        }

        if (context.mounted) {
          if (createdNote != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Memo tersimpan (id: ${createdNote.id})'), backgroundColor: Colors.green),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Gagal menyimpan memo'), backgroundColor: Colors.red),
            );
          }
          Navigator.of(context).pop();
        }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e'), backgroundColor: Colors.red),
        );
      }
    }

    if (context.mounted) {
      _setLoading(false);
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }
}