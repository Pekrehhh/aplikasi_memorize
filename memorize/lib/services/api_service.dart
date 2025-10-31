import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/note.dart';

class ApiService {
  // static const String _baseUrl = 'http://192.168.1.2:3000/api';
  static const String _baseUrl = 'http://10.0.2.2:3000/api';
  // (atau 'http://localhost:3000' jika pakai Web/iOS)

  // --- FUNGSI AUTH (Login) ---
  Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse('$_baseUrl/auth/login');
    try {
      final response = await http.post(
        url,
        headers: { 'Content-Type': 'application/json', },
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );
      final body = json.decode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'token': body['token'], 'user': body['user']};
      } else {
        return {'success': false, 'message': body['message']};
      }
    } catch (e) {
      return {'success': false, 'message': 'Tidak bisa terhubung ke server: $e'};
    }
  }

  // --- FUNGSI AUTH (Register) ---
  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    final url = Uri.parse('$_baseUrl/auth/register');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );
      final body = json.decode(response.body);
      if (response.statusCode == 201) {
        return {'success': true, 'message': body['message']};
      } else {
        return {'success': false, 'message': body['message']};
      }
    } catch (e) {
      return {'success': false, 'message': 'Tidak bisa terhubung ke server: $e'};
    }
  }

  // --- FUNGSI NOTES (BARU!) ---

  // 1. READ: Mengambil semua notes
  Future<List<Note>> getNotes(String token) async {
    final url = Uri.parse('$_baseUrl/notes');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // "Tiket" (Token)
        },
      );

      if (response.statusCode == 200) {
        // API mengembalikan List (array) dari JSON
        final List<dynamic> body = json.decode(response.body);
        // Kita ubah List JSON itu menjadi List<Note> pakai "pabrik"
        final List<Note> notes = body.map((jsonItem) => Note.fromJson(jsonItem)).toList();
        return notes;
      } else {
        // Jika gagal (misal: token salah), lempar error
        throw Exception('Gagal mengambil notes');
      }
    } catch (e) {
      throw Exception('Error koneksi: $e');
    }
  }

  // 2. CREATE: Membuat note baru
  Future<Note> createNote(
    String token,
    String title,
    String content, // <-- Pastikan ini String
    String color,
    DateTime? reminderAt,
  ) async {
    final url = Uri.parse('$_baseUrl/notes');
    try {
      Map<String, dynamic> body = {
        'title': title,
        'content': content, // <-- Kirim sebagai String
        'color': color,
      };

      if (reminderAt != null) {
        body['reminder_at'] = reminderAt.toIso8601String();
      }

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 201) {
        // Di sini Note.fromJson akan dipanggil, dan sekarang sudah aman
        return Note.fromJson(json.decode(response.body));
      } else {
        throw Exception('Gagal membuat note: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error koneksi: $e');
    }
  }

  // 3. DELETE: Menghapus note
  Future<bool> deleteNote(String token, int noteId) async {
    final url = Uri.parse('$_baseUrl/notes/$noteId');
    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // --- FUNGSI PROFIL (BARU!) ---

// GET: Ambil data profil
  Future<Map<String, dynamic>> getProfile(String token) async {
    final url = Uri.parse('$_baseUrl/profile/me');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {'success': false, 'message': 'Gagal mengambil profil'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error koneksi: $e'};
    }
  }

// POST: Upload gambar (pakai Multipart)
  Future<Map<String, dynamic>> uploadProfileImage(String token, String imagePath) async {
    final url = Uri.parse('$_baseUrl/profile/upload');
    try {
      var request = http.MultipartRequest('POST', url);
      // Tambahkan token ke header
      request.headers['Authorization'] = 'Bearer $token';
      // Tambahkan file gambar
      request.files.add(
        // 'profileImage' HARUS SAMA dengan di multer backend
          await http.MultipartFile.fromPath('profileImage', imagePath)
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {'success': false, 'message': 'Gagal upload: ${response.body}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error koneksi: $e'};
    }
  }

  Future<String?> getTimezoneDbApiKey() async {
    final url = Uri.parse('${_baseUrl.replaceAll('/api', '')}/api/config/keys'); 
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        return body['timezoneDbApiKey'];
      }
      return null;
    } catch (e) {
      print('Gagal mengambil API key: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getTimezoneInfo(
      String apiKey, double latitude, double longitude) async {
    final url = Uri.parse(
        'http://api.timezonedb.com/v2.1/get-time-zone?key=$apiKey&format=json&by=position&lat=$latitude&lng=$longitude');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['status'] == 'OK') {
          return body;
        } else {
          print('TimezoneDB API Error: ${body['message']}');
          return null;
        }
      }
      return null;
    } catch (e) {
      print('Error memanggil TimezoneDB: $e');
      return null;
    }
  }
}