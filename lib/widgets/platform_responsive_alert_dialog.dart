import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_canli_sohbet_uygulamasi/widgets/platform_responsive_widget.dart';

class PlatformResponsiveAlertDialog extends PlatformResponsiveWidget {
  final String baslik;
  final String icerik;
  final List<String> buttonTexts;
  final List<Function(BuildContext context)> buttonActions;
  const PlatformResponsiveAlertDialog({
    required this.baslik,
    required this.icerik,
    this.buttonTexts = const [],
    this.buttonActions = const [],
    super.key,
  }) : assert(buttonActions.length == buttonTexts.length);

  @override
  Widget buildAndroidWidget(BuildContext context) {
    return AlertDialog(
      title: Text(baslik),
      content: Text(icerik),
      actions: [
        for (int i = 0; i < buttonTexts.length; i++)
          TextButton(
            onPressed: () => buttonActions[i](context),
            child: Text(buttonTexts[i]),
          ),
      ],
    );
  }

  @override
  Widget buildIOSWidget(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(baslik),
      content: Text(icerik),
      actions: [
        for (int i = 0; i < buttonTexts.length; i++)
          CupertinoDialogAction(
            onPressed: () => buttonActions[i](context),
            child: Text(buttonTexts[i]),
          ),
      ],
    );
  }

  Future<bool?> goster(BuildContext context) async {
    return Platform.isIOS
        ? await showCupertinoDialog<bool>(
            context: context,
            builder: (context) => this,
          )
        : await showDialog<bool>(
            context: context,
            builder: (context) => this,
          );
    //this ile o an oluşturulan nesneden bu fonksiyona eriştiğimizde oluşturmuş olduğumuz nesneye direk erişiriz.
  }
}
