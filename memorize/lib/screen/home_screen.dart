import 'package:flutter/material.dart';
import 'tabs/notes_tab.dart'; 
import 'tabs/konverter_tab.dart';
import 'tabs/profile_tab.dart';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memorize'),
        // Mungkin ada tombol tambah catatan di sini
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Navigasi ke halaman tambah/edit catatan
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Tampilan Daftar Catatan'),
      ),
    );
  }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Indeks tab yang sedang aktif
  // Daftar halaman/widget untuk setiap tab
  static const List<Widget> _widgetOptions = <Widget>[
    NotesTab(),
    KonversiTab(),
    ProfileTab(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      // Ini adalah Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.note_alt_rounded),
            label: 'Notes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.construction_rounded),
            label: 'Konversi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        onTap: _onItemTapped, // Panggil fungsi ini saat tab diklik
      ),
    );
  }
}