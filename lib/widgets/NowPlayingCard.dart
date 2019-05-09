import 'package:flutter/material.dart';
import 'dart:io';

import '../scoped_models/MainModel.dart';
import '../utils/enums/PlayerStateEnum.dart';
import '../pages/SongPage.dart';

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
    String _songArtist = model.songsList[index].artist;
    _songArtist = _songArtist.length > 15
        ? _songArtist.substring(0, 15) + '...'
        : _songArtist;
    return Flexible(
      fit: FlexFit.tight,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              _songTitle.length >= 15
                  ? _songTitle.substring(0, 15) + '...'
                  : _songTitle,
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),
            SizedBox(height: 3.0),
            Text(
              _songArtist,
              style: TextStyle(fontSize: 12.0),
              textAlign: TextAlign.left,
            ),
          ],
        ),
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
              onPressed: () {
                model.startPlayback(model.previousSong());
              },
              icon: Icon(Icons.skip_previous, color: Colors.grey),
            ),
            IconButton(
              onPressed: () => model.playerState == PlayerState.PLAYING
                  ? model.pausePlayback()
                  : model.resumePlayback(),
              icon: Icon(
                  model.playerState == PlayerState.PLAYING
                      ? Icons.pause
                      : Icons.play_arrow,
                  color: Colors.grey,
                  size: 30.0),
            ),
            IconButton(
              onPressed: () {
                model.startPlayback(model.nextSong());
              },
              icon: Icon(Icons.skip_next, color: Colors.grey),
            )
          ],
        ));
  }

  // Widget _buildProgressBar() {
  //   return Container(
  //     width: MediaQuery.of(context).size.width * model.percentageCompletion(),
  //     height: 2.0,
  //     color: Colors.blue,
  //   );
  // }

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
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => SongPage()));
          },
          child: Container(
            color: Color.fromRGBO(244, 244, 244, 1),
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    _buildSongAvatar(),
                    SizedBox(width: 10),
                    _buildSongName(),
                    _buildControlButtons()
                  ],
                ),

                // _buildProgressBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
