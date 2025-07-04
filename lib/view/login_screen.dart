import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todo_flutter_app_2/controller/auth_controller.dart';
import 'package:todo_flutter_app_2/view/forgot_password.dart';
import 'package:todo_flutter_app_2/view/loading_messag.dart';
import 'package:todo_flutter_app_2/view/signup_screen.dart';
import 'package:todo_flutter_app_2/view/todo_screen.dart';
import 'package:todo_flutter_app_2/widgets/footer.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authController = AuthController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _isLoading = false;

  Future<void> _login(BuildContext context) async {
    if (_email.text.isEmpty || _password.text.isEmpty) {
      _showSnackBar("⚠️ Please fill all fields!", Colors.redAccent);
      return;
    }
    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _authController.signIn(
        _email.text.trim(),
        _password.text.trim(),
      );

      if (user != null) {
        _showSnackBar("✅ Login successful!", Colors.green);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => TodoPage(userEmail: user.email!, uid: user.uid),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar("❌ Login failed: Incorrect credentials.", Colors.red);
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
                      Icons.lock_open,
                      size: 100,
                      color: Colors.deepPurple,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Welcome Back",
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildTextField("Email", Icons.email, controller: _email),
                    const SizedBox(height: 12),

                    _buildTextField(
                      "Password",
                      Icons.lock,
                      controller: _password,
                      obscureText: true,
                    ),
                    const SizedBox(height: 24),

                    ElevatedButton.icon(
                      icon: const Icon(Icons.login),
                      label: const Text("Login"),
                      onPressed: () => _login(context),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                    const SizedBox(height: 10),

                    TextButton(
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const SignUpScreen()),
                      ),
                      child: const Text("Don't have an account? Sign up"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ForgotPasswordScreen(),
                        ),
                      ),
                      child: const Text("Forgot Password ?"),
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
