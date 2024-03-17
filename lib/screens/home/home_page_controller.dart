import 'dart:io';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mp3player/helpers/db_helper.dart';
import 'package:mp3player/models/song_model.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';

final homePageControllerProvider = Provider((ref) => HomePageController(ref: ref));
final mp3SongListProvider = StateProvider<List<SongsModel>>((ref) => []);
final scanPageLoaderProvider = StateProvider<bool>((ref) => false);

class HomePageController {
  final Ref ref;

  const HomePageController({required this.ref});

  Future<void> scanAllMp3Files() async {
    ref.read(scanPageLoaderProvider.notifier).state = true;
    List<SongsModel> songs = [];
    String path = "";
    List<String> filePath = [];
    final dir = await getExternalStorageDirectories();
    for (Directory i in dir!) {
      final data = i.path.split("/");
      if (data.contains("0")) {
        path = "${data[1]}/${data[2]}/${data[3]}";
        filePath.add(path);
      } else {
        path = "${data[1]}/${data[2]}";
        filePath.add(path);
      }
    }
    for (String path in filePath) {
      var withAndroidFolders = Directory(path).list();
      await for (FileSystemEntity file in withAndroidFolders) {
        if (!file.path.contains("Android")) {
          var lister = Directory(file.path).list(recursive: true);
          await for (FileSystemEntity file in lister) {
            if (file is File && file.path.endsWith(".mp3")) {
              print("file : ${file.path}");
              final metaData = await MetadataRetriever.fromFile(file);
              songs.add(
                SongsModel(
                  trackName: metaData.trackName,
                  trackArtistNames: metaData.trackArtistNames,
                  albumName: metaData.albumName,
                  albumArtistName: metaData.albumArtistName,
                  trackNumber: metaData.trackNumber.toString(),
                  albumLength: metaData.albumLength.toString(),
                  year: metaData.year.toString(),
                  genre: metaData.genre,
                  authorName: metaData.authorName,
                  writerName: metaData.writerName,
                  discNumber: metaData.discNumber.toString(),
                  mimeType: metaData.mimeType,
                  trackDuration: metaData.trackDuration.toString(),
                  bitrate: metaData.bitrate.toString(),
                  albumArt: metaData.albumArt.toString(),
                ),
              );
            }
          }
        }
      }
    }
    songs.sort((a, b) => a.trackName.toString().compareTo(b.trackName.toString()));
    ref.read(mp3SongListProvider.notifier).state = songs;
    await DbHelper().insertSong(songs);
    ref.read(scanPageLoaderProvider.notifier).state = false;
  }

  getDBSongs() async {
    final data = await DbHelper().getSongs();
    ref.read(mp3SongListProvider.notifier).state = data;
  }
}
