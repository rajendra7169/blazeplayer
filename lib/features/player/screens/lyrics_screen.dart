import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/music_player_provider.dart';

class LyricsScreen extends StatefulWidget {
  const LyricsScreen({super.key});

  @override
  State<LyricsScreen> createState() => _LyricsScreenState();
}

class _LyricsScreenState extends State<LyricsScreen> {
  String? _lyrics;
  int? _currentLineIndex;

  @override
  void initState() {
    super.initState();
    // TODO: Load lyrics from file or database
    // For now, we'll show placeholder text
  }

  Future<void> _pickLyricsFile() async {
    try {
      // FilePicker handles permissions internally on modern Android
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'lrc'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        // TODO: Read and parse the lyrics file
        // For now, show a success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lyrics file selected: ${result.files.first.name}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick file: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
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
        // Swipe down to close lyrics screen
        if (details.primaryVelocity != null && details.primaryVelocity! > 200) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
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
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              color: isDark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.white.withOpacity(0.1),
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
                      child: hasLyrics
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
                              activeTrackColor: isDark
                                  ? Colors.white
                                  : Colors.white,
                              inactiveTrackColor:
                                  (isDark ? Colors.white : Colors.white)
                                      .withOpacity(0.3),
                              thumbColor: isDark ? Colors.white : Colors.white,
                              overlayColor:
                                  (isDark ? Colors.white : Colors.white)
                                      .withOpacity(0.2),
                            ),
                            child: Slider(
                              value: playerProvider.currentPosition.inSeconds
                                  .toDouble(),
                              max: currentSong.duration.inSeconds.toDouble(),
                              onChanged: (value) {
                                playerProvider.seekTo(
                                  Duration(seconds: value.toInt()),
                                );
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
                                    playerProvider.currentPosition,
                                  ),
                                  style: TextStyle(
                                    color:
                                        (isDark ? Colors.white : Colors.white)
                                            .withOpacity(0.7),
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '-${_formatDuration(currentSong.duration - playerProvider.currentPosition)}',
                                  style: TextStyle(
                                    color:
                                        (isDark ? Colors.white : Colors.white)
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
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white.withOpacity(0.1),
                            ),
                            child: currentSong.albumArt != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.asset(
                                      currentSong.albumArt!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Icon(
                                    Icons.music_note_rounded,
                                    color: Colors.white.withOpacity(0.5),
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
                                    color:
                                        (isDark ? Colors.white : Colors.white)
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
          ),
        ),
      ),
    );
  }

  Widget _buildLyricsView(bool isDark) {
    // Sample lyrics structure (will be replaced with actual lyrics)
    final lines = [
      '(Verse 1)',
      '',
      'Sample lyric line one',
      'Sample lyric line two',
      'Sample lyric line three',
      '',
      '(Chorus)',
      '',
      'Sample chorus line one',
      'Sample chorus line two',
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      itemCount: lines.length,
      itemBuilder: (context, index) {
        final isCurrentLine = index == _currentLineIndex;
        final isVerseLabel =
            lines[index].startsWith('(') && lines[index].endsWith(')');

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
            textAlign: isVerseLabel ? TextAlign.left : TextAlign.left,
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
