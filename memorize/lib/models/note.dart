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

  // Ini adalah "pabrik" untuk mengubah data JSON
  // dari API menjadi objek Note
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'],
      content: json['content'] ?? '', // Jika content null, jadikan string kosong
      color: json['color'] ?? '#FFFF99', // Jika color null, beri default
      createdAt: DateTime.parse(json['created_at']),
      // Hati-hati dengan data null
      reminderAt: json['reminder_at'] != null 
        ? DateTime.parse(json['reminder_at']) 
        : null,
    );
  }
}