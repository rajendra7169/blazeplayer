import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../player/providers/music_player_provider.dart';
import '../../player/widgets/cached_artwork_widget.dart';

class SongSearchDelegate extends SearchDelegate<dynamic> {
  final List<dynamic> songs;
  final Function(dynamic song) onSongSelected;
  final bool isDark;
  final Color accentColor;

  SongSearchDelegate({
    required this.songs,
    required this.onSongSelected,
    required this.isDark,
    required this.accentColor,
  });

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: Icon(Icons.clear_rounded),
          onPressed: () {
            query = '';
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back_rounded),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = query.isEmpty
        ? songs
        : songs
              .where(
                (song) =>
                    song.title.toLowerCase().contains(query.toLowerCase()) ||
                    song.artist.toLowerCase().contains(query.toLowerCase()),
              )
              .toList();

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              color: isDark ? Colors.white38 : Colors.black38,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'No songs found',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final song = results[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Selector<MusicPlayerProvider, String?>(
                selector: (_, provider) =>
                    provider.getCustomArtForSong(song.id.toString()),
                builder: (context, customArtPath, _) {
                  if (customArtPath != null && customArtPath.isNotEmpty) {
                    return Image.file(
                      File(customArtPath),
                      fit: BoxFit.cover,
                      width: 50,
                      height: 50,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              accentColor.withOpacity(0.5),
                              accentColor.withOpacity(0.3),
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
                      borderRadius: BorderRadius.circular(8),
                      fallback: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              accentColor.withOpacity(0.5),
                              accentColor.withOpacity(0.3),
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
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            subtitle: Text(
              song.artist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
            ),
            trailing: Selector<MusicPlayerProvider, bool>(
              selector: (_, provider) =>
                  provider.isFavorite(song.id.toString()),
              builder: (context, isFavorite, _) {
                return IconButton(
                  icon: Icon(
                    isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: isFavorite ? accentColor : Colors.grey[400],
                    size: 24,
                  ),
                  onPressed: () {
                    Provider.of<MusicPlayerProvider>(
                      context,
                      listen: false,
                    ).toggleFavorite(song.id.toString());
                  },
                );
              },
            ),
            onTap: () {
              Provider.of<MusicPlayerProvider>(
                context,
                listen: false,
              ).playSong(song);
              close(context, song);
            },
          ),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = query.isEmpty
        ? songs
        : songs
              .where(
                (song) =>
                    song.title.toLowerCase().contains(query.toLowerCase()) ||
                    song.artist.toLowerCase().contains(query.toLowerCase()),
              )
              .toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final song = suggestions[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Selector<MusicPlayerProvider, String?>(
                selector: (_, provider) =>
                    provider.getCustomArtForSong(song.id.toString()),
                builder: (context, customArtPath, _) {
                  if (customArtPath != null && customArtPath.isNotEmpty) {
                    return Image.file(
                      File(customArtPath),
                      fit: BoxFit.cover,
                      width: 50,
                      height: 50,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              accentColor.withOpacity(0.5),
                              accentColor.withOpacity(0.3),
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
                      borderRadius: BorderRadius.circular(8),
                      fallback: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              accentColor.withOpacity(0.5),
                              accentColor.withOpacity(0.3),
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
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            subtitle: Text(
              song.artist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
            ),
            trailing: Selector<MusicPlayerProvider, bool>(
              selector: (_, provider) =>
                  provider.isFavorite(song.id.toString()),
              builder: (context, isFavorite, _) {
                return IconButton(
                  icon: Icon(
                    isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: isFavorite ? accentColor : Colors.grey[400],
                    size: 24,
                  ),
                  onPressed: () {
                    Provider.of<MusicPlayerProvider>(
                      context,
                      listen: false,
                    ).toggleFavorite(song.id.toString());
                  },
                );
              },
            ),
            onTap: () {
              Provider.of<MusicPlayerProvider>(
                context,
                listen: false,
              ).playSong(song);
              close(context, song);
            },
          ),
        );
      },
    );
  }
}
