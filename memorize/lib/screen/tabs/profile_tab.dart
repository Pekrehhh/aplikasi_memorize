import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  _ProfileTabState createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final ImagePicker _picker = ImagePicker();

  bool _isEditingSaran = false;
  String _saranText = "Aplikasi ini sangat membantu dalam mencatat memo dan tugas. Fitur notifikasi dan konversi juga sangat berguna!";
  late TextEditingController _saranEditController;

  @override
  void initState() {
    super.initState();
    _saranEditController = TextEditingController(text: _saranText);
  }

  @override
  void dispose() {
    _saranEditController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.token != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Mengupload foto...')),
        );
        await authProvider.uploadImage(authProvider.token!, image.path);
      }
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

  void _showLogoutDialog(BuildContext context) {
    final Color popupBgColor = Color(0xFF24cccc);
    final Color titleColor = Color(0xFF0c1320);
    final Color cancelBgColor = Color(0xFF065353);
    final Color logoutBgColor = Color(0xFFcc2424);

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            width: 376,
            height: 297,
            decoration: BoxDecoration(
              color: popupBgColor,
              borderRadius: BorderRadius.circular(25),
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Are you sure?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 43),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cancelBgColor,
                        foregroundColor: Colors.white,
                        fixedSize: Size(107, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 5,
                      ),
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(width: 39),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: logoutBgColor,
                        foregroundColor: Colors.white,
                        fixedSize: Size(107, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 5,
                      ),
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        Provider.of<AuthProvider>(context, listen: false).logout();
                      },
                      child: Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = Color(0xFF0c1320);
    final Color labelColor = Color(0xFF62f4f4);
    final Color logoutButtonColor = Color(0xFFcc2424);

    return Consumer<AuthProvider>(
      builder: (ctx, auth, child) {
        String? imageUrl = auth.profileImageUrl;
        NetworkImage? profileImage;
        if (imageUrl != null) {
          final fullUrl = 'http://10.0.2.2:3000$imageUrl'; 
          profileImage = NetworkImage(fullUrl);
        }

        return Scaffold(
          backgroundColor: backgroundColor,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Text(
                        'Profile',
                        style: TextStyle(
                          color: backgroundColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),

                  Text(
                    'This is Profile page',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 40),

                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 122.5,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 120,
                          backgroundImage: profileImage,
                          backgroundColor: Colors.grey[200],
                          child: profileImage == null
                              ? Icon(Icons.person, size: 100, color: Colors.grey[400])
                              : null,
                        ),
                      ),
                      if (auth.isUploading)
                        Positioned.fill(
                          child: CircularProgressIndicator(strokeWidth: 2, color: labelColor),
                        ),
                    ],
                  ),
                  SizedBox(height: 18),

                  GestureDetector(
                    onTap: auth.isUploading ? null : _pickAndUploadImage,
                    child: Text(
                      'Edit Photo',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: labelColor, fontSize: 14),
                    ),
                  ),
                  SizedBox(height: 32),

                  Container(
                    height: 140,
                    decoration: _buildShadowBorder(labelColor),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Saran & Kesan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 16),
                        if (_isEditingSaran)
                          Expanded(
                            child: TextField(
                              controller: _saranEditController,
                              autofocus: true,
                              style: TextStyle(color: labelColor, fontSize: 14),
                              maxLines: null,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          )
                        else
                          Text(
                            _saranText,
                            style: TextStyle(color: labelColor, fontSize: 14),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),

                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_isEditingSaran) {
                          _saranText = _saranEditController.text;
                        } else {
                          _saranEditController.text = _saranText;
                        }
                        _isEditingSaran = !_isEditingSaran;
                      });
                    },
                    child: Text(
                      _isEditingSaran ? 'Save' : 'Edit',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: labelColor, fontSize: 14),
                    ),
                  ),
                  SizedBox(height: 40),
                  
                  if (auth.isLoading)
                    CircularProgressIndicator(color: logoutButtonColor)
                  else
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: logoutButtonColor,
                        foregroundColor: Colors.white,
                        fixedSize: Size(180, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: () => _showLogoutDialog(context),
                      child: Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}