import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:memorize/models/note.dart';
import 'package:memorize/models/user.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';

class SaveFileService {
  Future<String> exportToJsonFile() async {
    final usersBox = Hive.box<User>('users');
    final notesBox = Hive.box<Note>('notes');

    final users = usersBox.values.map((u) => u.toMap()).toList();
    final notes = notesBox.values.map((n) => n.toMap()).toList();

    final Map<String, dynamic> payload = {
      'exportedAt': DateTime.now().toIso8601String(),
      'users': users,
      'notes': notes,
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(payload);

    final dir = await getApplicationDocumentsDirectory();
    final fileName = 'memorize_save_${DateTime.now().toIso8601String().replaceAll(':', '-')}.json';
    final file = File('${dir.path}/$fileName');

    await file.writeAsString(jsonString);
    return file.path;
  }

  Future<bool> importFromJsonFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) return false;

      final path = result.files.single.path;
      if (path == null) return false;

      final file = File(path);
      final content = await file.readAsString();
      final Map<String, dynamic> data = json.decode(content);

      final usersBox = Hive.box<User>('users');
      final notesBox = Hive.box<Note>('notes');
      
      await usersBox.clear();
      await notesBox.clear();

      if (data['users'] != null && data['users'] is List) {
        for (var u in data['users']) {
          try {
            final user = User.fromMap(Map<String, dynamic>.from(u));
            await usersBox.add(user);
          } catch (e) {
            if (kDebugMode) print('Failed to import user: $e');
          }
        }
      }

      if (data['notes'] != null && data['notes'] is List) {
        for (var n in data['notes']) {
          try {
            final note = Note.fromMap(Map<String, dynamic>.from(n));
            await notesBox.add(note);
          } catch (e) {
            if (kDebugMode) print('Failed to import note: $e');
          }
        }
      }

      return true;
    } catch (e) {
      if (kDebugMode) print('Import failed: $e');
      return false;
    }
  }
}
