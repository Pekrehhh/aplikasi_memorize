import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notes_provider.dart';
import '../screens/new_memo_screen.dart';
import '../../services/notification_service.dart';

class NotesTab extends StatefulWidget {
  const NotesTab({Key? key}) : super(key: key);

  @override
  _NotesTabState createState() => _NotesTabState();
}

class _NotesTabState extends State<NotesTab> {
  bool _isLoading = true;
  bool _isSearching = false;
  final _searchController = TextEditingController();

  final Color backgroundColor = Color(0xFF0c1320);
  final Color headerAccentColor = Color(0xFF24cccc);
  final Color searchBorderColor = Color(0xFF62f4f4);
  final Color fabAccentColor = Color(0xFF62f4f4);
  final Color cardBackgroundColor = Color(0xFF0c1320);
  final Color titleColor = Color(0xFF62f4f4);
  final Color subtitleColor = Colors.white;
  final Color timeColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _fetchNotes();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    Provider.of<NotesProvider>(context, listen: false)
        .searchNotes(_searchController.text);
  }

  Future<void> _fetchNotes() async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (mounted) {
      _searchController.clear();
      Provider.of<NotesProvider>(context, listen: false).searchNotes('');
    }
    if (token != null) {
      try {
        await Provider.of<NotesProvider>(context, listen: false).fetchNotes(token);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal memuat notes: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteNote(int noteId) async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    try {
      await NotificationService().cancelNotification(noteId);
      await Provider.of<NotesProvider>(context, listen: false).deleteNote(token!, noteId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus note: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
    });
    if (!_isSearching) {
      _searchController.clear();
    }
  }

  AppBar _buildAppBar() {
    if (_isSearching) {
      return AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: _toggleSearch,
        ),
        title: null,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 30.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: headerAccentColor,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Text(
                  'My Notes',
                  style: TextStyle(
                    color: backgroundColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 30.0,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: headerAccentColor,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Text(
            'My Notes',
            style: TextStyle(
              color: backgroundColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: headerAccentColor, size: 28),
            onPressed: _toggleSearch,
          ),
          SizedBox(width: 14),
        ],
      );
    }
  }

  Widget _buildSearchUI(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 20),
        Text(
          'What activity do you want\nto find?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            children: [
              Container(
                height: 61,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: searchBorderColor, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(134, 214, 225, 0.09),
                      offset: Offset(-3, -2),
                      blurRadius: 4,
                    ),
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.27),
                      offset: Offset(5, 4),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Center(
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Type some text',
                      hintStyle: TextStyle(color: searchBorderColor, fontSize: 14),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(left: 50, bottom: 8), 
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Type and choose your notes from the list',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: searchBorderColor,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildNotesList() {
    return Consumer<NotesProvider>(
      builder: (ctx, notesData, child) {
        if (notesData.notes.isEmpty) {
          return Center(
            child: Text(
              _isSearching ? 'No results found' : 'No Memos',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
          itemCount: notesData.notes.length,
          itemBuilder: (ctx, index) {
            final note = notesData.notes[index];
            Color noteColor = headerAccentColor;
            try {
              final hexColor = note.color.replaceFirst('#', 'FF');
              noteColor = Color(int.parse(hexColor, radix: 16));
            } catch (e) { /**/ }

            return Dismissible(
              key: ValueKey(note.id),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) { _deleteNote(note.id); },
              background: Container(
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(right: 20),
                margin: EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(Icons.delete, color: Colors.white),
              ),
              
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                height: 136,
                decoration: BoxDecoration(
                  color: cardBackgroundColor,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: noteColor, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(134, 214, 225, 0.09),
                      offset: Offset(-3, -2),
                      blurRadius: 4,
                    ),
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.27),
                      offset: Offset(5, 4),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: 41, top: 18, right: 16, bottom: 12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  note.title,
                                  style: TextStyle(
                                    color: titleColor,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (note.reminderAt != null)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      DateFormat('HH:mm').format(note.reminderAt!.toLocal()),
                                      style: TextStyle(
                                        color: timeColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      DateFormat('d MMM y').format(note.reminderAt!.toLocal()),
                                      style: TextStyle(
                                        color: timeColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Text(
                            note.content.replaceAll('\n', ' '), 
                            style: TextStyle(
                              color: subtitleColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 8.4, top: 20, bottom: 21, width: 6.777,
                      child: Container(
                        decoration: BoxDecoration(
                          color: noteColor,
                          borderRadius: BorderRadius.circular(11),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: fabAccentColor))
          : Column(
              children: [
                if (_isSearching)
                  _buildSearchUI(context),
                
                if (!_isSearching && !_isLoading && Provider.of<NotesProvider>(context).notes.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(30, 15, 30, 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'All Activity',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: _buildNotesList(), 
                ),
              ],
            ),
      
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 14.0, bottom: 29.0),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (ctx) => NewMemoScreen()),
            );
          },
          backgroundColor: fabAccentColor,
          foregroundColor: backgroundColor,
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}