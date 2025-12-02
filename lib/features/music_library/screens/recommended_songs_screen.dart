import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../player/providers/music_player_provider.dart';
import '../../player/widgets/cached_artwork_widget.dart';
import '../../player/widgets/mini_player.dart';
import '../../player/widgets/modern_search_delegate.dart';
import '../../player/models/song_model.dart';

class RecommendedSongsScreen extends StatefulWidget {
  const RecommendedSongsScreen({super.key});

  @override
  State<RecommendedSongsScreen> createState() => _RecommendedSongsScreenState();
}

class _RecommendedSongsScreenState extends State<RecommendedSongsScreen> {
  String _searchQuery = '';
  List<dynamic> _filteredSongs = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final playerProvider = Provider.of<MusicPlayerProvider>(
      context,
      listen: false,
    );
    _filteredSongs = playerProvider.recommendedSongs;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _applyFilter(List<dynamic> songs) {
    if (_searchQuery.isEmpty) {
      setState(() {
        _filteredSongs = songs;
      });
    } else {
      final filtered = songs
          .where(
            (song) =>
                song.title.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
      setState(() {
        _filteredSongs = filtered;
      });
    }
  }

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
              final songs = playerProvider.recommendedSongs;
              if (_filteredSongs.isEmpty && songs.isNotEmpty) {
                Future.microtask(() => _applyFilter(songs));
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: MediaQuery.of(context).padding.top + 48),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                  Icons.recommend_rounded,
                                  color: accentColor,
                                  size: 72,
                                ),
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              'Recommended for You',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 8,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  '${_filteredSongs.length} songs',
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white60
                                        : Colors.black54,
                                    fontSize: 16,
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.select_all_rounded,
                                  color: accentColor,
                                  size: 24,
                                ),
                              ],
                            ),
                          ),
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
                                      if (_filteredSongs.isNotEmpty) {
                                        Provider.of<MusicPlayerProvider>(
                                          context,
                                          listen: false,
                                        ).shuffleAndPlay(
                                          _filteredSongs.cast<Song>(),
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
                                      if (_filteredSongs.isNotEmpty) {
                                        Provider.of<MusicPlayerProvider>(
                                          context,
                                          listen: false,
                                        ).playSong(_filteredSongs.first);
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
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.only(top: 8, bottom: 100),
                            itemCount: _filteredSongs.length,
                            itemBuilder: (context, index) {
                              final song = _filteredSongs[index];
                              return ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Selector<MusicPlayerProvider, String?>(
                                    selector: (_, provider) =>
                                        provider.getCustomArtForSong(
                                          song.id.toString(),
                                        ),
                                    builder: (context, customArtPath, _) {
                                      if (customArtPath != null &&
                                          customArtPath.isNotEmpty) {
                                        return Image.file(
                                          File(customArtPath),
                                          fit: BoxFit.cover,
                                          width: 56,
                                          height: 56,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Container(
                                                    width: 56,
                                                    height: 56,
                                                    decoration: BoxDecoration(
                                                      color: isDark
                                                          ? Colors.white12
                                                          : Colors.grey[300],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            16,
                                                          ),
                                                    ),
                                                    child: Icon(
                                                      Icons.music_note_rounded,
                                                      color: isDark
                                                          ? Colors.white30
                                                          : Colors.grey[600],
                                                      size: 32,
                                                    ),
                                                  ),
                                        );
                                      } else {
                                        return CachedArtworkWidget(
                                          songId: song.id.toString(),
                                          width: 56,
                                          height: 56,
                                          fit: BoxFit.cover,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          fallback: Container(
                                            width: 56,
                                            height: 56,
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? Colors.white12
                                                  : Colors.grey[300],
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: Icon(
                                              Icons.music_note_rounded,
                                              color: isDark
                                                  ? Colors.white30
                                                  : Colors.grey[600],
                                              size: 32,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ),
                                title: Text(
                                  song.title,
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
                                  song.artist,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white60
                                        : Colors.black54,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: Icon(
                                    Icons.more_vert_rounded,
                                    color: isDark
                                        ? Colors.white54
                                        : Colors.black45,
                                  ),
                                  onPressed: () {
                                    // TODO: Show more options for song
                                  },
                                ),
                                onTap: () {
                                  Provider.of<MusicPlayerProvider>(
                                    context,
                                    listen: false,
                                  ).playSong(song);
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
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    bgColor,
                    bgColor.withOpacity(0.95),
                    bgColor.withOpacity(0.0),
                  ],
                  stops: const [0.0, 0.7, 1.0],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 4,
                    right: 4,
                    top: 0,
                    bottom: 8,
                  ),
                  child: Row(
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
                      IconButton(
                        icon: Icon(
                          Icons.search_rounded,
                          color: isDark ? Colors.white70 : Colors.black54,
                          size: 22,
                        ),
                        onPressed: () {
                          final playerProvider =
                              Provider.of<MusicPlayerProvider>(
                                context,
                                listen: false,
                              );
                          showSearch(
                            context: context,
                            delegate: ModernSearchDelegate<dynamic>(
                              items: playerProvider.recommendedSongs,
                              getTitle: (song) => song.title,
                              getSubtitle: (song) => song.artist,
                              getAlbum: (song) => song.album,
                              getArtist: (song) => song.artist,
                              getType: (song) => 'song',
                              onItemTap: (song) {
                                Provider.of<MusicPlayerProvider>(
                                  context,
                                  listen: false,
                                ).playSong(song);
                              },
                              onQueryChanged: (query) {
                                setState(() => _searchQuery = query);
                                _applyFilter(playerProvider.recommendedSongs);
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
