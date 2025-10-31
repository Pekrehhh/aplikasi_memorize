import 'dart:convert';

class Note {
  final int id;
  final String title;
  final String content;
  final String color;
  final DateTime createdAt;
  final DateTime? reminderAt; // Bisa jadi null

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.color,
    required this.createdAt,
    this.reminderAt,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    // --- PERBAIKAN DI SINI ---
    // Logika baru untuk 'content'
    String parsedContent;
    
    // Cek apakah data 'content' adalah JSON string (dari Quill lama) atau teks biasa
    try {
      // Coba decode. Jika ini data Quill, dia akan jadi Map
      var decoded = jsonDecode(json['content']);
      if (decoded is List) {
        // Ini adalah format Quill (Delta)
        // Ambil teks-nya saja
        parsedContent = decoded.map((item) => item['insert']).join('');
      } else {
        // Ini mungkin JSON aneh, anggap sebagai teks biasa
        parsedContent = json['content']?.toString() ?? '';
      }
    } catch (e) {
      // Jika decode gagal, berarti ini adalah teks biasa (string)
      parsedContent = json['content']?.toString() ?? '';
    }
    // --- BATAS PERBAIKAN ---

    return Note(
      id: json['id'],
      title: json['title'],
      content: parsedContent, // <-- Gunakan content yang sudah diparsing
      color: json['color'] ?? '#FFFF99',
      createdAt: DateTime.parse(json['created_at']),
      reminderAt: json['reminder_at'] != null
          ? DateTime.parse(json['reminder_at'])
          : null,
    );
  }
}