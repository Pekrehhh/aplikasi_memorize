import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';

class CurrencyProvider with ChangeNotifier {
  final String _apiKey = "214eeb10fdcd573416707973";
  final String _apiUrl = "https://v6.exchangerate-api.com/v6/214eeb10fdcd573416707973/latest/USD";

  Map<String, double> _rates = {};
  List<String> _currencies = [];
  bool _isLoading = true;
  String? _error;
  DateTime? _lastUpdated;

  Map<String, double> get rates => _rates;
  List<String> get currencies => _currencies;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get lastUpdatedDisplay {
    if (_lastUpdated == null) return '';
    return DateFormat('d MMM y').format(_lastUpdated!);
  }

  Future<void> fetchRates() async {

    if (_rates.isNotEmpty) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;

    notifyListeners(); 

    final uri = Uri.parse('$_apiUrl$_apiKey/latest/USD');

    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 5);
      final request = await client.getUrl(uri);
      final response = await request.close().timeout(const Duration(seconds: 8));
      final bodyString = await response.transform(utf8.decoder).join();
      final body = json.decode(bodyString);

      if (response.statusCode == 200 && body['result'] == 'success') {
        _rates = (body['conversion_rates'] as Map<String, dynamic>)
            .map((key, value) => MapEntry(key, (value as num).toDouble()));

        _currencies = ['USD', 'IDR', 'EUR', 'JPY', 'GBP', 'AUD', 'CAD', 'CHF', 'CNY', 'SGD', 'MYR'];
        _currencies.sort();

        _lastUpdated = DateTime.fromMillisecondsSinceEpoch(body['time_last_update_unix'] * 1000);
        _error = null;
      } else {
        _error = body['error-type'] ?? 'Gagal mengambil data kurs';
      }
    } catch (e) {
      _error = 'Tidak ada koneksi internet atau gagal mengambil data: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  double convert(double amount, String fromCurrency, String toCurrency) {
    if (_rates.isEmpty || !_rates.containsKey(fromCurrency) || !_rates.containsKey(toCurrency)) {
      return 0;
    }

    double fromRate = _rates[fromCurrency]!;
    double toRate = _rates[toCurrency]!;
    double amountInUsd = amount / fromRate;
    double finalAmount = amountInUsd * toRate;

    return finalAmount;
  }
}