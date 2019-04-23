import 'package:flutter/material.dart';
import 'dart:io';

import '../../scoped_models/MainModel.dart';

class SongCard extends StatelessWidget {
  final bool isNowPlaying;
  final BuildContext context;
  final int index;
  final MainModel model;

  SongCard(
      {@required this.isNowPlaying,
      @required this.context,
      @required this.index,
      @required this.model});

  Widget _buildSongAvatar(String albumArtUri) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
          padding: EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            image: DecorationImage(
                image: albumArtUri != null
                    ? FileImage(File.fromUri(Uri.parse(albumArtUri)))
                    : AssetImage('assets/images/AppLogo.png'),
                fit: BoxFit.contain),
          )),
    );
  }

  Widget _buildSongCard() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: FlatButton(
        onPressed: () async {
          isNowPlaying
              ? model.stopPlayback()
              : model.playSong(model.songsList[index], index);
        },
        padding: EdgeInsets.symmetric(vertical: 25.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            SizedBox(width: 10.0),
            _buildSongAvatar(model.songsList[index].albumArt),
            SizedBox(width: 10.0),
            Flexible(
              child: Text(
                model.songsList[index].title,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isNowPlaying
        ? Padding(
            padding: EdgeInsets.only(top: 1),
            child: Container(
              color: Colors.blue,
              child: _buildSongCard(),
            ),
          )
        : _buildSongCard();
  }
}
