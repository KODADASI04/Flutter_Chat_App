import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_canli_sohbet_uygulamasi/models/message_model.dart';
import 'package:flutter_canli_sohbet_uygulamasi/models/user_model.dart';
import 'package:flutter_canli_sohbet_uygulamasi/view_models/chat_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart' as provider;

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  late TextEditingController _messageController;
  late ScrollController _scrollController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      _scroolListener();
    });
    //AdmobOperations.interstitialAd();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sohbet"),
      ),
      body: Center(
        child: Column(
          children: [
            _buildMessageList(),
            _buildNewMessageField(),
          ],
        ),
      ),
    );
  }

  Widget _konusmaBalonuOlustur(MessageModel currentMessage) {
    Color gelenMesajRenk = Colors.blueAccent;
    Color gidenMesajRenk = Theme.of(context).primaryColor;

    bool isMessageMine = currentMessage.isMessageMine;
    String hourMinuteValue = _showHourMinute(currentMessage.sendAt);

    final ChatViewModel chatModel =
        provider.Provider.of<ChatViewModel>(context);
    UserModel chatUser = chatModel.chatUser;

    if (isMessageMine) {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: gidenMesajRenk,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        currentMessage.message,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      hourMinuteValue,
                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey.withAlpha(20),
              backgroundImage: NetworkImage(chatUser.profilPhotoUrl!),
            ),
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: gelenMesajRenk,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        currentMessage.message,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      hourMinuteValue,
                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  String _showHourMinute(Timestamp? date) {
    if (date != null) {
      return DateFormat.Hm().format(date.toDate());
    } else {
      return "";
    }
  }

  Widget _buildNewMessageField() {
    final ChatViewModel chatModel =
        provider.Provider.of<ChatViewModel>(context);
    UserModel currentUser = chatModel.currentUser;
    UserModel chatUser = chatModel.chatUser;
    return Row(
      children: [
        Expanded(
          child: Focus(
            onFocusChange: (deger) {
              if (deger && _scrollController.offset == 0) {
                _scrollController.animateTo(
                  _scrollController.initialScrollOffset,
                  duration: const Duration(milliseconds: 10),
                  curve: Curves.easeOut,
                );
              }
            },
            child: TextField(
              controller: _messageController,
              cursorColor: Colors.blueGrey,
              style: const TextStyle(
                fontSize: 16.0,
                color: Colors.black,
              ),
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                hintText: "Mesajınızı Yazın",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none),
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 4,
          ),
          child: FloatingActionButton(
            elevation: 0,
            backgroundColor: Colors.blue,
            child: const Icon(
              Icons.navigation,
              size: 35,
              color: Colors.white,
            ),
            onPressed: () async {
              if (_messageController.text.trim().isNotEmpty) {
                MessageModel message = MessageModel(
                  incomingPersonID: currentUser.userID,
                  outgoingPersonID: chatUser.userID,
                  message: _messageController.text.trim(),
                  isMessageMine: true,
                );
                //trim yapısı ile yazının kenarlarındaki boşluklar silinebilmektedir.
                bool sonuc = await chatModel.saveMessage(message);
                if (sonuc) {
                  _messageController.clear();
                  _scrollController.animateTo(
                    _scrollController.position.minScrollExtent,
                    duration: const Duration(milliseconds: 10),
                    curve: Curves.easeOut,
                  );
                }
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMessageList() {
    return provider.Consumer<ChatViewModel>(builder: (context, value, child) {
      List<MessageModel> messageList = value.allMessages;
      return Expanded(
        child: ListView.builder(
          controller: _scrollController,
          reverse: true,
          itemBuilder: (context, index) {
            if (index == messageList.length) {
              return Container(
                padding: const EdgeInsets.all(8.0),
                height: _isLoading ? null : 0,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return _konusmaBalonuOlustur(messageList[index]);
          },
          itemCount: messageList.length + 1,
        ),
      );
    });
  }

  void _scroolListener() {
    if (_scrollController.offset >=
            _scrollController.position.minScrollExtent &&
        !_scrollController.position.outOfRange) {
      _bringOldMessages();
    }
  }

  void _bringOldMessages() async {
    final ChatViewModel chatModel =
        provider.Provider.of<ChatViewModel>(context, listen: false);
    if (!_isLoading) {
      _isLoading = true;
      await chatModel.bringOldMessages();
      _isLoading = false;
    }
  }
}
