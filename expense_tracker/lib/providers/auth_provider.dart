import 'package:expense_tracker/services/auth_service.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;
  AuthService get authService => _authService;

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _authService.signInWithEmail(email: email, password: password);
      _isLoading = false;
      notifyListeners();
      return true;
    } on Exception catch (e) {
      _isLoading = false;
      final match = RegExp(r'\(([^)]+)\)').firstMatch(e.toString());
      final errorCode = match?.group(1) ?? 'unknown';
      _error = _authService.getErrorMessage(errorCode);
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(String email, String password, String name) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _authService.signUpWithEmail(
          email: email, password: password, name: name);
      _isLoading = false;
      notifyListeners();
      return true;
    } on Exception catch (e) {
      _isLoading = false;
      final match = RegExp(r'\(([^)]+)\)').firstMatch(e.toString());
      final errorCode = match?.group(1) ?? 'unknown';
      _error = _authService.getErrorMessage(errorCode);
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInAnonymously() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _authService.signInAnonymously();
      _isLoading = false;
      notifyListeners();
      return true;
    } on Exception catch (e) {
      _isLoading = false;
      final match = RegExp(r'\(([^)]+)\)').firstMatch(e.toString());
      final errorCode = match?.group(1) ?? 'unknown';
      _error = _authService.getErrorMessage(errorCode);
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
