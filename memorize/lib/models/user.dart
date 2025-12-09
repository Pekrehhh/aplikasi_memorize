import 'package:hive/hive.dart';
part 'user.g.dart'; 

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  final String username;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String password;

  @HiveField(3)
  String? saranKesan;

  @HiveField(4)
  String? profileImagePath;

  User({
    required this.username,
    required this.email,
    required this.password,
    this.saranKesan,
    this.profileImagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'saranKesan': saranKesan,
      'profileImagePath': profileImagePath,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      username: map['username'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      saranKesan: map['saranKesan'] as String?,
      profileImagePath: map['profileImagePath'] as String?,
    );
  }
}