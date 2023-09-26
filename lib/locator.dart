import 'package:flutter_canli_sohbet_uygulamasi/repository/user_repository.dart';
import 'package:flutter_canli_sohbet_uygulamasi/services/db_services/firestore_db_service.dart';
import 'package:flutter_canli_sohbet_uygulamasi/services/notification_service.dart';
import 'package:flutter_canli_sohbet_uygulamasi/services/storage_services/firestorage_services.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'services/auth_services/fake_auth_service.dart';
import 'services/auth_services/firebase_auth_service.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator
      .registerLazySingleton<FirebaseAuthService>(() => FirebaseAuthService());
  locator.registerLazySingleton<FakeAuthenticationService>(
      () => FakeAuthenticationService());
  locator.registerLazySingleton<UserRepository>(() => UserRepository());
  locator.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn());
  locator.registerLazySingleton<FirestoreDBService>(() => FirestoreDBService());
  locator.registerLazySingleton<FirestorageService>(() => FirestorageService());
  locator
      .registerLazySingleton<NotificationService>(() => NotificationService());
}
