import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/song_model.dart';

class DbHelper {
  static final DbHelper _dbHelper = DbHelper._internal();
  late Database database;

  factory DbHelper() {
    return _dbHelper;
  }

  DbHelper._internal();

  initDB() async {
    WidgetsFlutterBinding.ensureInitialized();
    database = await openDatabase(
      join(await getDatabasesPath(), 'songs.db'),
      onCreate: (db, version) async {
        await db.execute(
            'CREATE TABLE IF NOT EXISTS songData (trackName VARCHAR, trackArtistNames VARCHAR, albumName VARCHAR, albumArtistName VARCHAR, trackNumber VARCHAR, albumLength VARCHAR, year VARCHAR, genre VARCHAR, authorName VARCHAR, writerName VARCHAR, discNumber VARCHAR, mimeType VARCHAR, trackDuration VARCHAR, bitrate VARCHAR, albumArt VARCHAR)');
      },
      version: 1,
    );
  }

  insertSong(List<SongsModel> songs) async {
    for (SongsModel song in songs) {
      await database.execute(
        "INSERT OR REPLACE INTO songData (trackName,trackArtistNames,albumName,albumArtistName,trackNumber,albumLength,year,genre,authorName,writerName,discNumber,mimeType,trackDuration,bitrate,albumArt) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
        [
          song.trackName,
          song.trackArtistNames?.join(","),
          song.albumName,
          song.albumArtistName,
          song.trackNumber.toString(),
          song.albumLength.toString(),
          song.year.toString(),
          song.genre,
          song.authorName,
          song.writerName,
          song.discNumber.toString(),
          song.mimeType,
          song.trackNumber.toString(),
          song.bitrate.toString(),
          song.albumArt,
        ],
      );
    }
  }

  Future<List<SongsModel>> getSongs() async {
    List<SongsModel> data = [];
    final songs = await database.rawQuery("select * from songData");
    for (final element in songs) {
      data.add(SongsModel.fromMap(element));
    }
    return data;
  }
}
