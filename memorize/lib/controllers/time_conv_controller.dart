import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../services/api_service.dart';

class TimeConvController with ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _currentTimezoneInfo;
  List<Map<String, String>> _convertedTimes = [];
  
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get currentTimezoneInfo => _currentTimezoneInfo;
  List<Map<String, String>> get convertedTimes => _convertedTimes;
  
  TimeConvController() {
    tz.initializeTimeZones();
    fetchLocationAndTime();
  }

  Future<void> fetchLocationAndTime() async {
    _isLoading = true;
    _errorMessage = null;
    _convertedTimes = [];
    notifyListeners();

    try {
      final apiKey = await _apiService.getTimezoneDbApiKey();
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('API Key TimezoneDB tidak ditemukan.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          throw Exception('Izin lokasi ditolak.');
        }
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      final timezoneInfo = await _apiService.getTimezoneInfo(
          apiKey, position.latitude, position.longitude);
      
      if (timezoneInfo == null) {
        throw Exception('Gagal mendapatkan info zona waktu.');
      }

      _currentTimezoneInfo = timezoneInfo;
      _isLoading = false;

    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  void convertTimes() {
    if (_currentTimezoneInfo == null) return;

    final currentTimestamp = _currentTimezoneInfo!['timestamp'];
    final currentUtcTime = DateTime.fromMillisecondsSinceEpoch(currentTimestamp * 1000, isUtc: true);

    final targetZones = {
      'WITA': 'Asia/Makassar',
      'WIT': 'Asia/Jayapura',
      'London': 'Europe/London',
    };

    List<Map<String, String>> results = [];
    targetZones.forEach((zoneAbbreviation, zoneName) {
      try {
        final location = tz.getLocation(zoneName);
        final targetTime = tz.TZDateTime.from(currentUtcTime, location);
        results.add({
          'zone': zoneAbbreviation,
          'time': DateFormat('HH:mm').format(targetTime),
        });
      } catch (e) {
        print("Error konversi ke $zoneName: $e");
      }
    });

    _convertedTimes = results;
    notifyListeners();
  }
}