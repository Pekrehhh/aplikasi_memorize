import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:memorize/screen/register_screen.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureText = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    FocusScope.of(context).unfocus();
    setState(() { _isLoading = true; });
    Map<String, dynamic> result;
    try {
      result = await Provider.of<AuthProvider>(context, listen: false).login(
        _usernameController.text,
        _passwordController.text,
      );
    } catch (e) {
      result = {'success': false, 'message': 'Terjadi error: $e'};
    }
    if (!mounted) return;
    setState(() { _isLoading = false; });
    if (result['success'] == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Login Gagal. Cek kembali data Anda.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  // --- BATAS KODE LOGIKA ---

  @override
  Widget build(BuildContext context) {
    // --- STYLING BARU DARI HTML/CSS ---
    final Color backgroundColor = Color(0xFF0c1320); // .container
    final Color accentColor = Color(0xFF24cccc);      // .login-button
    final Color labelColor = Color(0xFF62f4f4);        // .label, .register-link
    final Color titleAccentColor = Color(0xFF00acac);  // .rize
    final Color inputFillColor = Colors.white;
    final Color inputTextColor = Color(0xFF0c1320);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0), // Padding L/R
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo
              Icon(
                Icons.note_alt_rounded,
                size: 92,
                color: titleAccentColor, // Samakan dengan 'rize'
              ),
              SizedBox(height: 12), // Jarak dari HTML (278 - (186+92))

              // Title "Memorize"
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold, // Dibuat bold agar lebih 'title'
                  ),
                  children: [
                    TextSpan(text: 'Memo', style: TextStyle(color: Colors.white)),
                    TextSpan(text: 'rize', style: TextStyle(color: titleAccentColor)),
                  ],
                ),
              ),
              SizedBox(height: 60), // Jarak dari HTML (391 - 278)

              // --- Username Input (Label + Field) ---
              Text(
                'Username',
                style: TextStyle(
                  color: labelColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 8), // Jarak label ke field
              TextField(
                controller: _usernameController,
                style: TextStyle(
                  color: inputTextColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: inputFillColor,
                  hintText: 'Username',
                  hintStyle: TextStyle(color: inputTextColor.withOpacity(0.5)),
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
                ),
                keyboardType: TextInputType.text,
              ),
              SizedBox(height: 15), // Jarak antar field (506 - (417+71))

              // --- Password Input (Label + Field) ---
              Text(
                'Password',
                style: TextStyle(
                  color: labelColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscureText,
                style: TextStyle(
                  color: inputTextColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: inputFillColor,
                  hintText: 'Password',
                  hintStyle: TextStyle(color: inputTextColor.withOpacity(0.5)),
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
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: inputTextColor.withOpacity(0.7),
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 40), // Jarak ke tombol (637 - (532+71))

              // --- Tombol Login ---
              if (_isLoading)
                CircularProgressIndicator(color: accentColor)
              else
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    minimumSize: Size(227, 50), // Ukuran dari HTML
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                  ),
                  onPressed: _submitLogin,
                  child: Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              
              SizedBox(height: 20), // Jarak ke link (694 - (637+50))

              // --- Link ke Register ---
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(color: labelColor, fontSize: 14),
                  children: [
                    TextSpan(text: "Doesn't have account? "),
                    TextSpan(
                      text: 'Register now!',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline, // HTML hover
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (ctx) => RegisterScreen()),
                          );
                        },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}