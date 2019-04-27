import 'package:scoped_model/scoped_model.dart';
import 'package:flute_music_player/flute_music_player.dart';

import '../models/SongModel.dart';
import '../utils/enums/PlayerStateEnum.dart';

mixin ConnectedModel on Model {
  List<SongModel> _songsList;
  MusicFinder _audioPlayer = MusicFinder();
  PlayerState _playerState = PlayerState.STOPPED;
  bool _isAvailable = false;
  int _currentIndex = -1;
  Duration _currentPosition = Duration(milliseconds: 0);
  Duration _duration = Duration(milliseconds: 0);
}

mixin SongsModel on ConnectedModel {
  Future<void> initMusicPlayer() async {
    var _songData = await MusicFinder.allSongs();
    _songsList = List<SongModel>();

    for (Song s in _songData) {
      SongModel _model = SongModel(
        album: s.album,
        albumArt: s.albumArt,
        artist: s.artist,
        duration: s.duration,
        id: s.id,
        title: s.title,
        uri: s.uri,
      );
      _songsList.add(_model);
    }
    _songsList.sort((SongModel model1, SongModel model2) =>
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

  List<SongModel> get songsList {
    return _songsList;
  }

  int get currentIndex {
    return _currentIndex;
  }
}

mixin PlayerModel on ConnectedModel {
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
    _audioPlayer.positionHandler(seekPosition);
    await _audioPlayer.play(_songsList[_currentIndex].uri);
    _playerState = PlayerState.PLAYING;
    notifyListeners();
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
}

mixin UtilityModel on ConnectedModel {
  bool get isAvailable {
    return _isAvailable;
  }

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
}
