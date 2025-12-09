import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:memorize/providers/currency_provider.dart';

class ConverterPage extends StatefulWidget {
  const ConverterPage({super.key});

  @override
  State<ConverterPage> createState() => _ConverterPageState();
}

class _ConverterPageState extends State<ConverterPage> {
  final TextEditingController _amountController = TextEditingController(text: '1');
  String _from = 'USD';
  String _to = 'IDR';
  double _result = 0;

  @override
  void initState() {
    super.initState();
    final prov = Provider.of<CurrencyProvider>(context, listen: false);
    prov.fetchRates();
  }

  void _reload() async {
    await Provider.of<CurrencyProvider>(context, listen: false).fetchRates();
  }

  void _convert() {
    final prov = Provider.of<CurrencyProvider>(context, listen: false);
    final amount = double.tryParse(_amountController.text) ?? 0;
    setState(() {
      _result = prov.convert(amount, _from, _to);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Currency Converter')),
      body: Consumer<CurrencyProvider>(builder: (context, prov, _) {
        if (prov.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (prov.error != null) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Butuh koneksi internet untuk mengakses konverter.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 12),
                Text(
                  prov.error ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  onPressed: _reload,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reload'),
                ),
              ],
            ),
          );
        }

        final currencies = prov.currencies.isNotEmpty ? prov.currencies : ['USD', 'IDR'];

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Amount'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _from,
                      items: currencies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (v) => setState(() => _from = v ?? _from),
                      decoration: const InputDecoration(labelText: 'From'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _to,
                      items: currencies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (v) => setState(() => _to = v ?? _to),
                      decoration: const InputDecoration(labelText: 'To'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: _convert,
                child: const Text('Convert'),
              ),
              const SizedBox(height: 18),
              Text('Result: $_result', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 6),
              Text('Last updated: ${prov.lastUpdatedDisplay}'),
            ],
          ),
        );
      }),
    );
  }
}
