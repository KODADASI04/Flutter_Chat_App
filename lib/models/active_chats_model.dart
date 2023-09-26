import 'package:cloud_firestore/cloud_firestore.dart';

class ActiveChatsModel {
  final String chatOwner;
  final String chatReceiver;
  final bool isSeen;
  final Timestamp? createdAt;
  final String lastMessage;
  String? chatUserUsername;
  String? chatUserProfilePhotoUrl;
  String? timeDifference;

  ActiveChatsModel({
    required this.chatOwner,
    required this.chatReceiver,
    required this.isSeen,
    this.createdAt,
    required this.lastMessage,
    this.chatUserUsername,
    this.chatUserProfilePhotoUrl,
  });

  factory ActiveChatsModel.fromMap(Map<String, dynamic> map) =>
      ActiveChatsModel(
        chatOwner: map["chatOwner"],
        chatReceiver: map["chatReceiver"],
        isSeen: map["isSeen"],
        createdAt: map["createdAt"],
        lastMessage: map["lastMessage"],
      );

  Map<String, dynamic> toMap() {
    return {
      "chatOwner": chatOwner,
      "chatReceiver": chatReceiver,
      "isSeen": false,
      "createdAt": createdAt ?? FieldValue.serverTimestamp(),
      "lastMessage": lastMessage,
    };
  }
}
