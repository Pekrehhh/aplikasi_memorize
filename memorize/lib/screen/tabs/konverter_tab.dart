import 'package:flutter/material.dart';
import '../konv_uang_screen.dart';
import '../konv_waktu_screen.dart';

class KonversiTab extends StatelessWidget {
  const KonversiTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Konversi'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch, // Agar tombol lebar
            children: [
              // Tombol Konversi Uang
              ElevatedButton.icon(
                icon: Icon(Icons.attach_money),
                label: Text('Konversi Mata Uang'),
                style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 16)),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (ctx) => CurrencyConverterScreen()),
                  );
                },
              ),
              SizedBox(height: 24), // Jarak antar tombol
              // Tombol Konversi Waktu
              ElevatedButton.icon(
                icon: Icon(Icons.access_time_filled),
                label: Text('Konversi Waktu (LBS)'),
                style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 16)),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (ctx) => TimeConverterScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}