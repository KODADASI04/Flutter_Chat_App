import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_canli_sohbet_uygulamasi/locator.dart';
import 'package:flutter_canli_sohbet_uygulamasi/models/user_model.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'auth_base.dart';

class FirebaseAuthService implements AuthBase {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = locator<GoogleSignIn>();

  @override
  Future<UserModel?> currentUser() async{
    User? user = _firebaseAuth.currentUser;

    return UserModel.userFromFirebase(user);
  }

  @override
  Future<UserModel?> signInAnonymously() async {
    try {
      UserCredential sonuc = await _firebaseAuth.signInAnonymously();
      return UserModel.userFromFirebase(sonuc.user);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> signOut() async {
    try {
      if (_googleSignIn.currentUser != null) {
        await _googleSignIn.disconnect();
      } else if (await FacebookAuth.instance.accessToken != null) {
        await FacebookAuth.instance.logOut();
      }
      await _firebaseAuth.signOut();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          accessToken: googleAuth.accessToken,
        );
        UserCredential user =
            await _firebaseAuth.signInWithCredential(credential);
        return UserModel.userFromFirebase(user.user);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  @override
  Future<UserModel?> signInWithFacebook() async {
    try {
      LoginResult result = await FacebookAuth.instance.login(
        permissions: ["public_profile", "email"],
      );
      switch (result.status) {
        case LoginStatus.success:
          if (result.accessToken != null) {
            UserCredential? user = await _firebaseAuth.signInWithCredential(
              FacebookAuthProvider.credential(result.accessToken!.token),
            );
            return UserModel.userFromFirebase(user.user);
          } else {
            return null;
          }

        case LoginStatus.operationInProgress:
          return null;
        case LoginStatus.cancelled:
          return null;
        case LoginStatus.failed:
          return null;
      }
    } catch (e) {
      return null;
    }
  }

  @override
  Future<UserModel?> createUserWithEmail(String email, String sifre) async {
    UserCredential user = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: sifre,
    );
    return UserModel.userFromFirebase(user.user);
  }

  @override
  Future<UserModel?> signInWithEmail(String email, String sifre) async {
    UserCredential user = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: sifre,
    );
    return UserModel.userFromFirebase(user.user);
  }
}
