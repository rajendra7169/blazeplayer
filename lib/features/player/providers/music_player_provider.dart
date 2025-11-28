import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:audiotagger/audiotagger.dart';
import 'package:audiotagger/models/tag.dart';
import '../models/song_model.dart';
import '../services/audio_player_service.dart';

class MusicPlayerProvider extends ChangeNotifier {
  final AudioPlayerService _audioService = AudioPlayerService();
  final OnAudioQuery _audioQuery = OnAudioQuery();

  Song? _currentSong;
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  bool _isShuffle = false;
  RepeatMode _repeatMode = RepeatMode.off;
  List<Song> _playlist = [];
  List<Song> _originalPlaylist = [];
  List<Song> _recentlyPlayedSongs = [];
  final Map<String, int> _songPlayCounts = {};

  static const _recentlyPlayedKey = 'recently_played_songs';

  MusicPlayerProvider() {
    _initializeAudioService();
    restoreRecentlyPlayedSongs();
  }

  void _initializeAudioService() {
    _audioService.initialize();

    // Listen to position changes
    _audioService.positionStream.listen((position) {
      _currentPosition = position;
      notifyListeners();
    });

    // Listen to playing state changes
    _audioService.playingStream.listen((playing) {
      _isPlaying = playing;
      notifyListeners();
    });

    // Listen to processing state for auto-next
    _audioService.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        _handleSongCompleted();
      }
    });
  }

  Song? get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;
  Duration get currentPosition => _currentPosition;
  bool get isShuffle => _isShuffle;
  RepeatMode get repeatMode => _repeatMode;
  List<Song> get playlist => _playlist;
  Duration? get duration => _audioService.duration;
  List<Song> get recentlyPlayedSongs => List.unmodifiable(_recentlyPlayedSongs);
  List<Song> get allSongs => List.unmodifiable(_originalPlaylist);

  List<Song> get recommendedSongs {
    // Recommend by most played
    final allSongs = [..._originalPlaylist];
    allSongs.sort((a, b) {
      final aCount = _songPlayCounts[a.id] ?? 0;
      final bCount = _songPlayCounts[b.id] ?? 0;
      return bCount.compareTo(aCount);
    });
    return allSongs.take(10).toList();
  }

  String? get favoriteGenre {
    final genreCounts = <String, int>{};
    for (final song in _originalPlaylist) {
      if (song.genre != null) {
        genreCounts[song.genre!] =
            (genreCounts[song.genre!] ?? 0) + (_songPlayCounts[song.id] ?? 0);
      }
    }
    if (genreCounts.isEmpty) return null;
    return genreCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  void setPlaylist(List<Song> songs) {
    _originalPlaylist = List.from(songs);

    // If shuffle is on, shuffle the new playlist but keep current song first if it exists
    if (_isShuffle) {
      final currentSongId = _currentSong?.id;
      if (currentSongId != null && songs.any((s) => s.id == currentSongId)) {
        // Current song exists in new playlist
        final otherSongs = songs.where((s) => s.id != currentSongId).toList();
        otherSongs.shuffle();
        _playlist = [
          songs.firstWhere((s) => s.id == currentSongId),
          ...otherSongs,
        ];
      } else {
        // Current song not in playlist or no current song
        _playlist = List.from(songs);
        _playlist.shuffle();
      }
    } else {
      _playlist = List.from(songs);
    }

    notifyListeners();
  }

  // Add persistent storage for last played song
  Future<void> saveLastPlayedSong() async {
    final prefs = await SharedPreferences.getInstance();
    if (_currentSong != null) {
      await prefs.setString('last_played_song_id', _currentSong!.id);
    }
  }

  Future<void> restoreLastPlayedSong() async {
    final prefs = await SharedPreferences.getInstance();
    final lastId = prefs.getString('last_played_song_id');
    if (lastId != null && _originalPlaylist.isNotEmpty) {
      final song = _originalPlaylist.firstWhere(
        (s) => s.id == lastId,
        orElse: () => Song(
          id: '',
          title: '',
          artist: '',
          album: '',
          duration: Duration.zero,
          filePath: '',
        ),
      );
      if (song.id.isNotEmpty) {
        _currentSong = song;
        _isPlaying = false;
        notifyListeners();
      }
    }
  }

  Future<void> saveRecentlyPlayedSongs() async {
    final prefs = await SharedPreferences.getInstance();
    final songJsonList = _recentlyPlayedSongs
        .map(
          (song) => {
            'id': song.id,
            'title': song.title,
            'artist': song.artist,
            'album': song.album,
            'albumArt': song.albumArt,
            'duration': song.duration.inMilliseconds,
            'filePath': song.filePath,
            'playCount': song.playCount,
            'genre': song.genre,
            'dateAdded': song.dateAdded,
          },
        )
        .toList();
    await prefs.setString(_recentlyPlayedKey, jsonEncode(songJsonList));
  }

  Future<void> restoreRecentlyPlayedSongs() async {
    final prefs = await SharedPreferences.getInstance();
    final songListString = prefs.getString(_recentlyPlayedKey);
    if (songListString != null && songListString.isNotEmpty) {
      try {
        final List<dynamic> songList = jsonDecode(songListString);
        _recentlyPlayedSongs = songList
            .map(
              (json) => Song(
                id: json['id'],
                title: json['title'],
                artist: json['artist'],
                album: json['album'],
                albumArt: json['albumArt'],
                duration: Duration(milliseconds: json['duration'] ?? 0),
                filePath: json['filePath'],
                playCount: json['playCount'] ?? 0,
                genre: json['genre'],
                dateAdded: json['dateAdded'] ?? 0,
              ),
            )
            .toList();
      } catch (e) {
        _recentlyPlayedSongs = [];
      }
      notifyListeners();
    }
  }

  Future<Song> _reloadSongFromFile(Song song) async {
    final tagger = Audiotagger();
    Tag? tags;
    try {
      tags = await tagger.readTags(path: song.filePath);
    } catch (e) {
      tags = null;
    }
    return Song(
      id: song.id,
      title: tags?.title ?? song.title,
      artist: tags?.artist ?? song.artist,
      album: tags?.album ?? song.album,
      albumArt: tags?.artwork ?? song.albumArt,
      duration: song.duration,
      filePath: song.filePath,
      playCount: song.playCount,
      genre: song.genre,
      dateAdded: song.dateAdded,
    );
  }

  Future<void> playSong(Song song) async {
    try {
      final reloadedSong = await _reloadSongFromFile(song);
      _currentSong = reloadedSong;
      _currentPosition = Duration.zero;
      // Update in playlist and originalPlaylist
      _playlist = _playlist
          .map((s) => s.id == reloadedSong.id ? reloadedSong : s)
          .toList();
      _originalPlaylist = _originalPlaylist
          .map((s) => s.id == reloadedSong.id ? reloadedSong : s)
          .toList();
      // Add to recently played
      if (!_recentlyPlayedSongs.any((s) => s.id == song.id)) {
        _recentlyPlayedSongs.insert(0, reloadedSong);
      } else {
        _recentlyPlayedSongs = _recentlyPlayedSongs
            .map((s) => s.id == reloadedSong.id ? reloadedSong : s)
            .toList();
        _recentlyPlayedSongs.removeWhere((s) => s.id == song.id);
        _recentlyPlayedSongs.insert(0, reloadedSong);
      }
      if (_recentlyPlayedSongs.length > 50) {
        _recentlyPlayedSongs = _recentlyPlayedSongs.sublist(0, 50);
      }
      // Increment play count
      _songPlayCounts[song.id] = (_songPlayCounts[song.id] ?? 0) + 1;
      await saveRecentlyPlayedSongs();
      await saveSongsToStorage();
      notifyListeners();

      if (song.filePath.isNotEmpty) {
        await _audioService.play(song.filePath);
        _isPlaying = true;
      }
      await saveLastPlayedSong();
      notifyListeners();
    } catch (e) {
      print('Error playing song: $e');
      _isPlaying = false;
      notifyListeners();
    }
  }

  Future<void> togglePlayPause() async {
    try {
      if (_isPlaying) {
        await _audioService.pause();
        _isPlaying = false;
      } else {
        await _audioService.resume();
        _isPlaying = true;
      }
      notifyListeners();
    } catch (e) {
      print('Error toggling play/pause: $e');
    }
  }

  Future<void> seekTo(Duration position) async {
    await _audioService.seekTo(position);
    _currentPosition = position;
    notifyListeners();
  }

  void _handleSongCompleted() {
    // Handle what happens when song completes
    if (_repeatMode == RepeatMode.one) {
      // Replay current song
      if (_currentSong != null) {
        playSong(_currentSong!);
      }
    } else {
      // Auto-play next song
      nextSong();
    }
  }

  void nextSong() {
    if (_playlist.isEmpty || _currentSong == null) return;
    final currentIndex = _playlist.indexWhere((s) => s.id == _currentSong!.id);
    if (currentIndex < _playlist.length - 1) {
      playSong(_playlist[currentIndex + 1]);
    } else if (_repeatMode == RepeatMode.all) {
      playSong(_playlist[0]);
    } else {
      _audioService.stop();
      _isPlaying = false;
      notifyListeners();
    }
  }

  void previousSong() {
    if (_playlist.isEmpty || _currentSong == null) return;
    if (_currentPosition.inSeconds > 3) {
      seekTo(Duration.zero);
      return;
    }
    final currentIndex = _playlist.indexWhere((s) => s.id == _currentSong!.id);
    if (currentIndex > 0) {
      playSong(_playlist[currentIndex - 1]);
    } else if (_repeatMode == RepeatMode.all) {
      playSong(_playlist[_playlist.length - 1]);
    }
  }

  Future<void> toggleShuffle() async {
    _isShuffle = !_isShuffle;

    if (_isShuffle) {
      // Shuffle the playlist, but keep current song at the beginning
      if (_currentSong != null) {
        final currentSong = _currentSong!;
        final otherSongs = _originalPlaylist
            .where((s) => s.id != currentSong.id)
            .toList();
        otherSongs.shuffle();

        // Check if current song is in the original playlist
        if (_originalPlaylist.any((s) => s.id == currentSong.id)) {
          _playlist = [currentSong, ...otherSongs];
        } else {
          // Current song not in playlist (shouldn't happen, but just in case)
          _playlist = List.from(_originalPlaylist);
          _playlist.shuffle();
        }
      } else {
        _playlist = List.from(_originalPlaylist);
        _playlist.shuffle();
      }
    } else {
      // Restore original playlist order
      _playlist = List.from(_originalPlaylist);
    }

    print(
      'Shuffle ${_isShuffle ? "ON" : "OFF"}: Playlist has ${_playlist.length} songs',
    );
    if (_currentSong != null) {
      print(
        'Current song: ${_currentSong!.title} at position ${_playlist.indexWhere((s) => s.id == _currentSong!.id)}',
      );
    }

    notifyListeners();
  }

  Future<void> cycleRepeatMode() async {
    switch (_repeatMode) {
      case RepeatMode.off:
        _repeatMode = RepeatMode.all;
        break;
      case RepeatMode.all:
        _repeatMode = RepeatMode.one;
        break;
      case RepeatMode.one:
        _repeatMode = RepeatMode.off;
        break;
    }
    notifyListeners();
  }

  Future<void> loadSongsOnStartup() async {
    _originalPlaylist = Song.getDummySongs();
    _playlist = List.from(_originalPlaylist);
    notifyListeners();
  }

  Future<void> fetchLocalSongs() async {
    final songModels = await _audioQuery.querySongs();
    final tagger = Audiotagger();
    List<Song> loadedSongs = [];
    for (var song in songModels) {
      // Read tags from file
      Tag? tags;
      try {
        tags = await tagger.readTags(path: song.data);
      } catch (e) {
        tags = null;
      }
      loadedSongs.add(
        Song(
          id: song.id.toString(),
          title: tags?.title ?? song.title,
          artist: tags?.artist ?? (song.artist ?? 'Unknown Artist'),
          album: tags?.album ?? (song.album ?? ''),
          albumArt: tags?.artwork ?? song.id.toString(),
          duration: Duration(milliseconds: song.duration ?? 0),
          genre: song.genre,
          filePath: song.data,
          dateAdded: song.dateAdded ?? 0,
        ),
      );
    }
    _originalPlaylist = loadedSongs;
    _playlist = List.from(_originalPlaylist);
    await saveSongsToStorage();
    notifyListeners();
  }

  // Update current song info from metadata map and persist everywhere
  Future<void> updateCurrentSongInfo(Map<String, String> info) async {
    if (_currentSong == null) return;
    final updatedSong = Song(
      id: _currentSong!.id,
      title: info['title'] ?? _currentSong!.title,
      artist: info['artist'] ?? _currentSong!.artist,
      album: info['album'] ?? _currentSong!.album,
      albumArt: info['albumArt'] ?? _currentSong!.albumArt,
      duration: _currentSong!.duration,
      filePath: _currentSong!.filePath,
      playCount: _currentSong!.playCount,
      genre: _currentSong!.genre,
      dateAdded: _currentSong!.dateAdded,
    );
    _currentSong = updatedSong;
    // Write tags to audio file
    final tagger = Audiotagger();
    final tag = Tag(
      title: updatedSong.title,
      artist: updatedSong.artist,
      album: updatedSong.album,
      artwork: updatedSong.albumArt,
    );
    try {
      await tagger.writeTags(path: updatedSong.filePath, tag: tag);
    } catch (e) {
      print('Error writing tags: $e');
    }
    // Update in playlist and originalPlaylist
    _playlist = _playlist
        .map((s) => s.id == updatedSong.id ? updatedSong : s)
        .toList();
    _originalPlaylist = _originalPlaylist
        .map((s) => s.id == updatedSong.id ? updatedSong : s)
        .toList();
    // Update in recently played
    _recentlyPlayedSongs = _recentlyPlayedSongs
        .map((s) => s.id == updatedSong.id ? updatedSong : s)
        .toList();
    await saveSongsToStorage();
    await saveRecentlyPlayedSongs();
    notifyListeners();
  }

  // Save all songs to SharedPreferences
  Future<void> saveSongsToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final songJsonList = _originalPlaylist
        .map(
          (song) => {
            'id': song.id,
            'title': song.title,
            'artist': song.artist,
            'album': song.album,
            'albumArt': song.albumArt,
            'duration': song.duration.inMilliseconds,
            'filePath': song.filePath,
            'playCount': song.playCount,
            'genre': song.genre,
            'dateAdded': song.dateAdded,
          },
        )
        .toList();
    await prefs.setString('all_songs', jsonEncode(songJsonList));
  }

  // Restore all songs from SharedPreferences
  Future<void> restoreSongsFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final songListString = prefs.getString('all_songs');
    if (songListString != null && songListString.isNotEmpty) {
      try {
        final List<dynamic> songList = jsonDecode(songListString);
        _originalPlaylist = songList
            .map(
              (json) => Song(
                id: json['id'],
                title: json['title'],
                artist: json['artist'],
                album: json['album'],
                albumArt: json['albumArt'],
                duration: Duration(milliseconds: json['duration'] ?? 0),
                filePath: json['filePath'],
                playCount: json['playCount'] ?? 0,
                genre: json['genre'],
                dateAdded: json['dateAdded'] ?? 0,
              ),
            )
            .toList();
        _playlist = List.from(_originalPlaylist);
      } catch (e) {
        // ignore error
      }
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}

enum RepeatMode { off, all, one }
