import 'package:flutter/material.dart';
import 'package:flutter_canli_sohbet_uygulamasi/models/user_model.dart';
import 'package:flutter_canli_sohbet_uygulamasi/pages/home_page.dart';
import 'package:flutter_canli_sohbet_uygulamasi/pages/sign_in/sign_in_page.dart';
import 'package:flutter_canli_sohbet_uygulamasi/providers/all_providers.dart';
import 'package:flutter_canli_sohbet_uygulamasi/view_models/user_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final landingPageKey = GlobalKey();

class LandingPage extends ConsumerWidget {
  LandingPage() : super(key: landingPageKey);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    UserModel? user = ref.watch(userProvider);
    ViewState viewState = ref.watch(viewStateProvider);
    if (viewState == ViewState.idle) {
      if (user == null) {
        return const SignInPage();
      } else {
        return const HomePage();
      }
    } else {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }
}
