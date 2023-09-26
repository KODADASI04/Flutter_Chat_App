import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_canli_sohbet_uygulamasi/models/active_chats_model.dart';
import 'package:flutter_canli_sohbet_uygulamasi/models/message_model.dart';
import 'package:flutter_canli_sohbet_uygulamasi/models/user_model.dart';

import 'db_base.dart';

class FirestoreDBService implements DBBase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<bool> saveUser(UserModel user) async {
    DocumentSnapshot readUser =
        await FirebaseFirestore.instance.doc("users/${user.userID}").get();

    if (readUser.data() == null) {
      Map<String, dynamic> eklenecekUser = user.toMap();
      eklenecekUser.addAll({
        "createdAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
      });

      try {
        await _firestore
            .collection("users")
            .doc(user.userID)
            .set(eklenecekUser);
        return true;
      } catch (e) {
        return false;
      }
    } else {
      return true;
    }
  }

  @override
  Future<UserModel?> readUser(String userID) async {
    QuerySnapshot user = await _firestore
        .collection("users")
        .where("userID", isEqualTo: userID)
        .get();
    return user.docs.isEmpty
        ? null
        : UserModel.fromMap(user.docs[0].data() as Map<String, dynamic>);
  }

  @override
  Future<bool> updateUsername(String userID, String newUsername) async {
    QuerySnapshot user = await _firestore
        .collection("users")
        .where("username", isEqualTo: newUsername)
        .get();
    if (user.docs.isEmpty) {
      await _firestore
          .collection("users")
          .doc(userID)
          .update({"username": newUsername});
      return true;
    } else {
      return false;
    }
  }

  @override
  Future<bool> updateProfilePhotoUrl(
      String userID, String profilePhotoUrl) async {
    await _firestore.collection("users").doc(userID).set(
      {
        "profilPhotoUrl": profilePhotoUrl,
      },
      SetOptions(
        merge: true,
      ),
    );
    return true;
  }

  @override
  Stream<List<MessageModel>> getMessages(
      String currentUserID, String chatUserID) {
    var snapshot = _firestore
        .collection("chats")
        .doc("$currentUserID--$chatUserID")
        .collection("messages")
        .orderBy("sendAt", descending: true)
        .limit(1)
        .snapshots();
    return snapshot.map((messageList) => messageList.docs
        .map(
          (e) => MessageModel.fromMap(e.data()),
        )
        .toList());
  }

  @override
  Future<bool> saveMessage(MessageModel message) async {
    String messageID = _firestore.collection("chats").doc().id;
    //rastgele bir id oluşturup o id ye göre mesajı kaydetmemizi sağlar.İki farklı yere aynı mesaj kaydedileceğinden aynı id olması burda sağlanır.
    String currentUserDocID =
        "${message.incomingPersonID}--${message.outgoingPersonID}";
    String chatUserDocID =
        "${message.outgoingPersonID}--${message.incomingPersonID}";
    Map<String, dynamic> sentMessage = message.toMap();
    await _firestore
        .collection("chats")
        .doc(currentUserDocID)
        .collection("messages")
        .doc(messageID)
        .set(sentMessage);
    sentMessage.update("isMessageMine", (value) => false);
    await _firestore
        .collection("chats")
        .doc(chatUserDocID)
        .collection("messages")
        .doc(messageID)
        .set(sentMessage);
    await _firestore.collection("chats").doc(currentUserDocID).set({
      "chatOwner": message.incomingPersonID,
      "chatReceiver": message.outgoingPersonID,
      "lastMessage": message.message,
      "isSeen": false,
      "createdAt": FieldValue.serverTimestamp(),
    });
    await _firestore.collection("chats").doc(chatUserDocID).set({
      "chatOwner": message.outgoingPersonID,
      "chatReceiver": message.incomingPersonID,
      "lastMessage": message.message,
      "isSeen": false,
      "createdAt": FieldValue.serverTimestamp(),
    });
    return true;
  }

  @override
  Future<List<ActiveChatsModel>> getActiveChats(String currentUserID) async {
    QuerySnapshot snapshot = await _firestore
        .collection("chats")
        .where("chatOwner", isEqualTo: currentUserID)
        .orderBy("createdAt", descending: true)
        .get();

    return snapshot.docs
        .map(
          (e) => ActiveChatsModel.fromMap(e.data() as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<DateTime> showTime(String currentUserID) async {
    await _firestore.collection("server").doc(currentUserID).set({
      "lastDateTime": FieldValue.serverTimestamp(),
    });

    var snapshot =
        await _firestore.collection("server").doc(currentUserID).get();
    Timestamp readDateTime = snapshot.data()!["lastDateTime"];
    return readDateTime.toDate();
  }

  @override
  Future<List<UserModel>> getUsersWithPagination(
      String currentUsername, UserModel? lastUser, int bringItemCount) async {
    QuerySnapshot snapshot;
    List<UserModel> allUsers = [];
    if (lastUser == null) {
      allUsers = [];
      snapshot = await _firestore
          .collection("users")
          .where("username", isNotEqualTo: currentUsername)
          .orderBy("username")
          .limit(bringItemCount)
          .get();
    } else {
      snapshot = await _firestore
          .collection("users")
          .where("username", isNotEqualTo: currentUsername)
          .orderBy("username")
          .startAfter([lastUser.username])
          .limit(bringItemCount)
          .get();
    }

    for (DocumentSnapshot snap in snapshot.docs) {
      allUsers.add(
        UserModel.fromMap(snap.data() as Map<String, dynamic>),
      );
    }
    return allUsers;
  }

  Future<List<MessageModel>> getMessagesWithPagination(String currentUserID,
      String chatUserID, MessageModel? lastMessage, int bringItemCount) async {
    QuerySnapshot snapshot;
    List<MessageModel> allMessages = [];
    if (lastMessage == null) {
      allMessages = [];
      snapshot = await _firestore
          .collection("chats")
          .doc("$currentUserID--$chatUserID")
          .collection("messages")
          .orderBy("sendAt", descending: true)
          .limit(bringItemCount)
          .get();
    } else {
      snapshot = await _firestore
          .collection("chats")
          .doc("$currentUserID--$chatUserID")
          .collection("messages")
          .orderBy("sendAt", descending: true)
          .startAfter([lastMessage.sendAt])
          .limit(bringItemCount)
          .get();
    }

    for (DocumentSnapshot snap in snapshot.docs) {
      allMessages.add(
        MessageModel.fromMap(snap.data() as Map<String, dynamic>),
      );
    }
    return allMessages;
  }
}
