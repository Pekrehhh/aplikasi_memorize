import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../controllers/notes_tab_controller.dart';
import '../../providers/notes_provider.dart';

class ListWidget extends StatelessWidget {
  final NotesTabController controller;

  const ListWidget({
    Key? key,
    required this.controller,
  }) : super(key: key);

  // Styling
  final Color headerAccentColor = const Color(0xFF24cccc);
  final Color cardBackgroundColor = const Color(0xFF0c1320);
  final Color titleColor = const Color(0xFF62f4f4);
  final Color subtitleColor = Colors.white;
  final Color timeColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Consumer<NotesProvider>(
      builder: (ctx, notesData, child) {
        if (notesData.notes.isEmpty) {
          return Center(
            child: Text(
              controller.isSearching ? 'No results found' : 'No Memos',
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
            } catch (e) { /* */ }

            return Dismissible(
              key: ValueKey(note.id),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) {
                controller.deleteNote(context, note.id);
              },
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
}