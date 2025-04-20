import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/gestures.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'terms_of_use_screen.dart';
import 'privacy_policy_screen.dart';
import 'forgot_password_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = AuthService();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  DateTime? _selectedDate;
  bool _isLogin = true;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 13)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      if (mounted) {
        setState(() {
          _selectedDate = picked;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isLogin && _selectedDate == null) {
      setState(() {
        _errorMessage = 'Please select your date of birth';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isLogin) {
        await _auth.signIn(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      } else {
        await _auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          dateOfBirth: _selectedDate!,
        );
      }

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } on auth.FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'We couldn\'t find an account with this email. Would you like to create one?';
          break;
        case 'wrong-password':
          errorMessage = 'The password you entered is incorrect. Please try again.';
          break;
        case 'invalid-email':
          errorMessage = 'Please enter a valid email address (e.g., yourname@example.com)';
          break;
        case 'email-already-in-use':
          errorMessage = 'This email is already registered. Please sign in instead.';
          break;
        case 'weak-password':
          errorMessage = 'Your password is too weak. Please use at least 6 characters with a mix of letters and numbers.';
          break;
        case 'network-request-failed':
          errorMessage = 'Unable to connect to the internet. Please check your connection and try again.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many attempts. Please wait a few minutes before trying again.';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been deactivated. Please contact support for assistance.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'This type of account is not allowed. Please try a different sign-in method.';
          break;
        default:
          errorMessage = 'Something went wrong. Please try again later.';
      }
      setState(() {
        _errorMessage = errorMessage;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred. Please try again or contact support if the problem persists.';
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
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final logoSize = size.width * 0.35;
    final titleSize = size.width * 0.06;
    final subtitleSize = size.width * 0.035;
    final padding = size.width * 0.06;
    final spacing = size.height * 0.02;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: size.height * 0.05),
                Image.asset(
                  'assets/images/wwlogo.png',
                  height: logoSize,
                  width: logoSize,
                ),
                SizedBox(height: spacing * 0.2),
                Text(
                  _isLogin ? 'Welcome Back!' : 'Create Account',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: titleSize,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: spacing * 0.5),
                Text(
                  _isLogin
                      ? 'Sign in to continue'
                      : 'Sign up to start finding perfect workspaces',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: subtitleSize,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: spacing * 1.6),
                if (!_isLogin) ...[
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: spacing),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: spacing),
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Date of Birth',
                          prefixIcon: const Icon(Icons.cake),
                          suffixIcon: const Icon(Icons.calendar_today),
                          hintText: _selectedDate == null
                              ? 'Select your date of birth'
                              : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                        ),
                        controller: TextEditingController(
                          text: _selectedDate == null
                              ? ''
                              : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                        ),
                        validator: (value) {
                          if (!_isLogin && _selectedDate == null) {
                            return 'Please select your date of birth';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: spacing),
                ],
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
                SizedBox(height: spacing),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                SizedBox(height: spacing * 1.25),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForgotPasswordScreen(),
                      ),
                    );
                  },
                  child: const Text('Forgot Password?'),
                ),
                SizedBox(height: spacing * 1.2),
                if (_errorMessage != null)
                  Padding(
                    padding: EdgeInsets.only(bottom: spacing),
                    child: Container(
                      padding: EdgeInsets.all(spacing * 0.8),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.red[200]!,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red[700],
                            size: size.width * 0.05,
                          ),
                          SizedBox(width: spacing * 0.5),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: Colors.red[700],
                                fontSize: subtitleSize * 0.875,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
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
                      : Text(_isLogin ? 'Sign In' : 'Sign Up'),
                ),
                SizedBox(height: spacing),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLogin = !_isLogin;
                      _errorMessage = null;
                    });
                  },
                  child: Text(
                    _isLogin
                        ? 'Don\'t have an account? Sign Up'
                        : 'Already have an account? Sign In',
                  ),
                ),
                if (!_isLogin) ...[
                  SizedBox(height: spacing * 0.5),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: padding * 0.5),
                    child: Text.rich(
                      TextSpan(
                        text: 'By signing up, you hereby agree to our ',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: subtitleSize * 0.9,
                        ),
                        children: [
                          TextSpan(
                            text: 'Terms of Use',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const TermsOfUseScreen(),
                                  ),
                                );
                              },
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const PrivacyPolicyScreen(),
                                  ),
                                );
                              },
                          ),
                          const TextSpan(text: '.'),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                SizedBox(height: spacing),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TermsOfUseScreen(),
                          ),
                        );
                      },
                      child: const Text('Terms of Use'),
                    ),
                    const Text(' • '),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PrivacyPolicyScreen(),
                          ),
                        );
                      },
                      child: const Text('Privacy Policy'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 