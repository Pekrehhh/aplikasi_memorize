import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../controllers/time_conv_controller.dart';

class TimeConverterScreen extends StatelessWidget {
  TimeConverterScreen({Key? key}) : super(key: key);
  
  final Color backgroundColor = Color(0xFF0c1320);
  final Color badgeBgColor = Color(0xFF065353);
  final Color labelColor = Color(0xFF62f4f4);
  final Color inputFillColor = Colors.white;
  final Color inputTextColor = Color(0xFF0c1320);
  
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
  
  Widget _buildConvertButton(VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
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
    return ChangeNotifierProvider(
      create: (_) => TimeConvController(),
      child: Scaffold(
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
        
        body: Consumer<TimeConvController>(
          builder: (context, controller, child) {
            if (controller.isLoading) {
              return Center(child: CircularProgressIndicator(color: labelColor));
            }

            if (controller.errorMessage != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'Error: ${controller.errorMessage}\n\nPastikan izin lokasi diberikan dan API Key TimezoneDB benar.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
              );
            }

            return SingleChildScrollView(
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
                    controller.currentTimezoneInfo?['cityName'] ?? 'Loading city...',
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
                        controller.currentTimezoneInfo!['timestamp'] * 1000,
                      ),
                    ),
                    controller.currentTimezoneInfo!['abbreviation'] ?? 'N/A',
                  ),
                  SizedBox(height: 34),
                  Text(
                    'Press to convert',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: labelColor, fontSize: 14),
                  ),
                  SizedBox(height: 12),
                  _buildConvertButton(controller.convertTimes),
                  SizedBox(height: 25),
                  if (controller.convertedTimes.isNotEmpty)
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
                          controller.convertedTimes[0]['time']!,
                          controller.convertedTimes[0]['zone']!,
                        ),
                        SizedBox(height: 29),
                        _buildTimeCard(
                          controller.convertedTimes[1]['time']!,
                          controller.convertedTimes[1]['zone']!,
                        ),
                        SizedBox(height: 29),
                        _buildTimeCard(
                          controller.convertedTimes[2]['time']!,
                          controller.convertedTimes[2]['zone']!,
                        ),
                      ],
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}