import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mp3player/helpers/app_methods.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../home/home_page_controller.dart';

final indexPageProvider = Provider((ref) => IndexPageController(ref: ref));
final pageChangerProvider = StateProvider<int>((ref) => 0);

class IndexPageController {
  final Ref ref;

  const IndexPageController({required this.ref});

  checkAndroidVersion() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    return androidInfo.version.release;
  }

  Future<bool> checkPermission(context) async {
    String androidVersion = await checkAndroidVersion();
    Permission permission = int.parse(androidVersion) < 13 ? Permission.storage : Permission.audio;
    bool storageGranted = await permission.isGranted;
    if (storageGranted) {
      ref.read(homePageControllerProvider).getDBSongs();
      final mp3Songs = ref.read(mp3SongListProvider);
      if (mp3Songs.isEmpty) {
        await ref.read(homePageControllerProvider).scanAllMp3Files();
      }
      return true;
    } else {
      if (await permission.request().isGranted) {
        await ref.read(homePageControllerProvider).getDBSongs();
        final mp3Songs = ref.read(mp3SongListProvider);
        if (mp3Songs.isEmpty) {
          await ref.read(homePageControllerProvider).scanAllMp3Files();
        }
        return true;
      } else {
        await AppMethods().showAlert(context: context, message: "Storage permission is required");
        return false;
      }
    }
  }
}
