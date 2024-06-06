import 'dart:isolate';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mp3player/helpers/app_methods.dart';
import 'package:permission_handler/permission_handler.dart';

import '../home/home_page_controller.dart';

final indexPageProvider = Provider((ref) => IndexPageController(ref: ref));
final pageChangerProvider = StateProvider<int>((ref) => 0);

class IndexPageController {
  final Ref ref;

  const IndexPageController({required this.ref});

  scanFiles() async {
    await ref.read(homePageControllerProvider).scanAllMp3Files();
  }

  Future<bool> checkPermission(context) async {
    String androidVersion = await AppMethods().checkAndroidVersion();
    Permission permission = int.parse(androidVersion.contains(".")
                ? androidVersion.split(".")[0]
                : androidVersion) <
            13
        ? Permission.storage
        : Permission.audio;
    bool storageGranted = await permission.isGranted;
    if (storageGranted) {
      ref.read(homePageControllerProvider).getDBSongs();
      final mp3Songs = ref.read(mp3SongListProvider);
      if (mp3Songs.isEmpty) {
        await scanFiles();
        final rp = ReceivePort();

        // await Isolate.run(() => );
      }
      return true;
    } else {
      if (await permission.request().isGranted) {
        await ref.read(homePageControllerProvider).getDBSongs();
        final mp3Songs = ref.read(mp3SongListProvider);
        if (mp3Songs.isEmpty) {
          await scanFiles();
          //await Isolate.run(() => scanFiles());
        }
        return true;
      } else {
        await AppMethods().showAlert(
            context: context, message: "Storage permission is required");
        return false;
      }
    }
  }
}
