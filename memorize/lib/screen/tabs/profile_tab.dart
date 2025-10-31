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
  
  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = Color(0xFF0c1320);
    final Color accentColor = Color(0xFF62f4f4);
    final Color cardColor = Color(0xFF1E1E1E);

    return Consumer<AuthProvider>(
      builder: (ctx, auth, child) {
        String? imageUrl = auth.profileImageUrl;
        NetworkImage? profileImage;
        if (imageUrl != null) {
          final fullUrl = 'http://10.0.2.2:3000' + imageUrl;
          profileImage = NetworkImage(fullUrl);
        }

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            title: Text('Profil'),
            backgroundColor: backgroundColor,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: profileImage,
                        child: profileImage == null
                            ? Icon(Icons.person, size: 60, color: Colors.grey)
                            : null,
                        backgroundColor: cardColor,
                      ),
                      if (auth.isUploading)
                        Positioned.fill(
                          child: CircularProgressIndicator(strokeWidth: 2, color: accentColor),
                        ),
                    ],
                  ),
                  SizedBox(height: 12),
                  TextButton.icon(
                    icon: Icon(Icons.edit, size: 16),
                    label: Text('Edit Foto'),
                    style: TextButton.styleFrom(foregroundColor: accentColor),
                    onPressed: auth.isUploading ? null : _pickAndUploadImage,
                  ),
                  SizedBox(height: 24),
                  Text(
                    auth.email ?? 'Loading email...',
                    style: TextStyle(
                      fontSize: 20, 
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 40),
                  Card(
                    color: cardColor,
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Saran & Kesan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: accentColor,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Aplikasi ini sangat membantu dalam mencatat memo dan tugas. Fitur notifikasi dan konversi juga sangat berguna!',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: Icon(Icons.logout),
                    label: Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      minimumSize: Size(double.infinity, 45),
                    ),
                    onPressed: () {
                      Provider.of<AuthProvider>(context, listen: false).logout();
                    },
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}