import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInResult {
  final bool success;
  final User? user;
  final String? idToken;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final String? errorMessage;

  const GoogleSignInResult({
    required this.success,
    this.user,
    this.idToken,
    this.email,
    this.displayName,
    this.photoUrl,
    this.errorMessage,
  });

  factory GoogleSignInResult.failure(String message) =>
      GoogleSignInResult(success: false, errorMessage: message);
}

class GoogleAuthService {
  static final GoogleAuthService _instance = GoogleAuthService._internal();
  factory GoogleAuthService() => _instance;
  GoogleAuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _webClientId =
      '250732932207-625mspf9laratikbvf5rr9dlp7pcd7bq.apps.googleusercontent.com';

  Future<GoogleSignInResult> signInWithGoogle(BuildContext context) async {
    try {
      if (kIsWeb) {
        return await _signInWeb();
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        return await _signInAndroid();
      } else {
        return await _signInIOS();
      }
    } catch (e) {
      print('Google Sign-In Error: $e');
      return GoogleSignInResult.failure(e.toString());
    }
  }

  // ─── Android ─────────────────────────────────────────────────────────────────
  Future<GoogleSignInResult> _signInAndroid() async {
    // initialize در main.dart صدا زده شده، اینجا فقط authenticate
    final googleUser = await GoogleSignIn.instance.authenticate();

    final googleAuth = googleUser.authentication;
    final idToken = googleAuth.idToken;

    if (idToken == null) {
      return GoogleSignInResult.failure('Failed to get ID token');
    }

    // accessToken برای Android اختیاریه ولی بهتره بگیریم
    String? accessToken;
    try {
      final clientAuth = await googleUser.authorizationClient
          .authorizeScopes(['email', 'profile']);
      accessToken = clientAuth.accessToken;
    } catch (_) {}

    return _toFirebase(idToken, accessToken);
  }

  // ─── iOS ──────────────────────────────────────────────────────────────────────
  Future<GoogleSignInResult> _signInIOS() async {
    // در iOS ابتدا lightweight امتحان کن
    GoogleSignIn.instance.attemptLightweightAuthentication();

    final completer = Completer<GoogleSignInAccount?>();
    late StreamSubscription sub;

    sub = GoogleSignIn.instance.authenticationEvents.listen(
          (event) {
        if (completer.isCompleted) return;
        if (event is GoogleSignInAuthenticationEventSignIn) {
          completer.complete(event.user);
        } else if (event is GoogleSignInAuthenticationEventSignOut) {
          completer.complete(null);
        }
        sub.cancel();
      },
      onError: (e) {
        if (!completer.isCompleted) completer.completeError(e);
        sub.cancel();
      },
    );

    // اگر lightweight کار نکرد، authenticate صدا بزن
    GoogleSignInAccount? googleUser;
    try {
      googleUser = await completer.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () => null,
      );
    } catch (_) {}

    // اگر lightweight جواب نداد، برو سراغ authenticate
    if (googleUser == null) {
      sub.cancel();
      if (GoogleSignIn.instance.supportsAuthenticate()) {
        googleUser = await GoogleSignIn.instance.authenticate();
      } else {
        return GoogleSignInResult.failure('iOS authentication not supported');
      }
    }

    final googleAuth = googleUser.authentication;
    final idToken = googleAuth.idToken;
    if (idToken == null) {
      return GoogleSignInResult.failure('Failed to get ID token');
    }

    String? accessToken;
    try {
      final clientAuth = await googleUser.authorizationClient
          .authorizeScopes(['email', 'profile']);
      accessToken = clientAuth.accessToken;
    } catch (_) {}

    return _toFirebase(idToken, accessToken);
  }

  // ─── Web ──────────────────────────────────────────────────────────────────────
  Future<GoogleSignInResult> _signInWeb() async {
    final provider = GoogleAuthProvider();
    provider.addScope('email');
    provider.addScope('profile');

    // Popup روی وب
    final userCredential = await _auth.signInWithPopup(provider);
    final user = userCredential.user;

    if (user == null) return GoogleSignInResult.failure('Firebase sign-in failed');

    // idToken برای ارسال به سرور
    final idToken = await user.getIdToken();

    return GoogleSignInResult(
      success: true,
      user: user,
      idToken: idToken,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }

  // ─── Firebase ─────────────────────────────────────────────────────────────────
  Future<GoogleSignInResult> _toFirebase(String idToken, String? accessToken) async {
    final credential = GoogleAuthProvider.credential(
      idToken: idToken,
      accessToken: accessToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user;

    if (user == null) return GoogleSignInResult.failure('Firebase sign-in failed');

    return GoogleSignInResult(
      success: true,
      user: user,
      idToken: idToken,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }

  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      GoogleSignIn.instance.signOut(),
    ]);
  }

  User? get currentUser => _auth.currentUser;
  bool get isSignedIn => _auth.currentUser != null;
}