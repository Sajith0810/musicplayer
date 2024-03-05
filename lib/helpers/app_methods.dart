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

  showAlert({required context, required String message}) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog.adaptive(
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
