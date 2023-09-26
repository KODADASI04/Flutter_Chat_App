import 'package:flutter/material.dart';

enum TabItem {
  allUsers,
  chats,
  profile,
}

class TabItemData {
  final String title;
  final Widget icon;

  TabItemData(this.title, this.icon);

  static Map<TabItem, TabItemData> tumTablar = {
    TabItem.allUsers: TabItemData(
      "Kullanıcılar",
      const Icon(Icons.supervised_user_circle),
    ),
    TabItem.chats: TabItemData(
      "Aktif Konuşmalar",
      const Icon(Icons.chat),
    ),
    TabItem.profile: TabItemData(
      "Profil",
      const Icon(Icons.person),
    ),
  };
}
