import 'package:scoped_model/scoped_model.dart';
import 'package:flute_music_player/flute_music_player.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/SongModel.dart';
import '../utils/enums/PlayerStateEnum.dart';

mixin ConnectedModel on Model {
  List<SongModel> _songsList;
  List<SongModel> _localSongs;
  Map<int, List<SongModel>> _albumList;
  Map<String, List<SongModel>> _artistList;
  MusicFinder _audioPlayer = MusicFinder();
  PlayerState _playerState = PlayerState.STOPPED;
  bool _isAvailable = false;
  int _currentIndex = -1;
  SharedPreferences _preferences;
  Duration _currentPosition = Duration(milliseconds: 0);
  Duration _duration = Duration(milliseconds: 0);
}

mixin SongsModel on ConnectedModel {
  List<SongModel> get songsList {
    return _songsList;
  }

  int get currentIndex {
    return _currentIndex;
  }

  bool get isAvailable {
    return _isAvailable;
  }

  Map<int, List<SongModel>> get albumsList {
    return _albumList;
  }

  Map<String, List<SongModel>> get artistList {
    return _artistList;
  }

  List<SongModel> get localSongs {
    return _localSongs;
  }

  void setSongsList(List<SongModel> list, bool refresh) {
    if (refresh) _songsList.clear();
    _songsList.addAll(list);
  }
}

mixin PlayerModel on ConnectedModel {
  //
  void _addToAlbum(SongModel s) {
    if (_albumList.containsKey(s.albumID)) {
      List<SongModel> _songs = _albumList[s.albumID];
      _songs.add(s);
      _albumList.update(s.albumID, (_) => _songs);
    } else {
      List<SongModel> _songs = List<SongModel>();
      _songs.add(s);
      _albumList.putIfAbsent(s.albumID, () => _songs);
    }
  }

  void _addToArtist(SongModel s) {
    if (_artistList.containsKey(s.artist)) {
      List<SongModel> _songs = _artistList[s.artist];
      _songs.add(s);
      _artistList.update(s.artist, (_) => _songs);
    } else {
      List<SongModel> _songs = List<SongModel>();
      _songs.add(s);
      _artistList.putIfAbsent(s.artist, () => _songs);
    }
  }

  Future<void> _initialize() async {
    _songsList = List<SongModel>();
    _localSongs = List<SongModel>();
    _albumList = Map();
    _artistList = Map();
    _preferences = await SharedPreferences.getInstance();
  }

  Future<void> initMusicPlayer() async {
    var _songData = await MusicFinder.allSongs();
    await _initialize();
    for (Song s in _songData) {
      SongModel _model = SongModel(
          album: s.album,
          albumArt: s.albumArt,
          artist: s.artist,
          duration: s.duration,
          id: s.id,
          title: s.title,
          uri: s.uri,
          albumID: s.albumId);
      _localSongs.add(_model);
      _addToAlbum(_model);
      _addToArtist(_model);
    }
    _localSongs.sort((SongModel model1, SongModel model2) =>
        model1.title.compareTo(model2.title));

    _audioPlayer.setPositionHandler((Duration currentDuration) {
      _currentPosition = currentDuration;
      notifyListeners();
    });

    _audioPlayer.setCompletionHandler(() async {
      _currentIndex++;
      if (_currentIndex >= _songsList.length) _currentIndex = 0;
      await _audioPlayer.stop();
      await _audioPlayer.play(_songsList[_currentIndex].uri);
      _playerState = PlayerState.PLAYING;
      _audioPlayer.positionHandler(Duration(milliseconds: 0));
    });

    _audioPlayer.setDurationHandler((Duration duration) {
      _duration = duration;
    });

    _audioPlayer.setErrorHandler((String error) {
      print(error);
    });

    _isAvailable = true;
    notifyListeners();
  }

  Future<void> startPlayback(int index) async {
    _currentIndex = index;
    await _audioPlayer.stop();
    if (_playerState != PlayerState.PAUSED &&
        _playerState != PlayerState.MUTED) {
      await _audioPlayer.play(_songsList[index].uri);
      _playerState = PlayerState.PLAYING;
    }
    _audioPlayer
        .durationHandler(Duration(milliseconds: _songsList[index].duration));
    _audioPlayer.positionHandler(Duration(milliseconds: 0));
  }

  Future<void> stopPlayback() async {
    await _audioPlayer.stop();
    _playerState = PlayerState.STOPPED;
    _currentIndex = -1;
    _songsList.clear();
    notifyListeners();
  }

  Future<void> pausePlayback() async {
    if (_playerState == PlayerState.PLAYING ||
        _playerState == PlayerState.MUTED) {
      await _audioPlayer.pause();
      _playerState = PlayerState.PAUSED;
      notifyListeners();
    }
  }

  Future<void> resumePlayback() async {
    _audioPlayer.positionHandler(_currentPosition);
    await _audioPlayer.play(_songsList[_currentIndex].uri);
    _playerState = PlayerState.PLAYING;
    notifyListeners();
  }

  Future<void> seekPlayback(Duration seekPosition) async {
    _currentPosition = seekPosition;
    await _audioPlayer.seek(seekPosition.inSeconds.toDouble());
    _playerState = PlayerState.PLAYING;
    notifyListeners();
  }

  Future<void> mutePlayback() async {
    await _audioPlayer.mute(true);
    _playerState = PlayerState.MUTED;
  }

  int nextSong() {
    _currentIndex++;
    if (_currentIndex >= _songsList.length) {
      _currentIndex = 0;
    }
    return _currentIndex;
  }

  int previousSong() {
    _currentIndex--;
    if (_currentIndex < 0) {
      _currentIndex = _songsList.length - 1;
    }
    return _currentIndex;
  }

  void setPlayerState(PlayerState state) {
    _playerState = state;
    notifyListeners();
  }
}

mixin UtilityModel on ConnectedModel {
  PlayerState get playerState {
    return _playerState;
  }

  MusicFinder get audioPlayer {
    return _audioPlayer;
  }

  Duration get currentPosition {
    return _currentPosition;
  }

  double percentageCompletion() {
    double _pCompletion =
        _currentPosition.inMilliseconds / _duration.inMilliseconds;
    return _pCompletion;
  }

  String getDurationText(Duration d) {
    int _totalDuration = d.inMilliseconds.toInt();
    int _minutes = (_totalDuration ~/ 1000) ~/ 60;
    int _seconds = (_totalDuration ~/ 1000) % 60;
    return _seconds < 10
        ? _minutes.toString() + ':0' + _seconds.toString()
        : _minutes.toString() + ':' + _seconds.toString();
  }
}
