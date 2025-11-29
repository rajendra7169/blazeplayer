import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;
  AudioPlayerService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();

  AudioPlayer get audioPlayer => _audioPlayer;

  Future<void> initialize() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
  }

  Future<void> play(String filePath) async {
    try {
      await _audioPlayer.setFilePath(filePath);
      await _audioPlayer.play();
    } catch (e) {
      print('Error playing audio: $e');
      rethrow;
    }
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> resume() async {
    await _audioPlayer.play();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  Future<void> seekTo(Duration position) async {
    await _audioPlayer.seek(position);
  }

  // Set loop mode for repeat functionality
  Future<void> setLoopMode(LoopMode loopMode) async {
    await _audioPlayer.setLoopMode(loopMode);
  }

  // Set shuffle mode
  Future<void> setShuffleModeEnabled(bool enabled) async {
    await _audioPlayer.setShuffleModeEnabled(enabled);
  }

  void setVolume(double value) {
    _audioPlayer.setVolume(value);
  }

  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;
  Stream<bool> get playingStream => _audioPlayer.playingStream;
  Stream<ProcessingState> get processingStateStream =>
      _audioPlayer.processingStateStream;

  Duration? get duration => _audioPlayer.duration;
  Duration get position => _audioPlayer.position;
  bool get playing => _audioPlayer.playing;
  ProcessingState get processingState => _audioPlayer.processingState;

  void dispose() {
    _audioPlayer.dispose();
  }
}
