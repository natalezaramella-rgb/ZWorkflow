import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/constants/firestore_paths.dart';
import '../domain/models/app_user.dart';

/// Repository that handles authentication via Firebase Auth
/// and user profile data from Firestore.
class AuthRepository {
  /// Creates an [AuthRepository].
  AuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  /// Stream of the current authenticated user.
  ///
  /// Emits [AppUser.empty] when the user is not authenticated.
  Stream<AppUser> get userStream {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return AppUser.empty;
      return _getUserProfile(firebaseUser.uid);
    });
  }

  /// Returns the current authenticated user, or [AppUser.empty].
  Future<AppUser> get currentUser async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return AppUser.empty;
    return _getUserProfile(firebaseUser.uid);
  }

  /// Signs in with email and password.
  Future<AppUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (credential.user == null) return AppUser.empty;
    return _getUserProfile(credential.user!.uid);
  }

  /// Creates a new account with email and password.
  Future<AppUser> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;
    if (user == null) return AppUser.empty;

    await user.updateDisplayName(displayName);

    // Create user profile in Firestore
    final appUser = AppUser(
      uid: user.uid,
      email: email,
      displayName: displayName,
    );

    await _firestore
        .collection(FirestorePaths.users)
        .doc(user.uid)
        .set(appUser.toFirestore());

    return appUser;
  }

  /// Signs in with Google.
  Future<AppUser> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw AppAuthException(
        code: 'sign-in-cancelled',
        message: 'Google sign-in was cancelled.',
      );
    }

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential =
        await _firebaseAuth.signInWithCredential(credential);
    final user = userCredential.user;
    if (user == null) return AppUser.empty;

    // Check if user profile exists, create if not
    final docRef = _firestore.collection(FirestorePaths.users).doc(user.uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      final appUser = AppUser(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? '',
      );
      await docRef.set(appUser.toFirestore());
      return appUser;
    }

    return _getUserProfile(user.uid);
  }

  /// Signs out from all providers.
  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  /// Fetches the user profile from Firestore.
  Future<AppUser> _getUserProfile(String uid) async {
    final doc =
        await _firestore.collection(FirestorePaths.users).doc(uid).get();

    if (!doc.exists) {
      // User exists in Firebase Auth but not in Firestore
      final firebaseUser = _firebaseAuth.currentUser;
      return AppUser(
        uid: uid,
        email: firebaseUser?.email ?? '',
        displayName: firebaseUser?.displayName ?? '',
      );
    }

    return AppUser.fromFirestore(doc.data()!);
  }
}

/// Custom exception for Auth errors.
class AppAuthException implements Exception {
  /// Creates an [AppAuthException].
  const AppAuthException({
    required this.code,
    required this.message,
  });

  /// Error code.
  final String code;

  /// Error message.
  final String message;

  @override
  String toString() => 'AppAuthException($code): $message';
}
