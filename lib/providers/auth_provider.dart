import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseService _firebaseService = FirebaseService();
  User? _user;
  UserModel? _userModel;
  bool _isLoading = true;
  String? _error;
  StreamSubscription? _userSub;
  bool _isBypassed = false;

  User? get user => _user;
  bool get isBypassed => _isBypassed;
  UserModel? get userModel => _isBypassed
      ? UserModel(
          uid: 'dev_bypass_uid',
          email: 'bypass@karunadu.com',
          name: 'Developer Mode',
          role: AppConstants.roleAdmin,
          centerId: AppConstants.defaultCenterId,
          createdAt: DateTime.now(),
        )
      : _userModel;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null || _isBypassed;

  AuthProvider() {
    _initAuthStream();
  }

  void _initAuthStream() {
    try {
      _userSub = _authService.userChanges.listen((User? user) async {
        _user = user;
        if (user != null) {
          await _fetchUserModel(user.uid);
        } else {
          _userModel = null;
        }
        _isLoading = false;
        notifyListeners();
      }, onError: (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      _error = 'Firebase not initialized';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchUserModel(String uid) async {
    try {
      _userModel = await _authService.getUserProfile(uid);
      if (_userModel != null) {
        _firebaseService.setCenterId(_userModel!.centerId);
      }
    } catch (e) {
      _error = 'Failed to load user profile: $e';
    }
  }

  @override
  void dispose() {
    _userSub?.cancel();
    super.dispose();
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      await _authService.signIn(email, password);
      // UserModel will be fetched by the stream listener
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _getAuthErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Something went wrong. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'invalid-credential':
        return 'Invalid email or password';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'network-request-failed':
        return 'No internet connection';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signOut() async {
    _isBypassed = false;
    await _authService.signOut();
    _user = null;
    _userModel = null;
    _error = null;
    notifyListeners();
  }

  void bypassLogin() {
    _isBypassed = true;
    _isLoading = false;
    notifyListeners();
  }
}
