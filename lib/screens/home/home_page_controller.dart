import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      var withAndroidFolders = Directory(path).list();
      await for (FileSystemEntity dirFile in withAndroidFolders) {
        if (!dirFile.path.contains("Android")) {
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
        file: file,
      ),
    );
  }

  getDBSongs() async {
    final data = await DbHelper().getSongs();
    ref.read(mp3SongListProvider.notifier).state = data;
  }
}

class AudioPlayerController {
  final Ref ref;
  final audioPlayer = AudioPlayer();

  AudioPlayerController({required this.ref}) {
    audioPlayer.onPlayerComplete.listen((event) {});
    audioPlayer.onPositionChanged.listen((event) {
      ref.read(sliderValueProvider.notifier).state = event.inSeconds.toDouble();
    });
    audioPlayer.onDurationChanged.listen((event) {
      ref.read(songMaxValueProvider.notifier).state = event.inSeconds.toDouble();
    });
  }

  playSong({required String songPath}) {
    audioPlayer.play(DeviceFileSource(songPath));
  }

  pauseSong() {
    audioPlayer.pause();
  }

  seekSong({required int seekedPosition}) {
    ref.read(sliderValueProvider.notifier).state = seekedPosition.toDouble();
    audioPlayer.seek(Duration(seconds: seekedPosition));
  }

  changeSong({bool isForward = true}) {
    final totalSong = ref.read(mp3SongListProvider);
    final selectedSongIndex = ref.read(selectedSongIndexProvider);
    if (isForward) {
      if (selectedSongIndex < totalSong.length) {
        ref.read(selectedSongIndexProvider.notifier).state = selectedSongIndex + 1;
      } else {
        ref.read(selectedSongIndexProvider.notifier).state = 0;
      }
    } else {
      if (selectedSongIndex == 0) {
        ref.read(selectedSongIndexProvider.notifier).state = totalSong.length - 1;
      } else {
        ref.read(selectedSongIndexProvider.notifier).state = selectedSongIndex - 1;
      }
    }
  }
}
