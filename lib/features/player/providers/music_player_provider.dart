import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../models/song_model.dart';
import '../models/album_model.dart';
import '../services/audio_player_service.dart';
import 'package:blazeplayer/core/services/local_storage_service.dart';

class MusicPlayerProvider extends ChangeNotifier {
  /// Shuffle the given list and play a random song
  Future<void> shuffleAndPlay(List<Song> songs) async {
    if (songs.isEmpty) return;
    final shuffled = List<Song>.from(songs)..shuffle();
    await playSong(shuffled.first);
  }

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
  Set<String> _favoriteSongIds = {}; // Track favorite song IDs
  final Map<String, int> _songPlayCounts = {};
  final Map<String, String> _customArtPaths = {};

  static const _recentlyPlayedKey = 'recently_played_songs';
  static const _favoriteSongsKey = 'favorite_songs';

  MusicPlayerProvider() {
    _initializeAudioService();
    restoreRecentlyPlayedSongs();
    restoreFavoriteSongs();
  }

  final ValueNotifier<Duration> positionNotifier = ValueNotifier(Duration.zero);
  Timer? _positionDebounceTimer;

  void _initializeAudioService() {
    _audioService.initialize();

    // Listen to position changes
    _audioService.positionStream.listen((position) {
      _currentPosition = position;
      if (_positionDebounceTimer?.isActive ?? false) return;
      _positionDebounceTimer = Timer(const Duration(milliseconds: 200), () {
        positionNotifier.value = position;
      });
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

  List<Album> get allAlbums {
    // Group songs by album name
    final Map<String, List<Song>> albumMap = {};
    for (final song in _originalPlaylist) {
      final albumName = song.album.isNotEmpty ? song.album : 'Unknown Album';
      albumMap.putIfAbsent(albumName, () => []).add(song);
    }
    // Create Album objects
    return albumMap.entries
        .map(
          (entry) => Album(
            id: entry.key,
            name: entry.key,
            songCount: entry.value.length,
          ),
        )
        .toList();
  }

  List<String> getAlbumArtImages(String albumId, {int maxCount = 4}) {
    // Find songs in this album
    final songs = _originalPlaylist.where((s) => s.album == albumId).toList();
    if (songs.isEmpty) return [''];

    // Return just the first song's ID for single artwork display
    return [songs[0].id];
  }

  List<Song> getSongsForAlbum(String albumId) {
    return _originalPlaylist.where((s) => s.album == albumId).toList();
  }

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

  Future<void> saveFavoriteSongs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoriteSongsKey, _favoriteSongIds.toList());
  }

  Future<void> restoreFavoriteSongs() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteIds = prefs.getStringList(_favoriteSongsKey);
    if (favoriteIds != null) {
      _favoriteSongIds = favoriteIds.toSet();
      notifyListeners();
    }
  }

  void toggleFavorite(String songId) {
    if (_favoriteSongIds.contains(songId)) {
      _favoriteSongIds.remove(songId);
    } else {
      _favoriteSongIds.add(songId);
    }
    saveFavoriteSongs();
    notifyListeners();
  }

  bool isFavorite(String songId) {
    return _favoriteSongIds.contains(songId);
  }

  List<Song> get favoriteSongs {
    return _originalPlaylist
        .where((song) => _favoriteSongIds.contains(song.id))
        .toList();
  }

  void preloadCustomArtPaths() {
    for (final song in _originalPlaylist) {
      final artPath = getCustomArtForSong(song.id);
      if (artPath != null && artPath.isNotEmpty) {
        _customArtPaths[song.id] = artPath;
      }
    }
  }

  Future<void> playSong(Song song) async {
    try {
      _currentSong = song;
      _currentPosition = Duration.zero;
      // Add to recently played
      if (!_recentlyPlayedSongs.any((s) => s.id == song.id)) {
        _recentlyPlayedSongs.insert(0, song);
      } else {
        _recentlyPlayedSongs.removeWhere((s) => s.id == song.id);
        _recentlyPlayedSongs.insert(0, song);
      }
      if (_recentlyPlayedSongs.length > 50) {
        _recentlyPlayedSongs = _recentlyPlayedSongs.sublist(0, 50);
      }
      // Increment play count
      _songPlayCounts[song.id] = (_songPlayCounts[song.id] ?? 0) + 1;
      await saveRecentlyPlayedSongs();
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
    positionNotifier.value = position;
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
      // Play next song
      playSong(_playlist[currentIndex + 1]);
    } else if (_repeatMode == RepeatMode.all) {
      // Loop back to first song
      playSong(_playlist[0]);
    } else {
      // End of playlist, stop playing
      _audioService.stop();
      _isPlaying = false;
      notifyListeners();
    }
  }

  void previousSong() {
    if (_playlist.isEmpty || _currentSong == null) return;

    // If current position > 3 seconds, restart current song
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
    _originalPlaylist = songModels
        .map(
          (song) => Song(
            id: song.id.toString(),
            title: song.title,
            artist: song.artist ?? 'Unknown Artist',
            album: song.album ?? 'Unknown Album',
            albumArt: song.id.toString(),
            duration: Duration(milliseconds: song.duration ?? 0),
            filePath: song.data,
          ),
        )
        .toList();
    preloadCustomArtPaths();
    notifyListeners();
  }

  void setVolume(double value) {
    _audioService.setVolume(value);
  }

  // Sleep Timer State
  Duration? _sleepTimerDuration;
  DateTime? _sleepTimerEndTime;
  bool get isSleepTimerActive =>
      _sleepTimerEndTime != null &&
      DateTime.now().isBefore(_sleepTimerEndTime!);
  Duration get sleepTimerRemaining {
    if (_sleepTimerEndTime == null) return Duration.zero;
    final remaining = _sleepTimerEndTime!.difference(DateTime.now());
    return remaining > Duration.zero ? remaining : Duration.zero;
  }

  Duration? get sleepTimerDuration => _sleepTimerDuration;

  void setSleepTimer(Duration duration) {
    _sleepTimerDuration = duration;
    _sleepTimerEndTime = DateTime.now().add(duration);
    notifyListeners();
    _startSleepTimerCountdown();
  }

  void cancelSleepTimer() {
    _sleepTimerDuration = null;
    _sleepTimerEndTime = null;
    notifyListeners();
  }

  void resetSleepTimer() {
    if (_sleepTimerDuration != null) {
      setSleepTimer(_sleepTimerDuration!);
    }
  }

  Timer? _sleepTimer;
  void _startSleepTimerCountdown() {
    _sleepTimer?.cancel();
    if (_sleepTimerEndTime == null) return;
    final remaining = _sleepTimerEndTime!.difference(DateTime.now());
    if (remaining <= Duration.zero) {
      _handleSleepTimerComplete();
      return;
    }
    _sleepTimer = Timer(remaining, _handleSleepTimerComplete);
  }

  void _handleSleepTimerComplete() {
    _sleepTimerDuration = null;
    _sleepTimerEndTime = null;
    _audioService.stop();
    _isPlaying = false;
    notifyListeners();
  }

  String? _customArtPath;
  String? get customArtPath => _customArtPath;

  Future<void> setCustomArtForSong(String songId, String imagePath) async {
    if (!LocalStorageService.isInitialized) {
      await LocalStorageService.init();
    }
    _customArtPath = imagePath;
    _customArtPaths[songId] = imagePath; // Update the map cache
    await LocalStorageService.setString('custom_art_$songId', imagePath);
    notifyListeners();
  }

  String? getCustomArtForSong(String songId) {
    if (!LocalStorageService.isInitialized) {
      LocalStorageService.init();
    }
    // Prefer cached value if available
    final artPath =
        _customArtPaths[songId] ??
        LocalStorageService.getString('custom_art_$songId');

    // Validate that the file exists, if not return null
    if (artPath != null && artPath.isNotEmpty) {
      if (File(artPath).existsSync()) {
        return artPath;
      } else {
        // File doesn't exist, clean up the invalid path
        _customArtPaths.remove(songId);
        LocalStorageService.remove('custom_art_$songId');
        return null;
      }
    }
    return null;
  }

  // Edit Tags: Update song info
  void updateSongTags(
    String songId, {
    String? title,
    String? album,
    String? artist,
    String? genre,
    int? trackNumber,
  }) {
    final songIndex = _originalPlaylist.indexWhere((s) => s.id == songId);
    if (songIndex != -1) {
      final oldSong = _originalPlaylist[songIndex];
      final updatedSong = oldSong.copyWith(
        title: title ?? oldSong.title,
        album: album ?? oldSong.album,
        artist: artist ?? oldSong.artist,
        genre: genre ?? oldSong.genre,
        trackNumber: trackNumber ?? oldSong.trackNumber,
      );
      _originalPlaylist[songIndex] = updatedSong;
      // Also update in playlist if present
      final playIndex = _playlist.indexWhere((s) => s.id == songId);
      if (playIndex != -1) {
        _playlist[playIndex] = updatedSong;
      }
      // Also update in recently played songs if present
      final recentIndex = _recentlyPlayedSongs.indexWhere(
        (s) => s.id == songId,
      );
      if (recentIndex != -1) {
        _recentlyPlayedSongs[recentIndex] = updatedSong;
        saveRecentlyPlayedSongs(); // Persist the updated recently played list
      }
      // If current song, update reference
      if (_currentSong?.id == songId) {
        _currentSong = updatedSong;
      }
      notifyListeners();
    }
  }

  // Edit Tags: Fetch song info stub
  void fetchSongInfo(String songId) {
    // TODO: Implement actual info fetch (e.g., from web or local DB)
    // For now, just notify listeners
    notifyListeners();
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}

enum RepeatMode { off, all, one }
