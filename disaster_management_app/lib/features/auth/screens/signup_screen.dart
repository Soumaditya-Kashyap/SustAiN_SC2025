import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../shared/widgets/custom_app_bar.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_text_field.dart';
import '../../shared/services/auth_service.dart';
import '../../shared/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  String _selectedGender = 'Male';
  int _age = 18;
  List<String> _selectedLocations = [];
  
  // State selection
  String? _selectedState;
  List<String> _availableCities = [];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _updateSelectedState(String? state) {
    if (state != null) {
      setState(() {
        _selectedState = state;
        _availableCities = AppConstants.locationsByState[state] ?? [];
        
        // Remove any previously selected locations that aren't in the new state
        _selectedLocations.removeWhere(
            (location) => !_availableCities.contains(location));
      });
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError 
            ? Theme.of(context).colorScheme.error 
            : Colors.green,
      ),
    );
  }

  Future<void> _signup() async {
    // Validate form inputs
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        _showSnackBar('Passwords do not match');
        return;
      }

      if (_selectedLocations.length < 3) {
        _showSnackBar('Please select 3 locations');
        return;
      }
      
      if (_selectedState == null) {
        _showSnackBar('Please select a state');
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        // Create user with email and password
        final userCredential =
            await _authService.createUserWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        // Get the user - either from the credential or from the auth state
        User? user = userCredential?.user;
        if (user == null) {
          // If credential is null due to PigeonUserDetails error, try getting current user
          user = _authService.currentUser;
          if (user == null || user.email != _emailController.text.trim()) {
            throw Exception('Failed to create user account');
          }
        }

        // Create user document in Firestore
        final newUser = UserModel(
          id: user.uid,
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          gender: _selectedGender,
          age: _age,
          selectedLocations: _selectedLocations,
          state: _selectedState,
          role: 'user',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _authService.createUser(newUser);
        
        if (mounted) {
          _showSnackBar('Account created successfully!', isError: false);
          
          // Navigate to user dashboard
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppConstants.userDashboardRoute,
            (route) => false,
          );
        }
      } on FirebaseAuthException catch (e) {
        print('FirebaseAuthException during signup: ${e.code} - ${e.message}');
        setState(() => _isLoading = false);
        if (mounted) {
          _showSnackBar(_getErrorMessage(e.code), isError: true);
        }
      } catch (e, stackTrace) {
        print('Error during signup: $e');
        print('Stack trace: $stackTrace');
        setState(() => _isLoading = false);
        if (mounted) {
          _showSnackBar(e.toString(), isError: true);
        }
      }
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'invalid-email':
        return 'Please enter a valid email address';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled';
      case 'weak-password':
        return 'Please enter a stronger password';
      default:
        return 'An error occurred during signup';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Sign Up',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                label: 'Full Name',
                hint: 'John Doe',
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppConstants.requiredField;
                  }
                  return null;
                },
                prefix: const Icon(Icons.person),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Email',
                hint: 'john@example.com',
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
                label: 'Phone Number',
                hint: '+1234567890',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppConstants.requiredField;
                  }
                  // Add more phone number validation if needed
                  return null;
                },
                prefix: const Icon(Icons.phone),
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
              CustomTextField(
                label: 'Confirm Password',
                hint: 'Confirm your password',
                controller: _confirmPasswordController,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppConstants.requiredField;
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
                prefix: const Icon(Icons.lock_outline),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                          value: _selectedGender,
                          items: const [
                            DropdownMenuItem(
                              value: 'Male',
                              child: Text('Male'),
                            ),
                            DropdownMenuItem(
                              value: 'Female',
                              child: Text('Female'),
                            ),
                            DropdownMenuItem(
                              value: 'Other',
                              child: Text('Other'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedGender = value);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.grey[100]
                      : Colors.grey[900],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _age,
                          items: List.generate(
                            83,
                            (index) => DropdownMenuItem(
                              value: index + 18,
                              child: Text('${index + 18} years'),
                            ),
                          ),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _age = value);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.only(left: 8.0, bottom: 4.0),
                child: Text(
                  'Select State',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedState,
                    hint: const Text('Select State'),
                    items: AppConstants.locationsByState.keys.map((String state) {
                      return DropdownMenuItem<String>(
                        value: state,
                        child: Text(state),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      _updateSelectedState(newValue);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_selectedState != null) ...[
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
                  child: Row(
                    children: [
                      const Text(
                        'Select Locations',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${_selectedLocations.length}/3)',
                        style: TextStyle(
                          color: _selectedLocations.length < 3
                              ? Colors.red
                              : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                Wrap(
                  spacing: 8.0,
                  children: _availableCities.map((location) {
                    return FilterChip(
                      label: Text(location),
                      selected: _selectedLocations.contains(location),
                      onSelected: _selectedLocations.length >= 3 &&
                              !_selectedLocations.contains(location)
                          ? null
                          : (selected) {
                              setState(() {
                                if (selected) {
                                  if (_selectedLocations.length < 3) {
                                    _selectedLocations.add(location);
                                  }
                                } else {
                                  _selectedLocations.remove(location);
                                }
                              });
                            },
                    );
                  }).toList(),
                ),
                if (_selectedLocations.length < 3)
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0, top: 4.0),
                    child: Text(
                      'Please select 3 locations',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
              ],
              const SizedBox(height: 24),
              CustomButton(
                text: 'Sign Up',
                onPressed: _signup,
                isLoading: _isLoading,
                icon: Icons.person_add,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account? '),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Login'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
