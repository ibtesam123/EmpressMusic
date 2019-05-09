import 'package:flutter/material.dart';
import 'dart:io';

import '../models/SongModel.dart';
import '../scoped_models/MainModel.dart';
import '../utils/enums/PlayerStateEnum.dart';
import '../pages/SongPage.dart';

class SongCard extends StatelessWidget {
  final BuildContext context;
  final int index;
  final List<SongModel> songsList;
  final MainModel model;
  final bool ifPlayAndPop;
  final bool fromPlaylist;

  SongCard(
      {@required this.context,
      @required this.index,
      @required this.songsList,
      @required this.model,
      @required this.ifPlayAndPop,
      @required this.fromPlaylist});

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

  Widget _buildSongName() {
    return Flexible(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            width: double.infinity,
            child: Text(
              songsList[index].title,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),
          ),
          SizedBox(height: 3),
          Container(
            width: double.infinity,
            child: Text(
              songsList[index].artist,
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDuration() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        model
            .getDurationText(Duration(milliseconds: songsList[index].duration)),
        style: TextStyle(fontWeight: FontWeight.normal),
      ),
    );
  }

  Widget _buildSongCard() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: FlatButton(
        onPressed: () async {
          if (fromPlaylist) {
            if (ifPlayAndPop) Navigator.of(context).pop();
            model.setPlayerState(PlayerState.PLAYING);
            model.startPlayback(index);
          } else {
            if (ifPlayAndPop) Navigator.of(context).pop();
            model.setSongsList(songsList, true);
            model.setPlayerState(PlayerState.PLAYING);
            model.startPlayback(index);
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => SongPage()));
          }
        },
        padding: EdgeInsets.symmetric(vertical: 25.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            SizedBox(width: 10.0),
            _buildSongAvatar(songsList[index].albumArt),
            SizedBox(width: 10.0),
            _buildSongName(),
            _buildDuration(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildSongCard();
  }
}
