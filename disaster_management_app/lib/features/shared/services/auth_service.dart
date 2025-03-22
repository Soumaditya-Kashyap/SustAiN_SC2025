import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../../../core/constants/app_constants.dart';
import 'prefs_service.dart';
import 'dart:async';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      print('Attempting to sign in with email: $email');

      // Try authentication
      UserCredential? result;
      try {
        result = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        print('Successfully signed in with email: $email');

        // Determine user role
        String role = 'user';
        String? name;

        // If admin credentials are used, set admin role
        if (email == 'admin123@gmail.com' && password == '123456') {
          // Set admin role in Firestore
          await _firestore
              .collection(AppConstants.usersCollection)
              .doc(result!.user!.uid)
              .set({
            'isAdmin': true,
            'email': email,
            'fullName': 'Admin User',
            'createdAt': DateTime.now(),
          }, SetOptions(merge: true));

          role = 'admin';
          name = 'Admin User';
          print('Admin user signed in: ${result.user!.uid}');
        } else {
          print('Regular user signed in: ${result!.user!.uid}');
          // Get user details from Firestore for regular users
          final userData = await getUser(result.user!.uid);
          if (userData != null) {
            role = userData.role;
            name = userData.name;
          }
        }

        // Save user session to shared preferences
        await PrefsService.saveUserSession(
          userId: result.user!.uid,
          email: email,
          role: role,
          name: name,
        );
      } catch (authError) {
        print('Auth error: $authError');
        rethrow;
      }

      return result;
    } catch (e) {
      print('Error signing in: $e');
      // If we get a PigeonUserDetails error, return null instead of throwing
      if (e.toString().contains('PigeonUserDetails')) {
        print('Caught PigeonUserDetails error, attempting recovery...');
        // Manual authentication check - verify if the user is logged in despite the error
        await Future.delayed(const Duration(seconds: 1));
        final currentUser = _auth.currentUser;
        if (currentUser != null && currentUser.email == email) {
          print('User is logged in despite error, returning success');

          // Still save the user session if authenticated
          String role = await getUserRole(currentUser.uid);
          await PrefsService.saveUserSession(
            userId: currentUser.uid,
            email: email,
            role: role,
          );

          return null; // Return null but don't throw - will be treated as success
        }
      }
      rethrow;
    }
  }

  // Create user with email and password
  Future<UserCredential?> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      print('Attempting to create user with email: $email');

      // Try creating user
      UserCredential? result;
      try {
        result = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        print('Successfully created user with email: $email');

        // Save the initial user session
        await PrefsService.saveUserSession(
          userId: result.user!.uid,
          email: email,
          role: 'user',
        );
      } catch (authError) {
        print('Auth error: $authError');
        rethrow;
      }

      return result;
    } catch (e) {
      print('Error creating user in Auth: $e');
      // If we get a PigeonUserDetails error, return null instead of throwing
      if (e.toString().contains('PigeonUserDetails')) {
        print('Caught PigeonUserDetails error, attempting recovery...');
        // Manual authentication check - verify if the user is logged in despite the error
        await Future.delayed(const Duration(seconds: 1));
        final currentUser = _auth.currentUser;
        if (currentUser != null && currentUser.email == email) {
          print('User is created despite error, returning success');

          // Still save the user session
          await PrefsService.saveUserSession(
            userId: currentUser.uid,
            email: email,
            role: 'user',
          );

          return null; // Return null but don't throw - will be treated as success
        }
      }
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      print('Signing out user');
      // Clear shared preferences first
      await PrefsService.clearUserSession();
      // Then sign out from Firebase
      await _auth.signOut();
      print('User signed out successfully');
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  // Create user in Firestore
  Future<void> createUser(UserModel user) async {
    try {
      print('Creating user in Firestore with ID: ${user.id}');
      print('User data: ${user.toMap()}');

      // First check if the user document already exists to avoid overwriting
      final docSnapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.id)
          .get();

      if (docSnapshot.exists) {
        print('User document already exists. Updating instead of creating.');
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(user.id)
            .update(user.toMap());
      } else {
        // Create new document
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(user.id)
            .set(user.toMap());
      }

      // Also update the shared preferences with user info
      await PrefsService.saveUserSession(
        userId: user.id,
        email: user.email,
        role: user.role,
        name: user.name,
      );

      print('User successfully created/updated in Firestore');
    } catch (e) {
      print('Error creating user in Firestore: $e');
      print('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  // Get user from Firestore
  Future<UserModel?> getUser(String uid) async {
    try {
      print('Attempting to get user from Firestore with ID: $uid');

      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();

      print('Firestore document exists: ${doc.exists}');
      if (doc.exists) {
        final data = doc.data();
        print('Document data: $data');
        if (data != null) {
          return UserModel.fromMap(data, doc.id);
        } else {
          print('Document exists but data is null');
          return null;
        }
      }
      print('No user found with ID: $uid');
      return null;
    } catch (e) {
      print('Error getting user from Firestore: $e');
      print('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  // Update user in Firestore
  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.id)
          .update(user.toMap());

      // Also update shared preferences with latest user data
      await PrefsService.saveUserSession(
        userId: user.id,
        email: user.email,
        role: user.role,
        name: user.name,
      );
    } catch (e) {
      print('Error updating user in Firestore: $e');
      rethrow;
    }
  }

  // Check if user is admin
  Future<bool> isAdmin(String uid) async {
    try {
      final user = await getUser(uid);
      return user?.role == 'admin';
    } catch (e) {
      print('Error checking admin status: $e');
      return false;
    }
  }

  // Get user role helper method
  Future<String> getUserRole(String uid) async {
    try {
      if (uid == 'admin' || uid == 'h6I1q2qErvYJ4m5BtMDjn2Aj9tx1') {
        // 'h6I1q2qErvYJ4m5BtMDjn2Aj9tx1' is the UID of admin@example.com
        return 'admin';
      }

      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data();
        if (data != null) {
          if (data['isAdmin'] == true) {
            return 'admin';
          }
          return data['role'] ?? 'user';
        }
      }
      return 'user';
    } catch (e) {
      print('Error getting user role: $e');
      return 'user';
    }
  }

  // Check if user is admin by email
  Future<bool> isAdminByEmail(String email) async {
    try {
      if (email == 'admin123@gmail.com') {
        return true;
      }

      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .where('email', isEqualTo: email)
          .where('isAdmin', isEqualTo: true)
          .limit(1)
          .get();

      return userDoc.docs.isNotEmpty;
    } catch (e) {
      print('Error checking admin status by email: $e');
      return false;
    }
  }

  // Restore user session from local storage
  Future<bool> restoreUserSession() async {
    try {
      // Check if already logged in
      final currentFirebaseUser = _auth.currentUser;
      if (currentFirebaseUser != null) {
        print('Firebase Auth already has a user: ${currentFirebaseUser.email}');

        // Get the user role from Firestore
        final role = await getUserRole(currentFirebaseUser.uid);

        // Update shared preferences to match current Firebase user
        await PrefsService.saveUserSession(
          userId: currentFirebaseUser.uid,
          email: currentFirebaseUser.email ?? '',
          role: role,
          name: currentFirebaseUser.displayName,
        );

        print(
            'Restored session for Firebase user: ${currentFirebaseUser.email} with role: $role');
        return true;
      }

      // Check if we have saved credentials
      final isLoggedIn = await PrefsService.isLoggedIn();
      final savedUserId = await PrefsService.getUserId();
      final savedEmail = await PrefsService.getUserEmail();
      final savedPassword = await PrefsService.getSavedPassword();

      if (isLoggedIn &&
          savedUserId != null &&
          savedEmail != null &&
          savedPassword != null) {
        print('Found saved credentials, attempting to sign in: $savedEmail');

        try {
          // Try to sign in with saved credentials
          final result = await _auth.signInWithEmailAndPassword(
            email: savedEmail,
            password: savedPassword,
          );

          if (result.user != null) {
            print('Successfully restored session with saved credentials');

            // Refresh user role from Firestore
            final role = await getUserRole(result.user!.uid);
            await PrefsService.saveUserSession(
              userId: result.user!.uid,
              email: savedEmail,
              role: role,
              name: result.user!.displayName,
            );

            return true;
          }
        } catch (e) {
          print('Failed to sign in with saved credentials: $e');
          // Don't clear the session yet, allow manual login
        }
      }

      print('No session to restore');
      return false;
    } catch (e) {
      print('Error restoring user session: $e');
      return false;
    }
  }

  // Get saved user session data
  Future<Map<String, dynamic>> getSavedUserSession() async {
    return await PrefsService.getUserSession();
  }

  // Create admin user if it doesn't exist
  Future<void> createAdminUserIfNotExists() async {
    const email = 'admin123@gmail.com';
    const password = '123456';

    try {
      // Try to find user with admin email first
      final methods = await _auth.fetchSignInMethodsForEmail(email);

      if (methods.isEmpty) {
        // Email not registered, create the admin user
        print('Creating admin user account...');
        try {
          final userCred = await _auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );

          if (userCred.user != null) {
            // Set admin role in Firestore
            await _firestore
                .collection(AppConstants.usersCollection)
                .doc(userCred.user!.uid)
                .set({
              'email': email,
              'fullName': 'Admin User',
              'isAdmin': true,
              'role': 'admin',
              'createdAt': DateTime.now(),
            });

            print('Admin user created successfully: ${userCred.user!.uid}');
          }
        } catch (e) {
          print('Error creating admin user: $e');
        }
      } else {
        print('Admin user already exists');
      }

      // Sign out after creating admin user
      if (_auth.currentUser?.email == email) {
        await _auth.signOut();
      }
    } catch (e) {
      print('Error checking/creating admin user: $e');
    }
  }

  // Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      print('Fetching user data for ID: $userId');
      final docSnapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();

      if (docSnapshot.exists) {
        print('User data found for ID: $userId');
        return docSnapshot.data();
      } else {
        print('No user data found for ID: $userId');
        return null;
      }
    } catch (e) {
      print('Error getting user data: $e');
      rethrow;
    }
  }
}
