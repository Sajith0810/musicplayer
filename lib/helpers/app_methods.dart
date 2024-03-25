import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class AppMethods {
  static final AppMethods _appMethods = AppMethods._internal();

  factory AppMethods() {
    return _appMethods;
  }

  AppMethods._internal();

  getWidth(context) {
    return MediaQuery.of(context).size.width;
  }

  getHeight(context) {
    return MediaQuery.of(context).size.height;
  }

  Uint8List imageConversion(String? img) {
    List<int> image = json.decode(img!).cast<int>();
    return Uint8List.fromList(image);
  }

  showAlert({required BuildContext context, required String message}) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Alert"),
          content: Text(message.toString()),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            FilledButton(
              onPressed: () async {
                await openAppSettings();
              },
              child: const Text("OpenApp Settings"),
            ),
          ],
        );
      },
    );
  }
}
