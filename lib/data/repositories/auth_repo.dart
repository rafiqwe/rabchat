import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:rabchats/data/model/user_model.dart';
import 'package:rabchats/data/services/auth_repository.dart';

class AuthRepo extends BaseRepository {

  Stream<User?>? get authStateChanges => auth.authStateChanges();

  Future<UserModel> signUp({
    required String username,
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    try {

      final userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user == null) {
        throw 'Failed to create user';
      }

      final formattedPhone = phoneNumber.replaceAll(RegExp(r'\s+'), ' '.trim());

      final user = UserModel(
        uid: userCredential.user!.uid,
        username: username,
        fullName: fullName,
        email: email,
        phoneNumber: formattedPhone,
      );
      await saveUserData(user);
      return user;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<UserModel> signIn({
    required String uid,
    required String username,
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw 'Failed to fetch user data';
      }

     final userData =  await getUserData(userCredential.user!.uid);
      return userData;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<UserModel> getUserData(String uid) async {
    final userDoc = await firebaseStore.collection('Users').doc(uid).get();
    if (!userDoc.exists) {
      throw 'User not found';
    }
    return UserModel.fromFirestore(userDoc);
  }

  Future<void> saveUserData(UserModel user) async {
    try {
      firebaseStore.collection('Users').doc(user.uid).set(user.toMap());
    } catch (e) {
      throw 'Failed to save user data';
    }
  }
}
