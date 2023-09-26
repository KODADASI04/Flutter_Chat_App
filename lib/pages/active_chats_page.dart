import 'package:flutter/material.dart';
import 'package:flutter_canli_sohbet_uygulamasi/models/active_chats_model.dart';
import 'package:flutter_canli_sohbet_uygulamasi/view_models/chat_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;

import '../models/user_model.dart';
import '../providers/all_providers.dart';
import 'chat_page.dart';

class ActiveChatsPage extends ConsumerStatefulWidget {
  const ActiveChatsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ActiveChatsPageState();
}

class _ActiveChatsPageState extends ConsumerState<ActiveChatsPage> {
  @override
  void initState() {
    super.initState();
    //AdmobOperations.rewardedAd();
  }

  @override
  Widget build(BuildContext context) {
    UserModel currentUser = ref.read(userProvider)!;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Aktif Konuşmalar Listesi"),
      ),
      body: FutureBuilder<List<ActiveChatsModel>>(
        future:
            ref.read(userProvider.notifier).getActiveChats(currentUser.userID),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            List<ActiveChatsModel> allUsers = snapshot.data!;
            if (allUsers.isEmpty) {
              return RefreshIndicator(
                onRefresh: () async {
                  //refresh indicator bir scroolable widget olamdan çalışamaz.
                  setState(() {});
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat,
                            color: Theme.of(context).primaryColor,
                            size: 120,
                          ),
                          const Text(
                            "Aktif bir konuşmanız bulunmamaktadır",
                            style: TextStyle(fontSize: 36),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                setState(() {});
              },
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(allUsers[index].lastMessage),
                    subtitle: Text(allUsers[index].chatUserUsername!),
                    trailing: Text(allUsers[index].timeDifference!),
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey.withAlpha(20),
                      backgroundImage: NetworkImage(
                          allUsers[index].chatUserProfilePhotoUrl!),
                    ),
                    onTap: () {
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              provider.ChangeNotifierProvider<ChatViewModel>(
                            create: (context) => ChatViewModel(
                              currentUser: currentUser,
                              chatUser: UserModel(
                                userID: allUsers[index].chatReceiver,
                                email: "",
                                profilPhotoUrl:
                                    allUsers[index].chatUserProfilePhotoUrl,
                              ),
                            ),
                            child: const ChatPage(),
                          ),
                        ),
                      );
                    },
                  );
                },
                itemCount: allUsers.length,
              ),
            );
          } else if (snapshot.hasError) {
            return RefreshIndicator(
              onRefresh: () async {
                //refresh indicator bir scroolable widget olamdan çalışamaz.
                setState(() {});
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat,
                          color: Theme.of(context).primaryColor,
                          size: 120,
                        ),
                        const Text(
                          "Mesajlar Getirilirken Bir Hata Oluştu",
                          style: TextStyle(fontSize: 36),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        }),
      ),
    );
  }
}
