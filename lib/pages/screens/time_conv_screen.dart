import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:memorize/providers/location_provider.dart';
import 'package:memorize/controllers/time_conv_controller.dart';

class TimeConvScreen extends StatelessWidget {
  const TimeConvScreen({super.key});

  static const Color backgroundColor = Color(0xFF0c1320);
  static const Color badgeBgColor = Color(0xFF065353);
  static const Color labelColor = Color(0xFF62f4f4);
  static const Color inputFillColor = Colors.white;
  static const Color inputTextColor = Color(0xFF0c1320);

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
          Text(time, style: TextStyle(color: inputTextColor, fontSize: 40, fontWeight: FontWeight.w400)),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(timezone, style: TextStyle(color: inputTextColor, fontSize: 24, fontWeight: FontWeight.w400)),
              const SizedBox(height: 4),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => TimeConvController(Provider.of<LocationProvider>(context, listen: false)),
      child: Consumer<TimeConvController>(
        builder: (ctx, controller, _) {
          return Scaffold(
            backgroundColor: backgroundColor,
            appBar: AppBar(
              backgroundColor: backgroundColor,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
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
                    child: const Center(
                      child: Text('Timezone', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
              ],
            ),
            body: controller.isLoading
                ? Center(child: CircularProgressIndicator(color: labelColor))
                : controller.errorMessage != null
                    ? Center(child: Padding(padding: const EdgeInsets.all(20.0), child: Text('Error: ${controller.errorMessage}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.red, fontSize: 16))))
                    : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text('Time based on Your address', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 50),
                            Text(controller.currentTimezoneInfo?['cityName'] ?? 'Unknown City', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 8),
                            Builder(builder: (ctx) {
                              try {
                                debugPrint('Timezone API response: ${controller.currentTimezoneInfo.toString()}');
                              } catch (_) {}
                              final formatted = controller.currentTimezoneInfo != null && controller.currentTimezoneInfo!['formatted'] != null
                                  ? controller.currentTimezoneInfo!['formatted'].toString().split(' ').last.substring(0,5)
                                  : '--:--';
                              return _buildTimeCard(formatted, controller.currentTimezoneInfo?['abbreviation'] ?? 'N/A');
                            }),
                            const SizedBox(height: 34),
                            const Text('Press to convert', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF62f4f4), fontSize: 14)),
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: () => controller.convertTimes(),
                              child: Container(
                                height: 71,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: backgroundColor,
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(color: labelColor, width: 1),
                                  boxShadow: const [
                                    BoxShadow(color: Color.fromRGBO(134, 214, 225, 0.09), offset: Offset(-3, -2), blurRadius: 4),
                                    BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.27), offset: Offset(5, 4), blurRadius: 4),
                                  ],
                                ),
                                child: Center(child: Text('Convert', style: TextStyle(color: labelColor, fontSize: 20, fontWeight: FontWeight.w400))),
                              ),
                            ),
                            const SizedBox(height: 25),
                            if (controller.convertedTimes.isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text('Conversion results', textAlign: TextAlign.center, style: TextStyle(color: labelColor, fontSize: 14)),
                                  const SizedBox(height: 12),
                                  for (var item in controller.convertedTimes) ...[
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        _buildTimeCard(item['time']!, item['zone']!),
                                        if ((item['note'] ?? '').isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(right: 12.0, top: 6),
                                            child: Text(item['note']!, textAlign: TextAlign.right, style: TextStyle(color: labelColor, fontSize: 12)),
                                          ),
                                        const SizedBox(height: 16),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                          ],
                        ),
                      ),
          );
        },
      ),
    );
  }
}