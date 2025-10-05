import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Stream for auth state changes - Provider can listen to this
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Current user getter
  User? get currentUser => _auth.currentUser;

  // Sign in with email and password
  // Add this method to find email by username
Future<String?> _findEmailByUsername(String username) async {
  try {
    final query = await _firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();
    
    if (query.docs.isNotEmpty) {
      return query.docs.first.data()['email'] as String?;
    }
    return null;
  } catch (e) {
    print('Error finding email by username: $e');
    return null;
  }
}

// Update the existing signInWithEmailAndPassword method to support username
Future<User?> signInWithEmailAndPassword(String emailOrUsername, String password) async {
  try {
    String email = emailOrUsername;
    
    // Check if input is a username (not containing @)
    if (!emailOrUsername.contains('@')) {
      final foundEmail = await _findEmailByUsername(emailOrUsername);
      if (foundEmail == null) {
        throw 'No account found with this username';
      }
      email = foundEmail;
    }
    
    UserCredential credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return credential.user;
  } on FirebaseAuthException catch (e) {
    throw _handleAuthException(e);
  } catch (e) {
    throw e.toString(); // Re-throw custom errors
  }
}

  // Sign up with email and password
  Future<User?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
    required String gender,
    String accountType = 'individual',
  }) async {
    try {
      print('🚀 Starting sign-up process...');
      print('📧 Email: $email');
      print('👤 Username: $username');
      
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      print('✅ Firebase Auth user created: ${credential.user?.uid}');

      if (credential.user != null) {
        try {
          print('📝 Creating Firestore document...');
          await _firestore.collection('users').doc(credential.user!.uid).set({
            'username': username,
            'email': email.trim(),
            'gender': gender,
            'accountType': accountType,
            'createdAt': FieldValue.serverTimestamp(),
            'profileImageUrl': '',
          });
          print('✅ Firestore document created successfully!');
          print('🔍 Document path: users/${credential.user!.uid}');
        } catch (firestoreError) {
          print('❌ Firestore error: $firestoreError');
          // Don't throw here - we still want to return the user even if Firestore fails
        }
      }

      return credential.user;
    } on FirebaseAuthException catch (e) {
      print('❌ Firebase Auth error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Password reset
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email': return 'Invalid email address';
      case 'user-disabled': return 'This account has been disabled';
      case 'user-not-found': return 'No account found with this email';
      case 'wrong-password': return 'Incorrect password';
      case 'email-already-in-use': return 'An account already exists with this email';
      case 'weak-password': return 'Password is too weak';
      default: return 'Authentication failed: ${e.message}';
    }
  }
}