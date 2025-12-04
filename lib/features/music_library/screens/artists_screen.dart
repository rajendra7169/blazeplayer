import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../player/providers/music_player_provider.dart';
import 'song_list_screen.dart';
import '../../player/widgets/mini_player.dart';
import '../../player/widgets/cached_artwork_widget.dart';
import '../../player/models/song_model.dart';

class ArtistsScreen extends StatelessWidget {
  const ArtistsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF232323) : Colors.white;
    final accentColor = isDark
        ? const Color(0xFFFFA726)
        : const Color(0xFFFF7043);
    final cardColor = isDark
        ? const Color(0xFF2C2C2C)
        : const Color(0xFFF5F5F5);
    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          Consumer<MusicPlayerProvider>(
            builder: (context, playerProvider, _) {
              // Group songs by artist
              final artistMap = <String, List<dynamic>>{};
              for (final song in playerProvider.allSongs) {
                final artist = song.artist.isNotEmpty
                    ? song.artist
                    : 'Unknown Artist';
                artistMap.putIfAbsent(artist, () => []).add(song);
              }
              final artists = artistMap.keys.toList();
              if (artists.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: MediaQuery.of(context).padding.top + 48),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Big icon at top
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Center(
                              child: Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  color: accentColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Icon(
                                  Icons.person_rounded,
                                  color: accentColor,
                                  size: 72,
                                ),
                              ),
                            ),
                          ),
                          // Page title
                          Center(
                            child: Text(
                              'Artists',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                          // Artist count
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 8,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  '${artists.length} artists',
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white60
                                        : Colors.black54,
                                    fontSize: 16,
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.person_rounded,
                                  color: accentColor,
                                  size: 24,
                                ),
                              ],
                            ),
                          ),
                          // Artist list
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.only(top: 8, bottom: 100),
                            itemCount: artists.length,
                            itemBuilder: (context, index) {
                              final artist = artists[index];
                              final songs = artistMap[artist]!;
                              final artImages = songs.isNotEmpty
                                  ? [songs[0].id.toString()]
                                  : <String>[];
                              return ListTile(
                                leading: ArtistArtGrid(artImages: artImages),
                                title: Text(
                                  artist,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                                subtitle: Text(
                                  '${songs.length} songs',
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white60
                                        : Colors.black54,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => SongListScreen(
                                        title: artist,
                                        songs: songs.cast<Song>(),
                                        showSearch: true,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          Selector<MusicPlayerProvider, dynamic>(
            selector: (_, provider) => provider.currentSong,
            builder: (context, currentSong, _) {
              if (currentSong == null) return SizedBox.shrink();
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
                      child: MiniPlayer(),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ArtistArtGrid extends StatelessWidget {
  final List<String> artImages;
  const ArtistArtGrid({super.key, required this.artImages});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final songId = artImages.isNotEmpty ? artImages[0] : '';

    if (songId.isEmpty) {
      return _artistPlaceholder(isDark);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 56,
        height: 56,
        child: Selector<MusicPlayerProvider, String?>(
          selector: (_, provider) => provider.getCustomArtForSong(songId),
          builder: (context, customArtPath, _) {
            if (customArtPath != null && customArtPath.isNotEmpty) {
              return Image.file(
                File(customArtPath),
                fit: BoxFit.cover,
                width: 56,
                height: 56,
                errorBuilder: (context, error, stackTrace) =>
                    _artistPlaceholder(isDark),
              );
            } else {
              return CachedArtworkWidget(
                songId: songId,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(8),
                fallback: _artistPlaceholder(isDark),
              );
            }
          },
        ),
      ),
    );
  }
}

Widget _artistPlaceholder(bool isDark) {
  return Container(
    width: 56,
    height: 56,
    decoration: BoxDecoration(
      color: isDark ? Colors.white12 : Colors.grey[300],
      borderRadius: BorderRadius.circular(8),
    ),
    child: Icon(
      Icons.person_rounded,
      color: isDark ? Colors.white30 : Colors.grey[600],
      size: 32,
    ),
  );
}
