import 'dart:io';
import 'package:flutter/material.dart';
import 'package:blazeplayer/features/player/widgets/playlist_screen/playlist_card_menu_sheet.dart';
import 'package:blazeplayer/features/player/widgets/playlist_screen/add_to_playlist_sheet.dart';
import 'package:blazeplayer/features/player/widgets/playlist_screen/playlist_options_sheet.dart';
import 'package:provider/provider.dart';
import '../../player/providers/music_player_provider.dart';
import '../../player/widgets/mini_player.dart';
import '../../player/widgets/cached_artwork_widget.dart';
import '../../player/models/song_model.dart';
import 'favorites_screen.dart';
import 'recently_played_screen.dart';
import 'song_list_screen.dart';

class PlaylistScreen extends StatelessWidget {
  const PlaylistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF232323) : Colors.white;
    final accentColor = isDark
        ? const Color(0xFFFFA726)
        : const Color(0xFFFF7043);
    final cardColors = [
      isDark
          ? const Color(0xFFB71C5A)
          : const Color(0xFFF06292), // My favourite
      isDark ? const Color(0xFF00838F) : const Color(0xFF4DD0E1), // Last added
      isDark
          ? const Color(0xFF283593)
          : const Color(0xFF7986CB), // Recently played
      isDark ? const Color(0xFF8D6E63) : const Color(0xFFA1887F), // Most played
    ];
    final playlistTitles = [
      'My favourite',
      'Last added',
      'Recently played',
      'Most played',
    ];

    return Scaffold(
      backgroundColor: bgColor,
      body: Consumer<MusicPlayerProvider>(
        builder: (context, playerProvider, _) {
          final playlists = [
            playerProvider.favouriteSongs,
            playerProvider.lastAddedSongs,
            playerProvider.recentlyPlayedSongs,
            playerProvider.mostPlayedSongs,
          ];
          final playlistScreens = [
            const FavoritesScreen(),
            SongListScreen(
              title: 'Last Added',
              songs: playerProvider.lastAddedSongs,
              showSearch: true,
            ),
            const RecentlyPlayedScreen(),
            SongListScreen(
              title: 'Most Played',
              songs: playerProvider.mostPlayedSongs,
              showSearch: true,
            ),
          ];
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
                          '${4 + playerProvider.myPlaylists.length} playlists',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(Icons.add_rounded, color: accentColor),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.more_vert_rounded,
                            color: accentColor,
                          ),
                          onPressed: () {},
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
                              physics: NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 16,
                                    crossAxisSpacing: 16,
                                    childAspectRatio: 1.6,
                                  ),
                              itemCount: 4,
                              itemBuilder: (context, i) {
                                final songs = playlists[i].cast<Song>();
                                final artImages = songs.take(4).map((song) {
                                  if (song.customArtPath != null &&
                                      song.customArtPath!.isNotEmpty) {
                                    return song.customArtPath!;
                                  } else if (song.albumArt != null &&
                                      song.albumArt!.isNotEmpty) {
                                    return song.albumArt!;
                                  } else {
                                    return '';
                                  }
                                }).toList();
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            playlistScreens[i],
                                      ),
                                    );
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(18),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: cardColors[i],
                                        boxShadow: [
                                          BoxShadow(
                                            color: cardColors[i].withOpacity(
                                              0.18,
                                            ),
                                            blurRadius: 12,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Stack(
                                        children: [
                                          // Right side artwork filling top to bottom (50% width)
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: FractionallySizedBox(
                                              widthFactor: 0.5,
                                              heightFactor: 1.0,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(18),
                                                  bottomRight: Radius.circular(
                                                    18,
                                                  ),
                                                ),
                                                child: artImages.isNotEmpty
                                                    ? AlbumArtGrid(
                                                        artImages: artImages,
                                                      )
                                                    : _albumPlaceholder(isDark),
                                              ),
                                            ),
                                          ),
                                          // Gradient fade overlay (blends artwork with card color)
                                          Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.centerLeft,
                                                end: Alignment.centerRight,
                                                stops: [
                                                  0.0,
                                                  0.45,
                                                  0.58,
                                                  0.7,
                                                  0.82,
                                                  0.95,
                                                  1.0,
                                                ],
                                                colors: [
                                                  cardColors[i],
                                                  cardColors[i],
                                                  cardColors[i].withOpacity(
                                                    0.98,
                                                  ),
                                                  cardColors[i].withOpacity(
                                                    0.88,
                                                  ),
                                                  cardColors[i].withOpacity(
                                                    0.6,
                                                  ),
                                                  cardColors[i].withOpacity(
                                                    0.25,
                                                  ),
                                                  cardColors[i].withOpacity(
                                                    0.05,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          // Content on top
                                          Padding(
                                            padding: const EdgeInsets.all(18),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        right: 32,
                                                      ),
                                                  child: Text(
                                                    playlistTitles[i],
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.white,
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  '${songs.length} songs',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.white70,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // 3-dot menu (clickable, uses widget)
                                          Positioned(
                                            right: 12,
                                            top: 12,
                                            child: GestureDetector(
                                              onTap: () {
                                                // Choose icon for each card
                                                final List<IconData> cardIcons =
                                                    [
                                                      Icons.favorite,
                                                      Icons.fiber_new_rounded,
                                                      Icons.history_rounded,
                                                      Icons.trending_up_rounded,
                                                    ];
                                                showModalBottomSheet(
                                                  context: context,
                                                  backgroundColor: Theme.of(
                                                    context,
                                                  ).colorScheme.surface,
                                                  shape: const RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.vertical(
                                                          top: Radius.circular(
                                                            18,
                                                          ),
                                                        ),
                                                  ),
                                                  builder: (context) => PlaylistCardMenuSheet(
                                                    cardIcon: cardIcons[i],
                                                    cardColor: cardColors[i],
                                                    title: playlistTitles[i],
                                                    songCount: songs.length,
                                                    onPlay: () {
                                                      final playerProvider =
                                                          Provider.of<
                                                            MusicPlayerProvider
                                                          >(
                                                            context,
                                                            listen: false,
                                                          );
                                                      if (songs.isNotEmpty) {
                                                        playerProvider
                                                            .playWithContext(
                                                              songs.first,
                                                              songs,
                                                            );
                                                      }
                                                      Navigator.pop(context);
                                                    },
                                                    onPlayNext: () {
                                                      final playerProvider =
                                                          Provider.of<
                                                            MusicPlayerProvider
                                                          >(
                                                            context,
                                                            listen: false,
                                                          );
                                                      if (songs.isNotEmpty) {
                                                        // Insert songs after current song in queue
                                                        final currentIndex =
                                                            playerProvider
                                                                .playlist
                                                                .indexWhere(
                                                                  (s) =>
                                                                      s.id ==
                                                                      playerProvider
                                                                          .currentSong
                                                                          ?.id,
                                                                );
                                                        if (currentIndex !=
                                                            -1) {
                                                          final newQueue =
                                                              List<Song>.from(
                                                                playerProvider
                                                                    .playlist,
                                                              );
                                                          newQueue.insertAll(
                                                            currentIndex + 1,
                                                            songs,
                                                          );
                                                          playerProvider
                                                              .setPlaylist(
                                                                newQueue,
                                                              );
                                                        }
                                                      }
                                                      Navigator.pop(context);
                                                    },
                                                    onAddToQueue: () {
                                                      final playerProvider =
                                                          Provider.of<
                                                            MusicPlayerProvider
                                                          >(
                                                            context,
                                                            listen: false,
                                                          );
                                                      if (songs.isNotEmpty) {
                                                        // Add songs to end of queue
                                                        final newQueue =
                                                            List<Song>.from(
                                                              playerProvider
                                                                  .playlist,
                                                            )..addAll(songs);
                                                        playerProvider
                                                            .setPlaylist(
                                                              newQueue,
                                                            );
                                                      }
                                                      Navigator.pop(context);
                                                    },
                                                    onAddToPlaylist: () {
                                                      Navigator.pop(context);
                                                      showModalBottomSheet(
                                                        context: context,
                                                        backgroundColor:
                                                            Theme.of(context)
                                                                .colorScheme
                                                                .surface,
                                                        shape: const RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.vertical(
                                                                top:
                                                                    Radius.circular(
                                                                      18,
                                                                    ),
                                                              ),
                                                        ),
                                                        builder: (context) => AddToPlaylistSheet(
                                                          favouriteCount:
                                                              songs.length,
                                                          onCreateNew: (playlistName) {
                                                            final playerProvider =
                                                                Provider.of<
                                                                  MusicPlayerProvider
                                                                >(
                                                                  context,
                                                                  listen: false,
                                                                );
                                                            playerProvider
                                                                .addMyPlaylist(
                                                                  playlistName,
                                                                  songs,
                                                                );
                                                          },
                                                          onAddToFavourite: () {
                                                            final playerProvider =
                                                                Provider.of<
                                                                  MusicPlayerProvider
                                                                >(
                                                                  context,
                                                                  listen: false,
                                                                );
                                                            for (final song
                                                                in songs) {
                                                              playerProvider
                                                                  .addToFavourite(
                                                                    song.id,
                                                                  );
                                                            }
                                                            Navigator.pop(
                                                              context,
                                                            );
                                                          },
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                );
                                              },
                                              child: Icon(
                                                Icons.more_vert_rounded,
                                                color: Colors.white70,
                                                size: 20,
                                              ),
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
                          const SizedBox(height: 18),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'My playlists',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                                Text(
                                  '${playerProvider.myPlaylists.length}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isDark
                                          ? const Color(0xFF2C2C2C)
                                          : const Color(0xFFF5F5F5),
                                      foregroundColor: isDark
                                          ? const Color(0xFFFFA726)
                                          : const Color(0xFFFF7043),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      elevation: 0,
                                    ),
                                    onPressed: () {
                                      // TODO: Implement export playlist functionality
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.import_export_rounded),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'Export playlist',
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
                                      backgroundColor: isDark
                                          ? const Color(0xFFFFA726)
                                          : const Color(0xFFFF7043),
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
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Theme.of(
                                          context,
                                        ).colorScheme.surface,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(18),
                                          ),
                                        ),
                                        builder: (context) {
                                          final theme = Theme.of(context);
                                          final controller =
                                              TextEditingController();
                                          return Padding(
                                            padding: EdgeInsets.only(
                                              left: 24,
                                              right: 24,
                                              bottom:
                                                  MediaQuery.of(
                                                    context,
                                                  ).viewInsets.bottom +
                                                  24,
                                              top: 24,
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Create new playlist',
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: theme
                                                        .colorScheme
                                                        .onSurface,
                                                  ),
                                                ),
                                                const SizedBox(height: 18),
                                                TextField(
                                                  controller: controller,
                                                  autofocus: true,
                                                  decoration: InputDecoration(
                                                    hintText: 'Playlist name',
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 24),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: OutlinedButton(
                                                        style: OutlinedButton.styleFrom(
                                                          foregroundColor: theme
                                                              .colorScheme
                                                              .primary,
                                                          side: BorderSide(
                                                            color: theme
                                                                .colorScheme
                                                                .primary,
                                                          ),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  12,
                                                                ),
                                                          ),
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                vertical: 14,
                                                              ),
                                                        ),
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                              context,
                                                            ),
                                                        child: const Text(
                                                          'Cancel',
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 16),
                                                    Expanded(
                                                      child: ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: theme
                                                              .colorScheme
                                                              .primary,
                                                          foregroundColor: theme
                                                              .colorScheme
                                                              .onPrimary,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  12,
                                                                ),
                                                          ),
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                vertical: 14,
                                                              ),
                                                        ),
                                                        onPressed: () {
                                                          final name =
                                                              controller.text
                                                                  .trim();
                                                          if (name.isNotEmpty) {
                                                            Navigator.pop(
                                                              context,
                                                            );
                                                            final playerProvider =
                                                                Provider.of<
                                                                  MusicPlayerProvider
                                                                >(
                                                                  context,
                                                                  listen: false,
                                                                );
                                                            playerProvider
                                                                .addMyPlaylist(
                                                                  name,
                                                                  [],
                                                                );
                                                          }
                                                        },
                                                        child: const Text(
                                                          'Create',
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.add_rounded),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'Create playlist',
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

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Consumer<MusicPlayerProvider>(
                              builder: (context, playerProvider, _) {
                                final myPlaylists = playerProvider.myPlaylists;
                                if (myPlaylists.isEmpty) {
                                  return const SizedBox.shrink();
                                }
                                return _ReorderablePlaylistGrid(
                                  playlists: myPlaylists,
                                  isDark: isDark,
                                  onReorder: (oldIndex, newIndex) {
                                    playerProvider.reorderPlaylist(
                                      oldIndex,
                                      newIndex,
                                    );
                                  },
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
    final songId = artImages.isNotEmpty ? artImages[0] : '';

    if (songId.isEmpty) {
      return _albumPlaceholder(isDark);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 48,
        height: 48,
        child: Selector<MusicPlayerProvider, String?>(
          selector: (_, provider) => provider.getCustomArtForSong(songId),
          builder: (context, customArtPath, _) {
            if (customArtPath != null && customArtPath.isNotEmpty) {
              return Image.file(
                File(customArtPath),
                fit: BoxFit.cover,
                width: 48,
                height: 48,
                errorBuilder: (context, error, stackTrace) =>
                    _albumPlaceholder(isDark),
              );
            } else {
              return CachedArtworkWidget(
                songId: songId,
                width: 48,
                height: 48,
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
    width: 48,
    height: 48,
    decoration: BoxDecoration(
      color: isDark ? Colors.white12 : Colors.grey[300],
      borderRadius: BorderRadius.circular(8),
    ),
    child: Icon(
      Icons.album_rounded,
      color: isDark ? Colors.white30 : Colors.grey[600],
      size: 24,
    ),
  );
}

class _PlaylistActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _PlaylistActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const SizedBox(width: 18),
            Icon(icon, color: isDark ? Colors.white : Colors.black87, size: 28),
            const SizedBox(width: 18),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReorderablePlaylistGrid extends StatefulWidget {
  final List<Map<String, dynamic>> playlists;
  final bool isDark;
  final void Function(int oldIndex, int newIndex) onReorder;

  const _ReorderablePlaylistGrid({
    required this.playlists,
    required this.isDark,
    required this.onReorder,
  });

  @override
  State<_ReorderablePlaylistGrid> createState() =>
      _ReorderablePlaylistGridState();
}

class _ReorderablePlaylistGridState extends State<_ReorderablePlaylistGrid> {
  int? _draggingIndex;
  int? _hoverIndex;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 64) / 2;
    final cardHeight = cardWidth / 1.6;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.6,
      ),
      itemCount: widget.playlists.length,
      itemBuilder: (context, index) {
        final playlist = widget.playlists[index];
        final songs = List<Song>.from(playlist['songs'] as List);
        final artImages = songs.take(4).map((song) {
          if (song.customArtPath != null && song.customArtPath!.isNotEmpty) {
            return song.customArtPath!;
          } else if (song.albumArt != null && song.albumArt!.isNotEmpty) {
            return song.albumArt!;
          } else {
            return '';
          }
        }).toList();

        final playlistColors = [
          widget.isDark ? const Color(0xFF6A1B9A) : const Color(0xFFAB47BC),
          widget.isDark ? const Color(0xFF00695C) : const Color(0xFF26A69A),
          widget.isDark ? const Color(0xFFC62828) : const Color(0xFFEF5350),
          widget.isDark ? const Color(0xFFEF6C00) : const Color(0xFFFF9800),
          widget.isDark ? const Color(0xFF2E7D32) : const Color(0xFF66BB6A),
          widget.isDark ? const Color(0xFF1565C0) : const Color(0xFF42A5F5),
        ];
        final cardColor = playlistColors[index % playlistColors.length];

        final isBeingDragged = _draggingIndex == index;
        final isHovered =
            _hoverIndex == index &&
            _draggingIndex != null &&
            _draggingIndex != index;

        return DragTarget<int>(
          key: ValueKey('playlist_$index'),
          onAcceptWithDetails: (details) {
            if (details.data != index) {
              widget.onReorder(details.data, index);
            }
            setState(() {
              _draggingIndex = null;
              _hoverIndex = null;
            });
          },
          onMove: (_) {
            if (_hoverIndex != index) {
              setState(() {
                _hoverIndex = index;
              });
            }
          },
          onLeave: (_) {
            setState(() {
              _hoverIndex = null;
            });
          },
          builder: (context, candidateData, rejectedData) {
            return LongPressDraggable<int>(
              data: index,
              feedback: Material(
                color: Colors.transparent,
                child: Transform.scale(
                  scale: 1.05,
                  child: Opacity(
                    opacity: 0.9,
                    child: SizedBox(
                      width: cardWidth,
                      height: cardHeight,
                      child: _PlaylistCard(
                        playlist: playlist,
                        artImages: artImages,
                        cardColor: cardColor,
                        isDark: widget.isDark,
                        index: index,
                      ),
                    ),
                  ),
                ),
              ),
              childWhenDragging: SizedBox(
                width: cardWidth,
                height: cardHeight,
                child: Opacity(
                  opacity: 0.3,
                  child: _PlaylistCard(
                    playlist: playlist,
                    artImages: artImages,
                    cardColor: cardColor,
                    isDark: widget.isDark,
                    index: index,
                  ),
                ),
              ),
              onDragStarted: () {
                setState(() {
                  _draggingIndex = index;
                });
              },
              onDragEnd: (_) {
                setState(() {
                  _draggingIndex = null;
                  _hoverIndex = null;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                width: cardWidth,
                height: cardHeight,
                transform: Matrix4.identity()..scale(isHovered ? 0.95 : 1.0),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isBeingDragged ? 0.0 : 1.0,
                  child: _PlaylistCard(
                    playlist: playlist,
                    artImages: artImages,
                    cardColor: cardColor,
                    isDark: widget.isDark,
                    index: index,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _PlaylistCard extends StatelessWidget {
  final Map<String, dynamic> playlist;
  final List<String> artImages;
  final Color cardColor;
  final bool isDark;
  final int index;

  const _PlaylistCard({
    required this.playlist,
    required this.artImages,
    required this.cardColor,
    required this.isDark,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final songs = List<Song>.from(playlist['songs'] as List);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SongListScreen(
              title: playlist['name'] ?? '',
              songs: songs,
              showSearch: true,
            ),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            color: cardColor,
            boxShadow: [
              BoxShadow(
                color: cardColor.withOpacity(0.18),
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
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(18),
                      bottomRight: Radius.circular(18),
                    ),
                    child: artImages.isNotEmpty
                        ? AlbumArtGrid(artImages: artImages)
                        : _albumPlaceholder(isDark),
                  ),
                ),
              ),
              // Gradient fade overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    stops: const [0.0, 0.45, 0.58, 0.7, 0.82, 0.95, 1.0],
                    colors: [
                      cardColor,
                      cardColor,
                      cardColor.withOpacity(0.98),
                      cardColor.withOpacity(0.88),
                      cardColor.withOpacity(0.6),
                      cardColor.withOpacity(0.25),
                      cardColor.withOpacity(0.05),
                    ],
                  ),
                ),
              ),
              // Content on top
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 32),
                      child: Text(
                        playlist['name'] ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${songs.length} songs',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              // 3-dot menu
              Positioned(
                right: 12,
                top: 12,
                child: GestureDetector(
                  onTap: () {
                    final playlistScreen = context
                        .findAncestorWidgetOfExactType<PlaylistScreen>();
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(18),
                        ),
                      ),
                      builder: (sheetContext) => PlaylistOptionsSheet(
                        playlistName: playlist['name'] ?? '',
                        songCount: songs.length,
                        coverImagePath: playlist['coverPath'],
                        onRename: () {
                          Navigator.pop(sheetContext);
                          _showRenameDialog(
                            context,
                            index,
                            playlist['name'] ?? '',
                          );
                        },
                        onChangeCover: () {
                          Navigator.pop(sheetContext);
                          _showChangeCoverDialog(
                            context,
                            index,
                            playlist['name'] ?? '',
                          );
                        },
                        onDelete: () {
                          Navigator.pop(sheetContext);
                          _showDeleteDialog(
                            context,
                            index,
                            playlist['name'] ?? '',
                          );
                        },
                      ),
                    );
                  },
                  child: const Icon(
                    Icons.more_vert_rounded,
                    color: Colors.white70,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _albumPlaceholder(bool isDark) {
    return Container(
      color: isDark ? Colors.grey[800] : Colors.grey[300],
      child: Icon(
        Icons.music_note_rounded,
        size: 40,
        color: isDark ? Colors.white24 : Colors.black26,
      ),
    );
  }
}

// Helper functions for playlist operations
void _showRenameDialog(BuildContext context, int index, String currentName) {
  final controller = TextEditingController(text: currentName);
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (context) {
      final theme = Theme.of(context);
      return Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rename playlist',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Playlist name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                      side: BorderSide(color: theme.colorScheme.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      final newName = controller.text.trim();
                      if (newName.isNotEmpty) {
                        Provider.of<MusicPlayerProvider>(
                          context,
                          listen: false,
                        ).renamePlaylist(index, newName);
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Rename'),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

void _showChangeCoverDialog(
  BuildContext context,
  int index,
  String playlistName,
) {
  // TODO: Implement change cover with online image search (similar to edit tags)
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Change cover feature coming soon!')),
  );
}

void _showDeleteDialog(BuildContext context, int index, String playlistName) {
  showDialog(
    context: context,
    builder: (context) {
      final theme = Theme.of(context);
      return AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Delete playlist'),
        content: Text('Are you sure you want to delete "$playlistName"?'),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              Provider.of<MusicPlayerProvider>(
                context,
                listen: false,
              ).deletePlaylist(index);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );
}

// nice working but in this page we have lots of code line in single page, if we can organizae it like creating different wedget for possible code or somthing else? what ado you suggest? we have some wedget of this page in this path "C:\Users\LOQ\Desktop\blazeplayer\lib\features\player\widgets\playlist_screen" now what do you say? what should we do ?
