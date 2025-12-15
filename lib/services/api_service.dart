import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _currencyApiKey = '214eeb10fdcd573416707973';
  static const String _currencyBaseUrl = 'https://v6.exchangerate-api.com/v6/$_currencyApiKey';

  static const String _timezoneApiKey = '34P3GPU1KEI1';
  static const String _timezoneBaseUrl = 'http://api.timezonedb.com/v2.1';

  static Future<Map<String, dynamic>> getCurrencyRates(String baseCurrency) async {
    final url = Uri.parse('$_currencyBaseUrl/latest/$baseCurrency');
    
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Gagal memuat kurs mata uang: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error koneksi currency: $e');
    }
  }
  
  static Future<Map<String, dynamic>?> getTimezoneInfo(double lat, double lng) async {
    final url = Uri.parse(
        '$_timezoneBaseUrl/get-time-zone?key=$_timezoneApiKey&format=json&by=position&lat=$lat&lng=$lng');
    
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['status'] == 'OK') {
          return body;
        } else {
          // API returned non-OK status
          return null;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}