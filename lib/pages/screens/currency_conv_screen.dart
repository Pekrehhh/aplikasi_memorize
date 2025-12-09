import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../controllers/currency_conv_controller.dart';
import '../../providers/currency_provider.dart';

class CurrencyConverterScreen extends StatelessWidget {

  final Color backgroundColor = Color(0xFF0c1320);
  final Color badgeBgColor = Color(0xFF065353);
  final Color accentColor = Color(0xFF24cccc);
  final Color labelColor = Color(0xFF62f4f4);
  final Color inputFillColor = Colors.white;
  final Color inputTextColor = Color(0xFF0c1320);

  CurrencyConverterScreen({super.key});

  BoxDecoration _buildShadowBorder(Color borderColor) {
    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(25),
      border: Border.all(color: borderColor, width: 1),
      boxShadow: [
        BoxShadow(
          color: Color.fromRGBO(134, 214, 225, 0.09),
          offset: Offset(-3, -2),
          blurRadius: 4,
          spreadRadius: 0,
        ),
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.27),
          offset: Offset(5, 4),
          blurRadius: 4,
          spreadRadius: 0,
        ),
      ],
    );
  }

  Widget _buildCurrencyButton(BuildContext context, CurrencyConvController controller, String currency) {
    bool isFrom = currency == controller.fromCurrency;
    return GestureDetector(
      onTap: () => controller.showCurrencyPicker(context, isFrom),
      child: Container(
        width: 140,
        height: 71,
        decoration: _buildShadowBorder(labelColor),
        child: Center(
          child: Text(
            currency,
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
      create: (ctx) => CurrencyConvController(
        Provider.of<CurrencyProvider>(ctx, listen: false),
      ),
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
                    'Currency',
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

        body: Consumer<CurrencyProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && provider.rates.isEmpty) {
              return Center(child: CircularProgressIndicator(color: labelColor));
            }

            if (provider.error != null && provider.rates.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'Gagal memuat data:\n${provider.error}\n\nPastikan API Key Anda benar.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
              );
            }
            
            return Consumer<CurrencyConvController>(
              builder: (context, controller, child) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Enter the nominal amount of money',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 50),
                      Container(
                        height: 71,
                        decoration: BoxDecoration(
                          color: inputFillColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: labelColor, width: 1),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Text(
                              controller.getCurrencySymbol(controller.fromCurrency),
                              style: TextStyle(
                                color: inputTextColor,
                                fontSize: 24,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: controller.amountController,
                                style: TextStyle(
                                  color: inputTextColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Amount of money',
                                  hintStyle: TextStyle(
                                    color: inputTextColor.withValues(alpha: 0.5),
                                    fontSize: 14,
                                  ),
                                  border: InputBorder.none,
                                ),
                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'^\d*[,.]?\d*')),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 34),
                      Text(
                        'Select the currency you want to convert',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: labelColor, fontSize: 14),
                      ),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildCurrencyButton(context, controller, controller.fromCurrency),
                          IconButton(
                            icon: Icon(Icons.swap_horiz, color: labelColor, size: 30),
                            onPressed: controller.swapCurrencies,
                          ),
                          _buildCurrencyButton(context, controller, controller.toCurrency),
                        ],
                      ),
                      SizedBox(height: 25),
                      GestureDetector(
                        onTap: controller.doConversion,
                        child: Container(
                          height: 71,
                          width: double.infinity,
                          decoration: _buildShadowBorder(labelColor),
                          child: Center(
                            child: controller.isConverting
                                ? CircularProgressIndicator(color: labelColor, strokeWidth: 2)
                                : Text(
                                    'Convert',
                                    style: TextStyle(
                                      color: labelColor,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      SizedBox(height: 35),
                      if (controller.resultText != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Conversion results',
                              style: TextStyle(color: labelColor, fontSize: 14),
                            ),
                            SizedBox(height: 12),
                            Container(
                              height: 71,
                              decoration: BoxDecoration(
                                color: inputFillColor,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: labelColor, width: 1),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                children: [
                                  Text(
                                    controller.resultCurrencySymbol ?? '',
                                    style: TextStyle(
                                      color: inputTextColor,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      controller.resultText!,
                                      style: TextStyle(
                                        color: inputTextColor,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              controller.disclaimerText,
                              style: TextStyle(color: labelColor, fontSize: 11),
                            ),
                          ],
                        ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}