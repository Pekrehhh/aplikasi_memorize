import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// Sesuaikan path ini jika file api_service.dart kamu ada di tempat lain
import '../services/api_service.dart'; 

class AuthProvider with ChangeNotifier {
  // Buat instance dari "juru bicara" API dan "brankas"
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String? _token;
  bool _isLoading = false;
  String? _email;
  String? _profileImageUrl;
  bool _isUploading = false;

  String? get email => _email;
  String? get profileImageUrl => _profileImageUrl;
  bool get isUploading => _isUploading;

  bool get isAuth {
    return _token != null;
  }

  String? get token {
    return _token;
  }

  bool get isLoading {
    return _isLoading;
  }

  // 1. FUNGSI LOGIN
  Future<Map<String, dynamic>> login(String email, String password) async {
    _isLoading = true;
    notifyListeners(); // Bilang ke UI -> "Tolong tampilkan loading"

    // Panggil ApiService yang kita buat tadi
    final result = await _apiService.login(email, password);

    if (result['success'] == true) {
      // Jika login API sukses
      _token = result['token']; // Simpan token di "otak"
      
      // Simpan token ke "brankas" HP dengan aman
      await _storage.write(key: 'authToken', value: _token);
      await fetchProfile(_token!); // Ambil data profil setelah login
      
      _isLoading = false;
      notifyListeners(); // Bilang ke UI -> "Oke, login berhasil, sembunyikan loading"
      return {'success': true};
    } else {
      // Jika login API gagal
      _isLoading = false;
      notifyListeners(); // Bilang ke UI -> "Login gagal, sembunyikan loading"
      return {'success': false, 'message': result['message']};
    }
  }

  // 2. FUNGSI CEK LOGIN (Saat app baru dibuka)
  Future<void> tryAutoLogin() async {
    // Coba baca token dari "brankas"
    final storedToken = await _storage.read(key: 'authToken');
    
    if (storedToken != null) {
      // Jika ada token, kita anggap dia sudah login
      _token = storedToken;
      await fetchProfile(_token!); // Ambil data profil saat auto-login
      notifyListeners();
    }
    // Jika tidak ada, _token tetap null (dia akan ke halaman login)
  }

  // 3. FUNGSI LOGOUT
  Future<void> logout() async {
    _token = null; // Hapus token dari "otak"
    await _storage.delete(key: 'authToken'); // Hapus token dari "brankas"
    notifyListeners(); // Bilang ke UI -> "User sudah logout"
  }

  // 4. FUNGSI REGISTER
  Future<Map<String, dynamic>> register(String email, String password) async {
    _isLoading = true;
    notifyListeners(); // Bilang ke UI -> "Tolong tampilkan loading"

    // Panggil ApiService
    final result = await _apiService.register(email, password);

    _isLoading = false;
    notifyListeners(); // Bilang ke UI -> "Loading selesai"

    // Kembalikan hasilnya (sukses atau gagal) ke UI
    return result;
  }

  // Dipanggil saat login/app start
  Future<void> fetchProfile(String token) async {
    final result = await _apiService.getProfile(token);
    if (result['success'] == true) {
      _email = result['data']['email'];
      _profileImageUrl = result['data']['profile_image_url'];
      notifyListeners();
    }
  }

  // Dipanggil saat tombol "Edit Foto" ditekan
  Future<void> uploadImage(String token, String imagePath) async {
    _isUploading = true;
    notifyListeners();

    final result = await _apiService.uploadProfileImage(token, imagePath);

    if (result['success'] == true) {
      // Jika sukses, ambil URL baru dan update
      _profileImageUrl = result['data']['profile_image_url'];
    } else {
      // TODO: Tampilkan error ke user
      print(result['message']);
    }

    _isUploading = false;
    notifyListeners();
  }
}