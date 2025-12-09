import 'package:flutter/material.dart';
import '../../controllers/notes_tab_controller.dart';

class SearchWidget extends StatelessWidget {
  final NotesTabController controller;

  const SearchWidget({
    super.key,
    required this.controller,
  });
  
  final Color backgroundColor = const Color(0xFF0c1320);
  final Color searchBorderColor = const Color(0xFF62f4f4);

  @override
  Widget build(BuildContext context) {
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
                    controller: controller.searchController,
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
}