import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/new_memo_controller.dart';

class NewMemoScreen extends StatelessWidget {
  
  const NewMemoScreen({super.key});

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

    return ChangeNotifierProvider(
      create: (_) => NewMemoController(),
      child: Consumer<NewMemoController>(
        builder: (context, controller, child) {
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
                  child: controller.isLoading
                      ? Center(child: CircularProgressIndicator(color: accentColor))
                      : ElevatedButton(
                          onPressed: () => controller.saveMemo(context),
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
                  Container(
                    height: 300,
                    width: double.infinity,
                    decoration: _buildShadowBorder(labelColor),
                    padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 18),
                    child: Column(
                      children: [
                        TextField(
                          controller: controller.titleController,
                          decoration: InputDecoration(
                            hintText: 'Title',
                            hintStyle: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
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
                            controller: controller.contentController,
                            decoration: InputDecoration(
                              hintText: 'Type some text',
                              hintStyle: TextStyle(
                                color: labelColor.withValues(alpha: 0.7),
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
                  GestureDetector(
                    onTap: () => controller.pickDateTime(context),
                    child: Container(
                      height: 70,
                      width: double.infinity,
                      decoration: _buildShadowBorder(labelColor),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_today, color: labelColor, size: 27),
                          SizedBox(width: 16),
                          Text(
                            controller.selectedDateTime == null
                                ? 'Add Time'
                                : DateFormat('E, d MMM, HH:mm').format(controller.selectedDateTime!),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (controller.selectedDateTime != null)
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.grey),
                              onPressed: controller.clearDateTime,
                            )
                          else
                            SizedBox(width: 48),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 36),
                  Container(
                    height: 130,
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
                          children: controller.colorPalette.entries.map((entry) {
                            final colorHex = entry.key;
                            final color = entry.value;

                            return GestureDetector(
                              onTap: () => controller.selectColor(colorHex),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: controller.selectedColor == colorHex
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
        },
      ),
    );
  }
}