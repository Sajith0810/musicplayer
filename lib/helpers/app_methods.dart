import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

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
    return showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text("Alert"),
        content: Text(message.toString()),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("okay"),
          ),
        ],
      ),
    );
  }
}
