// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String incomingPersonID;
  final String outgoingPersonID;
  final String message;
  final bool isMessageMine;
  final Timestamp? sendAt;

  MessageModel({
    required this.incomingPersonID,
    required this.outgoingPersonID,
    required this.message,
    required this.isMessageMine,
    this.sendAt,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map) => MessageModel(
        incomingPersonID: map["incomingPersonID"],
        outgoingPersonID: map["outgoingPersonID"],
        message: map["message"],
        isMessageMine: map["isMessageMine"],
        sendAt: map["sendAt"],
      );

  Map<String, dynamic> toMap() {
    return {
      "incomingPersonID": incomingPersonID,
      "outgoingPersonID": outgoingPersonID,
      "message": message,
      "isMessageMine": isMessageMine,
      "sendAt": sendAt ?? FieldValue.serverTimestamp(),
    };
  }


}
