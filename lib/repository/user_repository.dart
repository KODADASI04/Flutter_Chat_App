import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_canli_sohbet_uygulamasi/models/active_chats_model.dart';
import 'package:flutter_canli_sohbet_uygulamasi/models/message_model.dart';
import 'package:flutter_canli_sohbet_uygulamasi/models/user_model.dart';
import 'package:flutter_canli_sohbet_uygulamasi/services/db_services/firestore_db_service.dart';
import 'package:flutter_canli_sohbet_uygulamasi/services/notification_service.dart';
import 'package:flutter_canli_sohbet_uygulamasi/services/storage_services/firestorage_services.dart';
import 'package:flutter_canli_sohbet_uygulamasi/services/storage_services/storaga_base.dart';
import 'package:jiffy/jiffy.dart';

import '../locator.dart';
import '../services/auth_services/auth_base.dart';
import '../services/auth_services/fake_auth_service.dart';
import '../services/auth_services/firebase_auth_service.dart';

enum AppMode {
  debug,
  release,
}

class UserRepository implements AuthBase, StorageBase {
  AppMode appMode = AppMode.release;

  final FirebaseAuthService _firebaseAuthService =
      locator<FirebaseAuthService>();
  final FakeAuthenticationService _fakeAuthService =
      locator<FakeAuthenticationService>();
  final FirestoreDBService _firestoreDBService = locator<FirestoreDBService>();
  final FirestorageService _firestorageService = locator<FirestorageService>();

  final NotificationService _notificationService =
      locator<NotificationService>();

  List<UserModel> allUsers = [];

  Map<String, String> allTokens = {};

  @override
  Future<UserModel?> currentUser() async {
    if (appMode == AppMode.debug) {
      return _fakeAuthService.currentUser();
    } else {
      UserModel? user = await _firebaseAuthService.currentUser();
      if (user != null) {
        return await _firestoreDBService.readUser(user.userID);
      } else {
        return null;
      }
    }
  }

  @override
  Future<UserModel?> signInAnonymously() async {
    if (appMode == AppMode.debug) {
      return await _fakeAuthService.signInAnonymously();
    } else {
      UserModel? user = await _firebaseAuthService.signInAnonymously();
      bool sonuc = await _firestoreDBService.saveUser(user!);
      if (sonuc) {
        return _firestoreDBService.readUser(user.userID);
      } else {
        return null;
      }
    }
  }

  @override
  Future<bool> signOut() async {
    if (appMode == AppMode.debug) {
      return await _fakeAuthService.signOut();
    } else {
      return await _firebaseAuthService.signOut();
    }
  }

  @override
  Future<UserModel?> signInWithGoogle() async {
    if (appMode == AppMode.debug) {
      return await _fakeAuthService.signInWithGoogle();
    } else {
      UserModel? user = await _firebaseAuthService.signInWithGoogle();
      if (user != null) {
        bool sonuc = await _firestoreDBService.saveUser(user);
        if (sonuc) {
          return _firestoreDBService.readUser(user.userID);
        } else {
          await _firebaseAuthService.signOut();
          return null;
        }
      } else {
        return null;
      }
    }
  }

  @override
  Future<UserModel?> signInWithFacebook() async {
    if (appMode == AppMode.debug) {
      return await _fakeAuthService.signInWithFacebook();
    } else {
      UserModel? user = await _firebaseAuthService.signInWithFacebook();
      if (user != null) {
        bool sonuc = await _firestoreDBService.saveUser(user);
        if (sonuc) {
          return _firestoreDBService.readUser(user.userID);
        } else {
          _firebaseAuthService.signOut();
          return null;
        }
      } else {
        return null;
      }
    }
  }

  @override
  Future<UserModel?> createUserWithEmail(String email, String sifre) async {
    if (appMode == AppMode.debug) {
      return await _fakeAuthService.createUserWithEmail(email, sifre);
    } else {
      UserModel? user =
          await _firebaseAuthService.createUserWithEmail(email, sifre);
      if (user != null) {
        bool sonuc = await _firestoreDBService.saveUser(user);
        if (sonuc) {
          return _firestoreDBService.readUser(user.userID);
        } else {
          return null;
        }
      } else {
        return null;
      }
    }
  }

  @override
  Future<UserModel?> signInWithEmail(String email, String sifre) async {
    if (appMode == AppMode.debug) {
      return await _fakeAuthService.signInWithEmail(email, sifre);
    } else {
      UserModel? user =
          await _firebaseAuthService.signInWithEmail(email, sifre);
      if (user != null) {
        return _firestoreDBService.readUser(user.userID);
      } else {
        return null;
      }
    }
  }

  @override
  Future<String> uploadFile(String userID, String fileType, File file) async {
    if (appMode == AppMode.debug) {
      return "";
    } else {
      String link =
          await _firestorageService.uploadFile(userID, fileType, file);
      return link;
    }
  }

  Future<bool> updateUsername(String userID, String newUsername) async {
    if (appMode == AppMode.debug) {
      return false;
    } else {
      bool sonuc =
          await _firestoreDBService.updateUsername(userID, newUsername);
      return sonuc;
    }
  }

  Stream<List<MessageModel>> getMessages(
      String currentUserID, String chatUserID) {
    if (appMode == AppMode.debug) {
      return const Stream.empty();
    } else {
      Stream<List<MessageModel>> allUsers =
          _firestoreDBService.getMessages(currentUserID, chatUserID);
      return allUsers;
    }
  }

  Future<List<ActiveChatsModel>> getActiveChats(String currentUserID) async {
    if (appMode == AppMode.debug) {
      return [];
    } else {
      List<ActiveChatsModel> activeChats =
          await _firestoreDBService.getActiveChats(currentUserID);

      DateTime time = await _firestoreDBService.showTime(currentUserID);

      for (ActiveChatsModel chat in activeChats) {
        UserModel? userInUserList = findUserInList(chat.chatReceiver);
        if (userInUserList != null) {
          chat.chatUserUsername = userInUserList.username;
          chat.chatUserProfilePhotoUrl = userInUserList.profilPhotoUrl;
        } else {
          UserModel readUser =
              (await _firestoreDBService.readUser(chat.chatReceiver))!;
          chat.chatUserUsername = readUser.username;
          chat.chatUserProfilePhotoUrl = readUser.profilPhotoUrl;
        }
        await Jiffy.locale("tr");
        String timeDifference = Jiffy(time).from(chat.createdAt!.toDate());
        chat.timeDifference =
            "${timeDifference.substring(0, timeDifference.indexOf("içinde"))}önce";
      }
      return activeChats;
    }
  }

  UserModel? findUserInList(String userID) {
    for (UserModel user in allUsers) {
      if (user.userID == userID) {
        return user;
      }
    }
    return null;
  }

  Future<bool> saveMessage(MessageModel message, UserModel currentUser) async {
    if (appMode == AppMode.debug) {
      return true;
    } else {
      bool dbWriteResult = await _firestoreDBService.saveMessage(message);
      if (dbWriteResult) {
        String? token = "";
        if (allTokens.containsKey(message.outgoingPersonID)) {
          token = allTokens[message.outgoingPersonID]!;
        } else {
          DocumentSnapshot snapshot = await FirebaseFirestore.instance
              .doc("tokens/${message.outgoingPersonID}")
              .get();
          if (snapshot.data() != null) {
            allTokens[message.outgoingPersonID] =
                (snapshot.data() as Map<String, dynamic>)["token"];
            token = allTokens[message.outgoingPersonID]!;
          } else {
            token = "";
          }
        }
        //await _notificationService.sendNotification(message, currentUser, token);
      }
      return dbWriteResult;
    }
  }

  Future<List<UserModel>> getUsersWithPagination(
      String currentUsername, UserModel? lastUser, int bringItemCount) async {
    if (appMode == AppMode.debug) {
      return [];
    } else {
      List<UserModel> newUsers =
          await _firestoreDBService.getUsersWithPagination(
        currentUsername,
        lastUser,
        bringItemCount,
      );
      allUsers.addAll(newUsers);
      return newUsers;
    }
  }

  Future<List<MessageModel>> getMessagesWithPagination(
    String currentUserID,
    String chatUserID,
    MessageModel? lastMessage,
    int bringItemCount,
  ) async {
    if (appMode == AppMode.debug) {
      return [];
    } else {
      return await _firestoreDBService.getMessagesWithPagination(
        currentUserID,
        chatUserID,
        lastMessage,
        bringItemCount,
      );
    }
  }
}
