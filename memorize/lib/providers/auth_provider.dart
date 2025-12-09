import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String? _email;
  String? _profileImagePath;
  String? _saranKesan;
  bool _isLoading = false;
  bool _isUploading = false;

  String? get email => _email;
  String? get profileImagePath => _profileImagePath;
  String? get saranKesan => _saranKesan;
  bool get isUploading => _isUploading;
  bool get isLoading => _isLoading;

  bool get isAuth => _email != null;

  Future<Map<String, dynamic>> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    final usersBox = Hive.box<User>('users');
    try {
      final matched = usersBox.values.firstWhere(
        (u) => u.username == username && u.password == password,
        orElse: () => throw 'Username atau password salah',
      );

      _email = matched.email;
      _profileImagePath = matched.profileImagePath;
      _saranKesan = matched.saranKesan;

      await _storage.write(key: 'authEmail', value: _email);

      _isLoading = false;
      notifyListeners();
      return {'success': true};
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<void> tryAutoLogin() async {
    final storedEmail = await _storage.read(key: 'authEmail');
    if (storedEmail != null) {
      await fetchProfile(storedEmail);
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _email = null;
    _profileImagePath = null;
    _saranKesan = null;
    await _storage.delete(key: 'authEmail');
    notifyListeners();
  }

  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final usersBox = Hive.box<User>('users');

    // validation: unique username/email
    final usernameExists = usersBox.values.any((u) => u.username == username);
    if (usernameExists) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'Username sudah digunakan.'};
    }

    final emailExists = usersBox.values.any((u) => u.email == email);
    if (emailExists) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'Email sudah terdaftar.'};
    }

    final newUser = User(username: username, email: email, password: password);
    await usersBox.add(newUser);

    _isLoading = false;
    notifyListeners();
    return {'success': true, 'message': 'Registrasi berhasil'};
  }

  Future<void> fetchProfile(String email) async {
    final usersBox = Hive.box<User>('users');
    try {
      final user = usersBox.values.firstWhere((u) => u.email == email);
      _email = user.email;
      _profileImagePath = user.profileImagePath;
      _saranKesan = user.saranKesan;
      notifyListeners();
    } catch (_) {
      // ignore: no-op
    }
  }

  Future<void> uploadImage(String imagePath) async {
    if (_email == null) return;
    _isUploading = true;
    notifyListeners();

    final usersBox = Hive.box<User>('users');
    try {
      final idx = usersBox.values.toList().indexWhere((u) => u.email == _email);
      if (idx >= 0) {
        final key = usersBox.keyAt(idx);
        final user = usersBox.get(key) as User;
        user.profileImagePath = imagePath;
        await user.save();
        _profileImagePath = imagePath;
      }
    } catch (e) {
      // ignore
    }

    _isUploading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> updateSaranKesan(String saranKesan) async {
    if (_email == null) return {'success': false, 'message': 'Not logged in'};
    final usersBox = Hive.box<User>('users');
    try {
      final idx = usersBox.values.toList().indexWhere((u) => u.email == _email);
      if (idx >= 0) {
        final key = usersBox.keyAt(idx);
        final user = usersBox.get(key) as User;
        user.saranKesan = saranKesan;
        await user.save();
        _saranKesan = saranKesan;
        notifyListeners();
        return {'success': true, 'message': 'Saran & Kesan berhasil disimpan'};
      }
      return {'success': false, 'message': 'User tidak ditemukan'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}