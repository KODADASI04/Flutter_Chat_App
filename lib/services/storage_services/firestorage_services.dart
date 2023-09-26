import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_canli_sohbet_uygulamasi/locator.dart';
import 'package:flutter_canli_sohbet_uygulamasi/services/db_services/firestore_db_service.dart';
import 'package:flutter_canli_sohbet_uygulamasi/services/storage_services/storaga_base.dart';

class FirestorageService implements StorageBase {
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final FirestoreDBService _firestoreDBService = locator<FirestoreDBService>();
  late Reference profileRef;
  @override
  Future<String> uploadFile(String userID, String fileType, File file) async {
    profileRef =
        _firebaseStorage.ref().child(userID).child(fileType).child(fileType);
    UploadTask task = profileRef.putFile(file);
    String url = "";
    await task.whenComplete(() async {
      url = await profileRef.getDownloadURL();
      await _firestoreDBService.updateProfilePhotoUrl(userID, url);
    });
    return url;
  }
}
