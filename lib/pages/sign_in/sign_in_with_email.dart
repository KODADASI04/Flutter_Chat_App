// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_canli_sohbet_uygulamasi/errors.dart';
import 'package:flutter_canli_sohbet_uygulamasi/widgets/platform_responsive_alert_dialog.dart';
import 'package:flutter_canli_sohbet_uygulamasi/widgets/social_login_button.dart';
import 'package:flutter_canli_sohbet_uygulamasi/providers/all_providers.dart';
import 'package:flutter_canli_sohbet_uygulamasi/view_models/user_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum FormType {
  register,
  login,
}

class SignInWithEmailPage extends ConsumerWidget {
  SignInWithEmailPage({super.key});

  final _formKey = GlobalKey<FormState>();

  String _email = "";
  String _sifre = "";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    FormType formType = ref.watch(formTypeProvider);
    ViewState viewState = ref.watch(viewStateProvider);
    if (viewState == ViewState.busy) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            _textControl(
              formType,
              "Email ile Giriş",
              "Kayıt Ol",
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.mail),
                      hintText: "Emailinizi Giriniz",
                      labelText: "Email",
                      border: OutlineInputBorder(),
                    ),
                    onSaved: (newValue) {
                      _email = newValue!;
                    },
                    validator: (value) => ref
                        .read(userProvider.notifier)
                        .validator(value, ValidatorType.email),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  TextFormField(
                    obscureText: true,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.password),
                      hintText: "Şifrenizi Giriniz",
                      labelText: "Şifre",
                      border: OutlineInputBorder(),
                    ),
                    onSaved: (newValue) {
                      _sifre = newValue!;
                    },
                    validator: (value) => ref
                        .read(userProvider.notifier)
                        .validator(value, ValidatorType.password),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  SocialLoginButton(
                    onPressed: () {
                      _signInControl(context, ref, formType);
                    },
                    buttonText: _textControl(
                      formType,
                      "Giriş Yap",
                      "Kayıt Ol",
                    ),
                    buttonColor: Theme.of(context).primaryColor,
                    radius: 10,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextButton(
                    onPressed: () {
                      ref.read(formTypeProvider.notifier).state =
                          formType == FormType.login
                              ? FormType.register
                              : FormType.login;
                    },
                    child: Text(
                      _textControl(
                        formType,
                        "Hesabınız Yok Mu? Kayıt Olun",
                        "Hesabınız Var Mı? Giriş Yapın",
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  String _textControl(
      FormType formType, String textLogin, String textRegister) {
    return formType == FormType.login ? textLogin : textRegister;
  }

  void _signInControl(
      BuildContext context, WidgetRef ref, FormType formType) async {
    try {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();

        if (formType == FormType.login) {
          await ref.read(userProvider.notifier).signInWithEmail(_email, _sifre);
        } else {
          await ref
              .read(userProvider.notifier)
              .createUserWithEmail(_email, _sifre);
        }
        ref.read(formTypeProvider.notifier).state = FormType.login;
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      PlatformResponsiveAlertDialog(
        baslik: "Hata",
        icerik: Errors.show(e.code),
        buttonTexts: const ["Tamam"],
        buttonActions: [
          (BuildContext context) => Navigator.pop(context),
        ],
      ).goster(context);
    }
  }
}
