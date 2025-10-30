import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../services/api_service.dart'; 

class TimeConverterScreen extends StatefulWidget {
  const TimeConverterScreen({super.key});

  @override
  _TimeConverterScreenState createState() => _TimeConverterScreenState();
}

class _TimeConverterScreenState extends State<TimeConverterScreen> {
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _currentTimezoneInfo; // Data dari TimezoneDB
  List<Map<String, String>> _convertedTimes = []; // Hasil konversi

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones(); // Inisialisasi package timezone
    _fetchLocationAndTime(); // Mulai proses LBS
  }

  // --- Fungsi Utama (LBS & API Call) ---
  Future<void> _fetchLocationAndTime() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _convertedTimes = []; // Reset hasil konversi
    });

    try {
      // 1. Dapatkan API Key dari backend kita
      final apiKey = await _apiService.getTimezoneDbApiKey();
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('API Key TimezoneDB tidak ditemukan.');
      }

      // 2. Cek Izin Lokasi
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          throw Exception('Izin lokasi ditolak.');
        }
      }

      // 3. Dapatkan Lokasi Saat Ini (LBS)
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // 4. Panggil API TimezoneDB
      final timezoneInfo = await _apiService.getTimezoneInfo(
          apiKey, position.latitude, position.longitude);
      
      if (timezoneInfo == null) {
        throw Exception('Gagal mendapatkan info zona waktu.');
      }

      // 5. Simpan hasil
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

  // --- Fungsi Konversi Lokal (pakai package timezone) ---
  void _convertTimes() {
    if (_currentTimezoneInfo == null) return;

    // Ambil waktu saat ini dari hasil API (dalam Unix timestamp)
    final currentTimestamp = _currentTimezoneInfo!['timestamp'];
    final currentUtcTime = DateTime.fromMillisecondsSinceEpoch(currentTimestamp * 1000, isUtc: true);

    // Daftar zona waktu target
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
          'date': DateFormat('E, d MMM y').format(targetTime),
        });
      } catch (e) {
        print("Error konversi ke $zoneName: $e");
      }
    });

    setState(() {
      _convertedTimes = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Konversi Waktu (LBS)')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(child: Text('Error: $_errorMessage'))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // --- Card Lokasi Saat Ini ---
                      _buildTimeCard(
                        city: _currentTimezoneInfo!['cityName'] ?? 'Lokasi Tidak Diketahui',
                        zone: _currentTimezoneInfo!['abbreviation'] ?? 'N/A',
                        time: DateFormat('HH:mm').format(
                          DateTime.fromMillisecondsSinceEpoch(
                            _currentTimezoneInfo!['timestamp'] * 1000,
                          ),
                        ),
                        date: DateFormat('E, d MMM y').format(
                          DateTime.fromMillisecondsSinceEpoch(
                            _currentTimezoneInfo!['timestamp'] * 1000,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),

                      // --- Tombol Konversi ---
                      ElevatedButton(
                        onPressed: _convertTimes,
                        child: Text('Konversi ke Zona Waktu Lain'),
                      ),
                      SizedBox(height: 20),

                      // --- Hasil Konversi ---
                      if (_convertedTimes.isNotEmpty)
                        Expanded( // Agar bisa di-scroll jika banyak
                          child: ListView.separated(
                            itemCount: _convertedTimes.length,
                            separatorBuilder: (context, index) => SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final data = _convertedTimes[index];
                              return _buildTimeCard(
                                // Kita tidak punya nama kota di sini
                                city: data['zone']!, // Tampilkan singkatan saja
                                zone: data['zone']!,
                                time: data['time']!,
                                date: data['date']!,
                                isConverted: true,
                              );
                            },
                          ),
                        ),
                    ],
                  ),
      ),
    );
  }

  // --- Helper Widget untuk Card Waktu ---
  Widget _buildTimeCard({
    required String city,
    required String zone,
    required String time,
    required String date,
    bool isConverted = false,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isConverted ? zone : city, // Tampilkan singkatan jika hasil konversi
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
            if (!isConverted) // Hanya tampilkan zona di card pertama
              Text(
                zone,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
}