import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../player/providers/music_player_provider.dart';
import '../../player/widgets/cached_artwork_widget.dart';
import '../../player/widgets/mini_player.dart';

class AddSongsToFavoritesScreen extends StatefulWidget {
  const AddSongsToFavoritesScreen({super.key});

  @override
  State<AddSongsToFavoritesScreen> createState() =>
      _AddSongsToFavoritesScreenState();
}

class _AddSongsToFavoritesScreenState extends State<AddSongsToFavoritesScreen> {
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
    _filteredSongs = playerProvider.allSongs;
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

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          Consumer<MusicPlayerProvider>(
            builder: (context, playerProvider, _) {
              final songs = playerProvider.allSongs;
              if (_filteredSongs.isEmpty && songs.isNotEmpty) {
                Future.microtask(() => _applyFilter(songs));
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: MediaQuery.of(context).padding.top + 48),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white10 : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search songs...',
                          prefixIcon: Icon(Icons.search, color: accentColor),
                          border: InputBorder.none,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.transparent,
                              width: 0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: accentColor,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: 12,
                          ),
                        ),
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        onChanged: (value) {
                          _searchQuery = value;
                          _applyFilter(songs);
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_filteredSongs.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 60),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.music_note_rounded,
                                      color: isDark
                                          ? Colors.white38
                                          : Colors.black38,
                                      size: 80,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No Songs Found',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? Colors.white60
                                            : Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.only(
                                top: 8,
                                bottom: 100,
                                left: 16,
                                right: 16,
                              ),
                              itemCount: _filteredSongs.length,
                              itemBuilder: (context, index) {
                                final song = _filteredSongs[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF2C2C2C)
                                        : const Color(0xFFF5F5F5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListTile(
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
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
                                              width: 50,
                                              height: 50,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => Container(
                                                    width: 50,
                                                    height: 50,
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          accentColor
                                                              .withOpacity(0.5),
                                                          accentColor
                                                              .withOpacity(0.3),
                                                        ],
                                                      ),
                                                    ),
                                                    child: Icon(
                                                      Icons.music_note_rounded,
                                                      color: Colors.white,
                                                      size: 24,
                                                    ),
                                                  ),
                                            );
                                          } else {
                                            return CachedArtworkWidget(
                                              songId: song.id.toString(),
                                              width: 50,
                                              height: 50,
                                              fit: BoxFit.cover,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              fallback: Container(
                                                width: 50,
                                                height: 50,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      accentColor.withOpacity(
                                                        0.5,
                                                      ),
                                                      accentColor.withOpacity(
                                                        0.3,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                child: Icon(
                                                  Icons.music_note_rounded,
                                                  color: Colors.white,
                                                  size: 24,
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
                                    trailing: Selector<MusicPlayerProvider, bool>(
                                      selector: (_, provider) =>
                                          provider.isFavorite(song.id),
                                      builder: (context, isFavorite, _) {
                                        return IconButton(
                                          icon: Icon(
                                            isFavorite
                                                ? Icons.favorite_rounded
                                                : Icons.favorite_border_rounded,
                                            color: isFavorite
                                                ? accentColor
                                                : Colors.grey[400],
                                            size: 24,
                                          ),
                                          onPressed: () {
                                            Provider.of<MusicPlayerProvider>(
                                              context,
                                              listen: false,
                                            ).toggleFavorite(song.id);
                                          },
                                        );
                                      },
                                    ),
                                    onTap: () {
                                      final provider =
                                          Provider.of<MusicPlayerProvider>(
                                            context,
                                            listen: false,
                                          );
                                      provider.playWithContext(
                                        song,
                                        provider.allSongs,
                                      );
                                    },
                                  ),
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
          // Top Navigation Bar
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
                      Expanded(
                        child: Center(
                          child: Text(
                            'Add to Favorites',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 48),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Mini Player
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
