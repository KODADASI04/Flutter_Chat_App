import 'package:flutter_canli_sohbet_uygulamasi/models/message_model.dart';

import '../models/user_model.dart';

import "package:http/http.dart" as http;

class NotificationService {
  Future<bool> sendNotification(
      MessageModel notification, UserModel sendUser, String token) async {
    String endUrl = "https://fcm.googleapis.com/fcm/send";
    String firebaseKey =
        "AAAARmhSPTI:APA91bGt5YrEsuKuAT2L1TogPpwx_7IkjDaBEFxAu6clRch_IAPDX7QYRPQA_siTMhnDyNcQ3MdzLn4meVAEOll13YFK6GnHH8KaXRD3POiXFk0hHJa-6YUBIDXvwh4MzGE9ej0Wv309";
    String json =
        '{"to" : "$token", "data": {"message": "${notification.message}","title": "${sendUser.username} yeni mesaj","profilPhotoUrl": "${sendUser.profilPhotoUrl}","sendUserID" : "${sendUser.userID}" } }';

    http.Response response = await http.post(
      Uri.parse(endUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "key=$firebaseKey",
      },
      body: json,
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}
