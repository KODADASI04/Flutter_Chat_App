import 'package:flutter/material.dart';
import 'package:flutter_canli_sohbet_uygulamasi/models/user_model.dart';
import 'package:flutter_canli_sohbet_uygulamasi/pages/sign_in/sign_in_with_email.dart';
import 'package:flutter_canli_sohbet_uygulamasi/view_models/user_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../widgets/tab_items.dart';
import 'tab_item_notifier_provider.dart';

final StateProvider<ViewState> viewStateProvider =
    StateProvider((ref) => ViewState.idle);

final StateProvider<FormType> formTypeProvider =
    StateProvider((ref) => FormType.login);

final StateNotifierProvider<TabItemManager, TabItem> tabItemProvider =
    StateNotifierProvider((ref) => TabItemManager());

final Provider<Map<TabItem, GlobalKey<NavigatorState>>> keyProvider = Provider(
  (ref) => {
    TabItem.allUsers: GlobalKey<NavigatorState>(),
    TabItem.chats: GlobalKey<NavigatorState>(),
    TabItem.profile: GlobalKey<NavigatorState>(),
  },
);

final StateNotifierProvider<UserViewModel, UserModel?> userProvider =
    StateNotifierProvider(
  (ref) => UserViewModel(ref),
);
