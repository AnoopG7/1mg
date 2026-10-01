import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../core/services/firestore_service.dart';

class AuthProvider extends ChangeNotifier {
  final _ready = Completer<void>();

  AuthProvider() {
    _subscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      _user = user;
      _loading = false;
      if (!_ready.isCompleted) _ready.complete();
      if (user != null) {
        unawaited(_syncUserDocument(user));
        unawaited(FirestoreService.seedCatalogue());
      }
      notifyListeners();
    });
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<User?>? _subscription;
  User? _user;
  bool _loading = true;
  String? _errorMessage;

  User? get user => _user;
  bool get loading => _loading;
  bool get isSignedIn => _user != null;
  String? get errorMessage => _errorMessage;
  Future<void> get ready => _ready.future;
  String? get accountName {
    final displayName = _user?.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) return displayName;
    final emailName = _user?.email?.split('@').first.trim();
    if (emailName == null || emailName.isEmpty) return null;
    return emailName
        .split(RegExp(r'[._-]+'))
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  Future<bool> signIn(String email, String password) async {
    return _run(
      () => _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      ),
    );
  }

  Future<bool> register(String name, String email, String password) async {
    return _run(() async {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await credential.user?.updateDisplayName(name.trim());
      await credential.user?.reload();
      return credential;
    });
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> _syncUserDocument(User user) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'displayName': user.displayName,
        'email': user.email,
        'lastLoginAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on FirebaseException {
      // Authentication should remain usable if Firestore is unavailable.
    }
  }

  Future<bool> _run(Future<UserCredential> Function() action) async {
    _errorMessage = null;
    _loading = true;
    notifyListeners();
    try {
      final credential = await action();
      _user = _auth.currentUser ?? credential.user;
      if (_user != null) await _syncUserDocument(_user!);
      return true;
    } on FirebaseAuthException catch (error) {
      _errorMessage = _messageFor(error.code);
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  String _messageFor(String code) {
    switch (code) {
      case 'invalid-credential':
      case 'invalid-login-credentials':
        return 'The email or password is incorrect.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Use a password with at least 6 characters.';
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'network-request-failed':
        return 'Network unavailable. Please try again.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
