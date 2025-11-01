import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notes_provider.dart';
import '../screens/new_memo_screen.dart';
import '../../controllers/notes_tab_controller.dart';
import '../widgets/search_widget.dart';
import '../widgets/list_widget.dart';

class NotesTab extends StatelessWidget {
  const NotesTab({super.key});
  
  final Color backgroundColor = const Color(0xFF0c1320);
  final Color headerAccentColor = const Color(0xFF24cccc);
  final Color fabAccentColor = const Color(0xFF62f4f4);
  
  AppBar _buildAppBar(BuildContext context, NotesTabController controller) {
    if (controller.isSearching) {
      return AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => controller.toggleSearch(context),
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
            onPressed: () => controller.toggleSearch(context),
          ),
          SizedBox(width: 14),
        ],
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => NotesTabController()..init(ctx),
      child: Consumer<NotesTabController>( 
        builder: (context, controller, child) {
          return Scaffold(
            backgroundColor: backgroundColor,
            appBar: _buildAppBar(context, controller),
            body: controller.isLoading
                ? Center(child: CircularProgressIndicator(color: fabAccentColor))
                : Column(
                    children: [
                      if (controller.isSearching)
                        SearchWidget(controller: controller),
                      Consumer<NotesProvider>(
                        builder: (ctx, notesProvider, _) {
                          if (!controller.isSearching && !controller.isLoading && notesProvider.notes.isNotEmpty) {
                            return Padding(
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
                            );
                          } else {
                            return SizedBox.shrink(); 
                          }
                        },
                      ),
                      
                      Expanded(
                        child: ListWidget(controller: controller), 
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
        },
      ),
    );
  }
}