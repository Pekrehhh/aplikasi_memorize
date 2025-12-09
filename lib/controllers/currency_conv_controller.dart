import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:memorize/providers/currency_provider.dart';

class CurrencyConvController with ChangeNotifier {
  final CurrencyProvider currencyProvider;
  
  final TextEditingController amountController = TextEditingController();
  final NumberFormat formatter = NumberFormat("#,##0.00", "id_ID");

  String _fromCurrency = 'IDR';
  String _toCurrency = 'USD';
  String? _resultText;
  String? _resultCurrencySymbol;
  String _disclaimerText = '';
  bool _isConverting = false;

  String get fromCurrency => _fromCurrency;
  String get toCurrency => _toCurrency;
  String? get resultText => _resultText;
  String? get resultCurrencySymbol => _resultCurrencySymbol;
  String get disclaimerText => _disclaimerText;
  bool get isConverting => _isConverting;

  CurrencyConvController(this.currencyProvider) {
    if (currencyProvider.rates.isEmpty) {
      currencyProvider.fetchRates();
    }
  }

  void _setConverting(bool converting) {
    _isConverting = converting;
    notifyListeners();
  }

  void swapCurrencies() {
    final temp = _fromCurrency;
    _fromCurrency = _toCurrency;
    _toCurrency = temp;
    _resultText = null;
    _disclaimerText = '';
    notifyListeners();
  }

  void doConversion() {
    final amount = double.tryParse(amountController.text.replaceAll(',', '.')) ?? 0;

    if (amount == 0) {
      _resultText = '0.00';
      _resultCurrencySymbol = getCurrencySymbol(_toCurrency);
      _disclaimerText = '';
      notifyListeners();
      return;
    }

    if (currencyProvider.rates.isEmpty) {
      return;
    }

    _setConverting(true);

    Future.delayed(Duration(milliseconds: 250), () {
      final result = currencyProvider.convert(amount, _fromCurrency, _toCurrency);
      _resultText = formatter.format(result);
      _resultCurrencySymbol = getCurrencySymbol(_toCurrency);
      _disclaimerText = '*currency value per ${currencyProvider.lastUpdatedDisplay}';
      _setConverting(false);
    });
  }

  String getCurrencySymbol(String currencyCode) {
    switch (currencyCode) {
      case 'USD': return '\$';
      case 'EUR': return '€';
      case 'JPY': return '¥';
      case 'GBP': return '£';
      case 'IDR': return 'Rp';
      default: return currencyCode;
    }
  }

  void showCurrencyPicker(BuildContext context, bool isFromCurrency) {
    if (currencyProvider.currencies.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(currencyProvider.error ?? 'Gagal memuat daftar mata uang. Cek API Key.'),
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
                  itemCount: currencyProvider.currencies.length,
                  itemBuilder: (listCtx, index) {
                    final currency = currencyProvider.currencies[index];
                    return ListTile(
                      title: Text(
                        currency,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      onTap: () {
                        if (isFromCurrency) {
                          _fromCurrency = currency;
                        } else {
                          _toCurrency = currency;
                        }
                        _resultText = null;
                        _disclaimerText = '';
                        notifyListeners();
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

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }
}