import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../services/api_service.dart';

class TimeConverterScreen extends StatefulWidget {
  @override
  _TimeConverterScreenState createState() => _TimeConverterScreenState();
}

class _TimeConverterScreenState extends State<TimeConverterScreen> {
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _currentTimezoneInfo;
  List<Map<String, String>> _convertedTimes = [];

  final Color backgroundColor = Color(0xFF0c1320);
  final Color badgeBgColor = Color(0xFF065353);
  final Color accentColor = Color(0xFF24cccc);
  final Color labelColor = Color(0xFF62f4f4);
  final Color inputFillColor = Colors.white;
  final Color inputTextColor = Color(0xFF0c1320);

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    _fetchLocationAndTime();
  }

  Future<void> _fetchLocationAndTime() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _convertedTimes = [];
    });

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

      setState(() {
        _currentTimezoneInfo = timezoneInfo;
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _convertTimes() {
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

    setState(() {
      _convertedTimes = results;
    });
  }

  Widget _buildTimeCard(String time, String timezone) {
    return Container(
      height: 71,
      decoration: BoxDecoration(
        color: inputFillColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: labelColor, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            time,
            style: TextStyle(
              color: inputTextColor,
              fontSize: 40,
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            timezone,
            style: TextStyle(
              color: inputTextColor,
              fontSize: 24,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConvertButton() {
    return GestureDetector(
      onTap: _convertTimes,
      child: Container(
        height: 71,
        width: double.infinity,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: labelColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(134, 214, 225, 0.09),
              offset: Offset(-3, -2),
              blurRadius: 4,
            ),
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.27),
              offset: Offset(5, 4),
              blurRadius: 4,
            ),
          ],
        ),
        child: Center(
          child: Text(
            'Convert',
            style: TextStyle(
              color: labelColor,
              fontSize: 20,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0, top: 8, bottom: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: badgeBgColor,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Center(
                child: Text(
                  'Timezone',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: labelColor))
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'Error: $_errorMessage\n\nPastikan izin lokasi diberikan dan API Key TimezoneDB benar.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Time based on Your address',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 50),

                      Text(
                        _currentTimezoneInfo?['cityName'] ?? 'Loading city...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      _buildTimeCard(
                        DateFormat('HH:mm').format(
                          DateTime.fromMillisecondsSinceEpoch(
                            _currentTimezoneInfo!['timestamp'] * 1000,
                          ),
                        ),
                        _currentTimezoneInfo!['abbreviation'] ?? 'N/A',
                      ),
                      SizedBox(height: 34),

                      Text(
                        'Press to convert',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: labelColor, fontSize: 14),
                      ),
                      SizedBox(height: 12),
                      
                      _buildConvertButton(),
                      SizedBox(height: 25),
                      
                      if (_convertedTimes.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Conversion results',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: labelColor, fontSize: 14),
                            ),
                            SizedBox(height: 12),
                            _buildTimeCard(
                              _convertedTimes[0]['time']!,
                              _convertedTimes[0]['zone']!,
                            ),
                            SizedBox(height: 29),
                            _buildTimeCard(
                              _convertedTimes[1]['time']!,
                              _convertedTimes[1]['zone']!,
                            ),
                            SizedBox(height: 29),
                            _buildTimeCard(
                              _convertedTimes[2]['time']!,
                              _convertedTimes[2]['zone']!,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
    );
  }
}