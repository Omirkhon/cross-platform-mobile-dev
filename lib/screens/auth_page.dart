import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';
import 'package:provider/provider.dart';


class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  late final AuthService _auth;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _auth = Provider.of<AuthService>(context, listen: false);
  }
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        await _auth.signInWithEmailPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      } else {
        await _auth.registerWithEmailPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      }
      
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
    } on FirebaseAuthException catch (e) {
      _showErrorDialog(context, e.code);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorDialog(BuildContext context, String errorCode) {
    String message;
    switch (errorCode) {
      case 'user-not-found':
        message = 'user_not_found'.tr();
        break;
      case 'wrong-password':
        message = 'wrong_password'.tr();
        break;
      case 'email-already-in-use':
        message = 'email_in_use'.tr();
        break;
      case 'weak-password':
        message = 'weak_password'.tr();
        break;
      case 'invalid-email':
        message = 'invalid_email'.tr();
        break;
      default:
        message = 'auth_error'.tr();
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('error'.tr()),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('ok'.tr()),
          ),
        ],
      ),
    );
  }

  Future<void> _signInAsGuest() async {
    setState(() => _isLoading = true);
    try {
      await _auth.signInAnonymously();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/guest', (route) => false);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _isLogin ? 'login.title'.tr() : 'register.title'.tr(),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 40),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'email'.tr(),
                        prefixIcon: const Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'email_required'.tr();
                        }
                        if (!value.contains('@')) {
                          return 'email_invalid'.tr();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'password'.tr(),
                        prefixIcon: const Icon(Icons.lock),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'password_required'.tr();
                        }
                        if (value.length < 6) {
                          return 'password_length'.tr();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.deepPurple,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                _isLogin ? 'login.button'.tr() : 'register.button'.tr(),
                                style: const TextStyle(fontSize: 18),
                              ),
                      ),
                    ),
                    TextButton(
                      onPressed: _isLoading ? null : () {
                        setState(() => _isLogin = !_isLogin);
                      },
                      child: Text(
                        _isLogin ? 'register.switch'.tr() : 'login.switch'.tr(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'or'.tr(),
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: _isLoading ? null : _signInAsGuest,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.deepPurple),
                      ),
                      child: Text('guest.button'.tr()),
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}