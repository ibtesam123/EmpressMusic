import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../scoped_models/MainModel.dart';
import '../widgets/AlbumCard.dart';
import './AlbumSongListPage.dart';

class AlbumsPage extends StatefulWidget {
  @override
  _AlbumsPageState createState() => _AlbumsPageState();
}

class _AlbumsPageState extends State<AlbumsPage> {
  List<Widget> _buildGridViewChildren(MainModel model) {
    List<Widget> _albumContainers = List<Widget>();
    for (int id in model.albumsList.keys) {
      _albumContainers.add(GestureDetector(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) => AlbumSongListPage(albumID: id),
          ));
        },
        child: AlbumCard(
          context: context,
          model: model,
          albumID: id,
        ),
      ));
    }
    return _albumContainers;
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return GridView.extent(
          children: _buildGridViewChildren(model),
          maxCrossAxisExtent: (MediaQuery.of(context).size.width) / 2,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          padding: EdgeInsets.all(8.0),
        );
      },
    );
  }
}
