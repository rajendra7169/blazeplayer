import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../player/providers/music_player_provider.dart';
import 'song_list_screen.dart';
import '../../player/widgets/mini_player.dart';
import '../../player/widgets/cached_artwork_widget.dart';

class AlbumsScreen extends StatelessWidget {
  const AlbumsScreen({super.key});

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
              final albums = playerProvider.allAlbums;
              if (albums.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              // Get all songs from all albums for shuffle/play all
              final allAlbumSongs = albums
                  .expand((album) => playerProvider.getSongsForAlbum(album.id))
                  .toList();

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
                                  Icons.album_rounded,
                                  color: accentColor,
                                  size: 72,
                                ),
                              ),
                            ),
                          ),
                          // Page title
                          Center(
                            child: Text(
                              'Albums',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                          // Album count
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 8,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  '${albums.length} albums',
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white60
                                        : Colors.black54,
                                    fontSize: 16,
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.library_music_rounded,
                                  color: accentColor,
                                  size: 24,
                                ),
                              ],
                            ),
                          ),
                          // Shuffle and Play buttons
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 8,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: cardColor,
                                      foregroundColor: accentColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      elevation: 0,
                                    ),
                                    onPressed: () {
                                      if (allAlbumSongs.isNotEmpty) {
                                        playerProvider.shuffleAndPlay(
                                          allAlbumSongs,
                                        );
                                      }
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.shuffle_rounded,
                                          color: accentColor,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Shuffle',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: accentColor,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      elevation: 0,
                                    ),
                                    onPressed: () {
                                      if (allAlbumSongs.isNotEmpty) {
                                        playerProvider.playSong(
                                          allAlbumSongs.first,
                                        );
                                      }
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.play_arrow_rounded,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Play',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Album list
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.only(top: 8, bottom: 100),
                            itemCount: albums.length,
                            itemBuilder: (context, index) {
                              final album = albums[index];
                              final albumArtImages = playerProvider
                                  .getAlbumArtImages(album.id, maxCount: 4);
                              return ListTile(
                                leading: AlbumArtGrid(
                                  artImages: albumArtImages,
                                ),
                                title: Text(
                                  album.name,
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
                                  '${album.songCount} songs',
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
                                        title: album.name,
                                        songs: playerProvider.getSongsForAlbum(
                                          album.id,
                                        ),
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

class AlbumArtGrid extends StatelessWidget {
  final List<String> artImages;
  const AlbumArtGrid({super.key, required this.artImages});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final songId = artImages.isNotEmpty ? artImages[0] : '';

    if (songId.isEmpty) {
      return _albumPlaceholder(isDark);
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
                    _albumPlaceholder(isDark),
              );
            } else {
              return CachedArtworkWidget(
                songId: songId,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(8),
                fallback: _albumPlaceholder(isDark),
              );
            }
          },
        ),
      ),
    );
  }
}

Widget _albumPlaceholder(bool isDark) {
  return Container(
    width: 56,
    height: 56,
    decoration: BoxDecoration(
      color: isDark ? Colors.white12 : Colors.grey[300],
      borderRadius: BorderRadius.circular(8),
    ),
    child: Icon(
      Icons.album_rounded,
      color: isDark ? Colors.white30 : Colors.grey[600],
      size: 32,
    ),
  );
}
