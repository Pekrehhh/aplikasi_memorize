import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:io';
import 'dart:convert';
import '../config.dart';

class TimeConvController with ChangeNotifier {
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
      final apiKey = TIMEZONE_DB_API_KEY;
      if (apiKey.isEmpty) {
        throw Exception('API Key TimezoneDB belum diset. Edit lib/config.dart untuk menambahkannya.');
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
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ));

      final uri = Uri.parse('http://api.timezonedb.com/v2.1/get-time-zone?key=$apiKey&format=json&by=position&lat=${position.latitude}&lng=${position.longitude}');
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 8);
      final request = await client.getUrl(uri);
      final response = await request.close().timeout(const Duration(seconds: 10));
      final bodyString = await response.transform(utf8.decoder).join();
      final body = json.decode(bodyString) as Map<String, dynamic>;

      if (response.statusCode == 200 && (body['status'] == 'OK' || body['status'] == 'ok')) {
        _currentTimezoneInfo = body;
        _isLoading = false;
      } else {
        throw Exception('Gagal mengambil info zona waktu: ${body['message'] ?? 'unknown'}');
      }
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
        // Silently skip conversion errors
      }
    });

    _convertedTimes = results;
    notifyListeners();
  }
}