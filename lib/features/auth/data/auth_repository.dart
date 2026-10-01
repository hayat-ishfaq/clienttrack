import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for FirebaseAuth instance.
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

/// Provider for the AuthRepository.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(firebaseAuthProvider));
});

/// Stream provider for user authentication state.
final authStateStreamProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

/// Repository orchestrating authentication lifecycle and Firestore user profile initialization.
class AuthRepository {
  final FirebaseAuth _auth;

  AuthRepository(this._auth);

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  /// Register a new user with email and password, and initialize their profile in Firestore.
  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;
    if (user != null) {
      // Initialize root user profile document under /users/{uid}
      try {
        final firestore = FirebaseFirestore.instance;
        await firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': user.email ?? email.trim(),
          'fullName': '',
          'businessName': '',
          'currencyCode': 'USD',
          'phone': '',
          'logoUrl': null,
          'reminderSharesCount': 0,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e) {
        // Fallback for offline or local cache
      }
    }

    return credential;
  }

  /// Sign in an existing user with email and password.
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Send password reset link to user's email.
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  /// Update user profile details (fullName, businessName, currencyCode).
  Future<void> updateUserProfile({
    required String fullName,
    String? businessName,
    required String currencyCode,
  }) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final firestore = FirebaseFirestore.instance;
        await firestore.collection('users').doc(user.uid).set({
          'fullName': fullName.trim(),
          if (businessName != null && businessName.trim().isNotEmpty)
            'businessName': businessName.trim(),
          'currencyCode': currencyCode.trim(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (_) {
        // Fallback for offline or local cache
      }
    }
  }

  /// Sign out current user.
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
