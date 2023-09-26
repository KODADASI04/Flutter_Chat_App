import 'package:flutter_canli_sohbet_uygulamasi/models/active_chats_model.dart';
import 'package:flutter_canli_sohbet_uygulamasi/models/message_model.dart';
import 'package:flutter_canli_sohbet_uygulamasi/models/user_model.dart';

abstract class DBBase {
  Future<bool> saveUser(UserModel user);
  Future<UserModel?> readUser(String userID);
  Future<bool> updateUsername(String userID, String newUsername);
  Future<bool> updateProfilePhotoUrl(String userID, String profilePhotoUrl);
  Future<List<UserModel>> getUsersWithPagination(
      String currentUsername, UserModel? lastUser, int bringItemCount);
  Stream<List<MessageModel>> getMessages(
      String currentUserID, String chatUserID);
  Future<bool> saveMessage(MessageModel message);
  Future<List<ActiveChatsModel>> getActiveChats(String currentUserID);
  Future<DateTime> showTime(String currentUserID);
}
