import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/signup_screen.dart';
import 'features/user/screens/user_wrapper_screen.dart';
import 'features/admin/screens/admin_dashboard_screen.dart';
import 'features/shared/services/auth_service.dart';
import 'features/shared/services/prefs_service.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/search/screens/search_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Try to initialize Firebase Auth without the setPersistence call
  // as it's causing issues on web platform
  try {
    // Create admin user if it doesn't exist
    final authService = AuthService();
    await authService.createAdminUserIfNotExists();

    // Check for existing session
    await authService.restoreUserSession();
  } catch (e) {
    print('Error initializing Firebase Auth: $e');
    // Continue anyway, the app will show login screen
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Disaster Management App',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            debugShowCheckedModeBanner: false,
            routes: {
              '/': (context) => const AuthenticationWrapper(),
              AppConstants.loginRoute: (context) => const LoginScreen(),
              AppConstants.signupRoute: (context) => const SignupScreen(),
              AppConstants.userDashboardRoute: (context) =>
                  const UserWrapperScreen(),
              AppConstants.adminDashboardRoute: (context) =>
                  const AdminDashboardScreen(),
              AppConstants.profileRoute: (context) => const ProfileScreen(),
              AppConstants.searchRoute: (context) => const SearchScreen(),
            },
          );
        },
      ),
    );
  }
}

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadThemeMode();
  }

  void _loadThemeMode() async {
    final isDark = await PrefsService.getThemePreference();
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void toggleTheme() async {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await PrefsService.saveThemePreference(_themeMode == ThemeMode.dark);
    notifyListeners();
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkForExistingSession(context),
      builder: (context, sessionSnapshot) {
        if (sessionSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // If we have a valid session, handle it
        if (sessionSnapshot.data == true) {
          return FutureBuilder<Map<String, dynamic>>(
            future: Provider.of<AuthService>(context, listen: false)
                .getSavedUserSession(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final userData = snapshot.data ?? {};
              final userRole = userData['role'];

              print('Retrieved saved session with role: $userRole');

              if (userRole == 'admin') {
                return const AdminDashboardScreen();
              } else {
                return const UserWrapperScreen();
              }
            },
          );
        }

        // Otherwise, use the Firebase auth state stream
        return StreamBuilder<User?>(
          stream: context.read<AuthService>().authStateChanges,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (snapshot.hasData && snapshot.data != null) {
              print('User authenticated: ${snapshot.data!.uid}');
              return FutureBuilder<String>(
                future:
                    context.read<AuthService>().getUserRole(snapshot.data!.uid),
                builder: (context, roleSnapshot) {
                  if (roleSnapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  print('User role: ${roleSnapshot.data}');
                  if (roleSnapshot.data == 'admin') {
                    return const AdminDashboardScreen();
                  }

                  return const UserWrapperScreen();
                },
              );
            }

            print('No authenticated user, showing login screen');
            return const LoginScreen();
          },
        );
      },
    );
  }

  // Check if we have a valid saved session first
  Future<bool> _checkForExistingSession(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      // Check saved prefs first (fastest check)
      final isLoggedIn = await PrefsService.isLoggedIn();
      final savedUserId = await PrefsService.getUserId();
      final savedEmail = await PrefsService.getUserEmail();

      if (isLoggedIn && savedUserId != null && savedEmail != null) {
        print('Found saved login session for user: $savedEmail');

        // Check if Firebase Auth current user matches saved user
        final currentUser = FirebaseAuth.instance.currentUser;

        // If current logged in user doesn't match the saved user, sign out and let them sign in again
        if (currentUser != null && currentUser.uid != savedUserId) {
          print('Current user does not match saved user, signing out');
          await FirebaseAuth.instance.signOut();
          await PrefsService.clearUserSession();
          return false;
        }

        // If current user already matches, then we're good
        if (currentUser != null && currentUser.uid == savedUserId) {
          print('Current Firebase user matches saved user');
          return true;
        }

        // If we have saved credentials but no current user, consider session invalid
        if (currentUser == null) {
          print('No current Firebase user, but have saved credentials');
          return true; // Still return true to use saved preferences for navigation
        }

        return true;
      }

      // No saved session
      return false;
    } catch (e) {
      print('Error checking existing session: $e');
      return false;
    }
  }
}
