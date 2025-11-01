import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // --- KODE LOGIKA (TIDAK BERUBAH) ---
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscureText = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitRegister() async {
    FocusScope.of(context).unfocus();
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password dan konfirmasi tidak cocok!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() { _isLoading = true; });
    try {
      final result = await Provider.of<AuthProvider>(context, listen: false).register(
        _usernameController.text,
        _emailController.text,
        _passwordController.text,
      );
      if (!mounted) return;
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Registrasi berhasil! Silakan login.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Registrasi gagal.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi error: $e'), backgroundColor: Colors.red),
        );
      }
    }
    if (mounted) {
      setState(() { _isLoading = false; });
    }
  }
  // --- BATAS KODE LOGIKA ---

  @override
  Widget build(BuildContext context) {
    // --- STYLING BARU DARI HTML/CSS ---
    final Color backgroundColor = Color(0xFF0c1320); // .container
    final Color accentColor = Color(0xFF24cccc);      // .login-button
    final Color labelColor = Color(0xFF62f4f4);        // .label
    final Color titleAccentColor = Color(0xFF00acac);  // .rize
    final Color inputFillColor = Colors.white;
    final Color inputTextColor = Color(0xFF0c1320);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea( // Bungkus dengan SafeArea
        child: Stack( // Gunakan Stack untuk tombol back
          children: [
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 60), // Jarak dari atas (HTML: top 138px)

                    // --- Logo & Judul Aplikasi (HTML: .logo-app) ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.note_alt_rounded, // Logo kita
                          size: 58, // Ukuran dari HTML
                          color: titleAccentColor,
                        ),
                        SizedBox(width: 8), // Jarak dari HTML (66px - 58px)
                        RichText(
                          text: TextSpan(
                            // Menggunakan font default, bukan 'Prompt'
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              height: 1.2, // line-height: 59px
                            ),
                            children: [
                              TextSpan(text: 'Memo', style: TextStyle(color: Colors.white)),
                              TextSpan(text: 'rize', style: TextStyle(color: titleAccentColor)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 40), // Jarak ke form (HTML: 234px - 138px)

                    // --- Username (Label + Field) ---
                    _buildTextField(
                      controller: _usernameController,
                      label: 'Username',
                      hint: 'Username',
                      labelColor: labelColor,
                      inputFillColor: inputFillColor,
                      inputTextColor: inputTextColor,
                      accentColor: accentColor,
                      obscure: false,
                    ),
                    SizedBox(height: 18), // Jarak antar field

                    // --- Email (Label + Field) ---
                    _buildTextField(
                      controller: _emailController,
                      label: 'E-mail',
                      hint: 'E-mail',
                      labelColor: labelColor,
                      inputFillColor: inputFillColor,
                      inputTextColor: inputTextColor,
                      accentColor: accentColor,
                      obscure: false,
                      keyboard: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 18), // Jarak antar field

                    // --- Password (Label + Field) ---
                    _buildTextField(
                      controller: _passwordController,
                      label: 'Password',
                      hint: 'Password',
                      labelColor: labelColor,
                      inputFillColor: inputFillColor,
                      inputTextColor: inputTextColor,
                      accentColor: accentColor,
                      obscure: _obscureText,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText ? Icons.visibility_off : Icons.visibility,
                          color: inputTextColor.withOpacity(0.7),
                        ),
                        onPressed: () => setState(() => _obscureText = !_obscureText),
                      ),
                    ),
                    SizedBox(height: 18), // Jarak antar field

                    // --- Konfirmasi Password (Label + Field) ---
                    _buildTextField(
                      controller: _confirmPasswordController,
                      label: 'Confirm Password',
                      hint: 'Confirm Password',
                      labelColor: labelColor,
                      inputFillColor: inputFillColor,
                      inputTextColor: inputTextColor,
                      accentColor: accentColor,
                      obscure: _obscureText,
                    ),
                    SizedBox(height: 32), // Jarak ke tombol

                    // --- Tombol Register ---
                    if (_isLoading)
                      CircularProgressIndicator(color: accentColor)
                    else
                      Padding( // Bungkus tombol agar bisa atur alignment
                        padding: const EdgeInsets.symmetric(horizontal: 60),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            foregroundColor: Colors.white,
                            minimumSize: Size(227, 50), // Ukuran dari HTML
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: _submitRegister,
                          child: Text(
                            'Register',
                            style: TextStyle( // Font default
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    
                    SizedBox(height: 20), // Jarak ke link

                    // --- Link kembali ke Login ---
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(color: labelColor, fontSize: 14),
                        children: [
                          TextSpan(text: "Already have an account? "),
                          TextSpan(
                            text: 'Login now!',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.of(context).pop();
                              },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Tombol Back Manual di Kiri Atas
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                // Gunakan ikon iOS agar lebih ramping
                icon: Icon(Icons.arrow_back_ios_new, color: labelColor, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget untuk membuat TextField (sesuai styling HTML)
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required Color labelColor,
    required Color inputFillColor,
    required Color inputTextColor,
    required Color accentColor,
    required bool obscure,
    TextInputType keyboard = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: labelColor,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: TextStyle(
            color: inputTextColor,
            fontSize: 20,
            fontWeight: FontWeight.w300,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: inputFillColor,
            hintText: hint,
            hintStyle: TextStyle(color: inputTextColor.withOpacity(0.7)),
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: accentColor, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: accentColor, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: accentColor, width: 3),
            ),
            suffixIcon: suffixIcon,
          ),
          keyboardType: keyboard,
        ),
      ],
    );
  }
}