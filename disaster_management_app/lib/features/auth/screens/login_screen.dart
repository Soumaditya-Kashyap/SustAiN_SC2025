import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../shared/widgets/custom_app_bar.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_text_field.dart';
import '../../shared/services/auth_service.dart';
import '../../shared/models/user_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  String _selectedRole = 'user'; // 'user' or 'admin'

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      print('Starting login process...');

      // Admin login
      if (_selectedRole == 'admin') {
        if (_emailController.text.trim() == 'admin123@gmail.com' &&
            _passwordController.text.trim() == '123456') {
          print('Admin credentials verified');

          // Sign in admin
          final userCredential = await _authService.signInWithEmailAndPassword(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );

          print('Admin login completed, credential: ${userCredential != null}');

          // No need to check userCredential, if we got here without an exception, login was successful
          if (mounted) {
            print('Admin login successful. Navigating to admin dashboard.');
            // Direct navigation
            Navigator.of(context)
                .pushReplacementNamed(AppConstants.adminDashboardRoute);
          }
          return; // Return early to prevent executing regular user logic
        } else {
          throw FirebaseAuthException(
            code: 'wrong-credentials',
            message: 'Invalid admin credentials',
          );
        }
      }

      // Regular user login
      print('Attempting user login');

      // Sign in user
      final userCredential = await _authService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      print('User login completed, credential: ${userCredential != null}');

      // Check if we're logged in - either through userCredential or direct auth state
      final currentUser = _authService.currentUser;
      if (currentUser != null || userCredential != null) {
        if (mounted) {
          print('User login successful. Navigating to user dashboard.');
          // Direct navigation with a small delay to ensure auth state is updated
          await Future.delayed(const Duration(milliseconds: 300));
          Navigator.of(context)
              .pushReplacementNamed(AppConstants.userDashboardRoute);
        }
      } else {
        throw Exception('Login failed: Could not authenticate user');
      }
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException during login: ${e.code} - ${e.message}');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${e.message}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      print('Error during login: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted && _isLoading) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Login',
        showBackButton: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                label: 'Email',
                hint: 'Enter your email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppConstants.requiredField;
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                    return AppConstants.invalidEmail;
                  }
                  return null;
                },
                prefix: const Icon(Icons.email),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Password',
                hint: 'Enter your password',
                controller: _passwordController,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppConstants.requiredField;
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
                prefix: const Icon(Icons.lock),
              ),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.grey[100]
                      : Colors.grey[900],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person_outline),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedRole,
                          items: const [
                            DropdownMenuItem(
                              value: 'user',
                              child: Text('Login as User'),
                            ),
                            DropdownMenuItem(
                              value: 'admin',
                              child: Text('Login as Admin'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedRole = value);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Login',
                onPressed: _login,
                isLoading: _isLoading,
                icon: Icons.login,
              ),
              const SizedBox(height: 24),
              if (_selectedRole == 'user') ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? "),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppConstants.signupRoute);
                      },
                      child: const Text('Sign Up'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
