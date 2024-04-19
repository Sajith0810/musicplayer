import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mp3player/helpers/app_methods.dart';
import 'package:mp3player/helpers/db_helper.dart';
import 'package:mp3player/models/song_model.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';

final homePageControllerProvider = Provider((ref) => HomePageController(ref: ref));
final mp3SongListProvider = StateProvider<List<SongsModel>>((ref) => []);
final scanPageLoaderProvider = StateProvider<bool>((ref) => false);
final selectedSongProvider = StateProvider<SongsModel?>((ref) => null);
final selectedSongIndexProvider = StateProvider<int>((ref) => 0);
final sliderValueProvider = StateProvider<double>((ref) => 0.0);
final songMaxValueProvider = StateProvider<double>((ref) => 1.0);
final isPlayingProvider = StateProvider((ref) => false);
final isRepeatModeProvider = StateProvider<bool>((ref) => false);
final textFieldSwithcerProvider = StateProvider<bool>((ref) => false);
final isShuffleEnabledPRovider = StateProvider<bool>((ref) => false);
final isPermissionGrantedShimmerProvider = StateProvider<bool>((ref) => false);

final audioPlayerControllerProvider = Provider((ref) => AudioPlayerController(ref: ref));

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
      var withAndroidFolders = Directory(path).listSync();
      for (FileSystemEntity dirFile in withAndroidFolders) {
        if (Directory(dirFile.path).statSync().type == FileSystemEntityType.directory) {
          if (!dirFile.path.contains("Android") && await dirFile.exists()) {
            if (dirFile is File && dirFile.path.endsWith(".mp3")) {
              final metaData = await MetadataRetriever.fromFile(dirFile);
              if (metaData.trackName != null) {
                addToModel(songs: songs, metaData: metaData, file: dirFile);
              }
            } else {
              var lister = Directory(dirFile.path).list(recursive: true);
              await for (FileSystemEntity songFile in lister) {
                if (songFile is File && songFile.path.endsWith(".mp3")) {
                  print("file : ${songFile.path}");
                  final metaData = await MetadataRetriever.fromFile(songFile);
                  if (metaData.trackName != null) {
                    addToModel(songs: songs, metaData: metaData, file: songFile);
                  }
                }
              }
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

  addToModel({required List<SongsModel> songs, required Metadata metaData, required File file}) {
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
        file: file.path,
      ),
    );
  }

  getDBSongs() async {
    final data = await DbHelper().getSongs();
    ref.read(mp3SongListProvider.notifier).state = data;
    return data;
  }

  deleteSongs({required SongsModel song, required int index, required context}) async {
    final selectedSongPath = File("/${song.file}");
    if (await selectedSongPath.exists()) {
      await selectedSongPath.delete();
      final oldSongs = ref.read(mp3SongListProvider);
      oldSongs.removeAt(index);
      ref.refresh(mp3SongListProvider);
      ref.read(mp3SongListProvider.notifier).state = oldSongs;
    } else {
      AppMethods().showAlert(
        context: context,
        message: "Song doesn't exist",
      );
    }
  }
}

class AudioPlayerController {
  final Ref ref;
  final audioPlayer = AudioPlayer();

  AudioPlayerController({required this.ref}) {
    print("init called");
    audioPlayer.onDurationChanged.listen((event) {
      ref.read(songMaxValueProvider.notifier).state = event.inSeconds.toDouble();
    });
    audioPlayer.onPositionChanged.listen((event) {
      ref.read(sliderValueProvider.notifier).state = event.inSeconds.toDouble();
    });
    audioPlayer.onPlayerComplete.listen((event) {
      changeSong();
    });
  }

  playSong({required String songPath}) async {
    await audioPlayer.play(DeviceFileSource(songPath));
  }

  String convertSecondsToMinutes(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;

    String formattedMinutes = minutes.toString().padLeft(2, '0');
    String formattedSeconds = remainingSeconds.toString().padLeft(2, '0');

    return "$formattedMinutes:$formattedSeconds";
  }

  resumeSong() async {
    await audioPlayer.resume();
  }

  pauseSong() async {
    await audioPlayer.pause();
  }

  seekSong({required int seekedPosition}) {
    ref.read(sliderValueProvider.notifier).state = seekedPosition.toDouble();
    audioPlayer.seek(Duration(seconds: seekedPosition));
  }

  changeSong({bool isForward = true}) {
    final totalSong = ref.read(mp3SongListProvider);
    final selectedSongIndex = ref.read(selectedSongIndexProvider);
    final isRepeat = ref.read(isRepeatModeProvider);
    if (isRepeat) {
      ref.read(selectedSongIndexProvider.notifier).state = selectedSongIndex;
      ref.read(selectedSongProvider.notifier).state = totalSong[ref.read(selectedSongIndexProvider)];
    } else {
      if (isForward) {
        if (selectedSongIndex < totalSong.length - 1) {
          ref.read(selectedSongIndexProvider.notifier).state = selectedSongIndex + 1;
          ref.read(selectedSongProvider.notifier).state = totalSong[ref.read(selectedSongIndexProvider)];
        } else {
          ref.read(selectedSongIndexProvider.notifier).state = 0;
          ref.read(selectedSongProvider.notifier).state = totalSong[ref.read(selectedSongIndexProvider)];
        }
      } else {
        if (selectedSongIndex == 0) {
          ref.read(selectedSongIndexProvider.notifier).state = totalSong.length - 1;
          ref.read(selectedSongProvider.notifier).state = totalSong[ref.read(selectedSongIndexProvider)];
        } else {
          ref.read(selectedSongIndexProvider.notifier).state = selectedSongIndex - 1;
          ref.read(selectedSongProvider.notifier).state = totalSong[ref.read(selectedSongIndexProvider)];
        }
      }
    }
    pauseSong();
    playSong(songPath: ref.read(selectedSongProvider)!.file);
    ref.read(isPlayingProvider.notifier).state = true;
  }

  shuffleSongs() async {
    final sortedSongs = ref.read(mp3SongListProvider);
    sortedSongs.shuffle();
    ref.refresh(mp3SongListProvider);
    ref.read(mp3SongListProvider.notifier).state = sortedSongs;
    ref.read(isShuffleEnabledPRovider.notifier).state = true;
  }

  sortSongs() {
    final shuffledSongs = ref.read(mp3SongListProvider);
    shuffledSongs.sort((a, b) => a.trackName.toString().compareTo(b.trackName.toString()));
    ref.refresh(mp3SongListProvider);
    ref.read(mp3SongListProvider.notifier).state = shuffledSongs;
    ref.read(isShuffleEnabledPRovider.notifier).state = false;
  }
}
