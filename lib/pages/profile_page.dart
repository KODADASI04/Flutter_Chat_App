// ignore_for_file: use_build_context_synchronously, invalid_use_of_protected_member

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_canli_sohbet_uygulamasi/models/user_model.dart';
import 'package:flutter_canli_sohbet_uygulamasi/pages/landing_page.dart';
import 'package:flutter_canli_sohbet_uygulamasi/widgets/platform_responsive_alert_dialog.dart';
import 'package:flutter_canli_sohbet_uygulamasi/widgets/social_login_button.dart';
import 'package:flutter_canli_sohbet_uygulamasi/widgets/tab_items.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_picker/image_picker.dart';

import '../admob.dart';
import '../providers/all_providers.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  late final TextEditingController _usernameController;
  late UserModel _user;
  XFile? _profilePhoto;

  late AdManagerBannerAd myBannerAd;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _user = ref.read(userProvider.notifier).state!;
    _usernameController.text = _user.username!;
    AdmobOperations.admobInitialize();
    myBannerAd = AdmobOperations.buildBannerAd();
    myBannerAd.load();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    myBannerAd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Profil"),
          actions: [
            TextButton(
              onPressed: () => _exitPermission(context, ref),
              child: const Text(
                "Çıkış Yap",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        useSafeArea: true,
                        context: context,
                        builder: (context) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.camera),
                              title: const Text("Kameradan Çek"),
                              onTap: () {
                                _kameradanFotoCek();
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.image),
                              title: const Text("Galeriden Seç"),
                              onTap: () {
                                _galeridenResimSec();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: 75,
                      backgroundColor: Colors.white,
                      backgroundImage: _backgroundImage(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextFormField(
                    initialValue: _user.email,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: "Emailiniz",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: "Kullanıcı Adınız",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: SocialLoginButton(
                    onPressed: () {
                      _updateControl();
                    },
                    buttonText: "Değişiklikleri Kaydet",
                  ),
                ),
                Container(
                  height: 45,
                  color: Colors.white,
                  child: AdWidget(ad: myBannerAd),
                ) //reklam göstermek için kullanılıyor.
              ],
            ),
          ),
        ));
  }

  void _exitPermission(BuildContext context, WidgetRef ref) {
    PlatformResponsiveAlertDialog(
      baslik: "Emin Misiniz",
      icerik: "Çıkış yapmak istediğinizden emin misiniz",
      buttonTexts: const ["Evet", "Vazgeç"],
      buttonActions: [
        (BuildContext context) {
          ref.read(userProvider.notifier).signOut();
          ref.read(tabItemProvider.notifier).state = TabItem.allUsers;
          Navigator.of(context).pop();
        },
        (BuildContext context) => Navigator.of(context).pop(),
      ],
    ).goster(context);
  }

  Future<bool?> _usernameUpdate(BuildContext context) async {
    if (_user.username != _usernameController.text) {
      bool updateResult = await ref
          .read(userProvider.notifier)
          .updateUsername(_user.userID, _usernameController.text);
      return updateResult;
    } else {
      return null;
    }
  }

  Future<String?> _profilePhotoUpdate() async {
    if (_profilePhoto != null) {
      return await ref.read(userProvider.notifier).uploadFile(
            _user.userID,
            "profile_photo",
            File(_profilePhoto!.path),
          );
    } else {
      return null;
    }
  }

  void _updateControl() async {
    bool? usernameUpdateResult = await _usernameUpdate(context);
    String? photoUpdateResult = await _profilePhotoUpdate();
    if (usernameUpdateResult == null && photoUpdateResult == null) {
      PlatformResponsiveAlertDialog(
        baslik: "Hata",
        icerik: "Hiçbir Değişiklik Yapmadınız",
        buttonTexts: const ["Tamam"],
        buttonActions: [
          (context) => Navigator.pop(context),
        ],
      ).goster(context);
    } else {
      if (usernameUpdateResult == true || photoUpdateResult != "") {
        if (usernameUpdateResult == true && usernameUpdateResult != null) {
          _user.username = _usernameController.text;
        }
        if (photoUpdateResult != "" && photoUpdateResult != null) {
          _user.profilPhotoUrl = photoUpdateResult;
        }
        PlatformResponsiveAlertDialog(
          baslik: "Başarılı",
          icerik: "Değişiklikleriniz Başarıyla Kaydedildi",
          buttonTexts: const ["Tamam"],
          buttonActions: [
            (context) => Navigator.pop(context),
          ],
        ).goster(landingPageKey.currentContext!);
      } else {
        PlatformResponsiveAlertDialog(
          baslik: "Hata",
          icerik: "Değişiklikleriniz Kaydedilemedi",
          buttonTexts: const ["Tamam"],
          buttonActions: [
            (context) => Navigator.pop(context),
          ],
        ).goster(landingPageKey.currentContext!);
      }
    }
  }

  void _galeridenResimSec() async {
    _profilePhoto = await ImagePicker().pickImage(source: ImageSource.gallery);
    Navigator.of(context).pop();
    setState(() {});
  }

  void _kameradanFotoCek() async {
    _profilePhoto = await ImagePicker().pickImage(source: ImageSource.camera);
    Navigator.of(context).pop();
    setState(() {});
  }

  _backgroundImage() {
    return _profilePhoto != null
        ? FileImage(File(_profilePhoto!.path))
        : NetworkImage(_user.profilPhotoUrl!);
  }
}
