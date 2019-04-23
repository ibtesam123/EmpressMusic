import 'package:flutter/material.dart';

class SongModel {
  int id;
  String artist;
  String title;
  String album;
  int duration;
  String uri;
  String albumArt;

  SongModel(
      {@required this.id,
      @required this.artist,
      @required this.album,
      @required this.albumArt,
      @required this.duration,
      @required this.title,
      @required this.uri});
}