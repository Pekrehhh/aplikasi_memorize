import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationProvider with ChangeNotifier {
  Position? _position;
  DateTime? _fetchedAt;

  Position? get position => _position;
  bool get hasPosition => _position != null;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isStale() {
    if (_fetchedAt == null) return true;
    return DateTime.now().difference(_fetchedAt!).inMinutes > 10;
  }

  Future<void> preload() async {
    _isLoading = true;
    notifyListeners();

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
          _isLoading = false;
          notifyListeners();
          return;
        }
      }

      if (_position == null || _isStale()) {
        _position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
        );
        _fetchedAt = DateTime.now();
        notifyListeners();
      }
    } catch (e) {
      // ignore errors
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
