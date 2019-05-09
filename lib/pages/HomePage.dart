import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'dart:io';

import '../utils/themes/HomeTheme.dart';
import './FavouritesPage.dart';
import './AlbumsPage.dart';
import './TracksPage.dart';
import './ArtistsPage.dart';
import '../scoped_models/MainModel.dart';
import '../utils/enums/PlayerStateEnum.dart';
import '../widgets/NowPlayingCard.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PageController _pageController;
  int _currentPage;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 1);
    _currentPage = 1;
  }

  Widget _buildAppBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(110),
      child: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[
                  HomeThemeLight.appBarGradient1,
                  HomeThemeLight.appBarGradient2
                ],
              ),
            ),
          ),
          ListView(
            physics: NeverScrollableScrollPhysics(),
            children: <Widget>[
              AppBar(
                backgroundColor: Colors.red.withAlpha(0),
                elevation: 0.0,
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      //TODO: Implement Logic here
                    },
                  ),
                  // PopupMenuButton(
                  //   itemBuilder: (context) {
                  //     return <PopupMenuItem>[
                  //       PopupMenuItem(
                  //         child: Text('Item 1'),
                  //         value: 'item 1',
                  //       ),
                  //       PopupMenuItem(
                  //         child: Text('Item 2'),
                  //         value: 'item 2',
                  //       ),
                  //       PopupMenuItem(
                  //         child: Text('Item 3'),
                  //         value: 'item 3',
                  //       ),
                  //     ];
                  //   },
                  //   onSelected: (dynamic value) {
                  //     print(value);
                  //     //TODO: Implement Logic
                  //   },
                  // )
                ],
              ),
              AppBar(
                title: Text(
                  'Music',
                  //TODO: Change the font face
                  style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0.0,
                titleSpacing: 12.0,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSinglePageWidget(Widget title, bool isSelected, int pageNo) {
    double _bottomLineWidth;
    switch (pageNo) {
      case 0:
        _bottomLineWidth = 20;
        break;
      case 1:
        _bottomLineWidth = 40;
        break;
      case 2:
        _bottomLineWidth = 45;
        break;
      case 3:
        _bottomLineWidth = 40;
        break;
    }
    return isSelected
        ? Column(
            children: <Widget>[
              FlatButton(
                child: title,
                onPressed: () => _pageController.jumpToPage(pageNo),
                splashColor: Colors.transparent,
              ),
              Container(
                height: 2,
                width: _bottomLineWidth,
                decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.all(Radius.circular(8))),
              ),
            ],
          )
        : Column(
            children: <Widget>[
              FlatButton(
                child: title,
                onPressed: () => _pageController.jumpToPage(pageNo),
                splashColor: Colors.transparent,
              ),
              Container(
                height: 2,
                width: _bottomLineWidth,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8))),
              ),
            ],
          );
  }

  List<Widget> _buildPageWidgets() {
    return <Widget>[
      _currentPage == 0
          ? _buildSinglePageWidget(
              Icon(
                Icons.favorite,
                color: Colors.blue,
                size: 18,
              ),
              true,
              0)
          : _buildSinglePageWidget(
              Icon(
                Icons.favorite,
                size: 18,
              ),
              false,
              0),
      _currentPage == 1
          ? _buildSinglePageWidget(
              Text('Tracks',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue)),
              true,
              1)
          : _buildSinglePageWidget(
              Text('Tracks',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              false,
              1),
      _currentPage == 2
          ? _buildSinglePageWidget(
              Text('Albums',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue)),
              true,
              2)
          : _buildSinglePageWidget(
              Text('Albums',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              false,
              2),
      _currentPage == 3
          ? _buildSinglePageWidget(
              Text('Artists',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue)),
              true,
              3)
          : _buildSinglePageWidget(
              Text('Artists',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              false,
              3),
    ];
  }

  Widget _buildPageTitle() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Material(
        elevation: 1,
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              children: _buildPageWidgets(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageView() {
    return Expanded(
      child: PageView(
        controller: _pageController,
        onPageChanged: (int position) {
          this.setState(() {
            _currentPage = position;
          });
        },
        children: <Widget>[
          FavouritesPage(),
          TracksPage(),
          AlbumsPage(),
          ArtistsPage(),
        ],
      ),
    );
  }

  Widget _buildBody(MainModel model) {
    if (model.isAvailable) {
      return _buildPageView();
    } else {
      model.initMusicPlayer();
      return Expanded(child: Center(child: Text('Fetching your songs...')));
    }
  }

  Widget _buildNowPlaying(MainModel model, BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        model.playerState == PlayerState.PLAYING ||
                model.playerState == PlayerState.PAUSED
            ? NowPlayingCard(
                context: context,
                index: model.currentIndex,
                model: model,
              )
            : Container(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return WillPopScope(
          onWillPop: () {
            showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Exiting will stop the Playback'),
                    content: Text('Are you sure you want to exit?'),
                    actions: <Widget>[
                      FlatButton(
                        child: Text('OK'),
                        onPressed: () {
                          model.stopPlayback();
                          exit(0);
                        },
                      ),
                      FlatButton(
                        child: Text('Cancel'),
                        onPressed: () => Navigator.of(context).pop(),
                      )
                    ],
                  );
                });
          },
          child: Scaffold(
            appBar: _buildAppBar(),
            body: Stack(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    _buildPageTitle(),
                    _buildBody(model),
                  ],
                ),
                _buildNowPlaying(model, context)
              ],
            ),
          ),
        );
      },
    );
  }
}
