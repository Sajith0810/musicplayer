import 'dart:typed_data';

import 'package:device_info_plus/device_info_plus.dart';
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

  Uint8List imageConversion(String str) {
    final List<int> codeUnits = str.codeUnits;
    final Uint8List unit8List = Uint8List.fromList(codeUnits);

    return unit8List;
  }

  checkAndroidVersion() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    return androidInfo.version.release;
  }

  showAlert({required BuildContext context, required String message}) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Alert"),
          content: Text(message.toString()),
          actionsAlignment: MainAxisAlignment.spaceBetween,
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
