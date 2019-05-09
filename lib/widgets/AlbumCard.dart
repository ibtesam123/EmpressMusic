import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'dart:io';

import '../scoped_models/MainModel.dart';
import '../models/SongModel.dart';

class AlbumCard extends StatelessWidget {
  final BuildContext context;
  final MainModel model;
  final int albumID;
  AlbumCard(
      {@required this.context, @required this.model, @required this.albumID});

  Widget _buildSongAvatar(String albumArtUri) {
    return Container(
        padding: EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          image: DecorationImage(
              image: albumArtUri != null
                  ? FileImage(File.fromUri(Uri.parse(albumArtUri)))
                  : AssetImage('assets/images/AppLogo.png'),
              fit: BoxFit.contain),
        ));
  }

  Widget _buildAlbumArt() {
    String _albumArt = model.albumsList[albumID][0].albumArt;
    return Container(
      child: _buildSongAvatar(_albumArt),
      color: _albumArt == null
          ? Color.fromRGBO(234, 98, 72, 1)
          : Colors.transparent,
    );
  }

  Widget _buildGradient() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [Colors.transparent, Colors.transparent, Colors.black],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter),
      ),
    );
  }

  Widget _buildPopupButton() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return PopupMenuButton(
          itemBuilder: (BuildContext context) {
            return <PopupMenuItem>[
              PopupMenuItem(
                child: Text('Add to favorites'),
                value: 0,
              ),
              PopupMenuItem(
                child: Text('Add to Now Playing'),
                value: 1,
              )
            ];
          },
          icon: Icon(Icons.more_vert, color: Colors.white),
          onSelected: (dynamic value) {
            switch (value) {
              case 0:
                model.addListToFavourites(model.albumsList[albumID]);
                break;
              case 1:
                model.setSongsList(model.albumsList[albumID], false);
                break;
            }
          },
        );
      },
    );
  }

  Widget _buildAlbumInfo() {
    String _albumName = model.albumsList[albumID][0].album;
    int _albumLength = model.albumsList[albumID].length;
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      _albumName.length > 15
                          ? _albumName.substring(0, 15) + '...'
                          : _albumName,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _albumLength == 1
                          ? _albumLength.toString() + ' song'
                          : _albumLength.toString() + ' songs',
                      style: TextStyle(color: Colors.white),
                    )
                  ],
                ),
              ),
            ),
            _buildPopupButton(),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        _buildAlbumArt(),
        _buildGradient(),
        _buildAlbumInfo(),
      ],
    );
  }
}
