import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';
import '../models/user_role.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<AppUser?> getCurrentUserData() async {
    final user = currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;

    return AppUser.fromFirestore(doc);
  }

  Future<AppUser> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userDoc = await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      if (!userDoc.exists) {
        await _auth.signOut();
        throw Exception('User data not found');
      }

      final appUser = AppUser.fromFirestore(userDoc);

      // Check if user is blocked
      if (appUser.status == 'blocked') {
        await _auth.signOut();
        throw Exception('Your account has been blocked. Please contact admin.');
      }

      // Check if user is approved
      if (appUser.status == 'pending') {
        await _auth.signOut();
        throw Exception('Your account is pending approval. Please wait for admin approval.');
      }

      if (appUser.status == 'rejected') {
        await _auth.signOut();
        throw Exception('Your account has been rejected. Please contact admin.');
      }

      // Record login session for multi-device control
      await _recordLoginSession(credential.user!.uid);

      return appUser;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<AppUser> signUp({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? hostelId,
    String? phoneNumber,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = AppUser(
        uid: credential.user!.uid,
        name: name,
        email: email,
        role: role,
        hostelId: hostelId,
        phoneNumber: phoneNumber,
        status: role == UserRole.admin ? 'active' : 'pending',
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(user.toFirestore());

      await credential.user!.updateDisplayName(name);

      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Creates a new user account and returns both the user data and auth credential
  /// The caller is responsible for handling re-authentication
  Future<({AppUser user, String password})> createUserForAdmin({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? hostelId,
    String? phoneNumber,
  }) async {
    try {
      // Create new user (this will automatically sign in as the new user)
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final newUser = AppUser(
        uid: credential.user!.uid,
        name: name,
        email: email,
        role: role,
        hostelId: hostelId,
        phoneNumber: phoneNumber,
        status: role == UserRole.admin ? 'active' : 'pending',
        createdAt: DateTime.now(),
      );

      // Create user document (authenticated as new user, which is allowed by Firestore rules)
      await _firestore
          .collection('users')
          .doc(newUser.uid)
          .set(newUser.toFirestore());

      await credential.user!.updateDisplayName(name);

      // Return the user data - caller will handle re-authentication and student creation
      return (user: newUser, password: password);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> updateUserProfile({
    String? name,
    String? phoneNumber,
    String? photoUrl,
  }) async {
    final user = currentUser;
    if (user == null) throw Exception('No user logged in');

    final updates = <String, dynamic>{
      'updatedAt': Timestamp.now(),
    };

    if (name != null) {
      updates['name'] = name;
      await user.updateDisplayName(name);
    }

    if (phoneNumber != null) {
      updates['phoneNumber'] = phoneNumber;
    }

    if (photoUrl != null) {
      updates['photoUrl'] = photoUrl;
      await user.updatePhotoURL(photoUrl);
    }

    await _firestore.collection('users').doc(user.uid).update(updates);
  }

  // Block/Unblock Account Features
  Future<void> blockUser(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'status': 'blocked',
        'blockedAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });

      // Add to blocked sessions list
      await _firestore.collection('blocked_sessions').doc(uid).set({
        'uid': uid,
        'blockedAt': Timestamp.now(),
        'reason': 'Account blocked by admin',
      });
    } catch (e) {
      throw Exception('Failed to block user: ${e.toString()}');
    }
  }

  Future<void> unblockUser(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'status': 'active',
        'blockedAt': FieldValue.delete(),
        'updatedAt': Timestamp.now(),
      });

      // Remove from blocked sessions
      await _firestore.collection('blocked_sessions').doc(uid).delete();
    } catch (e) {
      throw Exception('Failed to unblock user: ${e.toString()}');
    }
  }

  // Multi-Device Login Control
  Future<void> _recordLoginSession(String uid) async {
    try {
      final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('sessions')
          .doc(sessionId)
          .set({
        'sessionId': sessionId,
        'loginTime': Timestamp.now(),
        'deviceInfo': await _getDeviceInfo(),
        'isActive': true,
      });

      // Clean up old sessions (keep only last 5)
      await _cleanupOldSessions(uid);
    } catch (e) {
      // Non-critical, just log
      print('Failed to record session: $e');
    }
  }

  Future<Map<String, dynamic>> _getDeviceInfo() async {
    // Basic device info - can be enhanced with device_info_plus package
    return {
      'platform': 'flutter',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  Future<void> _cleanupOldSessions(String uid) async {
    try {
      final sessions = await _firestore
          .collection('users')
          .doc(uid)
          .collection('sessions')
          .orderBy('loginTime', descending: true)
          .get();

      if (sessions.docs.length > 5) {
        // Delete sessions beyond the 5 most recent
        for (var i = 5; i < sessions.docs.length; i++) {
          await sessions.docs[i].reference.delete();
        }
      }
    } catch (e) {
      print('Failed to cleanup old sessions: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getActiveSessions(String uid) async {
    try {
      final sessions = await _firestore
          .collection('users')
          .doc(uid)
          .collection('sessions')
          .where('isActive', isEqualTo: true)
          .orderBy('loginTime', descending: true)
          .get();

      return sessions.docs
          .map((doc) => {
                'sessionId': doc.id,
                ...doc.data(),
              })
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> terminateSession(String uid, String sessionId) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('sessions')
          .doc(sessionId)
          .update({
        'isActive': false,
        'terminatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to terminate session: ${e.toString()}');
    }
  }

  Future<void> terminateAllOtherSessions(String uid) async {
    try {
      final sessions = await _firestore
          .collection('users')
          .doc(uid)
          .collection('sessions')
          .where('isActive', isEqualTo: true)
          .get();

      final currentSessionId = DateTime.now().millisecondsSinceEpoch.toString();

      for (var doc in sessions.docs) {
        // Keep only the most recent session (current one)
        if (doc.id != currentSessionId) {
          await doc.reference.update({
            'isActive': false,
            'terminatedAt': Timestamp.now(),
          });
        }
      }
    } catch (e) {
      throw Exception('Failed to terminate sessions: ${e.toString()}');
    }
  }

  // Enhanced Password Management
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('No user logged in');

      // Re-authenticate user with current password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);

      // Log password change
      await _firestore.collection('users').doc(user.uid).update({
        'passwordChangedAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> adminResetUserPassword(String uid, String newPassword) async {
    try {
      // Note: Firebase Admin SDK required for this in production
      // This is a placeholder - requires backend implementation
      throw Exception(
        'Admin password reset requires Firebase Admin SDK. '
        'Please use the password reset email feature instead.',
      );
    } catch (e) {
      rethrow;
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Wrong password';
      case 'email-already-in-use':
        return 'Email already in use';
      case 'invalid-email':
        return 'Invalid email address';
      case 'weak-password':
        return 'Password is too weak';
      case 'user-disabled':
        return 'This user has been disabled';
      case 'requires-recent-login':
        return 'Please log in again to perform this action';
      default:
        return 'Authentication error: ${e.message}';
    }
  }
}
