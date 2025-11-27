import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/music_player_provider.dart';
import '../widgets/artwork_color_builder.dart';
import '../widgets/cached_artwork_widget.dart';

class LyricsScreen extends StatefulWidget {
  const LyricsScreen({super.key});

  @override
  State<LyricsScreen> createState() => _LyricsScreenState();
}

class _LyricsScreenState extends State<LyricsScreen> {
  String? _lyrics;
  int? _currentLineIndex;
  bool _isLoading = false;
  bool _isDragging = false;
  double _dragPosition = 0.0;

  @override
  void initState() {
    super.initState();
    _loadSavedLyrics();
  }

  Future<void> _loadSavedLyrics() async {
    setState(() => _isLoading = true);

    try {
      final playerProvider = context.read<MusicPlayerProvider>();
      final currentSong = playerProvider.currentSong;

      if (currentSong != null) {
        final prefs = await SharedPreferences.getInstance();
        final songKey = 'lyrics_${currentSong.id}';
        final savedLyricsPath = prefs.getString(songKey);

        if (savedLyricsPath != null && savedLyricsPath.isNotEmpty) {
          final file = File(savedLyricsPath);
          if (await file.exists()) {
            final content = await file.readAsString();
            setState(() {
              _lyrics = _parseLrcFile(content);
            });
          } else {
            // File no longer exists, remove the saved path
            await prefs.remove(songKey);
          }
        }
      }
    } catch (e) {
      print('Error loading saved lyrics: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveLyricsPath(String songId, String filePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final songKey = 'lyrics_$songId';
      await prefs.setString(songKey, filePath);
    } catch (e) {
      print('Error saving lyrics path: $e');
    }
  }

  Future<void> _pickLyricsFile() async {
    try {
      final playerProvider = context.read<MusicPlayerProvider>();
      final currentSong = playerProvider.currentSong;

      if (currentSong == null) return;

      // Use allowedExtensions with proper type
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any, // Changed to 'any' for better compatibility
        allowMultiple: false,
        withData: true, // This ensures file content is available
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final fileName = file.name.toLowerCase();

        // Check if it's a valid lyrics file
        if (fileName.endsWith('.txt') || fileName.endsWith('.lrc')) {
          // Read the file content
          String? lyricsContent;
          String? filePath;

          if (file.path != null) {
            // Read from file path
            filePath = file.path!;
            final ioFile = File(filePath);
            lyricsContent = await ioFile.readAsString();
          } else if (file.bytes != null) {
            // Read from bytes
            lyricsContent = String.fromCharCodes(file.bytes!);
          }

          if (lyricsContent != null && lyricsContent.isNotEmpty) {
            setState(() {
              _lyrics = _parseLrcFile(lyricsContent!);
            });

            // Save the file path for this song
            if (filePath != null) {
              await _saveLyricsPath(currentSong.id.toString(), filePath);
            }

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Lyrics loaded: ${file.name}'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Lyrics file is empty'),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please select a .txt or .lrc file'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      }
    } catch (e) {
      print('Error picking file: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load lyrics: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  String _parseLrcFile(String content) {
    // Split by lines
    final lines = content.split('\n');
    final lyricsLines = <String>[];

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) {
        lyricsLines.add('');
        continue;
      }

      // Remove .lrc timestamp format [00:12.00] or [00:12:00]
      // This regex removes timestamps like [00:12.00] or [mm:ss.xx]
      final cleanedLine = line
          .replaceAll(RegExp(r'\[\d{2}:\d{2}[:.]\d{2}\]'), '')
          .trim();

      // Also handle metadata tags like [ti:Title], [ar:Artist], etc.
      if (cleanedLine.startsWith('[') &&
          cleanedLine.contains(':') &&
          cleanedLine.endsWith(']')) {
        // Skip metadata
        continue;
      }

      if (cleanedLine.isNotEmpty) {
        lyricsLines.add(cleanedLine);
      }
    }

    return lyricsLines.join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final playerProvider = context.watch<MusicPlayerProvider>();
    final currentSong = playerProvider.currentSong;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (currentSong == null) {
      Navigator.of(context).pop();
      return const SizedBox.shrink();
    }

    // Check if lyrics are available (for now, always false)
    final hasLyrics = _lyrics != null;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;

        // Swipe down to close lyrics screen (velocity > 300)
        if (velocity > 300) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: currentSong.albumArt != null
            ? ArtworkColorBuilder(
                songId: currentSong.albumArt!,
                builder: (dominantColor, vibrantColor) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          dominantColor,
                          Color.lerp(dominantColor, vibrantColor, 0.6)!,
                          vibrantColor,
                          Color.lerp(vibrantColor, Colors.black, 0.4)!,
                          const Color(0xFF000000),
                        ],
                        stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                      ),
                    ),
                    child: _buildLyricsContent(
                      context,
                      playerProvider,
                      currentSong,
                      isDark,
                    ),
                  );
                },
              )
            : Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDark
                        ? [
                            const Color(0xFF2D2D2D),
                            const Color(0xFF1A1A1A),
                            const Color(0xFF000000),
                          ]
                        : [
                            const Color(0xFFE8B4B8),
                            const Color(0xFFB8A4C9),
                            const Color(0xFF8B7B9B),
                          ],
                  ),
                ),
                child: _buildLyricsContent(
                  context,
                  playerProvider,
                  currentSong,
                  isDark,
                ),
              ),
      ),
    );
  }

  Widget _buildLyricsContent(
    BuildContext context,
    MusicPlayerProvider playerProvider,
    dynamic currentSong,
    bool isDark,
  ) {
    final hasLyrics = _lyrics != null;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        color: Colors.black.withOpacity(0.4),
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: isDark ? Colors.white : Colors.white,
                        size: 32,
                      ),
                    ),
                    Text(
                      currentSong.title,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.more_horiz_rounded,
                        color: isDark ? Colors.white : Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),

              // Lyrics Content
              Expanded(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Colors.white.withOpacity(0.7),
                        ),
                      )
                    : hasLyrics
                    ? _buildLyricsView(isDark)
                    : _buildNoLyricsView(isDark),
              ),

              // Progress Slider
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 8,
                ),
                child: Column(
                  children: [
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 3,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 6,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 16,
                        ),
                        activeTrackColor: isDark ? Colors.white : Colors.white,
                        inactiveTrackColor:
                            (isDark ? Colors.white : Colors.white).withOpacity(
                              0.3,
                            ),
                        thumbColor: isDark ? Colors.white : Colors.white,
                        overlayColor: (isDark ? Colors.white : Colors.white)
                            .withOpacity(0.2),
                      ),
                      child: Slider(
                        value: _isDragging
                            ? _dragPosition
                            : playerProvider.currentPosition.inSeconds
                                  .toDouble()
                                  .clamp(
                                    0.0,
                                    currentSong.duration.inSeconds.toDouble(),
                                  )
                                  .toDouble(),
                        max: currentSong.duration.inSeconds.toDouble() > 0
                            ? currentSong.duration.inSeconds.toDouble()
                            : 0.1,
                        onChanged: (value) {
                          setState(() {
                            _isDragging = true;
                            _dragPosition = value;
                          });
                        },
                        onChangeEnd: (value) {
                          playerProvider.seekTo(
                            Duration(seconds: value.toInt()),
                          );
                          setState(() {
                            _isDragging = false;
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(
                              _isDragging
                                  ? Duration(seconds: _dragPosition.toInt())
                                  : playerProvider.currentPosition,
                            ),
                            style: TextStyle(
                              color: (isDark ? Colors.white : Colors.white)
                                  .withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '-${_formatDuration(_isDragging ? Duration(seconds: (currentSong.duration.inSeconds - _dragPosition.toInt())) : currentSong.duration - playerProvider.currentPosition)}',
                            style: TextStyle(
                              color: (isDark ? Colors.white : Colors.white)
                                  .withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom Mini Player Info
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Album Art
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 50,
                        height: 50,
                        child: currentSong.albumArt != null
                            ? CachedArtworkWidget(
                                songId: currentSong.albumArt!,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                borderRadius: BorderRadius.zero,
                                fallback: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                  child: Icon(
                                    Icons.music_note_rounded,
                                    color: Colors.white.withOpacity(0.5),
                                  ),
                                ),
                              )
                            : Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                ),
                                child: Icon(
                                  Icons.music_note_rounded,
                                  color: Colors.white.withOpacity(0.5),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Song Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            currentSong.title,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            currentSong.artist,
                            style: TextStyle(
                              color: (isDark ? Colors.white : Colors.white)
                                  .withOpacity(0.7),
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Favorite Icon
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.favorite_border_rounded,
                        color: isDark ? Colors.white : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLyricsView(bool isDark) {
    // Split the lyrics into lines
    final lines = _lyrics?.split('\n') ?? [];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      itemCount: lines.length,
      itemBuilder: (context, index) {
        final isCurrentLine = index == _currentLineIndex;
        final isVerseLabel =
            lines[index].startsWith('(') && lines[index].endsWith(')');
        final isEmpty = lines[index].trim().isEmpty;

        // Handle empty lines
        if (isEmpty) {
          return const SizedBox(height: 16);
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            lines[index],
            style: TextStyle(
              color: isCurrentLine
                  ? (isDark ? const Color(0xFFFFA726) : Colors.white)
                  : (isDark ? Colors.white : Colors.white).withOpacity(
                      isVerseLabel ? 0.9 : 0.6,
                    ),
              fontSize: isCurrentLine ? 24 : (isVerseLabel ? 16 : 18),
              fontWeight: isCurrentLine
                  ? FontWeight.bold
                  : (isVerseLabel ? FontWeight.w600 : FontWeight.w400),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }

  Widget _buildNoLyricsView(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lyrics_outlined,
              size: 80,
              color: (isDark ? Colors.white : Colors.white).withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'No Lyrics Available',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Upload a lyrics file to see the lyrics for this song',
              style: TextStyle(
                color: (isDark ? Colors.white : Colors.white).withOpacity(0.7),
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _pickLyricsFile,
              icon: const Icon(Icons.upload_file_rounded),
              label: const Text('Upload Lyrics File'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark
                    ? const Color(0xFFFFA726)
                    : const Color(0xFFB8A4C9),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Supported formats: .txt, .lrc',
              style: TextStyle(
                color: (isDark ? Colors.white : Colors.white).withOpacity(0.5),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
