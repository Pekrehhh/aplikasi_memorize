import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:memorize/providers/auth_provider.dart';

class LoginController with ChangeNotifier {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _obscureText = true;
  bool get obscureText => _obscureText;
  
  void toggleObscureText() {
    _obscureText = !_obscureText;
    notifyListeners();
  }
  
  Future<void> submitLogin(BuildContext context) async {
    FocusScope.of(context).unfocus();
    _setLoading(true);
    Map<String, dynamic> result;
    try {
      result = await Provider.of<AuthProvider>(context, listen: false).login(
        usernameController.text,
        passwordController.text,
      );
    } catch (e) {
      result = {'success': false, 'message': 'Terjadi error: $e'};
    }

    if (!context.mounted) return;
    _setLoading(false);

    if (result['success'] == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Login Gagal. Cek kembali data Anda.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}