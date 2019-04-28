import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'dart:io';

import '../scoped_models/MainModel.dart';
import '../widgets/SongCard.dart';

class AlbumSongListPage extends StatefulWidget {
  final int albumID;
  AlbumSongListPage({@required this.albumID});
  @override
  _AlbumSongListPageState createState() => _AlbumSongListPageState();
}

class _AlbumSongListPageState extends State<AlbumSongListPage> {
  Widget _buildSongList(MainModel model) {
    return ListView.builder(
      itemCount: model.albumsList[widget.albumID].length,
      itemBuilder: (BuildContext context, int index) {
        return Column(
          children: <Widget>[
            SongCard(
              context: context,
              songsList: model.albumsList[widget.albumID],
              index: index,
              model: model,
              ifPlayAndPop: true,
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              color: Colors.black.withOpacity(0.5),
              height: 0.2,
            ),
          ],
        );
      },
    );
  }

  Widget _buildAlbumBackground(String albumArtUri) {
    return Stack(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: albumArtUri != null
                    ? FileImage(File.fromUri(Uri.parse(albumArtUri)))
                    : AssetImage('assets/images/AppLogo.png'),
                fit: BoxFit.cover),
          ),
        ),
        Container(
            decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.transparent, Colors.black54],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
        ))
      ],
    );
  }

  Widget _buildTitle(String albumName) {
    if (albumName.length > 20) {
      albumName = albumName.substring(0, 20) + '...';
    }
    return Text(
      albumName,
      style: TextStyle(color: Colors.white, fontSize: 15.0),
      overflow: TextOverflow.fade,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        String _albumName = model.albumsList[widget.albumID][0].album;
        String _albumArtUri = model.albumsList[widget.albumID][0].albumArt;
        return Scaffold(
          body: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxisScrolled) {
              return <Widget>[
                SliverAppBar(
                  expandedHeight: 150.0,
                  floating: false,
                  pinned: true,
                  forceElevated: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: _buildTitle(_albumName),
                    background: _buildAlbumBackground(_albumArtUri),
                  ),
                )
              ];
            },
            body: _buildSongList(model),
          ),
        );
      },
    );
  }
}
