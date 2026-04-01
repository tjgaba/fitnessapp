import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService([FirebaseAuth? firebaseAuth])
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;

  User? get currentUser => _firebaseAuth.currentUser;
  bool get isSignedIn => currentUser != null;
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<User?> register(String email, String password) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (error) {
      throw Exception(_mapAuthError(error.code));
    } catch (_) {
      throw Exception(_mapAuthError(null));
    }
  }

  Future<User?> login(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (error) {
      throw Exception(_mapAuthError(error.code));
    } catch (_) {
      throw Exception(_mapAuthError(null));
    }
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (error) {
      throw Exception(_mapAuthError(error.code));
    } catch (_) {
      throw Exception(_mapAuthError(null));
    }
  }

  Future<void> reloadCurrentUser() async {
    final user = currentUser;
    if (user == null) {
      return;
    }

    try {
      await user.reload();
    } on FirebaseAuthException catch (error) {
      throw Exception(_mapAuthError(error.code));
    } catch (_) {
      throw Exception(_mapAuthError(null));
    }
  }

  String _mapAuthError(String? code) {
    switch (code) {
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'user-disabled':
        return 'This account has been disabled. Contact support.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait and try again.';
      case 'network-request-failed':
        return 'No internet connection. Check your network.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
