import 'package:flutter/material.dart';
import 'package:memorize/services/save_file_service.dart';

class SaveLoadPage extends StatefulWidget {
  const SaveLoadPage({super.key});

  @override
  State<SaveLoadPage> createState() => _SaveLoadPageState();
}

class _SaveLoadPageState extends State<SaveLoadPage> {
  final SaveFileService _service = SaveFileService();
  bool _busy = false;

  void _export() async {
    setState(() => _busy = true);
    try {
      final path = await _service.exportToJsonFile();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File disimpan di: $path')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal ekspor: $e')),
      );
    } finally {
      setState(() => _busy = false);
    }
  }

  void _import() async {
    setState(() => _busy = true);
    try {
      final ok = await _service.importFromJsonFile();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ok ? 'Import berhasil' : 'Import dibatalkan / gagal')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal import: $e')),
      );
    } finally {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Save / Load')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: _busy ? null : _export,
              icon: const Icon(Icons.upload_file),
              label: const Text('Export Save File'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _busy ? null : _import,
              icon: const Icon(Icons.download),
              label: const Text('Import Save File'),
            ),
            const SizedBox(height: 24),
            if (_busy) const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
