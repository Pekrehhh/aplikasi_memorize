import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/currency_provider.dart';
import 'package:intl/intl.dart';

class CurrencyConverterScreen extends StatefulWidget {
  @override
  _CurrencyConverterScreenState createState() => _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  final _amountController = TextEditingController();
  final NumberFormat _formatter = NumberFormat("#,##0.00", "id_ID");

  String _fromCurrency = 'IDR';
  String _toCurrency = 'USD';
  String? _resultText;
  String? _resultCurrencySymbol;
  String _disclaimerText = '';

  bool _isConverting = false;

  final Color backgroundColor = Color(0xFF0c1320);
  final Color badgeBgColor = Color(0xFF065353);
  final Color accentColor = Color(0xFF24cccc);
  final Color labelColor = Color(0xFF62f4f4);
  final Color inputFillColor = Colors.white;
  final Color inputTextColor = Color(0xFF0c1320);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CurrencyProvider>(context, listen: false).fetchRates();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _swapCurrencies() {
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
      _resultText = null;
      _disclaimerText = '';
    });
  }

  void _doConversion() {
    FocusScope.of(context).unfocus();
    final provider = Provider.of<CurrencyProvider>(context, listen: false);
    final amount = double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0;

    if (amount == 0) {
      setState(() {
        _resultText = '0.00';
        _resultCurrencySymbol = _getCurrencySymbol(_toCurrency);
        _disclaimerText = '';
      });
      return;
    }

    if (provider.rates.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal melakukan konversi. Cek koneksi atau API Key.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() { _isConverting = true; });

    Future.delayed(Duration(milliseconds: 250), () {
      final result = provider.convert(amount, _fromCurrency, _toCurrency);

      setState(() {
        _resultText = _formatter.format(result);
        _resultCurrencySymbol = _getCurrencySymbol(_toCurrency);
        _disclaimerText = '*currency value per ${provider.lastUpdatedDisplay}';
        _isConverting = false;
      });
    });
  }

  String _getCurrencySymbol(String currencyCode) {
    switch (currencyCode) {
      case 'USD': return '\$';
      case 'EUR': return '€';
      case 'JPY': return '¥';
      case 'GBP': return '£';
      case 'IDR': return 'Rp';
      default: return currencyCode;
    }
  }

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

  void _showCurrencyPicker(bool isFromCurrency) {
    final provider = Provider.of<CurrencyProvider>(context, listen: false);
    
    if (provider.currencies.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Gagal memuat daftar mata uang. Cek API Key.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFF2C2C2C),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          height: 350,
          child: Column(
            children: [

              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: provider.currencies.length,
                  itemBuilder: (listCtx, index) {
                    final currency = provider.currencies[index];
                    return ListTile(
                      title: Text(
                        currency,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      onTap: () {
                        setState(() {
                          if (isFromCurrency) {
                            _fromCurrency = currency;
                          } else {
                            _toCurrency = currency;
                          }
                          _resultText = null; 
                          _disclaimerText = '';
                        });
                        Navigator.of(ctx).pop();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCurrencyButton(String currency) {
    return GestureDetector(
      onTap: () => _showCurrencyPicker(currency == _fromCurrency),
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
                        _getCurrencySymbol(_fromCurrency),
                        style: TextStyle(
                          color: inputTextColor,
                          fontSize: 24,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _amountController,
                          style: TextStyle(
                            color: inputTextColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Amount of money',
                            hintStyle: TextStyle(
                              color: inputTextColor.withOpacity(0.7),
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
                    _buildCurrencyButton(_fromCurrency),
                    IconButton(
                      icon: Icon(Icons.swap_horiz, color: labelColor, size: 30),
                      onPressed: _swapCurrencies,
                    ),
                    _buildCurrencyButton(_toCurrency),
                  ],
                ),
                SizedBox(height: 25),

                GestureDetector(
                  onTap: _doConversion,
                  child: Container(
                    height: 71,
                    width: double.infinity,
                    decoration: _buildShadowBorder(labelColor),
                    child: Center(
                      child: _isConverting
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

                if (_resultText != null)
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
                              _resultCurrencySymbol ?? '',
                              style: TextStyle(
                                color: inputTextColor,
                                fontSize: 24,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _resultText!,
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
                        _disclaimerText,
                        style: TextStyle(color: labelColor, fontSize: 11),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}