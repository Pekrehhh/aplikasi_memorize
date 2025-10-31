import 'package:flutter/material.dart';
import '../konv_uang_screen.dart'; 
import '../konv_waktu_screen.dart';   

class KonverterTab extends StatelessWidget {
  const KonverterTab({Key? key}) : super(key: key);

  Widget _buildKonversiCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color iconBackgroundColor,
    required Color iconColor,
    required Color buttonColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 71,
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            Positioned(
              left: 30,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
            ),
            
            Positioned(
              left: 95,
              child: Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = Color(0xFF0c1320);
    final Color buttonColor = Color(0xFF24cccc);
    final Color buttonTextColor = Color(0xFF0c1320);
    final Color iconDarkBg = Color(0xFF065353);
    final Color iconLightBg = Colors.white;
    
    return Scaffold(
      backgroundColor: backgroundColor,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: buttonColor,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Text(
                  'Converter',
                  style: TextStyle(
                    color: backgroundColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: 100),

              Container(
                width: double.infinity,
                child: Text(
                  'What activity do you want\nto use?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: 60),

              _buildKonversiCard(
                context: context,
                title: 'Currency conversion',
                icon: Icons.attach_money,
                iconBackgroundColor: iconDarkBg,
                iconColor: Colors.white,
                buttonColor: buttonColor,
                textColor: buttonTextColor,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (ctx) => CurrencyConverterScreen()),
                  );
                },
              ),
              SizedBox(height: 35),

              _buildKonversiCard(
                context: context,
                title: 'Time conversion',
                icon: Icons.access_time,
                iconBackgroundColor: iconLightBg,
                iconColor: Colors.black,
                buttonColor: buttonColor,
                textColor: buttonTextColor,
                onTap: () {
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