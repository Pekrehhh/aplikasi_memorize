import 'package:flutter/material.dart';
import 'package:memorize/screen/tabs/konverter_tab.dart'; 
import 'package:memorize/screen/tabs/notes_tab.dart';
import 'package:memorize/screen/tabs/profile_tab.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final Color backgroundColor = Color(0xFF0c1320);
  final Color activeColor = Colors.white;
  final Color inactiveColor = Color(0xFF24cccc);

  static const List<Widget> _widgetOptions = <Widget>[
    NotesTab(),
    KonverterTab(),
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
      backgroundColor: backgroundColor,
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),

      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 4,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.note_alt_rounded),
              label: 'Notes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.compare_arrows_rounded),
              label: 'Konversi',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profil',
            ),
          ],
          currentIndex: _selectedIndex,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: activeColor,
          unselectedItemColor: inactiveColor,
          onTap: _onItemTapped,
          showSelectedLabels: true,
          showUnselectedLabels: false,
        ),
      ),
    );
  }
}