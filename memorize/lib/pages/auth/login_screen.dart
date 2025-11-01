import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:memorize/pages/auth/register_screen.dart';
import 'package:provider/provider.dart';
import '../../controllers/login_controller.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = Color(0xFF0c1320);
    final Color accentColor = Color(0xFF24cccc);
    final Color labelColor = Color(0xFF62f4f4);
    final Color titleAccentColor = Color(0xFF00acac);
    final Color inputFillColor = Colors.white;
    final Color inputTextColor = Color(0xFF0c1320);

    return ChangeNotifierProvider(
      create: (_) => LoginController(),
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: Consumer<LoginController>(
          builder: (context, controller, child) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.note_alt_rounded,
                      size: 92,
                      color: titleAccentColor,
                    ),
                    SizedBox(height: 12),

                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(text: 'Memo', style: TextStyle(color: Colors.white)),
                          TextSpan(text: 'rize', style: TextStyle(color: titleAccentColor)),
                        ],
                      ),
                    ),
                    SizedBox(height: 60),

                    Text(
                      'Username',
                      style: TextStyle(
                        color: labelColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: controller.usernameController,
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
                    SizedBox(height: 15),

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
                      controller: controller.passwordController,
                      obscureText: controller.obscureText,
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
                            controller.obscureText ? Icons.visibility_off : Icons.visibility,
                            color: inputTextColor.withOpacity(0.7),
                          ),
                          onPressed: controller.toggleObscureText,
                        ),
                      ),
                    ),
                    SizedBox(height: 40),

                    if (controller.isLoading)
                      CircularProgressIndicator(color: accentColor)
                    else
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: Colors.white,
                          minimumSize: Size(227, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 5,
                        ),
                        onPressed: () => controller.submitLogin(context),
                        child: Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    
                    SizedBox(height: 20),

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
                              decoration: TextDecoration.underline,
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
            );
          },
        ),
      ),
    );
  }
}