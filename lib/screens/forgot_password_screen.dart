import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await AuthService().resetPassword(_emailController.text);
      setState(() {
        _successMessage = 'Password reset email sent. Please check your inbox.';
      });
    } on auth.FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final iconSize = size.width * 0.2;
    final titleSize = size.width * 0.06;
    final subtitleSize = size.width * 0.035;
    final padding = size.width * 0.06;
    final spacing = size.height * 0.02;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: size.height * 0.05),
                Icon(
                  Icons.lock_reset,
                  size: iconSize,
                  color: Colors.grey,
                ),
                SizedBox(height: spacing * 1.2),
                Text(
                  'Forgot your password?',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: titleSize,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: spacing * 0.5),
                Text(
                  'Enter your email address and we\'ll send you a link to reset your password.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: subtitleSize,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: spacing * 1.6),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: spacing * 1.2),
                if (_errorMessage != null)
                  Padding(
                    padding: EdgeInsets.only(bottom: spacing),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: subtitleSize * 0.875,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (_successMessage != null)
                  Padding(
                    padding: EdgeInsets.only(bottom: spacing),
                    child: Text(
                      _successMessage!,
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: subtitleSize * 0.875,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _resetPassword,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: spacing),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: spacing,
                          width: spacing,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Reset Password'),
                ),
                SizedBox(height: spacing),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Back to Sign In'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 