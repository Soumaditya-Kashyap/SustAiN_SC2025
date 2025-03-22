import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import 'user_dashboard_screen.dart';
import 'emergency_request_screen.dart';
import '../../../features/blog/screens/blog_screen.dart';
import '../../../features/search/screens/search_screen.dart';
import '../../../features/profile/screens/profile_screen.dart';

class UserWrapperScreen extends StatefulWidget {
  const UserWrapperScreen({super.key});

  @override
  State<UserWrapperScreen> createState() => _UserWrapperScreenState();
}

class _UserWrapperScreenState extends State<UserWrapperScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const UserDashboardScreen(),
    const BlogScreen(),
    const SearchScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EmergencyRequestScreen(),
                  ),
                );
              },
              backgroundColor: Colors.red,
              child: const Icon(Icons.emergency),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.article_outlined),
            selectedIcon: Icon(Icons.article),
            label: 'Blog',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
