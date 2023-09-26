import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import 'package:flutter_canli_sohbet_uygulamasi/view_models/chat_view_model.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

import 'models/user_model.dart';
import 'pages/chat_page.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  NotificationHandler.showNotification(message.data);
  return Future<void>.value();
}

class NotificationHandler {
  NotificationHandler._internal();

  static final NotificationHandler _singleton = NotificationHandler._internal();

  factory NotificationHandler() {
    return _singleton;
    //her nesne üretmede farklı değil de aynı nesneyi döndürmek için bunu kullandık.
  }

  final StreamController<String?> selectNotificationStream =
      StreamController<String?>.broadcast();

  initializeFCMNotification(BuildContext context,WidgetRef ref) async {
    User currentUser = FirebaseAuth.instance.currentUser!;
    var initializationSettingsAndroid =
        const AndroidInitializationSettings("app_icon");
    //burdaki app_icon resminin android src maindeki res klasöründe bulunması gerekmektedir.
    var initializationSettingsIOS = DarwinInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) {
        switch (notificationResponse.notificationResponseType) {
          case NotificationResponseType.selectedNotification:
            selectNotificationStream.add(notificationResponse.payload);
            if (notificationResponse.payload != null) {
              Map<String, dynamic> incomingNotification =
                  jsonDecode(notificationResponse.payload!);
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (context) =>
                      provider.ChangeNotifierProvider<ChatViewModel>(
                    create: (context) => ChatViewModel(
                      currentUser: UserModel.userFromFirebase(currentUser)!,
                      chatUser: UserModel(
                        userID: incomingNotification["sendUserID"],
                        email: "",
                        profilPhotoUrl: incomingNotification["profilPhotoUrl"],
                      ),
                    ),
                    child: const ChatPage(),
                  ),
                ),
              );
            }
            break;
          case NotificationResponseType.selectedNotificationAction:
            break;
        }
      },
    );

    String token = (await FirebaseMessaging.instance.getToken())!;
    
    await FirebaseFirestore.instance
        .doc("tokens/${currentUser.uid}")
        .set({"token": token});
    //ayrıca token cihaza özgü bir değerdir.
    //kullanıcı tokenları sadece kullanıcı uygulamayı yeni yüklediğinde veya dataları sildiğinde oluşmaktadır.
    //belli konulara göre kişileri bölümlere ayırıp ona göre bildirim göndermeler yapılabilmektedir.
    FirebaseMessaging.instance.subscribeToTopic("spor");

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) {}

  static void showNotification(Map<String, dynamic> messageData) async {
    var filePath =
        await _downloadAndSaveImage(messageData["profilPhotoUrl"], 'largeIcon');

    var mesaj = Person(
      name: messageData["title"],
      key: '1',
      //icon: BitmapFilePathAndroidIcon(filePath),
    );
    final mesajStyle = MessagingStyleInformation(
      mesaj,
      messages: [
        Message(messageData["message"], DateTime.now(), mesaj),
      ],
    );
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('123', 'yeni mesaj',
            channelDescription: 'yeni mesaj tanımlaması',
            styleInformation: mesajStyle,
            importance: Importance.max,
            priority: Priority.high,
            number: 1);
    //Bu kanallar bildirim türlerini kullanıcıya bildirmek için kullanılmaktadır.
    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(0, messageData["title"],
        messageData["message"], platformChannelSpecifics,
        payload: jsonEncode(messageData));
  }

  static _downloadAndSaveImage(String url, String name) async {
    var directory = await getApplicationDocumentsDirectory();
    var filePath = '${directory.path}/$name';
    var response = await http.get(Uri.parse(url));
    var file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }
}
