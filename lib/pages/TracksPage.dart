import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../models/SongModel.dart';
import '../scoped_models/MainModel.dart';
import '../widgets/SongCard.dart';

class TracksPage extends StatefulWidget {
  @override
  _TracksPageState createState() => _TracksPageState();
}

class _TracksPageState extends State<TracksPage> {
  
  Widget _buildSongsList(List<SongModel> songList, MainModel model) {
    return ListView.builder(
      itemCount: songList.length,
      itemBuilder: (BuildContext context, int index) {
        return Column(
          children: <Widget>[
            SongCard(
              context: context,
              index: index,
              model: model,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 0.2,
              child: Container(color: Colors.black.withOpacity(0.5)),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return _buildSongsList(model.songsList, model);
      },
    );
  }
}
