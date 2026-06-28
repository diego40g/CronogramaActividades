import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  User? get currentFirebaseUser;

  Stream<User?> get authStateChanges;

  Future<UserModel> signInWithGoogle();

  Future<void> signOut();

  Future<UserModel> getUser(String userId);

  Future<UserModel> createUser(UserModel user);

  Future<UserModel> updateUser(UserModel user);

  Future<void> updateFcmToken(String userId, String token);
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  AuthRemoteDataSourceImpl(
    this._firebaseAuth,
    this._firestore,
    this._googleSignIn,
  );

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection('users');

  @override
  User? get currentFirebaseUser => _firebaseAuth.currentUser;

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthException(message: 'Google sign in aborted');
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw const AuthException(message: 'Failed to sign in with Google');
      }

      // Check if user exists in Firestore
      final userDoc = await _usersRef.doc(firebaseUser.uid).get();

      if (userDoc.exists) {
        return UserModel.fromFirestore(userDoc);
      }

      // Create new user
      final newUser = UserModel(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName,
        photoURL: firebaseUser.photoURL,
        settings: const UserSettingsModel(),
        createdAt: DateTime.now(),
      );

      await _usersRef.doc(firebaseUser.uid).set(newUser.toFirestore());
      return newUser;
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: e.message ?? 'Authentication failed', code: e.code);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(message: e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw AuthException(message: 'Failed to sign out: $e');
    }
  }

  @override
  Future<UserModel> getUser(String userId) async {
    try {
      final doc = await _usersRef.doc(userId).get();
      if (!doc.exists) {
        throw const NotFoundException(message: 'User not found');
      }
      return UserModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to get user');
    }
  }

  @override
  Future<UserModel> createUser(UserModel user) async {
    try {
      await _usersRef.doc(user.id).set(user.toFirestore());
      return user;
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to create user');
    }
  }

  @override
  Future<UserModel> updateUser(UserModel user) async {
    try {
      await _usersRef.doc(user.id).update(user.toFirestore());
      return user;
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to update user');
    }
  }

  @override
  Future<void> updateFcmToken(String userId, String token) async {
    try {
      await _usersRef.doc(userId).update({'fcmToken': token});
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to update FCM token');
    }
  }
}
