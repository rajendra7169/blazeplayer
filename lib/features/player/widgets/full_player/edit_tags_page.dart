import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../cached_artwork_widget.dart';
import '../../models/song_model.dart';
import '../../providers/music_player_provider.dart';

class EditTagsPage extends StatefulWidget {
  final dynamic song;
  final bool isDark;
  const EditTagsPage({super.key, required this.song, required this.isDark});

  @override
  State<EditTagsPage> createState() => _EditTagsPageState();
}

class _EditTagsPageState extends State<EditTagsPage> {
  bool _isSaving = false;
  static const _tagChannel = MethodChannel('blazeplayer/tag_editor');
  final OnAudioQuery _audioQuery = OnAudioQuery();
  late TextEditingController titleController;
  late TextEditingController albumController;
  late TextEditingController artistController;
  late TextEditingController genreController;
  late TextEditingController trackController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.song.title);
    albumController = TextEditingController(text: widget.song.album ?? '');
    artistController = TextEditingController(text: widget.song.artist ?? '');
    genreController = TextEditingController(text: widget.song.genre ?? '');
    trackController = TextEditingController(
      text: widget.song.trackNumber?.toString() ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final song = widget.song;
    final themeColor = isDark
        ? const Color(0xFFFFA726)
        : const Color(0xFFFF7043);
    // Always get the latest customArtPath from provider
    final provider = Provider.of<MusicPlayerProvider>(context, listen: false);
    final latestCustomArtPath =
        provider.getCustomArtForSong(song.id) ?? song.customArtPath;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF232323) : Colors.white,
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          SafeArea(
            child: Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              alignment: Alignment.center,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      color: isDark ? Colors.white70 : Colors.black54,
                      size: 22,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  Text(
                    'Edit Tags',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const Spacer(),
                  // No save button here
                ],
              ),
            ),
          ),
          // Art image fixed at top, not scrollable
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.of(
                    context,
                  ).pushNamed('/changeCover', arguments: song);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child:
                      latestCustomArtPath != null &&
                          latestCustomArtPath.isNotEmpty &&
                          File(latestCustomArtPath).existsSync()
                      ? Image.file(
                          File(latestCustomArtPath),
                          width: 140,
                          height: 140,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: 140,
                                height: 140,
                                color: isDark
                                    ? Colors.grey[800]
                                    : Colors.grey[300],
                                child: Icon(
                                  Icons.music_note_rounded,
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black54,
                                  size: 48,
                                ),
                              ),
                        )
                      : (song.albumArt != null
                            ? CachedArtworkWidget(
                                songId: song.albumArt!,
                                width: 140,
                                height: 140,
                                fit: BoxFit.cover,
                                borderRadius: BorderRadius.circular(18),
                                fallback: Container(
                                  width: 140,
                                  height: 140,
                                  color: isDark
                                      ? Colors.grey[800]
                                      : Colors.grey[300],
                                  child: Icon(
                                    Icons.music_note_rounded,
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black54,
                                    size: 48,
                                  ),
                                ),
                              )
                            : Container(
                                width: 140,
                                height: 140,
                                color: isDark
                                    ? Colors.grey[800]
                                    : Colors.grey[300],
                                child: Icon(
                                  Icons.music_note_rounded,
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black54,
                                  size: 48,
                                ),
                              )),
                ),
              ),
            ),
          ),
          // Editable fields and buttons scrollable
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildEditableField('Title', titleController, isDark),
                    _buildEditableField('Album', albumController, isDark),
                    _buildEditableField('Artist', artistController, isDark),
                    _buildEditableField('Genre', genreController, isDark),
                    _buildEditableField(
                      'Track Number',
                      trackController,
                      isDark,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: Container(
                            height: 54,
                            margin: const EdgeInsets.only(right: 12),
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                backgroundColor: isDark
                                    ? const Color(0xFF232323)
                                    : Colors.white,
                                foregroundColor: isDark
                                    ? Colors.white
                                    : Colors.black87,
                                side: BorderSide(color: themeColor, width: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              onPressed: _fetchInfo,
                              child: const Text(
                                'Fetch Info',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 54,
                            margin: const EdgeInsets.only(left: 12),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: themeColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                elevation: 0,
                              ),
                              onPressed: _isSaving
                                  ? null
                                  : () async {
                                      setState(() => _isSaving = true);
                                      await _saveTags();
                                      if (mounted) {
                                        setState(() => _isSaving = false);
                                      }
                                    },
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                switchInCurve: Curves.easeOut,
                                switchOutCurve: Curves.easeIn,
                                transitionBuilder: (child, animation) =>
                                    FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    ),
                                child: _isSaving
                                    ? SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                themeColor,
                                              ),
                                        ),
                                      )
                                    : const Text(
                                        'Save',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableField(
    String label,
    TextEditingController controller,
    bool isDark, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: isDark ? Colors.white70 : Colors.black54,
            fontWeight: FontWeight.w600,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: isDark ? Colors.white24 : Colors.black12,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: isDark ? const Color(0xFFFFA726) : const Color(0xFFFF7043),
              width: 2,
            ),
          ),
          fillColor: isDark ? Colors.white10 : Colors.grey[100],
          filled: true,
        ),
      ),
    );
  }

  Future<void> _fetchInfo() async {
    final title = titleController.text.trim();
    final artist = artistController.text.trim();
    final album = albumController.text.trim();
    // Helper to check if a field is invalid
    bool isInvalid(String value) {
      final v = value.toLowerCase();
      return v.isEmpty ||
          v == '<unknown>' ||
          v == 'unknown' ||
          v == 'videotoaudio';
    }

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter song title.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    // If artist or album is invalid, search only by title
    String searchTerm;
    if (isInvalid(artist) || isInvalid(album)) {
      searchTerm = Uri.encodeComponent(title);
    } else {
      searchTerm = Uri.encodeComponent('$title $artist');
    }
    final url = Uri.parse(
      'https://itunes.apple.com/search?term=$searchTerm&entity=song&limit=1',
    );
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final response = await http.get(url);
      Navigator.of(context).pop();
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List<dynamic>?;
        if (results != null && results.isNotEmpty) {
          final songData = results.first;
          setState(() {
            titleController.text =
                songData['trackName'] ?? titleController.text;
            artistController.text =
                songData['artistName'] ?? artistController.text;
            albumController.text =
                songData['collectionName'] ?? albumController.text;
            genreController.text =
                songData['primaryGenreName'] ?? genreController.text;
            trackController.text =
                songData['trackNumber']?.toString() ?? trackController.text;
          });

          // Fetch cover art
          String? artPath;
          final artworkUrl = songData['artworkUrl100'] as String?;
          if (artworkUrl != null && artworkUrl.isNotEmpty) {
            // Use higher resolution if possible
            final highResUrl = artworkUrl.replaceAll('100x100', '600x600');
            try {
              final artResponse = await http.get(Uri.parse(highResUrl));
              if (artResponse.statusCode == 200) {
                final dir = await getApplicationDocumentsDirectory();
                final filePath = '${dir.path}/cover_${widget.song.id}.jpg';
                final file = File(filePath);
                await file.writeAsBytes(artResponse.bodyBytes);
                artPath = filePath;
                if (mounted) {
                  final provider = Provider.of<MusicPlayerProvider>(
                    context,
                    listen: false,
                  );
                  provider.setCustomArtForSong(widget.song.id, artPath);
                }
                setState(() {});
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Art image not found or network error.'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error fetching art image: $e'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                artPath != null
                    ? 'Song info and art fetched!'
                    : 'Song info fetched!',
              ),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No info found for this song.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching info: ${response.statusCode}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network error or SSL issue: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _saveTags() async {
    final original = widget.song;
    try {
      final trackText = trackController.text.trim();
      final updated = original.copyWith(
        title: titleController.text.trim(),
        album: albumController.text.trim(),
        artist: artistController.text.trim(),
        genre: genreController.text.trim(),
        trackNumber: trackText.isNotEmpty ? int.tryParse(trackText) : null,
      );

      // Request correct storage permission for Android 11+
      PermissionStatus status;
      if (Platform.isAndroid) {
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;
        final sdkInt = androidInfo.version.sdkInt;
        if (sdkInt >= 30) {
          status = await Permission.manageExternalStorage.request();
          if (!status.isGranted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Storage permission required. Please enable "Allow access to manage all files" in system settings.',
                ),
                duration: Duration(seconds: 5),
                action: SnackBarAction(
                  label: 'Open Settings',
                  onPressed: () {
                    openAppSettings();
                  },
                ),
              ),
            );
            return;
          }
        } else {
          status = await Permission.storage.request();
          if (!status.isGranted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Storage permission required to edit tags.'),
                duration: Duration(seconds: 3),
              ),
            );
            return;
          }
        }
      }

      // Save tags to file via platform channel (Android)
      if (updated.filePath != null) {
        final trackNum = updated.trackNumber?.toString();
        final success = await _saveTagsToFile(
          updated.filePath,
          updated.title,
          updated.album,
          updated.artist,
          updated.genre,
          trackNum,
        );
        if (success != true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to save tags. Check permissions and file path.',
              ),
              duration: Duration(seconds: 3),
            ),
          );
          return;
        }

        // Update the song in the provider immediately with user-entered values
        if (mounted) {
          final provider = Provider.of<MusicPlayerProvider>(
            context,
            listen: false,
          );
          provider.updateSongTags(
            updated.id,
            title: updated.title,
            album: updated.album,
            artist: updated.artist,
            genre: updated.genre,
            trackNumber: updated.trackNumber,
          );
        }

        // Wait for media scanner to update MediaStore database
        await Future.delayed(Duration(milliseconds: 1500));

        // Reload song tags from MediaStore after scanning
        final reloadedSong = await _reloadSongFromFile(updated.filePath);

        // Update provider again with MediaStore data to ensure consistency
        if (reloadedSong != null && mounted) {
          final provider = Provider.of<MusicPlayerProvider>(
            context,
            listen: false,
          );
          provider.updateSongTags(
            reloadedSong.id,
            title: reloadedSong.title,
            album: reloadedSong.album,
            artist: reloadedSong.artist,
            genre: reloadedSong.genre,
            trackNumber: reloadedSong.trackNumber,
          );

          // Refresh the entire song library from MediaStore in background
          provider.fetchLocalSongs();
        }

        Navigator.of(context).pop(reloadedSong ?? updated);
      } else {
        Navigator.of(context).pop(updated);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving tags: ${e.toString()}'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<bool?> _saveTagsToFile(
    String filePath,
    String title,
    String album,
    String artist,
    String genre,
    String? trackNumber,
  ) async {
    try {
      final result = await _tagChannel.invokeMethod('saveTags', {
        'filePath': filePath,
        'title': title,
        'album': album,
        'artist': artist,
        'genre': genre,
        'trackNumber': trackNumber,
      });
      return result == true;
    } catch (e) {
      return false;
    }
  }

  /// Reload the song tags from the file after saving.
  Future<dynamic> _reloadSongFromFile(String filePath) async {
    try {
      // Query all songs and find the one with matching file path
      final songModels = await _audioQuery.querySongs(
        sortType: null,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );

      // Find the song with the matching file path
      final matchingSong = songModels.firstWhere(
        (s) => s.data == filePath,
        orElse: () => throw Exception('Song not found'),
      );

      // Get latest customArtPath from provider if available
      String? latestCustomArtPath;
      if (mounted) {
        final provider = Provider.of<MusicPlayerProvider>(
          context,
          listen: false,
        );
        latestCustomArtPath = provider.getCustomArtForSong(
          matchingSong.id.toString(),
        );
      }
      // Fallback to widget.song.customArtPath if provider returns null
      latestCustomArtPath ??= widget.song.customArtPath;

      // Convert to Song model
      final reloadedSong = Song(
        id: matchingSong.id.toString(),
        title: matchingSong.title,
        artist: matchingSong.artist ?? 'Unknown Artist',
        album: matchingSong.album ?? 'Unknown Album',
        albumArt: matchingSong.id.toString(),
        duration: Duration(milliseconds: matchingSong.duration ?? 0),
        filePath: matchingSong.data,
        genre: matchingSong.genre,
        trackNumber: matchingSong.track,
        customArtPath: latestCustomArtPath,
        playCount: widget.song.playCount,
        dateAdded: widget.song.dateAdded,
      );

      return reloadedSong;
    } catch (e) {
      return null;
    }
  }
}
