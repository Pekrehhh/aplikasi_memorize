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
        // Tampilkan SnackBar untuk konfirmasi (opsional)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Mengupload foto...')),
        );
        await authProvider.uploadImage(authProvider.token!, image.path);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (ctx, auth, child) {
        String? imageUrl = auth.profileImageUrl;
        NetworkImage? profileImage;
        if (imageUrl != null) {
          // --- PENTING: GANTI DENGAN IP PC ANDA ---
          // (Harus sama dengan _baseUrl di api_service.dart tapi tanpa /api)
          // Contoh: 'http://192.168.1.10:3000'
          final fullUrl = 'http://192.168.1.10:3000' + imageUrl;
          profileImage = NetworkImage(fullUrl);
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Profil'),
          ),
          body: Center(
            child: SingleChildScrollView( // Tambahkan SingleChildScrollView
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // --- CircleAvatar (Gambar Profil) ---
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: profileImage,
                        child: profileImage == null
                            ? Icon(Icons.person, size: 60, color: Colors.grey)
                            : null,
                        backgroundColor: Colors.grey[200],
                      ),
                      if (auth.isUploading)
                        Positioned.fill(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                  SizedBox(height: 12),

                  // --- Tombol Edit Foto ---
                  TextButton.icon(
                    icon: Icon(Icons.edit, size: 16),
                    label: Text('Edit Foto'),
                    onPressed: auth.isUploading ? null : _pickAndUploadImage,
                  ),
                  SizedBox(height: 24),

                  // --- Email Pengguna ---
                  Text(
                    auth.email ?? 'Loading email...',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 40),

                  // --- KARTU SARAN & KESAN (REVISI) ---
                  Card(
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
                              color: Theme.of(context).primaryColor, // Biar keren
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Aplikasi ini sangat membantu dalam mencatat memo dan tugas. Fitur notifikasi dan konversi juga sangat berguna!',
                          ),
                        ],
                      ),
                    ),
                  ),
                  // --- BATAS REVISI ---

                  SizedBox(height: 16),

                  // --- Tombol Logout ---
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