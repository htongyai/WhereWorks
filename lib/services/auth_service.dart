import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  auth.User? get currentUser => _auth.currentUser;

  // Sign in with email and password
  Future<auth.UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Sign up with email and password
  Future<auth.UserCredential> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required DateTime dateOfBirth,
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Create user profile in Firestore
    await _firestore.collection('users').doc(userCredential.user!.uid).set({
      'id': userCredential.user!.uid,
      'name': name,
      'email': email,
      'phone': phone,
      'dateOfBirth': dateOfBirth,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return userCredential;
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data();
  }

  // Update user profile
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }

  Future<void> deleteAccount() async {
    try {
      final user = auth.FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Delete user data from Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
        
        // Delete user's saved places
        final savedPlacesSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('saved_places')
            .get();
        
        for (var doc in savedPlacesSnapshot.docs) {
          await doc.reference.delete();
        }
        
        // Delete the user account
        await user.delete();
      }
    } catch (e) {
      print('Error deleting account: $e');
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    await auth.FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }
} 