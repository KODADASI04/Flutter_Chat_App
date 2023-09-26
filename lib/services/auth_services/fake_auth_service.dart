import '/models/user_model.dart';
import 'auth_base.dart';

class FakeAuthenticationService implements AuthBase {
  final String _userID = "1234567890";
  @override
  Future<UserModel?> currentUser() async{
    return UserModel(userID: _userID,email: "fakeuser@fake.com");
  }

  @override
  Future<UserModel> signInAnonymously() async {
    return await Future.delayed(
      const Duration(seconds: 2),
      () => UserModel(userID: _userID,email: "fakeuser@fake.com"),
    );
  }

  @override
  Future<bool> signOut() {
    return Future.value(true);
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    return await Future.delayed(
      const Duration(seconds: 2),
      () => UserModel(userID: _userID,email: "fakeuser@fake.com"),
    );
  }

  @override
  Future<UserModel?> signInWithFacebook() async {
    return await Future.delayed(
      const Duration(seconds: 2),
      () => UserModel(userID: _userID,email: "fakeuser@fake.com"),
    );
  }

  @override
  Future<UserModel?> createUserWithEmail(String email, String sifre) async {
    return await Future.delayed(
      const Duration(seconds: 2),
      () => UserModel(userID: _userID,email: "fakeuser@fake.com"),
    );
  }

  @override
  Future<UserModel?> signInWithEmail(String email, String sifre) async {
    return await Future.delayed(
      const Duration(seconds: 2),
      () => UserModel(userID: _userID,email: "fakeuser@fake.com"),
    );
  }
}
