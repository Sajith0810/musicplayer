import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

final indexPageProvider = Provider((ref) => IndexPageController(ref: ref));
final pageChangerProvider = StateProvider<int>((ref) => 0);

class IndexPageController {
  final Ref ref;

  const IndexPageController({required this.ref});

  Future<bool> checkPermission() async {
    Map<Permission, PermissionStatus> status = {
      Permission.storage: await Permission.storage.status,
    };
    status.forEach((key, value) async {
      if (status[key] != PermissionStatus.granted) {
        print("permission");
        await key.request();
      }
    });
    return true;
  }
}
