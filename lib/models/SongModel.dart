import 'package:flutter/material.dart';

class SongModel {
  int id;
  String artist;
  String title;
  String album;
  int albumID;
  int duration;
  String uri;
  String albumArt;
  bool isFavourite;

  SongModel(
      {@required this.id,
      @required this.artist,
      @required this.album,
      @required this.albumArt,
      @required this.duration,
      @required this.title,
      @required this.uri,
      @required this.albumID,
      @required this.isFavourite});

  void setFavourite(bool status) {
    this.isFavourite = status;
  }
}
