import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/register_controller.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});


  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = Color(0xFF0c1320);
    final Color accentColor = Color(0xFF24cccc);
    final Color labelColor = Color(0xFF62f4f4);
    final Color titleAccentColor = Color(0xFF00acac);
    final Color inputFillColor = Colors.white;
    final Color inputTextColor = Color(0xFF0c1320);

    return ChangeNotifierProvider(
      create: (_) => RegisterController(),
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: Stack(
            children: [
              Consumer<RegisterController>(
                builder: (context, controller, child) {
                  return Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 40.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: 60),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.note_alt_rounded,
                                size: 58,
                                color: titleAccentColor,
                              ),
                              SizedBox(width: 8),
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    height: 1.2,
                                  ),
                                  children: [
                                    TextSpan(text: 'Memo', style: TextStyle(color: Colors.white)),
                                    TextSpan(text: 'rize', style: TextStyle(color: titleAccentColor)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 40),

                          _buildTextField(
                            controller: controller.usernameController,
                            label: 'Username',
                            hint: 'Username',
                            labelColor: labelColor,
                            inputFillColor: inputFillColor,
                            inputTextColor: inputTextColor,
                            accentColor: accentColor,
                            obscure: false,
                          ),
                          SizedBox(height: 18),

                          _buildTextField(
                            controller: controller.emailController,
                            label: 'E-mail',
                            hint: 'E-mail',
                            labelColor: labelColor,
                            inputFillColor: inputFillColor,
                            inputTextColor: inputTextColor,
                            accentColor: accentColor,
                            obscure: false,
                            keyboard: TextInputType.emailAddress,
                          ),
                          SizedBox(height: 18),
                          
                          _buildTextField(
                            controller: controller.passwordController,
                            label: 'Password',
                            hint: 'Password',
                            labelColor: labelColor,
                            inputFillColor: inputFillColor,
                            inputTextColor: inputTextColor,
                            accentColor: accentColor,
                            obscure: controller.obscureText,
                            suffixIcon: IconButton(
                              icon: Icon(
                                controller.obscureText ? Icons.visibility_off : Icons.visibility,
                                color: inputTextColor.withValues(alpha: 0.7),
                              ),
                              onPressed: controller.toggleObscureText,
                            ),
                          ),
                          SizedBox(height: 18),

                          _buildTextField(
                            controller: controller.confirmPasswordController,
                            label: 'Confirm Password',
                            hint: 'Confirm Password',
                            labelColor: labelColor,
                            inputFillColor: inputFillColor,
                            inputTextColor: inputTextColor,
                            accentColor: accentColor,
                            obscure: controller.obscureText,
                          ),
                          SizedBox(height: 32),

                          if (controller.isLoading)
                            CircularProgressIndicator(color: accentColor)
                          else
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 60),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accentColor,
                                  foregroundColor: Colors.white,
                                  minimumSize: Size(227, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                onPressed: () => controller.submitRegister(context),
                                child: Text(
                                  'Register',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          
                          SizedBox(height: 20),

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
                  );
                },
              ),

              Positioned(
                top: 16,
                left: 16,
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios_new, color: labelColor, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
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
            hintStyle: TextStyle(color: inputTextColor.withValues(alpha: 0.7)),
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