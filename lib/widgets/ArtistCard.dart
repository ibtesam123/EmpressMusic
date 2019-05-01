import 'package:flutter/material.dart';

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
    return PopupMenuButton(
      itemBuilder: (BuildContext context) {
        return <PopupMenuItem>[
          PopupMenuItem(
            child: Text('Item 1'),
            value: 'item 1',
          ),
          PopupMenuItem(
            child: Text('Item 2'),
            value: 'item2',
          )
        ];
      },
      icon: Icon(Icons.more_vert, color: Colors.black),
    );
    //TODO: Implement this
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
