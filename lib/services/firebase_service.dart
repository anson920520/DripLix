import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Authentication Methods
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<User?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
    required String gender,
    String accountType = 'individual',
  }) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user != null) {
        // Store user profile in Firestore
        await _firestore.collection('users').doc(credential.user!.uid).set({
          'username': username,
          'email': email.trim(),
          'gender': gender,
          'accountType': accountType,
          'createdAt': FieldValue.serverTimestamp(),
          'profileImageUrl': '',
          'followers': 0,
          'following': 0,
        });
      }

      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Image Storage Methods (Pinterest-like functionality)
  Future<String> uploadPostImage(File imageFile, String userId) async {
    try {
      // Create unique filename
      String fileName = 'posts/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // Upload to Firebase Storage
      TaskSnapshot snapshot = await _storage.ref(fileName).putFile(imageFile);
      
      // Get download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw 'Failed to upload image: $e';
    }
  }

  Future<String> uploadProfileImage(File imageFile, String userId) async {
    try {
      String fileName = 'profiles/$userId/profile.jpg';
      TaskSnapshot snapshot = await _storage.ref(fileName).putFile(imageFile);
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      // Update user profile with new image URL
      await _firestore.collection('users').doc(userId).update({
        'profileImageUrl': downloadUrl,
      });
      
      return downloadUrl;
    } catch (e) {
      throw 'Failed to upload profile image: $e';
    }
  }

  // Post Management (Pinterest-like posts)
  Future<void> createPost({
    required String userId,
    required String imageUrl,
    required String description,
    List<String> tags = const [],
  }) async {
    try {
      await _firestore.collection('posts').add({
        'userId': userId,
        'imageUrl': imageUrl,
        'description': description,
        'tags': tags,
        'likes': 0,
        'saves': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'commentsCount': 0,
      });
    } catch (e) {
      throw 'Failed to create post: $e';
    }
  }

  // Get posts for feed (like Pinterest)
  Stream<QuerySnapshot> getPostsFeed() {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Get user's posts
  Stream<QuerySnapshot> getUserPosts(String userId) {
    return _firestore
        .collection('posts')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // User management
  Future<Map<String, dynamic>> getUserData(String userId) async {
    DocumentSnapshot snapshot = await _firestore.collection('users').doc(userId).get();
    return snapshot.data() as Map<String, dynamic>;
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;
  Future<void> signOut() => _auth.signOut();

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email': return 'Invalid email address';
      case 'user-disabled': return 'This account has been disabled';
      case 'user-not-found': return 'No account found with this email';
      case 'wrong-password': return 'Incorrect password';
      case 'email-already-in-use': return 'An account already exists with this email';
      case 'weak-password': return 'Password is too weak';
      case 'operation-not-allowed': return 'Email/password accounts are not enabled';
      default: return 'Authentication failed: ${e.message}';
    }
  }
}