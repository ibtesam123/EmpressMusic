import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../scoped_models/MainModel.dart';
import '../widgets/ArtistCard.dart';
import './ArtistSongListPage.dart';

class ArtistsPage extends StatefulWidget {
  @override
  _ArtistsPageState createState() => _ArtistsPageState();
}

class _ArtistsPageState extends State<ArtistsPage> {
  Widget _buildArtistList(MainModel model) {
    return ListView.builder(
      itemCount: model.artistList.keys.length,
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => ArtistSongListPage(
                    artistName: model.artistList.keys.toList()[index],
                  ))),
          child: ArtistCard(
            context: context,
            model: model,
            artistName: model.artistList.keys.toList()[index],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return _buildArtistList(model);
      },
    );
  }
}
