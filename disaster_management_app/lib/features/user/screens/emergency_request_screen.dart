import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../shared/widgets/custom_app_bar.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_text_field.dart';
import '../../shared/services/auth_service.dart';
import '../../shared/models/emergency_request.dart';
import '../../shared/models/user_model.dart';

class EmergencyRequestScreen extends StatefulWidget {
  const EmergencyRequestScreen({super.key});

  @override
  State<EmergencyRequestScreen> createState() => _EmergencyRequestScreenState();
}

class _EmergencyRequestScreenState extends State<EmergencyRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _phoneController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  UserModel? _currentUser;
  Map<String, double>? _currentLocation;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      // TODO: Implement actual location service
      // For now, using dummy coordinates
      setState(() {
        _currentLocation = {
          'lat': 37.7749, // San Francisco coordinates as example
          'lon': -122.4194,
        };
      });
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<void> _loadUserData() async {
    final user = _authService.currentUser;
    if (user != null) {
      final userData = await _authService.getUser(user.uid);
      if (userData != null) {
        setState(() {
          _currentUser = userData;
          if (userData.phoneNumber != null) {
            _phoneController.text = userData.phoneNumber!;
          }
        });
      }
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = _authService.currentUser;
      if (user == null || _currentUser == null) {
        throw Exception('User not found');
      }

      // Use phone number from form if provided, otherwise use the one from user profile
      final phoneNumber = _phoneController.text.trim().isNotEmpty
          ? _phoneController.text.trim()
          : _currentUser!.phoneNumber;

      if (phoneNumber == null || phoneNumber.isEmpty) {
        throw Exception('Phone number is required for emergency requests');
      }

      final request = EmergencyRequest(
        id: '',
        userId: user.uid,
        userName: _currentUser!.name,
        phoneNumber: phoneNumber,
        location: _locationController.text,
        description: _descriptionController.text,
        status: 'pending',
        createdAt: DateTime.now(),
        coordinates: _currentLocation ??
            {
              'lat': 0.0,
              'lon': 0.0,
            },
        age: _currentUser!.age,
        gender: _currentUser!.gender,
      );

      final doc = await FirebaseFirestore.instance
          .collection(AppConstants.emergencyRequestsCollection)
          .add(request.toMap());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Emergency request sent successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
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
      appBar: const CustomAppBar(
        title: 'Emergency Request',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Emergency Icon and Title
              const Center(
                child: Icon(
                  Icons.emergency,
                  size: 64,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Send Emergency Request',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Please provide accurate information for quick assistance',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ),
              const SizedBox(height: 32),

              // Phone Number Field
              CustomTextField(
                label: 'Phone Number',
                hint: 'Enter your contact number',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                prefix: const Icon(Icons.phone),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    if (_currentUser?.phoneNumber == null ||
                        _currentUser!.phoneNumber!.isEmpty) {
                      return 'Phone number is required for emergency requests';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Location Field
              CustomTextField(
                label: 'Current Location',
                hint: 'Enter your current location',
                controller: _locationController,
                prefix: const Icon(Icons.location_on),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Location is required';
                  }
                  return null;
                },
              ),
              if (_currentLocation != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'GPS Coordinates: ${_currentLocation!['lat']?.toStringAsFixed(4)}, ${_currentLocation!['lon']?.toStringAsFixed(4)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              const SizedBox(height: 16),

              // Description Field
              CustomTextField(
                label: 'Emergency Description',
                hint: 'Describe your emergency situation',
                controller: _descriptionController,
                maxLines: 5,
                prefix: const Icon(Icons.description),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Description is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // User Information Preview
              if (_currentUser != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Information',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow('Name', _currentUser!.name),
                      _buildInfoRow(
                          'Phone', _currentUser!.phoneNumber ?? 'Not provided'),
                      _buildInfoRow('Age', _currentUser!.age.toString()),
                      _buildInfoRow('Gender', _currentUser!.gender),
                    ],
                  ),
                ),
              const SizedBox(height: 32),

              // Submit Button
              CustomButton(
                text: 'Send Emergency Request',
                onPressed: _submitRequest,
                isLoading: _isLoading,
                backgroundColor: Colors.red,
                icon: Icons.send,
              ),
              const SizedBox(height: 16),

              // Warning Text
              const Text(
                'Note: False emergency requests are punishable by law',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(value),
        ],
      ),
    );
  }
}
