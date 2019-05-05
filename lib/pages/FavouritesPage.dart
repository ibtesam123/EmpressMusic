import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../scoped_models/MainModel.dart';
import '../widgets/SongCard.dart';

class FavouritesPage extends StatefulWidget {
  @override
  _FavouritesPageState createState() => _FavouritesPageState();
}

class _FavouritesPageState extends State<FavouritesPage> {
  Widget _buildFavouriteList() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return ListView.builder(
          itemCount: model.favourites.length,
          itemBuilder: (BuildContext context, int index) {
            return SongCard(
              context: context,
              ifPlayAndPop: false,
              index: index,
              model: model,
              songsList: model.favourites,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(child: _buildFavouriteList());
  }
}
