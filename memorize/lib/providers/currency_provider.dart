import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // Untuk format tanggal

class CurrencyProvider with ChangeNotifier {
  // --- PENTING: GANTI DENGAN API KEY ANDA ---
  final String _apiKey = "214eeb10fdcd573416707973";
  final String _apiUrl = "https://v6.exchangerate-api.com/v6/";

  Map<String, double> _rates = {};
  List<String> _currencies = [];
  bool _isLoading = true; // Mulai dengan true
  String? _error;
  DateTime? _lastUpdated; // Kapan data ini diambil

  // Getters
  Map<String, double> get rates => _rates;
  List<String> get currencies => _currencies;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get lastUpdatedDisplay {
    if (_lastUpdated == null) return '';
    // Format tanggal
    return DateFormat('d MMM y').format(_lastUpdated!);
  }

  // Fungsi untuk mengambil data kurs dari API
  // Kita akan selalu ambil dari base USD agar mudah dikonversi
  Future<void> fetchRates() async {
    // Jangan fetch ulang jika data sudah ada
    if (_rates.isNotEmpty) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    // Kita panggil notifyListeners() di awal HANYA jika _rates KOSONG
    notifyListeners(); 

    final url = Uri.parse('$_apiUrl$_apiKey/latest/USD');

    try {
      final response = await http.get(url);
      final body = json.decode(response.body);

      if (response.statusCode == 200 && body['result'] == 'success') {
        _rates = (body['conversion_rates'] as Map<String, dynamic>)
            .map((key, value) => MapEntry(key, value.toDouble()));
        
        // Ambil daftar mata uang (hanya beberapa yang populer)
        _currencies = ['USD', 'IDR', 'EUR', 'JPY', 'GBP', 'AUD', 'CAD', 'CHF', 'CNY', 'SGD', 'MYR'];
        // Urutkan daftar
        _currencies.sort();
        
        _lastUpdated = DateTime.fromMillisecondsSinceEpoch(body['time_last_update_unix'] * 1000);
        _error = null;
      } else {
        _error = body['error-type'] ?? 'Gagal mengambil data kurs';
      }
    } catch (e) {
      _error = 'Error koneksi: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Fungsi untuk melakukan konversi
  double convert(double amount, String fromCurrency, String toCurrency) {
    if (_rates.isEmpty || !_rates.containsKey(fromCurrency) || !_rates.containsKey(toCurrency)) {
      return 0;
    }
    
    // Ambil kurs dari USD
    double fromRate = _rates[fromCurrency]!;
    double toRate = _rates[toCurrency]!;

    // 1. Konversi 'amount' ke USD dulu
    double amountInUsd = amount / fromRate;
    // 2. Konversi dari USD ke mata uang target
    double finalAmount = amountInUsd * toRate;

    return finalAmount;
  }
}