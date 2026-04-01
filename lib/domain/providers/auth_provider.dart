import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../data/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authService);

  final AuthService _authService;

  bool _isLoading = false;
  String? _errorMessage;
  String? _sessionExpiredMessage;
  bool _hasShownProfilePromptForSession = false;

  bool get isLoading => _isLoading;
  bool get isSignedIn => _authService.isSignedIn;
  String? get errorMessage => _errorMessage;
  bool get hasError => (_errorMessage ?? '').isNotEmpty;
  String? get userEmail => _authService.currentUser?.email;
  String? get userId => _authService.currentUser?.uid;
  DateTime? get lastSignInTime =>
      _authService.currentUser?.metadata.lastSignInTime;
  Stream<User?> get authStateChanges => _authService.authStateChanges;
  User? get currentUser => _authService.currentUser;
  bool get hasShownProfilePromptForSession => _hasShownProfilePromptForSession;

  void clearError() {
    if (_errorMessage == null) {
      return;
    }
    _errorMessage = null;
    notifyListeners();
  }

  String? consumeSessionExpiredMessage() {
    final message = _sessionExpiredMessage;
    _sessionExpiredMessage = null;
    return message;
  }

  Future<bool> register(String email, String password) async {
    _beginLoading();
    try {
      await _authService.register(email, password);
      return true;
    } catch (error) {
      _errorMessage = _normalizeError(error);
      return false;
    } finally {
      _finishLoading();
    }
  }

  Future<bool> login(String email, String password) async {
    _beginLoading();
    try {
      await _authService.login(email, password);
      return true;
    } catch (error) {
      _errorMessage = _normalizeError(error);
      return false;
    } finally {
      _finishLoading();
    }
  }

  Future<bool> resetPassword(String email) async {
    _beginLoading();
    try {
      await _authService.resetPassword(email);
      return true;
    } catch (error) {
      _errorMessage = _normalizeError(error);
      return false;
    } finally {
      _finishLoading();
    }
  }

  Future<void> logout() async {
    clearError();
    _hasShownProfilePromptForSession = false;
    await _authService.logout();
  }

  Future<bool> validatePersistedSession() async {
    final user = currentUser;
    if (user == null) {
      _hasShownProfilePromptForSession = false;
      return true;
    }

    try {
      await _authService.reloadCurrentUser();
      return true;
    } catch (_) {
      _sessionExpiredMessage = 'Your session has expired. Please sign in again.';
      _hasShownProfilePromptForSession = false;
      await _authService.logout();
      notifyListeners();
      return false;
    }
  }

  void markProfilePromptShown() {
    if (_hasShownProfilePromptForSession) {
      return;
    }
    _hasShownProfilePromptForSession = true;
    notifyListeners();
  }

  void _beginLoading() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
  }

  void _finishLoading() {
    _isLoading = false;
    notifyListeners();
  }

  String _normalizeError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }
}
