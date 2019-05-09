import 'package:flutter/material.dart';
import 'dart:io';
import 'package:scoped_model/scoped_model.dart';

import '../scoped_models/MainModel.dart';
import '../utils/enums/PlayerStateEnum.dart';
import '../utils/themes/HomeTheme.dart';
import '../pages/PlaylistSongListPage.dart';

class SongPage extends StatefulWidget {
  @override
  _SongPageState createState() => _SongPageState();
}

class _SongPageState extends State<SongPage> {
  double _seekBarValue = 0.0;
  bool _isSeeking = false;

  Widget _buildAppBarBackground() {
    return Stack(
      children: <Widget>[
        Container(
          height: MediaQuery.of(context).size.height * 0.4,
          color: Colors.pinkAccent,
          width: double.infinity,
        ),
        AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          actions: <Widget>[
            PopupMenuButton(
              itemBuilder: (BuildContext context) {
                return <PopupMenuItem>[
                  PopupMenuItem(
                    child: Text('Item 1'),
                    value: 'Item 1',
                  ),
                  PopupMenuItem(
                    child: Text('Item 2'),
                    value: 'Item 2',
                  ),
                ];
              },
            )
          ],
        )
      ],
    );
  }

  Widget _buildAlbumArt() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return Align(
          alignment: Alignment.center,
          child: Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            elevation: 5.0,
            semanticContainer: true,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: Container(
              height: MediaQuery.of(context).size.width * 0.5,
              width: MediaQuery.of(context).size.width * 0.5,
              color: model.songsList[model.currentIndex].albumArt != null
                  ? Colors.transparent
                  : HomeThemeLight.appBarGradient1,
              child: model.songsList[model.currentIndex].albumArt != null
                  ? Image.file(
                      File.fromUri(Uri.parse(
                          model.songsList[model.currentIndex].albumArt)),
                      fit: BoxFit.cover,
                    )
                  : Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Image.asset(
                        'assets/images/MusicPlaceHolder.png',
                        fit: BoxFit.contain,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaylistFavouriteMute() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              color: Colors.blueGrey,
              icon: Icon(Icons.library_music),
              iconSize: 25,
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            PlaylistSongListPage()));
              },
            ),
            IconButton(
              color: model.songsList[model.currentIndex].isFavourite
                  ? Colors.red
                  : Colors.blueGrey,
              icon: Icon(model.songsList[model.currentIndex].isFavourite
                  ? Icons.favorite
                  : Icons.favorite_border),
              iconSize: 25,
              onPressed: () {
                if (model.favourites
                    .contains(model.songsList[model.currentIndex])) {
                  model.removeFromFavourites(
                      model.songsList[model.currentIndex]);
                } else {
                  model.addToFavourites(model.songsList[model.currentIndex]);
                }
              },
            ),
            IconButton(
              color: Colors.blueGrey,
              icon: Icon(model.isMuted ? Icons.volume_off : Icons.volume_up),
              iconSize: 25,
              onPressed: () {
                model.toggleMutePlayback();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildSeekBar() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return Slider(
          onChanged: (double value) {
            this.setState(() => _seekBarValue = value);
          },
          onChangeEnd: (double value) {
            this.setState(() => _isSeeking = false);
            model.seekPlayback(Duration(milliseconds: value.toInt()));
          },
          onChangeStart: (double value) {
            this.setState(() => _isSeeking = true);
          },
          value: _isSeeking
              ? _seekBarValue
              : model.currentPosition.inMilliseconds.toDouble(),
          activeColor: Colors.blue,
          inactiveColor: Colors.blueAccent[100],
          min: 0.0,
          max: model.songsList[model.currentIndex].duration.toDouble(),
        );
      },
    );
  }

  Widget _buildDurationText() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  _isSeeking
                      ? model.getDurationText(
                          Duration(milliseconds: _seekBarValue.toInt()))
                      : model.getDurationText(model.currentPosition),
                  style: TextStyle(color: Colors.blueGrey),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  model.getDurationText(Duration(
                      milliseconds:
                          model.songsList[model.currentIndex].duration)),
                  style: TextStyle(color: Colors.blueGrey),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildControlButtons() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 15.0, top: 5.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.shuffle),
                color: model.isShuffleOn ? Colors.blue : Colors.blueGrey,
                onPressed: () {
                  model.toggleShuffle();
                },
              ),
              IconButton(
                icon: Icon(Icons.skip_previous),
                color: Colors.blueGrey,
                iconSize: 30.0,
                onPressed: () {
                  model.startPlayback(model.previousSong());
                },
              ),
              SizedBox(width: 20),
              IconButton(
                icon: Icon(Icons.skip_next),
                color: Colors.blueGrey,
                iconSize: 30.0,
                onPressed: () {
                  model.startPlayback(model.nextSong());
                },
              ),
              IconButton(
                icon: Icon(Icons.stop),
                color: Colors.blueGrey,
                onPressed: () {
                  Navigator.of(context).pop();
                  model.stopPlayback();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSongTitle() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        String _songTitle, _albumTitle;
        _songTitle = model.songsList[model.currentIndex].title;
        _albumTitle = model.songsList[model.currentIndex].album;
        _songTitle = _songTitle.length > 30
            ? _songTitle.substring(0, 30) + '...'
            : _songTitle;
        _albumTitle = _albumTitle.length > 25
            ? _albumTitle.substring(0, 25) + '...'
            : _albumTitle;
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _songTitle,
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 15),
            Text(_albumTitle),
          ],
        );
      },
    );
  }

  Widget _buildBody() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        _buildAlbumArt(),
        SizedBox(height: 10),
        _buildSongTitle(),
        SizedBox(height: 40),
        _buildPlaylistFavouriteMute(),
        SizedBox(height: 5),
        _buildSeekBar(),
        SizedBox(height: 1),
        _buildDurationText(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return Scaffold(
          body: model.currentIndex != -1
              ? Stack(
                  children: <Widget>[
                    _buildAppBarBackground(),
                    _buildBody(),
                  ],
                )
              : Container(),
          bottomNavigationBar: BottomAppBar(
            color: Colors.grey.withOpacity(0.3),
            elevation: 0.0,
            shape: CircularNotchedRectangle(),
            notchMargin: 0.0,
            child: _buildControlButtons(),
          ),
          floatingActionButton: FloatingActionButton(
            child: Icon(model.playerState == PlayerState.PLAYING
                ? Icons.pause
                : Icons.play_arrow),
            onPressed: () => model.playerState == PlayerState.PLAYING
                ? model.pausePlayback()
                : model.resumePlayback(),
            backgroundColor: Colors.pinkAccent,
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
        );
      },
    );
  }
}
