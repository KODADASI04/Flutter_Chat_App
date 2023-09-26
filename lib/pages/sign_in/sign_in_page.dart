import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_canli_sohbet_uygulamasi/widgets/social_login_button.dart';
import 'package:flutter_canli_sohbet_uygulamasi/pages/sign_in/sign_in_with_email.dart';
import 'package:flutter_canli_sohbet_uygulamasi/providers/all_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../errors.dart';
import '../../widgets/platform_responsive_alert_dialog.dart';

class SignInPage extends ConsumerWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter Lovers"),
        elevation: 0,
      ),
      backgroundColor: Colors.grey.shade200,
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Oturum Aç",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 32,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            SocialLoginButton(
              onPressed: () {
                try {
                  ref.read(userProvider.notifier).signInWithGoogle();
                } on PlatformException catch (e) {
                  PlatformResponsiveAlertDialog(
                    baslik: "Hata",
                    icerik: Errors.show(e.code),
                    buttonTexts: const ["Tamam"],
                    buttonActions: [
                      (BuildContext context) => Navigator.pop(context),
                    ],
                  ).goster(context);
                }
              },
              buttonText: "Google İle Giriş Yap",
              buttonColor: Colors.white,
              textColor: Colors.black87,
              buttonIcon: Image.asset("assets/images/google-logo.png"),
            ),
            SocialLoginButton(
              onPressed: () {
                try {
                  ref.read(userProvider.notifier).signInWithFacebook();
                } on PlatformException catch (e) {
                  PlatformResponsiveAlertDialog(
                    baslik: "Hata",
                    icerik: Errors.show(e.code),
                    buttonTexts: const ["Tamam"],
                    buttonActions: [
                      (BuildContext context) => Navigator.pop(context),
                    ],
                  ).goster(context);
                }
              },
              buttonText: "Facebook İle Giriş Yap",
              buttonColor: const Color(0xFF334092),
              buttonIcon: Image.asset("assets/images/facebook-logo.png"),
            ),
            SocialLoginButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    fullscreenDialog: true,
                    //bir diyalog gibi bir yer açar ve geri işlemi için x işareti bulunur.
                    builder: (context) => SignInWithEmailPage(),
                  ),
                );
              },
              buttonText: "Email ve Şifre İle Giriş Yap",
              buttonIcon: const Icon(Icons.email),
            ),
            SocialLoginButton(
              onPressed: () {
                ref.read(userProvider.notifier).signInAnonymously();
                //anonim girişte her çıkış yapılıp tekrar giriş yapıldığında tekrardan yeni bir ıd ile bir kullanıcı oluşturuluyor.Aynı telefondan giriş yapsan bile.
              },
              buttonText: "Misafir Girişi",
              buttonIcon: const Icon(Icons.supervised_user_circle),
            ),
          ],
        ),
      ),
    );
  }
}
