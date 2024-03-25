// To parse this JSON data, do
//
//     final temperatures = temperaturesFromMap(jsonString);

import 'dart:convert';

SongsModel songsModelFromMap(String str) => SongsModel.fromMap(json.decode(str));

String songsModelToMap(SongsModel data) => json.encode(data.toMap());

class SongsModel {
  final String? trackName;
  final List<String>? trackArtistNames;
  final String? albumName;
  final String? albumArtistName;
  final String? trackNumber;
  final String? albumLength;
  final String? year;
  final String? genre;
  final String? authorName;
  final String? writerName;
  final String? discNumber;
  final String? mimeType;
  final String? trackDuration;
  final String? bitrate;
  final String? albumArt;
  final String file;

  SongsModel(
      {this.trackName,
      this.trackArtistNames,
      this.albumName,
      this.albumArtistName,
      this.trackNumber,
      this.albumLength,
      this.year,
      this.genre,
      this.authorName,
      this.writerName,
      this.discNumber,
      this.mimeType,
      this.trackDuration,
      this.bitrate,
      this.albumArt,
      required this.file});

  factory SongsModel.fromMap(Map<String, dynamic> json) => SongsModel(
      trackName: json["trackName"],
      trackArtistNames: json["trackArtistNames"] == [] || json["trackArtistNames"] == null ? [] : json["trackArtistNames"].split(","),
      albumName: json["albumName"],
      albumArtistName: json["albumArtistName"],
      trackNumber: json["trackNumber"],
      albumLength: json["albumLength"],
      year: json["year"],
      genre: json["genre"],
      authorName: json["authorName"],
      writerName: json["writerName"],
      discNumber: json["discNumber"],
      mimeType: json["mimeType"],
      trackDuration: json["trackDuration"],
      bitrate: json["bitrate"],
      albumArt: json["albumArt"].toString(),
      file: json["file"]);

  Map<String, dynamic> toMap() => {
        "trackName": trackName,
        "trackArtistNames": trackArtistNames,
        "albumName": albumName,
        "albumArtistName": albumArtistName,
        "trackNumber": trackNumber,
        "albumLength": albumLength,
        "year": year,
        "genre": genre,
        "authorName": authorName,
        "writerName": writerName,
        "discNumber": discNumber,
        "mimeType": mimeType,
        "trackDuration": trackDuration,
        "bitrate": bitrate,
        "albumArt": albumArt,
        "file": file
      };
}
