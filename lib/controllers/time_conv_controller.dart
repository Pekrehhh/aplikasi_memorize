import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import '../services/api_service.dart';
import '../providers/location_provider.dart';

class TimeConvController with ChangeNotifier {
  final LocationProvider locationProvider;
  

  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _currentTimezoneInfo;
  List<Map<String, String>> _convertedTimes = [];
  double? _lastLat;
  double? _lastLng;
  
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get currentTimezoneInfo => _currentTimezoneInfo;
  List<Map<String, String>> get convertedTimes => _convertedTimes;
  
  TimeConvController(this.locationProvider) {
    tzdata.initializeTimeZones();
    fetchLocationAndTime();
  }

  Future<void> fetchLocationAndTime() async {
    _isLoading = true;
    _errorMessage = null;
    _convertedTimes = [];
    notifyListeners();

    try {
      Position? pos = locationProvider.position;
      if (pos == null) {
        await locationProvider.preload();
        pos = locationProvider.position;
      }

      if (pos == null) {
        throw Exception('Izin lokasi ditolak atau posisi tidak tersedia.');
      }

      final lat = pos.latitude;
      final lng = pos.longitude;
      if (_lastLat != null && _lastLng != null) {
        final dx = (_lastLat! - lat).abs();
        final dy = (_lastLng! - lng).abs();
        if (dx < 0.0005 && dy < 0.0005 && _currentTimezoneInfo != null) {
          _isLoading = false;
          notifyListeners();
          return;
        }
      }

      final body = await ApiService.getTimezoneInfo(lat, lng);
      if (body != null) {
        _currentTimezoneInfo = body;
        _lastLat = lat;
        _lastLng = lng;
        _isLoading = false;
      } else {
        throw Exception('Gagal mengambil info zona waktu');
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  void convertTimes() {
    if (_currentTimezoneInfo == null) return;

    try {
      final timestamp = _currentTimezoneInfo!['timestamp'];
      final gmtOffset = _currentTimezoneInfo!['gmtOffset'] ?? 0;
      final serverZoneName = _currentTimezoneInfo!['zoneName'] ?? _currentTimezoneInfo!['zone'] ?? _currentTimezoneInfo!['abbreviation'] ?? 'UTC';

      final utcSeconds = (timestamp as int) - (gmtOffset as int);
      final utcMoment = DateTime.fromMillisecondsSinceEpoch(utcSeconds * 1000, isUtc: true);

      final serverLocation = tz.getLocation(serverZoneName);
      final serverLocal = tz.TZDateTime.from(utcMoment, serverLocation);

      final targets = [
        {'label': 'WIB', 'zone': 'Asia/Jakarta'},
        {'label': 'WITA', 'zone': 'Asia/Makassar'},
        {'label': 'WIT', 'zone': 'Asia/Jayapura'},
        {'label': 'London', 'zone': 'Europe/London'},
      ];

      final List<Map<String, String>> results = [];

      for (final t in targets) {
        if (serverZoneName == t['zone']) continue;
        try {
          final loc = tz.getLocation(t['zone']!);
          final targetTime = tz.TZDateTime.from(utcMoment, loc);
          final timeText = DateFormat('HH:mm').format(targetTime);

          String dayNote;
          if (targetTime.year == serverLocal.year && targetTime.month == serverLocal.month && targetTime.day == serverLocal.day) {
            dayNote = 'Today';
          } else if (tz.TZDateTime(loc, targetTime.year, targetTime.month, targetTime.day).isBefore(tz.TZDateTime(serverLocation, serverLocal.year, serverLocal.month, serverLocal.day))) {
            dayNote = 'Yesterday';
          } else if (tz.TZDateTime(loc, targetTime.year, targetTime.month, targetTime.day).isAfter(tz.TZDateTime(serverLocation, serverLocal.year, serverLocal.month, serverLocal.day))) {
            dayNote = 'Tomorrow';
          } else {
            dayNote = '';
          }

          results.add({
            'zone': t['label']!,
            'time': timeText,
            'note': dayNote,
          });
        } catch (e) {
          // skip
        }
      }

      _convertedTimes = results;
      notifyListeners();
    } catch (e) {
      _convertedTimes = [];
      notifyListeners();
    }
  }
}