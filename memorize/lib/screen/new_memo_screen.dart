import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/notes_provider.dart';

class NewMemoScreen extends StatefulWidget {
  const NewMemoScreen({super.key});

  @override
  _NewMemoScreenState createState() => _NewMemoScreenState();
}

class _NewMemoScreenState extends State<NewMemoScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  DateTime? _selectedDateTime;
  String _selectedColor = '#F0F0F0'; // Default
  bool _isLoading = false;

  final Map<String, Color> _colorPalette = {
    '#F0F0F0': Colors.grey[300]!,
    '#FFAB91': Colors.red[200]!,
    '#FFF59D': Colors.yellow[400]!,
    '#A5D6A7': Colors.green[200]!,
    '#81D4FA': Colors.blue[200]!,
  };

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date == null) return;

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime ?? DateTime.now()),
    );
    if (time == null) return;

    setState(() {
      _selectedDateTime = DateTime(
        date.year, date.month, date.day,
        time.hour, time.minute,
      );
    });
  }

  Future<void> _saveMemo() async {
    final title = _titleController.text;

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Judul tidak boleh kosong'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() { _isLoading = true; });
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    
    if (token == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sesi tidak valid, silakan login ulang.'), backgroundColor: Colors.red),
        );
      }
      setState(() { _isLoading = false; });
      return;
    }

    try {
      await Provider.of<NotesProvider>(context, listen: false).addNote(
        token,
        title,
        _contentController.text,
        _selectedColor,
        _selectedDateTime,
      );

      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e'), backgroundColor: Colors.red),
        );
      }
    }

    if (context.mounted) {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New memo'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- KARTU MEMO ---
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: 'Judul Memo',
                        border: InputBorder.none,
                      ),
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Divider(height: 4, thickness: 1),
                    // Editor utama
                    Container(
                      constraints: BoxConstraints(
                        minHeight: 200,
                      ),
                      child: TextField(
                        controller: _contentController,
                        decoration: InputDecoration(
                          hintText: 'Isi Memo',
                          border: InputBorder.none,
                        ),
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                      ),
                    ),
                    SizedBox(height: 8),
                  ],
                ),
                ),
            ),
            SizedBox(height: 16),
            // --- KARTU "ADD TIME" ---
            Card(
              elevation: 2,
              child: ListTile(
                leading: Icon(Icons.calendar_today),
                title: Text(_selectedDateTime == null
                    ? 'Add time'
                    : 'Waktu: ${DateFormat('E, d MMM y, HH:mm').format(_selectedDateTime!)}'),
                trailing: _selectedDateTime != null
                    ? IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => setState(() => _selectedDateTime = null),
                      )
                    : null,
                onTap: _pickDateTime,
              ),
            ),
            SizedBox(height: 16),
            // --- KARTU "PILIH WARNA" ---
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Warna Memo', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: _colorPalette.entries.map((entry) {
                        final colorHex = entry.key;
                        final color = entry.value;

                        return GestureDetector(
                          onTap: () {
                            setState(() { _selectedColor = colorHex; });
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: _selectedColor == colorHex
                                  ? Border.all(color: Theme.of(context).primaryColor, width: 3)
                                  : null,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // --- TOMBOL BAWAH (BARU) ---
      bottomNavigationBar: BottomAppBar(
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // TOMBOL CANCEL
              TextButton(
                onPressed: _isLoading ? null : () {
                  // Cukup kembali ke halaman sebelumnya
                  Navigator.of(context).pop();
                },
                child: Text('Cancel', style: TextStyle(fontSize: 18)),
              ),             
              // TOMBOL SAVE
              TextButton(
                onPressed: _isLoading ? null : _saveMemo,
                child: Text('Save', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}