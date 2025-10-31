import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/notes_provider.dart';
import '../services/notification_service.dart';

class NewMemoScreen extends StatefulWidget {
  // const NewMemoScreen({Key? key, this.note}) : super(key: key);
  // final Note? note; // Nanti untuk mode Edit

  const NewMemoScreen({Key? key}) : super(key: key);

  @override
  _NewMemoScreenState createState() => _NewMemoScreenState();
}

class _NewMemoScreenState extends State<NewMemoScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  DateTime? _selectedDateTime;
  bool _isLoading = false;

  final Map<String, Color> _colorPalette = {
    '#24cccc': Color(0xFF24cccc),
    '#62f4f4': Color(0xFF62f4f4),
    '#065353': Color(0xFF065353),
    '#FFFFFF': Colors.white,
  };

  String _selectedColor = '#24cccc'; 



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
    final content = _contentController.text; 

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
        content,
        _selectedColor,
        _selectedDateTime,
      );

      if (_selectedDateTime != null && _selectedDateTime!.isAfter(DateTime.now())) {
        await Provider.of<NotesProvider>(context, listen: false).fetchNotes(token);
        final newNote = Provider.of<NotesProvider>(context, listen: false).notes.first;

        NotificationService().scheduleNotification(
          id: newNote.id,
          title: newNote.title,
          body: newNote.content,
          scheduledTime: _selectedDateTime!,
        );
      }

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

  BoxDecoration _buildShadowBorder(Color borderColor) {
    return BoxDecoration(
      color: Color(0xFF0c1320),
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

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = Color(0xFF0c1320);
    final Color accentColor = Color(0xFF24cccc);
    final Color labelColor = Color(0xFF62f4f4);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'New Memo',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: _isLoading 
              ? Center(child: CircularProgressIndicator(color: accentColor))
              : ElevatedButton(
                  onPressed: _saveMemo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: backgroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                  child: Text(
                    'Save',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 20, 28, 20),
        child: Column(
          children: [
            // --- KARTU MEMO ---
            Container(
              height: 300,
              width: double.infinity,
              decoration: _buildShadowBorder(labelColor),
              padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 18),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: 'Title',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Expanded(
                    child: TextField(
                      controller: _contentController,
                      decoration: InputDecoration(
                        hintText: 'Type some text',
                        hintStyle: TextStyle(
                          color: labelColor.withOpacity(0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(
                        color: labelColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 36),

            // --- KARTU "ADD TIME" ---
            GestureDetector(
              onTap: _pickDateTime,
              child: Container(
                height: 71,
                width: double.infinity,
                decoration: _buildShadowBorder(labelColor),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today, color: labelColor, size: 30),
                    SizedBox(width: 16),
                    Text(
                      _selectedDateTime == null 
                        ? 'Add Time' 
                        : DateFormat('E, d MMM, HH:mm').format(_selectedDateTime!),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    
                    if (_selectedDateTime != null)
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.grey),
                        onPressed: () { 
                          setState(() => _selectedDateTime = null);
                        },
                      )
                    else
                      SizedBox(width: 48),
                  ],
                ),
              ),
            ),
            SizedBox(height: 36),

            // --- KARTU "PILIH WARNA" ---
            Container(
              height: 120,
              width: double.infinity,
              decoration: _buildShadowBorder(labelColor),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Choose a color for Notes',
                    style: TextStyle(
                      color: labelColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                ? Border.all(color: labelColor, width: 3)
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}