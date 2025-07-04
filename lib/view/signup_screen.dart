// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todo_flutter_app_2/controller/auth_controller.dart';
import 'package:todo_flutter_app_2/controller/profile_controller.dart';
import 'package:todo_flutter_app_2/view/loading_messag.dart';
import 'package:todo_flutter_app_2/view/login_screen.dart';
import 'package:todo_flutter_app_2/widgets/footer.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _authController = AuthController();
  final _profileController = ProfileController();

  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmpassword = TextEditingController();
  bool _isLoading = false;

  void _submit(BuildContext context) async {
    if (_username.text.isEmpty ||
        _email.text.isEmpty ||
        _password.text.isEmpty ||
        _confirmpassword.text.isEmpty) {
      _showSnackBar("⚠️ Please fill all fields!", Colors.redAccent);
      return;
    }

    if (_password.text != _confirmpassword.text) {
      _showSnackBar("❌ Passwords do not match!", Colors.redAccent);
      return;
    }

    setState(() {
      _isLoading = true;
    });
    try {
      final user = await _authController.signUp(_email.text, _password.text);
      if (user != null) {
        await _profileController.createProfile(user.uid, _username.text);
        _showSnackBar("✅ Account created successfully!", Colors.green);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar("❌  ${e.toString().substring(36)}", Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? LoadingMessage()
        : Scaffold(
            backgroundColor: Colors.blueGrey.shade50,
            body: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(
                      Icons.app_registration,
                      size: 100,
                      color: Colors.deepPurple,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Create Account",
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildTextField(
                      "Username",
                      Icons.person,
                      controller: _username,
                    ),
                    const SizedBox(height: 12),

                    _buildTextField("Email", Icons.email, controller: _email),
                    const SizedBox(height: 12),

                    _buildTextField(
                      "Password",
                      Icons.lock,
                      controller: _password,
                      obscureText: true,
                    ),
                    const SizedBox(height: 12),

                    _buildTextField(
                      "Confirm Password",
                      Icons.lock_outline,
                      controller: _confirmpassword,
                      obscureText: true,
                    ),
                    const SizedBox(height: 24),

                    ElevatedButton.icon(
                      icon: const Icon(
                        Icons.person_add,
                        color: Colors.deepPurple,
                      ),
                      label: const Text(
                        "Sign Up",
                        style: TextStyle(color: Colors.deepPurple),
                      ),
                      onPressed: () => _submit(context),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                    const SizedBox(height: 10),

                    TextButton(
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => LoginScreen()),
                      ),
                      child: const Text("Already have an account? Log in"),
                    ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: const AppFooter(),
          );
  }

  Widget _buildTextField(
    String hint,
    IconData icon, {
    bool obscureText = false,
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
