import '../../models/user_model.dart';

abstract class AuthBase {
  Future<UserModel?> currentUser();
  Future<UserModel?> signInAnonymously();
  Future<bool> signOut();
  Future<UserModel?> signInWithGoogle();
  Future<UserModel?> signInWithFacebook();
  Future<UserModel?> signInWithEmail(String email, String sifre);
  Future<UserModel?> createUserWithEmail(String email, String sifre);
}
