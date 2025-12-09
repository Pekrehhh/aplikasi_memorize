import 'package:hive/hive.dart';
part 'note.g.dart'; 

@HiveType(typeId: 1)
class Note extends HiveObject {
  @HiveField(0)
  final int id;
  
  @HiveField(1)
  String title;
  
  @HiveField(2)
  String content;
  
  @HiveField(3)
  String color;
  
  @HiveField(4)
  DateTime createdAt;
  
  @HiveField(5)
  DateTime? reminderAt;
  
  @HiveField(6)
  final String userEmail;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.color,
    required this.createdAt,
    this.reminderAt,
    required this.userEmail,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'color': color,
      'createdAt': createdAt.toIso8601String(),
      'reminderAt': reminderAt?.toIso8601String(),
      'userEmail': userEmail,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as int,
      title: map['title'] as String,
      content: map['content'] as String,
      color: map['color'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      reminderAt: map['reminderAt'] != null
          ? DateTime.parse(map['reminderAt'] as String)
          : null,
      userEmail: map['userEmail'] as String,
    );
  }
}