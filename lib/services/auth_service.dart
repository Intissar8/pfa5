import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // LOGIN
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  }

  // SIGN UP + CREATE FIRESTORE USER
  Future<User?> signUp({
    required String email,
    required String password,
  }) async {
    // 1. Create auth user
    final result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = result.user;

    if (user != null) {
      // 2. Create Firestore document
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': email,
        'role': 'client',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    return user;
  }
}
