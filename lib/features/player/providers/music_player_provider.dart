import 'package:flutter/material.dart';
import '../models/song_model.dart';
import '../services/audio_player_service.dart';

class MusicPlayerProvider extends ChangeNotifier {
  final AudioPlayerService _audioService = AudioPlayerService();

  Song? _currentSong;
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  bool _isShuffle = false;
  RepeatMode _repeatMode = RepeatMode.off;
  List<Song> _playlist = [];

  MusicPlayerProvider() {
    _initializeAudioService();
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
  }

  Song? get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;
  Duration get currentPosition => _currentPosition;
  bool get isShuffle => _isShuffle;
  RepeatMode get repeatMode => _repeatMode;
  List<Song> get playlist => _playlist;
  Duration? get duration => _audioService.duration;

  void setPlaylist(List<Song> songs) {
    _playlist = songs;
    notifyListeners();
  }

  Future<void> playSong(Song song) async {
    try {
      _currentSong = song;
      _currentPosition = Duration.zero;
      notifyListeners();

      if (song.filePath.isNotEmpty) {
        await _audioService.play(song.filePath);
        _isPlaying = true;
      }
      notifyListeners();
    } catch (e) {
      print('Error playing song: $e');
      _isPlaying = false;
      notifyListeners();
    }
  }

  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await _audioService.pause();
    } else {
      await _audioService.resume();
    }
    notifyListeners();
  }

  Future<void> seekTo(Duration position) async {
    await _audioService.seekTo(position);
    _currentPosition = position;
    notifyListeners();
  }

  void nextSong() {
    if (_playlist.isEmpty || _currentSong == null) return;

    final currentIndex = _playlist.indexWhere((s) => s.id == _currentSong!.id);
    if (currentIndex < _playlist.length - 1) {
      playSong(_playlist[currentIndex + 1]);
    } else if (_repeatMode == RepeatMode.all) {
      playSong(_playlist[0]);
    }
  }

  void previousSong() {
    if (_playlist.isEmpty || _currentSong == null) return;

    final currentIndex = _playlist.indexWhere((s) => s.id == _currentSong!.id);
    if (currentIndex > 0) {
      playSong(_playlist[currentIndex - 1]);
    } else if (_repeatMode == RepeatMode.all) {
      playSong(_playlist[_playlist.length - 1]);
    }
  }

  void toggleShuffle() {
    _isShuffle = !_isShuffle;
    notifyListeners();
  }

  void cycleRepeatMode() {
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

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}

enum RepeatMode { off, all, one }
