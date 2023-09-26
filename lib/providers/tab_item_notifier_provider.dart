import 'package:flutter/material.dart';
import 'package:flutter_canli_sohbet_uygulamasi/widgets/tab_items.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../pages/active_chats_page.dart';
import '../pages/profile_page.dart';
import '../pages/users_page.dart';

class TabItemManager extends StateNotifier<TabItem> {
  TabItemManager() : super(TabItem.allUsers);

  Widget sayfaOlusturucu() {
    return state == TabItem.allUsers
        ? const UsersPage()
        : state == TabItem.chats
            ? const ActiveChatsPage()
            : const ProfilePage();
  }
}
