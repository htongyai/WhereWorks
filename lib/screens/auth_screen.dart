import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
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
  bool _isLogin = true;
  bool _isLoading = false;
  String _email = '';
  String _password = '';
  String _name = '';
  String _phone = '';
  String? _errorMessage;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    _formKey.currentState!.save();

    try {
      if (_isLogin) {
        await _auth.signIn(_email, _password);
      } else {
        await _auth.signUp(
          email: _email,
          password: _password,
          name: _name,
          phone: _phone,
        );
      }

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
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
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final logoSize = size.width * 0.25;
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
                SizedBox(height: spacing * 1.2),
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
                    onSaved: (value) => _name = value!.trim(),
                  ),
                  SizedBox(height: spacing),
                  TextFormField(
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
                    onSaved: (value) => _phone = value!.trim(),
                  ),
                  SizedBox(height: spacing),
                ],
                TextFormField(
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
                  onSaved: (value) => _email = value!.trim(),
                ),
                SizedBox(height: spacing),
                TextFormField(
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
                  onSaved: (value) => _password = value!.trim(),
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
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: subtitleSize * 0.875,
                      ),
                      textAlign: TextAlign.center,
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