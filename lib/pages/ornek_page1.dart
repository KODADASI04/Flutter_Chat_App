import 'package:flutter/material.dart';
import 'package:flutter_canli_sohbet_uygulamasi/pages/ornek_page2.dart';

class OrnekPage1 extends StatelessWidget {
  const OrnekPage1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ornek Sayfa 1"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const OrnekPage2(),
                  fullscreenDialog: true,
                ),
              );
            },
            icon: const Icon(Icons.arrow_forward_ios),
          ),
        ],
      ),
    );
  }
}
