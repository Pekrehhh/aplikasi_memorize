import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class CurrencyProvider with ChangeNotifier {

  Map<String, double> _rates = {};
  List<String> _currencies = [];
  bool _isLoading = false;
  String? _error;

  String _lastUpdatedDisplay = '-';

  Map<String, double> get rates => _rates;
  List<String> get currencies => _currencies;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get lastUpdatedDisplay => _lastUpdatedDisplay;
  
  Future<void> fetchRates() async {
    if (_rates.isNotEmpty) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      
      final data = await ApiService.getCurrencyRates('USD');
      
      if (data['result'] == 'success') {
        _rates = Map<String, double>.from(data['conversion_rates'].map(
          (key, value) => MapEntry(key, value.toDouble()),
        ));
        _currencies = ['USD', 'IDR', 'EUR', 'JPY', 'GBP', 'AUD', 'SGD', 'MYR', 'CNY'];
        _currencies.sort();
        
        final lastUpdate = DateTime.fromMillisecondsSinceEpoch(data['time_last_update_unix'] * 1000);
        _lastUpdatedDisplay = DateFormat('d MMM y').format(lastUpdate);
        
        _error = null;
      } else {
        _error = 'Gagal mengambil data dari API.';
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
  
  double convert(double amount, String fromCurrency, String toCurrency) {
    if (_rates.isEmpty || !_rates.containsKey(fromCurrency) || !_rates.containsKey(toCurrency)) {
      return 0;
    }
    
    double amountInUsd = amount / _rates[fromCurrency]!;
    double finalAmount = amountInUsd * _rates[toCurrency]!;

    return finalAmount;
  }
}