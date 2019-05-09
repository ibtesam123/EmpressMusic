import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../scoped_models/MainModel.dart';
import '../widgets/SongCard.dart';

class PlaylistSongListPage extends StatefulWidget {
  @override
  _PlaylistSongListPageState createState() => _PlaylistSongListPageState();
}

class _PlaylistSongListPageState extends State<PlaylistSongListPage> {
  Widget _buildPlayList() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return ListView.builder(
          itemCount: model.songsList.length,
          itemBuilder: (BuildContext context, int index) {
            return SongCard(
              context: context,
              ifPlayAndPop: true,
              index: index,
              model: model,
              songsList: model.songsList,
              fromPlaylist: true,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildPlayList(),
    );
  }
}
