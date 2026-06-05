import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';
import '../models/user_model.dart';

class AuthService {
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  Stream<User?> get userChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _db.collection(AppConstants.usersCollection).doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
    } catch (e) {
      print('Error fetching user profile: $e');
    }
    return null;
  }

  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> register(String email, String password, String name, {String? centerId}) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    if (cred.user != null) {
      await _db.collection(AppConstants.usersCollection).doc(cred.user!.uid).set({
        'email': email,
        'name': name,
        'role': 'admin', // Default role for testing
        'centerId': centerId ?? AppConstants.defaultCenterId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    return cred;
  }

  Future<String?> getUserCenterId() async {
    if (currentUser == null) return null;
    try {
      final doc = await _db.collection(AppConstants.usersCollection).doc(currentUser!.uid).get();
      if (doc.exists) {
        return doc.data()?['centerId'] as String?;
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
