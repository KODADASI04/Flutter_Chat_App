import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_canli_sohbet_uygulamasi/models/message_model.dart';

import '../locator.dart';
import '../models/user_model.dart';
import '../repository/user_repository.dart';

enum ChatViewState {
  idle,
  loaded,
  busy,
}

class ChatViewModel with ChangeNotifier {
  late final List<MessageModel> _allMessages;

  static const bringItemCount = 10;

  bool _hasMore = true;
  bool _realTimeListener = false;
  bool _addRealTimeFirstTime = true;

  final UserRepository _userRepository = locator<UserRepository>();

  ChatViewState _state = ChatViewState.idle;

  late StreamSubscription _streamSubscription;

  MessageModel? lastMessage;

  final UserModel chatUser;
  final UserModel currentUser;

  ChatViewModel({required this.currentUser, required this.chatUser}) {
    _allMessages = [];
    getMessagesWithPagination();
  }

  List<MessageModel> get allMessages => _allMessages;

  ChatViewState get state => _state;

  set state(ChatViewState value) {
    _state = value;
    notifyListeners();
  }

  @override
  dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }

  Future<void> getMessagesWithPagination() async {
    if (_allMessages.isNotEmpty) {
      lastMessage = _allMessages.last;
    }
    state = ChatViewState.busy;
    List<MessageModel> bringMessages =
        await _userRepository.getMessagesWithPagination(
            currentUser.userID, chatUser.userID, lastMessage, bringItemCount);
    if (bringMessages.length < bringItemCount) {
      _hasMore = false;
    }
    _allMessages.addAll(bringMessages);
    state = ChatViewState.loaded;

    if (!_realTimeListener) {
      _realTimeListener = true;
      addRealTimeListener();
    }
  }

  Future<void> bringOldMessages() async {
    if (_hasMore) await getMessagesWithPagination();
  }

  Future<bool> saveMessage(MessageModel message) async {
    return await _userRepository.saveMessage(message, currentUser);
  }

  void addRealTimeListener() {
    _streamSubscription = _userRepository
        .getMessages(currentUser.userID, chatUser.userID)
        .listen((event) {
      if (!_addRealTimeFirstTime && event[0].sendAt != null) {
        _allMessages.insert(0, event[0]);
        state = ChatViewState.loaded;
      } else {
        _addRealTimeFirstTime = false;
      }
    });
  }
}
