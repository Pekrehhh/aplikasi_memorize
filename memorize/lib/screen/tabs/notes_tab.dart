import 'package:flutter/material.dart';
import 'package:memorize/screen/new_memo_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notes_provider.dart';

class _NotesTabState extends State<NotesTab> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  late Future<void> _notesFuture;
  
  // Maximum characters to show in the preview snippet
  final int _previewMaxChars = 100;

  String _truncate(String? text, int maxChars) {
    if (text == null) return '';
    final trimmed = text.trim();
    if (trimmed.length <= maxChars) return trimmed;
    return '${trimmed.substring(0, maxChars)}…';
  }

  Future<void> _fetchNotes() {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token != null) {
      return Provider.of<NotesProvider>(context, listen: false).fetchNotes(token);
    }
    return Future.value();
  }

  @override
  void initState() {
    super.initState();
    _notesFuture = _fetchNotes();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // --- FUNGSI UNTUK HAPUS NOTE ---
  Future<void> _deleteNote(int noteId) async {
     final token = Provider.of<AuthProvider>(context, listen: false).token;
     try {
        await Provider.of<NotesProvider>(context, listen: false).deleteNote(token!, noteId);
     } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menghapus note: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
     }
  }

  // --- UI UTAMA ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Notes'),
      ),

      body: FutureBuilder(
        future: _notesFuture,
        builder: (ctx, snapshot) {
          // 1. JIKA MASIH LOADING
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          // 2. JIKA ADA ERROR
          if (snapshot.error != null) {
            return Center(child: Text('Terjadi error: ${snapshot.error}'));
          }
          
          // 3. JIKA SUKSES, TAMPILKAN LIST NOTES
          return Consumer<NotesProvider>(
            builder: (ctx, notesData, child) {
              // 3a. JIKA TIDAK ADA NOTES
              if (notesData.notes.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.note_alt_outlined, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No memos', style: TextStyle(fontSize: 18, color: Colors.grey)),
                    ],
                  ),
                );
              }
              // 3b. JIKA ADA NOTES, TAMPILKAN LISTVIEW
              return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: notesData.notes.length,
                itemBuilder: (ctx, index) {
                  final note = notesData.notes[index];

                  Color noteColor = Color(0xFFF0F0F0);
                  try {
                    final hexColor = note.color.replaceFirst('#', 'FF');
                    noteColor = Color(int.parse(hexColor, radix: 16));
                  } catch (e) {
                    // Jika parsing gagal, gunakan warna default
                  }

                  // -- SWIPE-TO-DELETE --
                  return Dismissible(
                    key: ValueKey(note.id),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      _deleteNote(note.id); // Fungsi hapus note
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 20),
                      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    // -- TAMPILAN NOTE (KARTU) --
                    child: Card(
                    margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(color: noteColor, width: 5),
                        ),
                      ),
                      child: ListTile(
                        title: Text(
                          note.title, 
                          style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        // SUBTITLE: tampilkan waktu jika ada, lalu cuplikan isi memo (terpotong)
                        subtitle: (note.reminderAt != null || note.content.trim().isNotEmpty)
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (note.reminderAt != null)
                                  Text(
                                    DateFormat('E, d MMM, HH:mm').format(note.reminderAt!.toLocal()),
                                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                                  ),
                                if (note.content.trim().isNotEmpty) ...[
                                  SizedBox(height: 4),
                                  Text(
                                    _truncate(note.content, _previewMaxChars),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                ],
                              ],
                            )
                          : null,
                        onTap: () {},
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      }),

      // -- TOMBOL TAMBAH NOTE --
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) => NewMemoScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class NotesTab extends StatefulWidget {
  const NotesTab({super.key});

  @override
  _NotesTabState createState() => _NotesTabState();
}