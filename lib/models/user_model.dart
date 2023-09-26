import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final String userID;
  final String email;
  String? username;
  String? profilPhotoUrl;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? level;

  UserModel({
    required this.userID,
    required this.email,
    this.username,
    this.profilPhotoUrl,
    this.createdAt,
    this.updatedAt,
    this.level,
  });

  factory UserModel.fromMap(Map<String, dynamic> userMap) => UserModel(
        userID: userMap["userID"],
        email: userMap["email"],
        username: userMap["username"],
        profilPhotoUrl: userMap["profilPhotoUrl"],
        createdAt: (userMap["createdAt"] as Timestamp).toDate(),
        updatedAt: (userMap["updatedAt"] as Timestamp).toDate(),
        level: userMap["level"],
      );

  Map<String, dynamic> toMap() {
    return {
      "userID": userID,
      "email": email,
      "username": username ??
          email.substring(0, email.indexOf("@")) + _randomSayiUret(),
      "profilPhotoUrl": profilPhotoUrl ??
          "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460__340.png",
      "createdAt": createdAt ?? "",
      "updatedAt": updatedAt ?? "",
      "level": level ?? 1,
    };
  }

  static UserModel? userFromFirebase(User? user) {
    if (user == null) {
      return null;
    } else {
      return UserModel(
        userID: user.uid,
        email: user.email ?? "anonimkullanici@anonimkullanici.com",
      );
    }
  }

  String _randomSayiUret() {
    return Random().nextInt(999999).toString();
  }
}
