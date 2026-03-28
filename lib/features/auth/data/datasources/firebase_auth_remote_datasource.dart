import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../models/user_model.dart';
import 'auth_remote_datasource.dart';

class FirebaseAuthRemoteDataSource implements AuthRemoteDataSource {
  FirebaseAuthRemoteDataSource({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  @override
  Future<UserModel> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw Exception('Unable to sign in. Please try again.');
      }
      return _buildAndSyncUser(user);
    } on FirebaseAuthException catch (e) {
      throw Exception(_authErrorMessage(e));
    }
  }

  @override
  Future<UserModel> signUpWithEmail(
    String email,
    String password,
    String fullName,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw Exception('Unable to create account. Please try again.');
      }

      await user.updateDisplayName(fullName);
      await user.reload();

      return _buildAndSyncUser(
        _auth.currentUser ?? user,
        fallbackName: fullName,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_authErrorMessage(e));
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      // On web, use Firebase popup flow directly.
      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        final userCredential = await _auth.signInWithPopup(provider);
        final webUser = userCredential.user;
        if (webUser == null) {
          throw Exception('Google sign-in failed. Please try again.');
        }
        return _buildAndSyncUser(webUser);
      }

      // On Android/iOS/macOS, use google_sign_in plugin.
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign-in was cancelled.');
      }
      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) {
        throw Exception('Google sign-in failed. Please try again.');
      }

      return _buildAndSyncUser(user);
    } on FirebaseAuthException catch (e) {
      throw Exception(_authErrorMessage(e));
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Future<UserModel> signInWithApple() async {
    if (defaultTargetPlatform != TargetPlatform.iOS &&
        defaultTargetPlatform != TargetPlatform.macOS) {
      throw Exception('Apple sign-in is available only on iOS/macOS.');
    }

    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential = await _auth.signInWithCredential(oauthCredential);
      final user = userCredential.user;
      if (user == null) {
        throw Exception('Apple sign-in failed. Please try again.');
      }

      final resolvedName = _appleFullName(appleCredential) ?? user.displayName;
      return _buildAndSyncUser(user, fallbackName: resolvedName);
    } on FirebaseAuthException catch (e) {
      throw Exception(_authErrorMessage(e));
    } catch (_) {
      throw Exception('Apple sign-in was cancelled or failed.');
    }
  }

  @override
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  @override
  UserModel? get currentUser {
    final user = _auth.currentUser;
    if (user == null) return null;

    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      fullName: user.displayName ?? 'Move Smart User',
      photoUrl: user.photoURL,
    );
  }

  Future<UserModel> _buildAndSyncUser(
    User user, {
    String? fallbackName,
  }) async {
    final docRef = _firestore.collection('users').doc(user.uid);
    final doc = await docRef.get();

    final firestoreName = doc.data()?['fullName'] as String?;
    final fullName =
        user.displayName ?? firestoreName ?? fallbackName ?? 'Move Smart User';
    final token = await user.getIdToken();

    final userModel = UserModel(
      uid: user.uid,
      email: user.email ?? '',
      fullName: fullName,
      photoUrl: user.photoURL,
      authToken: token,
    );

    await docRef.set(
      {
        ...userModel.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
        if (!doc.exists) 'createdAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    return userModel;
  }

  String _authErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Email is invalid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'network-request-failed':
        return 'No internet connection.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }

  String? _appleFullName(AuthorizationCredentialAppleID credential) {
    final givenName = credential.givenName?.trim();
    final familyName = credential.familyName?.trim();
    final names = [
      if (givenName != null && givenName.isNotEmpty) givenName,
      if (familyName != null && familyName.isNotEmpty) familyName,
    ];

    if (names.isEmpty) return null;
    return names.join(' ');
  }
}
