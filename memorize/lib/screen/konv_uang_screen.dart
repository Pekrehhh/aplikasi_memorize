import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  _CurrencyConverterScreenState createState() =>
      _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  final _amountController = TextEditingController();
  final List<String> _currencies = ['USD', 'EUR', 'IDR', 'JPY'];
  String _fromCurrency = 'USD';
  String _toCurrency = 'IDR';
  String _result = '';
  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _amountController.text = '1';
    _convertCurrency();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
  // Fungsi untuk menukar mata uang
  void _swapCurrencies() {
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
      _convertCurrency();
    });
  }
  // Fungsi placeholder untuk konversi (nanti pakai data API)
  void _convertCurrency() {
    // --- INI HANYA CONTOH LOGIC, NANTI DIGANTI ---
    final amount = double.tryParse(_amountController.text) ?? 0;
    double rate = 15000; // Contoh rate USD ke IDR
    if (_fromCurrency == 'IDR' && _toCurrency == 'USD') {
      rate = 1 / 15000;
    } else if (_fromCurrency == 'EUR' && _toCurrency == 'IDR') {
      rate = 16000;
    } // Tambah logic lain nanti
    
    final convertedAmount = amount * rate;

    setState(() {
      // Format hasil dengan pemisah ribuan
      _result = '${convertedAmount.toStringAsFixed(2)} $_toCurrency';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Konversi Mata Uang')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- Input Amount ---
            TextField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Jumlah',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
              ],
              onChanged: (value) => _convertCurrency(), // Hitung ulang saat diketik
            ),
            SizedBox(height: 20),
            // --- Baris Dropdown dan Tombol Swap ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Dropdown "From"
                _buildCurrencyDropdown(_fromCurrency, (newValue) {
                  setState(() {
                    _fromCurrency = newValue!;
                    _convertCurrency();
                  });
                }),

                // Tombol Swap
                IconButton(
                  icon: Icon(Icons.swap_horiz, size: 30),
                  onPressed: _swapCurrencies,
                ),

                // Dropdown "To"
                _buildCurrencyDropdown(_toCurrency, (newValue) {
                  setState(() {
                    _toCurrency = newValue!;
                    _convertCurrency();
                  });
                }),
              ],
            ),
            SizedBox(height: 30),

            // --- Hasil Konversi ---
            if (_isLoading)
              CircularProgressIndicator()
            else
              Text(
                _result,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }

  // Helper widget untuk membuat Dropdown
  Widget _buildCurrencyDropdown(
      String value, ValueChanged<String?> onChanged) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: _currencies.map((String currency) {
            return DropdownMenuItem<String>(
              value: currency,
              child: Text(currency, style: TextStyle(fontSize: 18)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}