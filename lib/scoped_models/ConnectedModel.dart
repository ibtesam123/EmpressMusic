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
  Future<void> fetchLocalSongs() async {
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
      await _audioPlayer.stop();
      _currentPosition = _duration;
      _playerState = PlayerState.STOPPED;
      notifyListeners();
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
  Future<void> startPlayback(SongModel song, int index) async {
    await _audioPlayer.stop();
    await _audioPlayer.play(song.uri);
    _playerState = PlayerState.PLAYING;
    _currentIndex = index;
    _audioPlayer.durationHandler(Duration(milliseconds: song.duration));
    notifyListeners();
  }

  Future<void> stopPlayback() async {
    await _audioPlayer.stop();
    _playerState = PlayerState.STOPPED;
    _currentIndex = -1;
    notifyListeners();
  }

  Future<void> pausePlayback() async {
    await _audioPlayer.pause();
    _playerState = PlayerState.PAUSED;
    notifyListeners();
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

  double percentageCompletion() {
    return (_currentPosition.inMilliseconds / _duration.inMilliseconds)
        .toDouble();
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
}
