import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../player/providers/music_player_provider.dart';
import '../../player/widgets/mini_player.dart';
import '../../player/widgets/cached_artwork_widget.dart';
import 'song_list_screen.dart';

class MoodPlaylistsScreen extends StatelessWidget {
  const MoodPlaylistsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF232323) : Colors.white;
    final accentColor = isDark
        ? const Color(0xFFFFA726)
        : const Color(0xFFFF7043);

    // Mood colors and icons
    final moodData = {
      'Happy': {
        'color': isDark ? const Color(0xFFFFA726) : const Color(0xFFFFB74D),
        'icon': Icons.sentiment_very_satisfied_rounded,
      },
      'Workout': {
        'color': isDark ? const Color(0xFFEF5350) : const Color(0xFFE57373),
        'icon': Icons.fitness_center_rounded,
      },
      'Party': {
        'color': isDark ? const Color(0xFFAB47BC) : const Color(0xFFBA68C8),
        'icon': Icons.celebration_rounded,
      },
      'Chill': {
        'color': isDark ? const Color(0xFF26C6DA) : const Color(0xFF4DD0E1),
        'icon': Icons.self_improvement_rounded,
      },
      'Sad': {
        'color': isDark ? const Color(0xFF5C6BC0) : const Color(0xFF7986CB),
        'icon': Icons.sentiment_dissatisfied_rounded,
      },
      'Focus': {
        'color': isDark ? const Color(0xFF66BB6A) : const Color(0xFF81C784),
        'icon': Icons.psychology_rounded,
      },
    };

    return Scaffold(
      backgroundColor: bgColor,
      body: Consumer<MusicPlayerProvider>(
        builder: (context, playerProvider, _) {
          final moodPlaylists = playerProvider.moodPlaylists;

          return Stack(
            children: [
              Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).padding.top + 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back_rounded,
                            color: accentColor,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Mood Playlists',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(Icons.refresh_rounded, color: accentColor),
                          onPressed: () async {
                            await playerProvider.generateMoodPlaylists();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Mood playlists refreshed!'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 16,
                                    crossAxisSpacing: 16,
                                    childAspectRatio: 1.6,
                                  ),
                              itemCount: moodPlaylists.length,
                              itemBuilder: (context, i) {
                                final moodName = moodPlaylists.keys.elementAt(
                                  i,
                                );
                                final songs = moodPlaylists[moodName] ?? [];
                                final moodColor =
                                    moodData[moodName]?['color'] as Color? ??
                                    accentColor;
                                final moodIcon =
                                    moodData[moodName]?['icon'] as IconData? ??
                                    Icons.music_note_rounded;

                                final artImages = songs.take(4).map((song) {
                                  if (song.albumArt != null &&
                                      song.albumArt!.isNotEmpty) {
                                    return song.albumArt!;
                                  }
                                  return '';
                                }).toList();

                                return GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => SongListScreen(
                                          title: moodName,
                                          songs: songs,
                                          showSearch: true,
                                          isMoodPlaylist: true,
                                        ),
                                      ),
                                    );
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(18),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: moodColor,
                                        boxShadow: [
                                          BoxShadow(
                                            color: moodColor.withOpacity(0.18),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Stack(
                                        children: [
                                          // Right side artwork
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: FractionallySizedBox(
                                              widthFactor: 0.5,
                                              heightFactor: 1.0,
                                              child: ClipRRect(
                                                borderRadius:
                                                    const BorderRadius.only(
                                                      topRight: Radius.circular(
                                                        18,
                                                      ),
                                                      bottomRight:
                                                          Radius.circular(18),
                                                    ),
                                                child: Stack(
                                                  children: [
                                                    artImages.isNotEmpty
                                                        ? SizedBox.expand(
                                                            child: AlbumArtGrid(
                                                              artImages:
                                                                  artImages,
                                                            ),
                                                          )
                                                        : _albumPlaceholder(
                                                            isDark,
                                                          ),
                                                    // Left-to-right gradient overlay
                                                    Positioned.fill(
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          gradient: LinearGradient(
                                                            begin: Alignment
                                                                .centerLeft,
                                                            end: Alignment
                                                                .centerRight,
                                                            colors: [
                                                              Colors.black
                                                                  .withOpacity(
                                                                    0.22,
                                                                  ),
                                                              Colors
                                                                  .transparent,
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          // Gradient overlay
                                          Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.centerLeft,
                                                end: Alignment.centerRight,
                                                stops: const [
                                                  0.0,
                                                  0.45,
                                                  0.58,
                                                  0.7,
                                                  0.82,
                                                  0.95,
                                                  1.0,
                                                ],
                                                colors: [
                                                  moodColor,
                                                  moodColor,
                                                  moodColor.withOpacity(0.85),
                                                  moodColor.withOpacity(0.6),
                                                  moodColor.withOpacity(0.35),
                                                  moodColor.withOpacity(0.15),
                                                  Colors.transparent,
                                                ],
                                              ),
                                            ),
                                          ),
                                          // Content (left side)
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 10,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  moodIcon,
                                                  color: Colors.white,
                                                  size: 28,
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  moodName,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 3),
                                                Text(
                                                  '${songs.length} songs',
                                                  style: TextStyle(
                                                    color: Colors.white
                                                        .withOpacity(0.85),
                                                    fontSize: 12,
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
                              },
                            ),
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // Floating MiniPlayer
              Selector<MusicPlayerProvider, dynamic>(
                selector: (_, provider) => provider.currentSong,
                builder: (context, currentSong, _) {
                  if (currentSong == null) return const SizedBox.shrink();
                  return Positioned(
                    left: 0,
                    right: 0,
                    bottom: 24,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Material(
                          elevation: 8,
                          color: Colors.transparent,
                          child: const MiniPlayer(),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class AlbumArtGrid extends StatelessWidget {
  final List<String> artImages;
  const AlbumArtGrid({super.key, required this.artImages});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (artImages.isEmpty || artImages.every((img) => img.isEmpty)) {
      return _albumPlaceholder(isDark);
    }

    if (artImages.length == 1) {
      return _buildSingleArtwork(artImages[0], isDark);
    }

    return GridView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 0,
        crossAxisSpacing: 0,
        childAspectRatio: 0.8, // Fill vertical space better
      ),
      itemCount: 4,
      itemBuilder: (context, i) {
        if (i < artImages.length && artImages[i].isNotEmpty) {
          return _buildSingleArtwork(artImages[i], isDark);
        } else {
          return _albumPlaceholder(isDark);
        }
      },
    );
  }

  Widget _buildSingleArtwork(String songId, bool isDark) {
    return Selector<MusicPlayerProvider, String?>(
      selector: (_, provider) => provider.getCustomArtForSong(songId),
      builder: (context, customArtPath, _) {
        if (customArtPath != null && customArtPath.isNotEmpty) {
          return Image.file(
            File(customArtPath),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                _albumPlaceholder(isDark),
          );
        } else {
          return CachedArtworkWidget(
            songId: songId,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            fallback: _albumPlaceholder(isDark),
          );
        }
      },
    );
  }
}

Widget _albumPlaceholder(bool isDark) {
  return Container(
    color: isDark ? Colors.white12 : Colors.grey[300],
    child: Icon(
      Icons.music_note_rounded,
      color: isDark ? Colors.white30 : Colors.grey[600],
      size: 32,
    ),
  );
}
