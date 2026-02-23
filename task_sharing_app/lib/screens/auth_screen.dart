import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _obscurePassword = true;
  bool _isLoading = false;

  Future<void> _submit() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) return;

    setState(() => _isLoading = true);
    String? error;
    final messenger = ScaffoldMessenger.of(context);

    if (_isLogin) {
      error = await authService.signIn(email, password);
    } else {
      error = await authService.signUp(email, password);
    }

    if (error != null && mounted) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(error, style: GoogleFonts.dmSans()),
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _showForgotPasswordDialog() {
    final resetController = TextEditingController(text: _emailController.text);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Forgot Password?', style: GoogleFonts.dmSerifDisplay(fontSize: 24)),
        content: TextField(
          controller: resetController,
          style: GoogleFonts.dmSans(fontSize: 14),
          decoration: _inputDecoration('Email Address', Icons.email_outlined),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.dmSans(color: const Color(0xFFB0AA9F))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2C2C2C),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              final email = resetController.text.trim();
              if (email.isNotEmpty) {
                final authService = Provider.of<AuthService>(context, listen: false);
                final navigator = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);
                
                final error = await authService.resetPassword(email);
                
                if (!mounted) return;
                
                navigator.pop();
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(error ?? 'Reset email sent to $email', style: GoogleFonts.dmSans()),
                    backgroundColor: error == null ? Colors.green : Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.dmSans(color: const Color(0xFFB0AA9F), fontSize: 13),
      prefixIcon: Icon(icon, color: const Color(0xFFD4CFC7), size: 20),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFECEAE5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFECEAE5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF2C2C2C)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F3),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isLogin ? 'Welcome Back' : 'Create Account',
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 38,
                  color: const Color(0xFF1A1A1A),
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isLogin ? 'Manage your tasks seamlessly.' : 'Start your journey with us.',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: const Color(0xFFB0AA9F),
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _emailController,
                style: GoogleFonts.dmSans(fontSize: 14),
                decoration: _inputDecoration('Email', Icons.email_outlined),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: GoogleFonts.dmSans(fontSize: 14),
                decoration: _inputDecoration('Password', Icons.lock_outline).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: const Color(0xFFD4CFC7), size: 20),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              if (_isLogin)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _showForgotPasswordDialog,
                    child: Text(
                      'Forgot Password?',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: const Color(0xFFB0AA9F),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF2C2C2C)))
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C2C2C),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      onPressed: _submit,
                      child: Text(
                        _isLogin ? 'Login' : 'Sign Up',
                        style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                    ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => setState(() => _isLogin = !_isLogin),
                  child: Text(
                    _isLogin ? 'Create new account' : 'Already have an account? Login',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: const Color(0xFFB0AA9F),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
