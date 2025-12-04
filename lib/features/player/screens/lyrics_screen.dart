import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../providers/music_player_provider.dart';
import '../widgets/artwork_color_builder.dart';
import '../widgets/cached_artwork_widget.dart';

class LyricsScreen extends StatefulWidget {
  const LyricsScreen({super.key});

  @override
  State<LyricsScreen> createState() => _LyricsScreenState();
}

class _LyricsScreenState extends State<LyricsScreen> {
  Future<void> _fetchAndCacheLyrics() async {
    final playerProvider = context.read<MusicPlayerProvider>();
    final currentSong = playerProvider.currentSong;
    if (currentSong == null) return;

    setState(() => _isLoading = true);
    String? lyrics;
    bool isLrcFormat = false;

    // 1. Try LRCLIB first (synced LRC lyrics - FREE, no API key needed)
    try {
      final lrclibResponse = Uri.parse(
        'https://lrclib.net/api/get?artist_name=${Uri.encodeComponent(currentSong.artist)}&track_name=${Uri.encodeComponent(currentSong.title)}',
      );
      print(
        '🔍 Searching LRCLIB: ${currentSong.artist} - ${currentSong.title}',
      );
      final lrclibResult = await http.get(lrclibResponse);
      print('📡 LRCLIB Status: ${lrclibResult.statusCode}');
      if (lrclibResult.statusCode == 200) {
        final data = jsonDecode(lrclibResult.body);
        print('📦 LRCLIB Response: ${data.keys}');
        if (data['syncedLyrics'] != null &&
            data['syncedLyrics'].toString().isNotEmpty) {
          lyrics = data['syncedLyrics'] as String;
          isLrcFormat = true;
          print('✅ Found synced LRC lyrics from LRCLIB');
        } else if (data['plainLyrics'] != null &&
            data['plainLyrics'].toString().isNotEmpty) {
          lyrics = data['plainLyrics'] as String;
          print('✅ Found plain lyrics from LRCLIB');
        } else {
          print('⚠️ LRCLIB returned empty lyrics');
        }
      } else {
        print(
          '❌ LRCLIB failed: ${lrclibResult.statusCode} - ${lrclibResult.body}',
        );
      }
    } catch (e) {
      print('❌ LRCLIB API error: $e');
    }

    // 2. Try AudD API if no result (requires free API key)
    if (lyrics == null || lyrics.isEmpty) {
      const auddApiKey = '488d79b4b321c972a5762e99841d8089';
      try {
        final auddResponse = Uri.parse(
          'https://api.audd.io/findLyrics/?q=${Uri.encodeComponent('${currentSong.title} ${currentSong.artist}')}&api_token=$auddApiKey',
        );
        print('🔍 Searching AudD: ${currentSong.title} ${currentSong.artist}');
        final auddResult = await http.get(auddResponse);
        print('📡 AudD Status: ${auddResult.statusCode}');
        if (auddResult.statusCode == 200) {
          final data = jsonDecode(auddResult.body);
          print('📦 AudD Response: ${data.keys}');
          if (data['result'] != null && data['result']['lyrics'] != null) {
            lyrics = data['result']['lyrics'] as String;
            print('✅ Found lyrics from AudD');
          } else {
            print('⚠️ AudD returned no lyrics in result');
          }
        } else {
          print('❌ AudD failed: ${auddResult.statusCode}');
        }
      } catch (e) {
        print('❌ AudD API error: $e');
      }
    }

    // 3. Fallback to Lyrics.ovh if still no result
    if (lyrics == null || lyrics.isEmpty) {
      try {
        final ovhResponse = Uri.parse(
          'https://api.lyrics.ovh/v1/${Uri.encodeComponent(currentSong.artist)}/${Uri.encodeComponent(currentSong.title)}',
        );
        print(
          '🔍 Searching Lyrics.ovh: ${currentSong.artist} - ${currentSong.title}',
        );
        final ovhResult = await http.get(ovhResponse);
        print('📡 Lyrics.ovh Status: ${ovhResult.statusCode}');
        if (ovhResult.statusCode == 200) {
          final data = jsonDecode(ovhResult.body);
          print('📦 Lyrics.ovh Response: ${data.keys}');
          if (data['lyrics'] != null) {
            lyrics = data['lyrics'] as String;
            print('✅ Found lyrics from Lyrics.ovh');
          } else {
            print('⚠️ Lyrics.ovh returned no lyrics');
          }
        } else {
          print('❌ Lyrics.ovh failed: ${ovhResult.statusCode}');
        }
      } catch (e) {
        print('❌ Lyrics.ovh API error: $e');
      }
    }

    // Parse LRC format if applicable
    if (lyrics != null && lyrics.isNotEmpty) {
      // Cache the original lyrics (with timestamps if LRC)
      try {
        final prefs = await SharedPreferences.getInstance();
        final cachedLyricsKey = 'lyrics_cached_${currentSong.id}';
        await prefs.setString(cachedLyricsKey, lyrics); // Cache original
      } catch (e) {
        print('Error caching lyrics: $e');
      }

      // Parse LRC to extract timestamps and display text
      if (isLrcFormat || lyrics.contains(RegExp(r'\[\d{2}:\d{2}'))) {
        print('🔄 Parsing LRC format lyrics');
        lyrics = _parseLrcFile(lyrics);
      }
    }

    setState(() {
      _lyrics = lyrics;
      _isLoading = false;
    });
  }

  // Add required imports
  // import 'dart:convert';
  // import 'package:http/http.dart' as http;
  String? _lyrics;
  int? _currentLineIndex;
  bool _isLoading = false;
  bool _isDragging = false;
  double _dragPosition = 0.0;
  final ScrollController _scrollController = ScrollController();
  final Map<int, int> _lrcTimestamps = {}; // line index -> milliseconds
  List<String> _lyricsLines = [];
  final Map<int, GlobalKey> _lineKeys = {}; // Keys for accurate positioning

  @override
  void initState() {
    super.initState();
    _loadSavedLyrics();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedLyrics() async {
    setState(() => _isLoading = true);

    try {
      final playerProvider = context.read<MusicPlayerProvider>();
      final currentSong = playerProvider.currentSong;

      if (currentSong != null) {
        final prefs = await SharedPreferences.getInstance();
        final songKey = 'lyrics_${currentSong.id}';
        final cachedLyricsKey = 'lyrics_cached_${currentSong.id}';

        // First check for cached lyrics text
        final cachedLyrics = prefs.getString(cachedLyricsKey);
        if (cachedLyrics != null && cachedLyrics.isNotEmpty) {
          // Check if cached lyrics are in LRC format and parse them
          if (cachedLyrics.contains(RegExp(r'\[\d{2}:\d{2}'))) {
            print('🔄 Parsing cached LRC lyrics');
            final parsed = _parseLrcFile(cachedLyrics);
            setState(() {
              _lyrics = parsed;
              _isLoading = false;
            });
          } else {
            setState(() {
              _lyrics = cachedLyrics;
              _isLoading = false;
            });
          }
          return;
        }

        // Then check for saved LRC file path
        final savedLyricsPath = prefs.getString(songKey);
        if (savedLyricsPath != null && savedLyricsPath.isNotEmpty) {
          final file = File(savedLyricsPath);
          if (await file.exists()) {
            final content = await file.readAsString();
            setState(() {
              _lyrics = _parseLrcFile(content);
              _isLoading = false;
            });
            return;
          } else {
            // File no longer exists, remove the saved path
            await prefs.remove(songKey);
          }
        }

        // No cached lyrics found, try to fetch from API
        await _fetchAndCacheLyrics();
      }
    } catch (e) {
      print('Error loading saved lyrics: $e');
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
    _lrcTimestamps.clear();
    int lineIndex = 0;

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) {
        lyricsLines.add('');
        lineIndex++;
        continue;
      }

      // Extract timestamp from LRC format [mm:ss.xx] or [mm:ss:xx]
      final timestampMatch = RegExp(
        r'\[(\d{2}):(\d{2})[\.:\\]?(\d{2})\]',
      ).firstMatch(line);
      int? timestamp;
      if (timestampMatch != null) {
        final minutes = int.parse(timestampMatch.group(1)!);
        final seconds = int.parse(timestampMatch.group(2)!);
        final centiseconds = int.parse(timestampMatch.group(3)!);
        timestamp =
            (minutes * 60 * 1000) + (seconds * 1000) + (centiseconds * 10);
      }

      // Remove timestamp from line
      final cleanedLine = line
          .replaceAll(RegExp(r'\[\d{2}:\d{2}[\.:\\]?\d{2}\]'), '')
          .trim();

      // Skip metadata tags like [ti:Title], [ar:Artist], etc.
      if (cleanedLine.startsWith('[') &&
          cleanedLine.contains(':') &&
          cleanedLine.endsWith(']')) {
        continue;
      }

      if (cleanedLine.isNotEmpty) {
        if (timestamp != null) {
          _lrcTimestamps[lineIndex] = timestamp;
          print('📍 Line $lineIndex: "$cleanedLine" -> ${timestamp}ms');
        }
        lyricsLines.add(cleanedLine);
        lineIndex++;
      }
    }

    _lyricsLines = lyricsLines;
    print(
      '✅ Parsed ${_lrcTimestamps.length} timestamped lines out of ${lyricsLines.length} total lines',
    );
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
                    : _lyrics != null
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
                    ValueListenableBuilder<Duration>(
                      valueListenable: playerProvider.positionNotifier,
                      builder: (context, position, _) {
                        return SliderTheme(
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
                            overlayColor: (isDark ? Colors.white : Colors.white)
                                .withOpacity(0.2),
                          ),
                          child: Slider(
                            value: _isDragging
                                ? _dragPosition
                                : position.inSeconds
                                      .toDouble()
                                      .clamp(
                                        0.0,
                                        currentSong.duration.inSeconds
                                            .toDouble(),
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
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: ValueListenableBuilder<Duration>(
                        valueListenable: playerProvider.positionNotifier,
                        builder: (context, position, _) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(
                                  _isDragging
                                      ? Duration(seconds: _dragPosition.toInt())
                                      : position,
                                ),
                                style: TextStyle(
                                  color: (isDark ? Colors.white : Colors.white)
                                      .withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '-${_formatDuration(_isDragging ? Duration(seconds: (currentSong.duration.inSeconds - _dragPosition.toInt())) : currentSong.duration - position)}',
                                style: TextStyle(
                                  color: (isDark ? Colors.white : Colors.white)
                                      .withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          );
                        },
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
                    Builder(
                      builder: (context) {
                        final customArtPath = Provider.of<MusicPlayerProvider>(
                          context,
                          listen: false,
                        ).getCustomArtForSong(currentSong.id);
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child:
                                (customArtPath != null &&
                                    customArtPath.isNotEmpty)
                                ? Image.file(
                                    File(customArtPath),
                                    fit: BoxFit.cover,
                                    width: 50,
                                    height: 50,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                              width: 50,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    const Color(
                                                      0xFFFFA726,
                                                    ).withOpacity(0.7),
                                                    const Color(
                                                      0xFFFF7043,
                                                    ).withOpacity(0.7),
                                                  ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Icon(
                                                Icons.music_note_rounded,
                                                color: Colors.white.withOpacity(
                                                  0.5,
                                                ),
                                              ),
                                            ),
                                  )
                                : (currentSong.albumArt != null)
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
                                        gradient: LinearGradient(
                                          colors: [
                                            const Color(
                                              0xFFFFA726,
                                            ).withOpacity(0.7),
                                            const Color(
                                              0xFFFF7043,
                                            ).withOpacity(0.7),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(8),
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
                                      gradient: LinearGradient(
                                        colors: [
                                          const Color(
                                            0xFFFFA726,
                                          ).withOpacity(0.7),
                                          const Color(
                                            0xFFFF7043,
                                          ).withOpacity(0.7),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.music_note_rounded,
                                      color: Colors.white.withOpacity(0.5),
                                    ),
                                  ),
                          ),
                        );
                      },
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
                    Selector<MusicPlayerProvider, bool>(
                      selector: (_, provider) =>
                          provider.isFavorite(currentSong.id),
                      builder: (context, isFavorite, _) {
                        return IconButton(
                          onPressed: () {
                            Provider.of<MusicPlayerProvider>(
                              context,
                              listen: false,
                            ).toggleFavorite(currentSong.id);
                          },
                          icon: Icon(
                            isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: Colors.white,
                          ),
                        );
                      },
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
    return Consumer<MusicPlayerProvider>(
      builder: (context, playerProvider, _) {
        return ValueListenableBuilder<Duration>(
          valueListenable: playerProvider.positionNotifier,
          builder: (context, position, _) {
            // Update current line based on position
            _updateCurrentLine(position);

            final lines = _lyricsLines.isNotEmpty
                ? _lyricsLines
                : (_lyrics?.split('\n') ?? []);

            return ListView.builder(
              controller: _scrollController,
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

                // Create or get GlobalKey for this line
                _lineKeys[index] ??= GlobalKey();

                return Padding(
                  key: _lineKeys[index],
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    lines[index],
                    style: TextStyle(
                      color: isCurrentLine
                          ? const Color(
                              0xFFFFA726,
                            ) // Bright orange for current line
                          : Colors.white.withOpacity(
                              isVerseLabel ? 0.7 : 0.4,
                            ), // Dimmed for others
                      fontSize: isCurrentLine
                          ? 28
                          : (isVerseLabel ? 18 : 20), // Bigger text
                      fontWeight: isCurrentLine
                          ? FontWeight
                                .w900 // Extra bold for current
                          : (isVerseLabel
                                ? FontWeight.w700
                                : FontWeight.w600), // Bold for all
                      height: 1.6,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _updateCurrentLine(Duration position) {
    if (_lrcTimestamps.isEmpty) {
      return;
    }

    final positionMs = position.inMilliseconds;
    int? newLineIndex;

    // Find the current line based on timestamp (with better matching)
    final sortedEntries = _lrcTimestamps.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    for (var i = 0; i < sortedEntries.length; i++) {
      final entry = sortedEntries[i];
      final nextEntry = i < sortedEntries.length - 1
          ? sortedEntries[i + 1]
          : null;

      if (positionMs >= entry.value &&
          (nextEntry == null || positionMs < nextEntry.value)) {
        newLineIndex = entry.key;
        break;
      }
    }

    if (newLineIndex != null && newLineIndex != _currentLineIndex) {
      final tempLineIndex = newLineIndex; // Capture the value

      // Schedule state update and immediate scroll
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _currentLineIndex = tempLineIndex;
          });
          _scrollToCurrentLine();
        }
      });
    }
  }

  void _scrollToCurrentLine() {
    if (_currentLineIndex == null) {
      return;
    }

    // Get the GlobalKey for the current line
    final key = _lineKeys[_currentLineIndex!];
    if (key == null || key.currentContext == null) {
      return;
    }

    // Use Scrollable.ensureVisible for accurate centering
    Scrollable.ensureVisible(
      key.currentContext!,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      alignment: 0.5, // 0.5 = center of screen
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
