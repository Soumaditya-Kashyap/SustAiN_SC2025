import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_constants.dart';
import '../../shared/widgets/custom_app_bar.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/services/auth_service.dart';
import '../../shared/models/user_model.dart';
import '../../shared/models/emergency_request_model.dart';
import '../../../main.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final _authService = AuthService();
  bool _isLoading = true;
  UserModel? _user;
  List<EmergencyRequest> _userRequests = [];
  bool _isLoadingRequests = false;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserData();

    // Set up a listener for tab changes
    _tabController!.addListener(() {
      // If user switches to the requests tab, refresh the requests
      if (_tabController!.index == 1 && _user != null) {
        _loadUserRequests(_user!.id);
      }
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      final user = _authService.currentUser;
      if (user != null) {
        print('Loading profile data for user: ${user.uid}');
        print('Email: ${user.email}');

        final userData = await _authService.getUser(user.uid);
        if (userData != null) {
          print('User data loaded successfully: ${userData.toMap()}');
          if (mounted) {
            setState(() => _user = userData);
          }

          // Load user's emergency requests
          await _loadUserRequests(user.uid);
        } else {
          print('⚠️ No user data found in Firestore for authenticated user');
          // If we have auth but no Firestore data, create a basic profile
          if (user.email != null) {
            final newUser = UserModel(
              id: user.uid,
              name: user.displayName ?? user.email!.split('@')[0],
              email: user.email!,
              phoneNumber: user.phoneNumber,
              age: 18,
              gender: 'Not specified',
              selectedLocations: [],
              role: 'user',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );

            print('Creating basic profile in Firestore');
            await _authService.createUser(newUser);
            if (mounted) {
              setState(() => _user = newUser);
            }
          } else {
            throw Exception('Cannot create user profile: missing email');
          }
        }
      } else {
        print('❌ No authenticated user found');
        throw Exception('Please login to view your profile');
      }
    } catch (e) {
      print('Error loading user data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load profile: ${e.toString()}'),
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

  Future<void> _loadUserRequests(String userId) async {
    if (mounted) {
      setState(() => _isLoadingRequests = true);
    }

    try {
      print('Loading emergency requests for user: $userId');

      try {
        // First try the query with ordering
        final querySnapshot = await FirebaseFirestore.instance
            .collection(AppConstants.emergencyRequestsCollection)
            .where('userId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .get();

        print('Found ${querySnapshot.docs.length} requests for user $userId');
        _processRequestQueryResults(querySnapshot);
      } catch (e) {
        print('Error with ordered query: $e');
        if (e.toString().contains('requires an index')) {
          // Fallback to simpler query without ordering if index is missing
          print('Falling back to query without ordering');
          final querySnapshot = await FirebaseFirestore.instance
              .collection(AppConstants.emergencyRequestsCollection)
              .where('userId', isEqualTo: userId)
              .get();

          print(
              'Found ${querySnapshot.docs.length} requests (unordered) for user $userId');
          _processRequestQueryResults(querySnapshot);

          // Show a more user-friendly message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                    'Requests loaded but may not be in order. Admin is working on optimizing the database.'),
                duration: const Duration(seconds: 5),
                action: SnackBarAction(
                  label: 'OK',
                  onPressed: () {},
                ),
              ),
            );
          }
        } else {
          // If it's not an index issue, rethrow
          throw e;
        }
      }
    } catch (e) {
      print('Error loading user requests: $e');
      if (mounted) {
        setState(() => _isLoadingRequests = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading requests. Please try again later.'),
            backgroundColor: Theme.of(context).colorScheme.error,
            action: SnackBarAction(
              label: 'RETRY',
              onPressed: () => _loadUserRequests(userId),
              textColor: Colors.white,
            ),
          ),
        );
      }
    }
  }

  void _processRequestQueryResults(QuerySnapshot querySnapshot) {
    if (!mounted) return;

    final List<EmergencyRequest> requests = [];

    for (var doc in querySnapshot.docs) {
      try {
        final data = doc.data() as Map<String, dynamic>;
        print('Request document ID: ${doc.id}');

        // Handle Timestamp conversion for createdAt
        if (data['createdAt'] is Timestamp) {
          final timestamp = data['createdAt'] as Timestamp;
          data['createdAt'] = timestamp.toDate();
        }

        // Ensure we have a status - default to 'pending' if missing
        if (data['status'] == null || (data['status'] as String).isEmpty) {
          data['status'] = 'pending';
        }

        final request = EmergencyRequest.fromMap(data, doc.id);
        requests.add(request);
        print(
            'Successfully parsed request: ${request.id}, status: ${request.status}');
      } catch (e) {
        print('Error parsing request document: $e');
      }
    }

    print('Parsed ${requests.length} valid requests');

    setState(() {
      _userRequests = requests;
      _isLoadingRequests = false;
    });
  }

  Future<void> _signOut() async {
    setState(() => _isLoading = true);
    try {
      await _authService.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppConstants.loginRoute,
          (route) => false,
        );
      }
    } catch (e) {
      print('Error signing out: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to sign out: ${e.toString()}'),
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

  void _showContactUsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Us'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildContactRow(
                Icons.email, 'Email', 'support@disastermanagement.com'),
            const SizedBox(height: 16),
            _buildContactRow(Icons.phone, 'Phone', '+1 234 567 8900'),
            const SizedBox(height: 16),
            _buildContactRow(Icons.location_on, 'Address',
                '123 Emergency St, Safety City, 12345'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Profile',
        showBackButton: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Failed to load user data'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadUserData,
                        child: const Text('Retry'),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _signOut,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Sign Out'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadUserData,
                  child: Column(
                    children: [
                      // Header with user info
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Theme.of(context).primaryColor,
                              Theme.of(context).primaryColor.withOpacity(0.7),
                            ],
                          ),
                        ),
                        child: Column(
                          children: [
                            // Profile Picture
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.white,
                              child: Text(
                                _user!.name.isNotEmpty
                                    ? _user!.name[0].toUpperCase()
                                    : '?',
                                style: TextStyle(
                                  fontSize: 32,
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _user!.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _user!.email,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Chip(
                              label: Text(
                                _user!.role.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              backgroundColor: Colors.deepOrange,
                            ),
                          ],
                        ),
                      ),

                      // Tab bar for navigation
                      TabBar(
                        controller: _tabController,
                        tabs: const [
                          Tab(
                            icon: Icon(Icons.person),
                            text: 'Profile',
                          ),
                          Tab(
                            icon: Icon(Icons.history),
                            text: 'My Requests',
                          ),
                        ],
                        labelColor: Theme.of(context).primaryColor,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Theme.of(context).primaryColor,
                      ),

                      // Tab content
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            // Profile info tab
                            _buildProfileTab(),

                            // Emergency requests tab
                            _buildRequestsTab(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildProfileTab() {
    return RefreshIndicator(
      onRefresh: _loadUserData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User Information
            _buildInfoCard(
              title: 'Personal Information',
              icon: Icons.person,
              items: [
                _buildInfoRow('Name', _user!.name),
                _buildInfoRow('Email', _user!.email),
                _buildInfoRow('Phone', _user!.phoneNumber),
                _buildInfoRow('Age', _user!.age.toString()),
                _buildInfoRow('Gender', _user!.gender),
              ],
            ),
            const SizedBox(height: 16),

            // Selected Locations
            _buildInfoCard(
              title: 'Monitoring Locations',
              icon: Icons.location_on,
              items: _user!.selectedLocations.isEmpty
                  ? [_buildInfoRow('Locations', 'No locations selected')]
                  : _user!.selectedLocations
                      .map((location) => _buildLocationChip(location))
                      .toList(),
            ),
            const SizedBox(height: 16),

            // Account Actions
            _buildInfoCard(
              title: 'Account',
              icon: Icons.settings,
              items: [
                ListTile(
                  leading: const Icon(Icons.contact_support),
                  title: const Text('Contact Support'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _showContactUsDialog,
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.nightlight_round),
                  title: const Text('Dark Mode'),
                  trailing: Switch(
                    value: Provider.of<ThemeProvider>(context).themeMode ==
                        ThemeMode.dark,
                    onChanged: (value) {
                      Provider.of<ThemeProvider>(context, listen: false)
                          .toggleTheme();
                    },
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Sign Out',
                      style: TextStyle(color: Colors.red)),
                  onTap: _signOut,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationChip(String location) {
    return Chip(
      label: Text(location),
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
      avatar: const Icon(Icons.location_on, size: 16),
    );
  }

  Widget _buildRequestsTab() {
    return RefreshIndicator(
      onRefresh: () async {
        if (_user != null) {
          await _loadUserRequests(_user!.id);
        }
      },
      child: _isLoadingRequests
          ? const Center(child: CircularProgressIndicator())
          : _userRequests.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.history,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No Emergency Requests',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You haven\'t sent any emergency requests yet',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => _loadUserRequests(_user!.id),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _userRequests.length,
                  itemBuilder: (context, index) {
                    final request = _userRequests[index];
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: _buildRequestCard(request),
                    );
                  },
                ),
    );
  }

  Widget _buildRequestCard(EmergencyRequest request) {
    Color statusColor;
    IconData statusIcon;

    switch (request.status.toLowerCase()) {
      case 'accepted':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
    }

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Status: ${request.status.toUpperCase()}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(request.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Request details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 18,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Location: ${request.location}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Description: ${request.description}',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 12),

                // Additional info
                Row(
                  children: [
                    Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      request.phoneNumber,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      request.gender == 'Male' ? Icons.male : Icons.female,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${request.gender}, ${request.age} yrs',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Admin response if any
                if (request.adminResponse != null &&
                    request.adminResponse!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.blue.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.admin_panel_settings,
                                size: 16, color: Colors.blue),
                            SizedBox(width: 8),
                            Text(
                              'Admin Response:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(request.adminResponse!),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildInfoCard({
    required String title,
    IconData? icon,
    required List<Widget> items,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                ],
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            ...items,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'Not provided',
              style: const TextStyle(
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
