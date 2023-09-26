// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/cupertino.dart';
import 'package:flutter_canli_sohbet_uygulamasi/providers/all_providers.dart';
import 'package:flutter_canli_sohbet_uygulamasi/widgets/tab_items.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomBottomNavigation extends ConsumerStatefulWidget {
  const CustomBottomNavigation({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CustomBottomNavigationState();
}

class _CustomBottomNavigationState
    extends ConsumerState<CustomBottomNavigation> {
  @override
  Widget build(BuildContext context) {
    TabItem currentTab = ref.watch(tabItemProvider);
    Map<TabItem, GlobalKey<NavigatorState>> navigatorKeys =
        ref.read(keyProvider);

    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        currentIndex: currentTab == TabItem.allUsers ? 0 : 1,
        items: [
          _navItemOlustur(TabItem.allUsers),
          _navItemOlustur(TabItem.chats),
          _navItemOlustur(TabItem.profile),
        ],
        onTap: (index) {
          TabItem secilenTab = TabItem.values[index];
          if (secilenTab == currentTab) {
            navigatorKeys[secilenTab]!
                .currentState!
                .popUntil((route) => route.isFirst);
          }
          ref.read(tabItemProvider.notifier).state = TabItem.values[index];
        },
      ),
      tabBuilder: (context, index) {
        return CupertinoTabView(
          navigatorKey: navigatorKeys[TabItem.values[index]],
          builder: (context) =>
              ref.read(tabItemProvider.notifier).sayfaOlusturucu(),
        );
      },
    );
  }

  BottomNavigationBarItem _navItemOlustur(TabItem tabItem) {
    final createTabData = TabItemData.tumTablar[tabItem];
    return BottomNavigationBarItem(
      icon: createTabData!.icon,
      label: createTabData.title,
    );
  }
}
