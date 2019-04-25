import 'package:flutter/material.dart';
import 'dart:io';

import '../scoped_models/MainModel.dart';

class NowPlayingCard extends StatelessWidget {
  final BuildContext context;
  final MainModel model;
  final int index;

  NowPlayingCard(
      {@required this.context, @required this.model, @required this.index});

  Widget _buildSongAvatar() {
    String _imageURL = model.songsList[index].albumArt;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        padding: EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          image: DecorationImage(
              image: _imageURL == null
                  ? AssetImage('assets/images/AppLogo.png')
                  : FileImage(File(Uri.parse(_imageURL).toString())),
              fit: BoxFit.contain),
        ),
      ),
    );
  }

  Widget _buildSongName() {
    String _songTitle = model.songsList[index].title;
    return Flexible(
      fit: FlexFit.tight,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.0),
        child: Text(_songTitle.length >= 15
            ? _songTitle.substring(0, 15) + '...'
            : _songTitle),
      ),
    );
  }

  Widget _buildControlButtons() {
    return Container(
        margin: EdgeInsets.only(right: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.skip_previous, color: Colors.grey),
            ),
            IconButton(
              onPressed: () => model.stopPlayback(),
              icon: Icon(Icons.stop, color: Colors.grey),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.skip_next, color: Colors.grey),
            )
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 20.0,
      shadowColor: Colors.black,
      child: Container(
        color: Colors.black.withOpacity(0.1),
        padding: EdgeInsets.only(top: 0.5),
        child: GestureDetector(
          onTap: () {
            // model.stopPlayback();
          },
          child: Container(
            color: Color.fromRGBO(244, 244, 244, 1),
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _buildSongAvatar(),
                SizedBox(width: 10),
                _buildSongName(),
                _buildControlButtons()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
