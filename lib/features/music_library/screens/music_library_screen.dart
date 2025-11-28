import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import '../../player/models/song_model.dart';
import '../../player/providers/music_player_provider.dart';
import '../../player/screens/full_player_screen.dart';
import '../../player/widgets/cached_artwork_widget.dart';

class MusicLibraryScreen extends StatefulWidget {
  const MusicLibraryScreen({super.key});

  @override
  State<MusicLibraryScreen> createState() => _MusicLibraryScreenState();
}

class _MusicLibraryScreenState extends State<MusicLibraryScreen> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  List<SongModel> _songs = [];
  bool _isLoading = true;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _requestPermissionAndLoadSongs();
  }

  Future<void> _requestPermissionAndLoadSongs() async {
    setState(() {
      _isLoading = true;
    });

    // Check permission using on_audio_query
    bool permissionGranted = await _audioQuery.permissionsStatus();

    print('Permission status: $permissionGranted');

    if (!permissionGranted) {
      // Request permission
      permissionGranted = await _audioQuery.permissionsRequest();
      print('Permission after request: $permissionGranted');
    }

    setState(() {
      _hasPermission = permissionGranted;
    });

    if (permissionGranted) {
      await _loadSongs();
    } else {
      setState(() {
        _isLoading = false;
      });

      // Show dialog to open settings
      if (mounted) {
        _showPermissionDialog();
      }
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
          'This app needs storage permission to access your music files. Please grant the permission in app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _requestPermissionAndLoadSongs();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadSongs() async {
    try {
      print('Starting to query songs...');

      final songs = await _audioQuery.querySongs(
        sortType: SongSortType.TITLE,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );

      print('Found ${songs.length} songs');

      setState(() {
        _songs = songs;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading songs: $e');
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading songs: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Song _convertToSong(SongModel songModel) {
    return Song(
      id: songModel.id.toString(),
      title: songModel.title,
      artist: songModel.artist ?? 'Unknown Artist',
      album: songModel.album ?? 'Unknown Album',
      albumArt: songModel.id.toString(), // Store the song ID to query artwork
      duration: Duration(milliseconds: songModel.duration ?? 0),
      filePath: songModel.data,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final playerProvider = context.watch<MusicPlayerProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Music Library'),
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : !_hasPermission
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.music_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Storage permission is required',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _requestPermissionAndLoadSongs,
                    child: const Text('Grant Permission'),
                  ),
                ],
              ),
            )
          : _songs.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.music_note, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No songs found', style: TextStyle(fontSize: 16)),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _songs.length,
              padding: const EdgeInsets.only(bottom: 100),
              itemBuilder: (context, index) {
                final songModel = _songs[index];
                final song = _convertToSong(songModel);
                final isPlaying =
                    playerProvider.currentSong?.id == song.id &&
                    playerProvider.isPlaying;

                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: CachedArtworkWidget(
                        songId: songModel.id.toString(),
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        borderRadius: BorderRadius.zero,
                        fallback: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF3D3D3D)
                                : Colors.grey[300],
                          ),
                          child: const Icon(
                            Icons.music_note,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    songModel.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: isPlaying
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isPlaying ? const Color(0xFFFFA726) : null,
                    ),
                  ),
                  subtitle: Text(
                    songModel.artist ?? 'Unknown Artist',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: isPlaying
                      ? const Icon(Icons.equalizer, color: Color(0xFFFFA726))
                      : null,
                  onTap: () async {
                    // Set playlist
                    final allSongs = _songs.map(_convertToSong).toList();
                    playerProvider.setPlaylist(allSongs);

                    // Play song
                    await playerProvider.playSong(song);

                    // Navigate to full player
                    if (context.mounted) {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          opaque: false,
                          barrierColor: Colors.black.withOpacity(0.0),
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const FullPlayerScreen(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                                const begin = Offset(0.0, 1.0);
                                const end = Offset.zero;
                                const curve = Curves.easeOutCubic;
                                var tween = Tween(
                                  begin: begin,
                                  end: end,
                                ).chain(CurveTween(curve: curve));
                                var offsetAnimation = animation.drive(tween);
                                return SlideTransition(
                                  position: offsetAnimation,
                                  child: child,
                                );
                              },
                          transitionDuration: const Duration(milliseconds: 400),
                        ),
                      );
                    }
                  },
                );
              },
            ),
    );
  }
}
