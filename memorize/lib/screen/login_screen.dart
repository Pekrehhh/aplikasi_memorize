import 'package:flutter/material.dart';
import 'package:memorize/screen/register_screen.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscureText = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    Map<String, dynamic> result;

    try {
      result = await Provider.of<AuthProvider>(context, listen: false).login(
        _emailController.text,
        _passwordController.text,
      );
    } catch (e) {
      result = {'success': false, 'message': 'Terjadi error: $e'};
    }

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    // Tampilkan error HANYA jika login gagal
    if (result['success'] == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Login Gagal. Cek kembali data Anda.'),
          backgroundColor: Colors.red,
        ),
      );
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login Memorize'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo atau Icon (Opsional)
              Icon(Icons.note_alt_rounded, size: 80, color: Colors.blueAccent),
              SizedBox(height: 20),

              // TextField Email
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16),

              // TextField Password
              TextField(
                controller: _passwordController,
                obscureText: _obscureText, // Sembunyikan teks
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText; // Toggle password
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 24),

              // Tombol Login
              if (_isLoading)
                CircularProgressIndicator() // Tampilkan ini jika sedang loading
              else
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50), // Buat tombol jadi lebar
                  ),
                  onPressed: _submitLogin,
                  child: Text('Login'),
                ),

              SizedBox(height: 16),

              // Tombol untuk pindah ke Register
              TextButton(
                onPressed: () {
                  // Pindah ke Halaman Register
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (ctx) => RegisterScreen()),
                  );
                },
                child: Text('Belum punya akun? Daftar di sini'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}