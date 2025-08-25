import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  String _email = '';
  
  bool get isAuthenticated => _isAuthenticated;
  String get email => _email;

  Future<bool> login(String email, String password) async {
    // In a real app, you would validate credentials against a backend
    // For this example, we'll accept any non-empty values
    if (email.isNotEmpty && password.isNotEmpty) {
      _isAuthenticated = true;
      _email = email;
      
      // Store authentication state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAuthenticated', true);
      await prefs.setString('email', email);
      
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _email = '';
    
    // Clear authentication state
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAuthenticated', false);
    await prefs.remove('email');
    
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
    _email = prefs.getString('email') ?? '';
    notifyListeners();
  }
}