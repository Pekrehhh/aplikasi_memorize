import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart'; 

class AuthProvider with ChangeNotifier {
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

  Future<Map<String, dynamic>> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    final result = await _apiService.login(username, password);

    if (result['success'] == true) {
      _token = result['token'];
      _email = result['user']['email'];
      _profileImageUrl = result['user']['profile_image_url'];
      
      await _storage.write(key: 'authToken', value: _token);

      _isLoading = false;
      notifyListeners();
      return {'success': true};
    } else {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': result['message']};
    }
  }

  Future<void> tryAutoLogin() async {
    final storedToken = await _storage.read(key: 'authToken');
    
    if (storedToken != null) {
      _token = storedToken;
      await fetchProfile(_token!);
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _token = null;
    await _storage.delete(key: 'authToken');
    notifyListeners();
  }

  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    _isLoading = true;
    notifyListeners();
    final result = await _apiService.register(username, email, password);

    _isLoading = false;
    notifyListeners();
    return result;
  }

  Future<void> fetchProfile(String token) async {
    final result = await _apiService.getProfile(token);
    if (result['success'] == true) {
      _email = result['data']['email'];
      _profileImageUrl = result['data']['profile_image_url'];
      notifyListeners();
    }
  }
  
  Future<void> uploadImage(String token, String imagePath) async {
    _isUploading = true;
    notifyListeners();

    final result = await _apiService.uploadProfileImage(token, imagePath);

    if (result['success'] == true) {
      _profileImageUrl = result['data']['profile_image_url'];
    } else {
      print(result['message']);
    }

    _isUploading = false;
    notifyListeners();
  }
}