import 'package:scoped_model/scoped_model.dart';
import 'package:flute_music_player/flute_music_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:math';

import '../models/SongModel.dart';
import '../utils/enums/PlayerStateEnum.dart';

mixin ConnectedModel on Model {
  List<SongModel> _songsList;
  List<SongModel> _localSongs;
  Map<int, List<SongModel>> _albumList;
  Map<String, List<SongModel>> _artistList;
  List<SongModel> _favourites;
  MusicFinder _audioPlayer = MusicFinder();
  PlayerState _playerState = PlayerState.STOPPED;
  bool _isAvailable = false;
  int _currentIndex = -1;
  bool _isMuted = false;
  bool _isShuffleOn = false;
  SharedPreferences _preferences;
  Duration _currentPosition = Duration(milliseconds: 0);
  Duration _duration = Duration(milliseconds: 0);
  Database _localDB;
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

  List<SongModel> get favourites {
    return _favourites;
  }

  void setSongsList(List<SongModel> list, bool refresh) {
    if (refresh) _songsList.clear();
    _songsList.addAll(list);
  }

  void toggleShuffle() {
    _isShuffleOn = !_isShuffleOn;
    notifyListeners();
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

  void _buildFavourites() {
    List<String> _fIDs = _preferences.getStringList('Favourites');
    List<SongModel> _fSongsList = List<SongModel>();
    if (_fIDs != null) {
      for (String id in _fIDs) {
        SongModel song = _localSongs
            .firstWhere((SongModel model) => model.id == int.parse(id));
        song.setFavourite(true);
        _fSongsList.add(song);
      }
    }
    _favourites.addAll(_fSongsList);
  }

  void addListToFavourites(List<SongModel> list) async {
    _favourites.addAll(list);
    for (SongModel s in list) s.setFavourite(true);
    List<String> _fIDs = List<String>();
    for (SongModel _song in _favourites) {
      _fIDs.add(_song.id.toString());
    }
    await _preferences.setStringList('Favourites', _fIDs);
    notifyListeners();
  }

  void addToFavourites(SongModel s) async {
    _favourites.add(s);
    s.setFavourite(true);
    List<String> _fIDs = List<String>();
    for (SongModel _song in _favourites) {
      _fIDs.add(_song.id.toString());
    }
    await _preferences.setStringList('Favourites', _fIDs);
    notifyListeners();
  }

  void removeFromFavourites(SongModel s) async {
    _favourites.remove(s);
    s.setFavourite(false);
    List<String> _fIDs = List<String>();
    for (SongModel _song in _favourites) {
      _fIDs.add(_song.id.toString());
    }
    await _preferences.setStringList('Favourites', _fIDs);
    notifyListeners();
  }

  Future<void> _initialize() async {
    _songsList = List<SongModel>();
    _localSongs = List<SongModel>();
    _favourites = List<SongModel>();
    _albumList = Map();
    _artistList = Map();
    _preferences = await SharedPreferences.getInstance();
    _localDB = await _getDatabase();
  }

  Map<String, dynamic> _songToMap(SongModel song) {
    return {
      'id': song.id,
      'artist': song.artist,
      'title': song.title,
      'album': song.album,
      'albumID': song.albumID,
      'duration': song.duration,
      'uri': song.uri,
      'albumArt': song.albumArt,
      'isFavourite': song.isFavourite ? 1 : 0
    };
  }

  SongModel _mapToSong(Map<String, dynamic> map) {
    return SongModel(
        id: map['id'],
        artist: map['artist'],
        title: map['title'],
        album: map['album'],
        albumID: map['albumID'],
        duration: map['duration'],
        uri: map['uri'],
        albumArt: map['albumArt'],
        isFavourite: map['isFavourite'] == 1 ? true : false);
  }

  Future<Database> _getDatabase() async {
    String databasesPath = await getDatabasesPath();
    String dbPath = databasesPath + '/EmpressMusic.db';

    var database =
        await openDatabase(dbPath, version: 1, onCreate: _onCreateDB);
    return database;
  }

  void _onCreateDB(Database database, int version) async {
    await database.execute('CREATE TABLE SONGS (' +
        'id INTEGER,' +
        'artist TEXT,' +
        'title TEXT,' +
        'album TEXT,' +
        'albumID INTEGER,' +
        'duration INTEGER,' +
        'uri TEXT,' +
        'albumArt TEXT,' +
        'isFavourite INTEGER' +
        ')');
  }

  Future<void> _addSongToLocalDB(SongModel song) async {
    await _localDB.insert('SONGS', _songToMap(song));
  }

  Future<void> _clearLocalDB() async {
    _localDB.execute('DELETE FROM SONGS');
  }

  Future<void> _fetchSongs() async {
    var _results = await _localDB.rawQuery('SELECT * FROM SONGS');
    var _songData;
    if (_results.toList().length > 0) {
      print('Fetching songs from LocalDB');
      _songData = _results.toList();
      for (Map<String, dynamic> map in _songData) {
        _localSongs.add(_mapToSong(map));
        _addToAlbum(_mapToSong(map));
        _addToArtist(_mapToSong(map));
      }
      _buildFavourites();
    } else {
      print('Fetching songs using LIBRARY');
      _songData = await MusicFinder.allSongs();
      for (Song s in _songData) {
        SongModel _model = SongModel(
            album: s.album,
            albumArt: s.albumArt,
            artist: s.artist,
            duration: s.duration,
            id: s.id,
            title: s.title,
            uri: s.uri,
            albumID: s.albumId,
            isFavourite: false);
        _localSongs.add(_model);
        _addToAlbum(_model);
        _addToArtist(_model);
        _addSongToLocalDB(_model);
      }
      _buildFavourites();
    }
    _localSongs.sort((SongModel model1, SongModel model2) =>
        model1.title.compareTo(model2.title));
  }

  Future<void> initMusicPlayer() async {
    await _initialize();
    await _fetchSongs();

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
    if (_playerState != PlayerState.PAUSED) {
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
    if (_playerState == PlayerState.PLAYING) {
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

  Future<void> toggleMutePlayback() async {
    _isMuted = !_isMuted;
    await _audioPlayer.mute(_isMuted);
    notifyListeners();
  }

  int nextSong() {
    if (_isShuffleOn) {
      Random r = Random();
      _currentIndex = r.nextInt(_songsList.length);
    } else {
      _currentIndex++;
    }
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

  bool get isMuted {
    return _isMuted;
  }

  bool get isShuffleOn {
    return _isShuffleOn;
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
