import 'dart:convert';

class Note {
  final int id;
  final String title;
  final String content;
  final String color;
  final DateTime createdAt;
  final DateTime? reminderAt;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.color,
    required this.createdAt,
    this.reminderAt,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    String parsedContent;

    try {
      var decoded = jsonDecode(json['content']);
      if (decoded is List) {
        parsedContent = decoded.map((item) => item['insert']).join('');
      } else {
        parsedContent = json['content']?.toString() ?? '';
      }
    } catch (e) {
      parsedContent = json['content']?.toString() ?? '';
    }

    return Note(
      id: json['id'],
      title: json['title'],
      content: parsedContent,
      color: json['color'] ?? '#FFFF99',
      createdAt: DateTime.parse(json['created_at']),
      reminderAt: json['reminder_at'] != null
          ? DateTime.parse(json['reminder_at'])
          : null,
    );
  }
}