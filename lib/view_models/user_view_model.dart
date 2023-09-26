import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:flutter_canli_sohbet_uygulamasi/models/active_chats_model.dart';
import 'package:flutter_canli_sohbet_uygulamasi/models/message_model.dart';
import 'package:flutter_canli_sohbet_uygulamasi/models/user_model.dart';
import 'package:flutter_canli_sohbet_uygulamasi/providers/all_providers.dart';
import 'package:flutter_canli_sohbet_uygulamasi/repository/user_repository.dart';
import 'package:flutter_canli_sohbet_uygulamasi/services/storage_services/storaga_base.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../locator.dart';
import '../services/auth_services/auth_base.dart';

enum ValidatorType {
  email,
  password,
}

enum ViewState {
  idle,
  busy,
}

class UserViewModel extends StateNotifier<UserModel?>
    implements AuthBase, StorageBase {
  StateNotifierProviderRef<UserViewModel, UserModel?> ref;
  UserViewModel(this.ref) : super(null) {
    currentUser();
  }
  final UserRepository _userRepository = locator<UserRepository>();

  //Burada provider yerine bloc yapısı kullanılsa daha kolay işlemler yapılabilir bence.

  @override
  Future<UserModel?> currentUser() async {
    state = await _userRepository.currentUser();
    return state;
  }

  @override
  Future<UserModel?> signInAnonymously() async {
    ref.read(viewStateProvider.notifier).state = ViewState.busy;
    state = await _userRepository.signInAnonymously();
    ref.read(viewStateProvider.notifier).state = ViewState.idle;
    return state;
  }

  @override
  Future<bool> signOut() async {
    ref.read(viewStateProvider.notifier).state = ViewState.busy;
    bool sonuc = await _userRepository.signOut();
    state = sonuc ? null : state;
    ref.read(viewStateProvider.notifier).state = ViewState.idle;
    return sonuc;
  }

  @override
  Future<UserModel?> signInWithGoogle() async {
    ref.read(viewStateProvider.notifier).state = ViewState.busy;
    state = await _userRepository.signInWithGoogle();
    ref.read(viewStateProvider.notifier).state = ViewState.idle;
    return state;
  }

  @override
  Future<UserModel?> signInWithFacebook() async {
    ref.read(viewStateProvider.notifier).state = ViewState.busy;
    state = await _userRepository.signInWithFacebook();
    ref.read(viewStateProvider.notifier).state = ViewState.idle;
    return state;
  }

  @override
  Future<UserModel?> createUserWithEmail(String email, String sifre) async {
    try {
      ref.read(viewStateProvider.notifier).state = ViewState.busy;
      state = await _userRepository.createUserWithEmail(email, sifre);
      return state;
    } finally {
      ref.read(viewStateProvider.notifier).state = ViewState.idle;
    }
  }

  @override
  Future<UserModel?> signInWithEmail(String email, String sifre) async {
    try {
      ref.read(viewStateProvider.notifier).state = ViewState.busy;
      state = await _userRepository.signInWithEmail(email, sifre);
      return state;
    } finally {
      ref.read(viewStateProvider.notifier).state = ViewState.idle;
    }
  }

  @override
  Future<String> uploadFile(String userID, String fileType, File file) async {
    String link = await _userRepository.uploadFile(userID, fileType, file);
    return link;
  }

  Future<bool> updateUsername(String userID, String newUsername) async {
    bool sonuc = await _userRepository.updateUsername(userID, newUsername);
    return sonuc;
  }

  String? validator(String? deger, ValidatorType validatorType) {
    if (deger!.isEmpty) {
      return validatorType == ValidatorType.email
          ? "Email Boş Geçilemez"
          : "Şifre Boş Geçilemez";
    } else if (validatorType == ValidatorType.password && deger.length < 8) {
      return "Şifreniz En Az 8 Haneli Olmalıdır";
    } else if (validatorType == ValidatorType.email &&
        !EmailValidator.validate(deger)) {
      return "Gerçek Bir Email Giriniz";
    } else {
      return null;
    }
  }

  Stream<List<MessageModel>> getMessages(
      String currentUserID, String chatUserID) {
    return _userRepository.getMessages(currentUserID, chatUserID);
  }


  Future<List<ActiveChatsModel>> getActiveChats(String userID) async {
    return await _userRepository.getActiveChats(userID);
  }

  Future<List<UserModel>> getUsersWithPagination(
      String currentUsername, UserModel? lastUser, int bringItemCount) async {
    List<UserModel> tumKullaniciListesi = await _userRepository
        .getUsersWithPagination(currentUsername, lastUser, bringItemCount);
    return tumKullaniciListesi;
  }
}
