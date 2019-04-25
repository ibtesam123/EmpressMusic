import 'package:flutter/material.dart';
import 'dart:io';

import '../scoped_models/MainModel.dart';

class SongCard extends StatelessWidget {
  final BuildContext context;
  final int index;
  final MainModel model;

  SongCard(
      {@required this.context, @required this.index, @required this.model});

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
      child: Text(
        model.songsList[index].title,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildSongCard() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: FlatButton(
        onPressed: () async {
          model.playSong(model.songsList[index], index);
        },
        padding: EdgeInsets.symmetric(vertical: 25.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            SizedBox(width: 10.0),
            _buildSongAvatar(model.songsList[index].albumArt),
            SizedBox(width: 10.0),
            _buildSongName(),
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
