import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CurrencyProvider with ChangeNotifier {
  final String _apiKey = "214eeb10fdcd573416707973"; 
  final String _apiUrl = "https://v6.exchangerate-api.com/v6/";

  Map<String, double> _rates = {};
  List<String> _currencies = [];
  bool _isLoading = false;
  String? _error;

  Map<String, double> get rates => _rates;
  List<String> get currencies => _currencies;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchRates(String baseCurrency) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final url = Uri.parse('$_apiUrl$_apiKey/latest/$baseCurrency');

    try {
      final response = await http.get(url);
      final body = json.decode(response.body);

      if (response.statusCode == 200 && body['result'] == 'success') {
        _rates = (body['conversion_rates'] as Map<String, dynamic>)
            .map((key, value) => MapEntry(key, value.toDouble()));
        
        _currencies = _rates.keys.toList();

        _error = null;
      } else {
        _error = body['error-type'] ?? 'Gagal mengambil data kurs';
        _rates = {};
        _currencies = [];
      }
    } catch (e) {
      _error = 'Error koneksi: $e';
      _rates = {};
      _currencies = [];
    }

    _isLoading = false;
    notifyListeners();
  }
}