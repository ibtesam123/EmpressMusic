import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../scoped_models/MainModel.dart';

class ArtistCard extends StatelessWidget {
  final BuildContext context;
  final String artistName;
  final MainModel model;

  ArtistCard(
      {@required this.context,
      @required this.artistName,
      @required this.model});

  Widget _buildArtistAvatar() {
    return CircleAvatar(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.asset(
          'assets/images/Artist.png',
          fit: BoxFit.contain,
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.blueAccent,
    );
  }

  Widget _buildArtistName() {
    return Expanded(
      child: Text(
        artistName,
        overflow: TextOverflow.ellipsis,
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
          icon: Icon(
            Icons.more_vert,
            color: Colors.black.withOpacity(0.7),
          ),
          onSelected: (dynamic value) {
            switch (value) {
              case 0:
                model.addListToFavourites(model.artistList[artistName]);
                break;
              case 1:
                model.setSongsList(model.artistList[artistName], false);
                break;
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _buildArtistAvatar(),
              SizedBox(width: 10.0),
              _buildArtistName(),
              _buildPopupButton(),
            ],
          )),
    );
  }
}
