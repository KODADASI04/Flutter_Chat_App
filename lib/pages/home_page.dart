// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_canli_sohbet_uygulamasi/providers/all_providers.dart';
import 'package:flutter_canli_sohbet_uygulamasi/widgets/custom_bottom_navigation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    //NotificationHandler().initializeFCMNotification(context,ref);
  }

  @override
  Widget build(BuildContext context) {
    final currentTab = ref.watch(tabItemProvider);
    return WillPopScope(
      onWillPop: () async =>
          !await ref.read(keyProvider)[currentTab]!.currentState!.maybePop(),
      //on will pop çalışırsa uygulamadan çıkar çalışmazsa ise bir önceki sayfaya donanımsal geri ile gidilebilir hale gelir.Bu yüzden ! ile kullanıyoruz.
      child: const CustomBottomNavigation(),
    );
  }
}
