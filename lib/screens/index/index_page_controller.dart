import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mp3player/helpers/app_methods.dart';
import 'package:permission_handler/permission_handler.dart';

import '../home/home_page_controller.dart';

final indexPageProvider = Provider((ref) => IndexPageController(ref: ref));
final pageChangerProvider = StateProvider<int>((ref) => 0);

class IndexPageController {
  final Ref ref;

  const IndexPageController({required this.ref});

  Future<bool> checkPermission(context) async {
    Map<Permission, PermissionStatus> status = {
      Permission.storage: await Permission.storage.status,
    };
    status.forEach((key, value) async {
      if (status[key] != PermissionStatus.granted) {
        print("permission");
        final accessSongs = await key.request();
        if (accessSongs.isGranted) {
          ref.read(homePageControllerProvider).getDBSongs();
          final mp3Songs = ref.read(mp3SongListProvider);
          if (mp3Songs.isEmpty) {
            ref.read(homePageControllerProvider).scanAllMp3Files();
          }
        } else {
          AppMethods().showAlert(context: context, message: "Storage permission is required");
        }
      }
    });
    return true;
  }
}
