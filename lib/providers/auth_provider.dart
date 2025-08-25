import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  User? _user;
  bool _isLoading = false;
  String _errorMessage = '';
  
  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String get email => _user?.email ?? '';
  String get errorMessage => _errorMessage;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<UserCredential?> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);
      
      // Store authentication state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAuthenticated', true);
      
      _user = userCredential.user;  // Make sure user is set
      _isLoading = false;
      notifyListeners();
      return userCredential;
    } catch (e) {
      _isLoading = false;
      
      // Handle specific error cases
      if (e is FirebaseAuthException) {
        _errorMessage = "Firebase Auth Error: ${e.message}";
      } else {
        _errorMessage = "Error signing in: $e";
      }
      
      debugPrint("Google Sign-In Error: $e");
      notifyListeners();
      return null;
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      
      // Clear authentication state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAuthenticated', false);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> checkAuthStatus() async {
    _user = _auth.currentUser;
    notifyListeners();
  }
}