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
  Future<void> playSong(SongModel song,int index) async {
    await _audioPlayer.stop();
    await _audioPlayer.play(song.uri);
    _playerState = PlayerState.PLAYING;
    _currentIndex=index;
    notifyListeners();
  }

  Future<void> stopPlayback() async {
    await _audioPlayer.stop();
    _playerState = PlayerState.STOPPED;
    _currentIndex=-1;
    notifyListeners();
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
}
