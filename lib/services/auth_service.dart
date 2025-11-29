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

      // Check if user is approved
      if (appUser.status == 'pending') {
        await _auth.signOut();
        throw Exception('Your account is pending approval. Please wait for admin approval.');
      }

      if (appUser.status == 'rejected') {
        await _auth.signOut();
        throw Exception('Your account has been rejected. Please contact admin.');
      }

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
      default:
        return 'Authentication error: ${e.message}';
    }
  }
}
