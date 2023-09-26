import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_canli_sohbet_uygulamasi/models/user_model.dart';
import 'package:flutter_canli_sohbet_uygulamasi/pages/ornek_page1.dart';
import 'package:flutter_canli_sohbet_uygulamasi/providers/all_providers.dart';
import 'package:flutter_canli_sohbet_uygulamasi/view_models/chat_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'chat_page.dart';

import 'package:provider/provider.dart' as provider;

class UsersPage extends ConsumerStatefulWidget {
  const UsersPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UsersPageState();
}

class _UsersPageState extends ConsumerState<UsersPage> {
  List<UserModel>? _allUsers;
  bool _isLoading = false;
  bool _hasMore = true;
  final int _bringItemNumber = 10;
  UserModel? _lastUser;
  late ScrollController _scrollController;
  late UserModel currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = ref.read(userProvider)!;
    SchedulerBinding.instance.addPostFrameCallback(
      (timeStamp) {
        getUser(_lastUser);
      },
    );
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      //min scroll extend listenin en altına gelme ile alakalıdır.Max ile ise sayfanın en yukarısına çektiğimizde olur.
      if (_scrollController.offset >=
              _scrollController.position.minScrollExtent &&
          !_scrollController.position.outOfRange) {
        getUser(_lastUser);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kullanıcılar"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const OrnekPage1(),
                ),
              );
            },
            icon: const Icon(Icons.arrow_forward_ios),
          ),
        ],
      ),
      body: _allUsers == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Expanded(
                  child: _buildUsersList(),
                ),
              ],
            ),
    );
  }

  getUser(UserModel? lastUser) async {
    if (!_hasMore || _isLoading) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    List<UserModel> newUsers = await ref
        .read(userProvider.notifier)
        .getUsersWithPagination(
            currentUser.username!, lastUser, _bringItemNumber);
    _allUsers ??= [];
    if (newUsers.isNotEmpty) {
      _allUsers!.addAll(newUsers);
      _lastUser = _allUsers!.last;
    }

    if (newUsers.length < _bringItemNumber) {
      _hasMore = false;
    }

    setState(() {
      _isLoading = false;
    });
  }

  _buildUsersList() {
    if (_allUsers!.isEmpty) {
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
                    Icons.supervised_user_circle,
                    color: Theme.of(context).primaryColor,
                    size: 120,
                  ),
                  const Text(
                    "Herhangi bir kullanıcı bulunamadı",
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
        _allUsers!.clear();
        _hasMore = true;
        _lastUser = null;
        getUser(_lastUser);
      },
      child: ListView.builder(
        controller: _scrollController,
        itemBuilder: (context, index) {
          if (index == _allUsers!.length) {
            return Container(
              padding: const EdgeInsets.all(8.0),
              height: _isLoading ? null : 0,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          UserModel userInIndex = _allUsers![index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(70),
            ),
            elevation: 3,
            child: ListTile(
              title: Text(userInIndex.username!),
              subtitle: Text(userInIndex.email),
              leading: CircleAvatar(
                backgroundColor: Colors.grey.withAlpha(20),
                backgroundImage: NetworkImage(userInIndex.profilPhotoUrl!),
              ),
              onTap: () {
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        provider.ChangeNotifierProvider<ChatViewModel>(
                      create: (context) => ChatViewModel(
                          currentUser: currentUser, chatUser: userInIndex),
                      child: const ChatPage(),
                    ),
                  ),
                );
              },
            ),
          );
        },
        itemCount: _allUsers!.length + 1,
      ),
    );
  }
}

/*FutureBuilder<List<UserModel>>(
        future: ref.read(userProvider.notifier).getAllUsers(currentUser.userID),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            List<UserModel> allUsers = snapshot.data!;
            return RefreshIndicator(
              onRefresh: () async {
                setState(() {});
              },
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(allUsers[index].username!),
                    subtitle: Text(allUsers[index].email),
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey.withAlpha(20),
                      backgroundImage:
                          NetworkImage(allUsers[index].profilPhotoUrl!),
                    ),
                    onTap: () {
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                          builder: (context) => ChatPage(
                            chatUser: allUsers[index],
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
                          Icons.supervised_user_circle,
                          color: Theme.of(context).primaryColor,
                          size: 120,
                        ),
                        const Text(
                          "Herhangi bir kullanıcı bulunamadı",
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
      ), */