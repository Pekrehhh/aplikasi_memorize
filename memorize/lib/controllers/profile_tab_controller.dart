import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';

class ProfileTabController with ChangeNotifier {
  final AuthProvider authProvider;
  final ImagePicker _picker = ImagePicker();

  bool _isEditingSaran = false;
  bool _isSavingSaran = false;
  final TextEditingController saranEditController = TextEditingController();

  bool get isEditingSaran => _isEditingSaran;
  bool get isSavingSaran => _isSavingSaran;
  
  ProfileTabController(this.authProvider) {
    saranEditController.text = authProvider.saranKesan ?? "";
  }

  @override
  void dispose() {
    saranEditController.dispose();
    super.dispose();
  }

  void _setSavingSaran(bool saving) {
    _isSavingSaran = saving;
    notifyListeners();
  }
  
  void toggleEditSaran() {
    if (_isEditingSaran) {
      _isEditingSaran = false;
      saranEditController.text = authProvider.saranKesan ?? "";
    } else {
      _isEditingSaran = true;
    }
    notifyListeners();
  }
  
  void handleEditSaveClick(BuildContext context) {
    if (_isEditingSaran) {
      _saveSaranKesan(context);
    } else {
      saranEditController.text = authProvider.saranKesan ?? "Aplikasi ini sangat membantu...";
      _isEditingSaran = true;
      notifyListeners();
    }
  }
  
  Future<void> pickAndUploadImage(BuildContext context) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final token = authProvider.token;
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sesi tidak valid'), backgroundColor: Colors.red),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Mengupload foto...')),
    );
    await authProvider.uploadImage(token, image.path);
  }
  
  Future<void> _saveSaranKesan(BuildContext context) async {
    final token = authProvider.token;
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sesi tidak valid'), backgroundColor: Colors.red),
      );
      return;
    }

    _setSavingSaran(true);

    final result = await authProvider.updateSaranKesan(token, saranEditController.text);

    if (!context.mounted) return;

    _setSavingSaran(false);

    if (result['success'] == true) {
      _isEditingSaran = false;
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saran & Kesan berhasil disimpan!'), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Gagal menyimpan'), backgroundColor: Colors.red),
      );
    }
  }
}