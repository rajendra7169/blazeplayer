import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../player/providers/music_player_provider.dart';
import '../../player/widgets/cached_artwork_widget.dart';
import '../../player/widgets/mini_player.dart';
import '../../player/models/song_model.dart';

class AllSongsScreen extends StatefulWidget {
  const AllSongsScreen({super.key});

  @override
  State<AllSongsScreen> createState() => _AllSongsScreenState();
}

class _AllSongsScreenState extends State<AllSongsScreen> {
  String _searchQuery = '';
  String _sortType = 'A-Z';
  List<Song> _filteredSongs = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final playerProvider = Provider.of<MusicPlayerProvider>(
        context,
        listen: false,
      );
      if (playerProvider.allSongs.isNotEmpty) {
        _applyFilter(playerProvider.allSongs);
      }
    });
  }

  void _applyFilter(List<Song> songs) {
    List<Song> filtered = List<Song>.from(songs); // Make a mutable copy
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (song) =>
                song.title.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }
    if (_sortType == 'A-Z') {
      filtered.sort((a, b) => a.title.compareTo(b.title));
    } else if (_sortType == 'Date Added') {
      filtered.sort((a, b) => (b.dateAdded).compareTo(a.dateAdded));
    }
    setState(() {
      _filteredSongs = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : Colors.white;
    final accentColor = isDark
        ? const Color(0xFFFFA726)
        : const Color(0xFFFF7043);
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        title: Text(
          'All Songs',
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ),
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
      ),
      body: Stack(
        children: [
          Consumer<MusicPlayerProvider>(
            builder: (context, playerProvider, _) {
              final songs = playerProvider.allSongs;
              if (songs.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              // Remove setState from build
              // if (_filteredSongs.isEmpty && songs.isNotEmpty) {
              //   _applyFilter(songs);
              // }
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white10 : Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search songs...',
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: accentColor,
                                ),
                                border: InputBorder.none,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
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
                        const SizedBox(width: 12),
                        Container(
                          height: 44,
                          constraints: BoxConstraints(minWidth: 110),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 0,
                            vertical: 0,
                          ),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white10 : Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              canvasColor: isDark
                                  ? const Color(0xFF232323)
                                  : Colors.white,
                              highlightColor: accentColor.withOpacity(0.15),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _sortType,
                                icon: Icon(
                                  Icons.arrow_drop_down,
                                  color: accentColor,
                                ),
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                dropdownColor: isDark
                                    ? const Color(0xFF232323)
                                    : Colors.white,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'A-Z',
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      child: Text('A-Z'),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Date Added',
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      child: Text('Date Added'),
                                    ),
                                  ),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    _sortType = value;
                                    _applyFilter(songs);
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      itemCount: _filteredSongs.length,
                      itemBuilder: (context, index) {
                        final song = _filteredSongs[index];
                        return ListTile(
                          leading: Selector<MusicPlayerProvider, String?>(
                            selector: (_, provider) => provider
                                .getCustomArtForSong(song.id.toString()),
                            builder: (context, customArtPath, _) {
                              if (customArtPath != null &&
                                  customArtPath.isNotEmpty) {
                                return Image.file(
                                  File(customArtPath),
                                  fit: BoxFit.cover,
                                  width: 56,
                                  height: 56,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(
                                        Icons.music_note_rounded,
                                        color: isDark
                                            ? Colors.white30
                                            : Colors.grey[600],
                                        size: 32,
                                      ),
                                );
                              } else {
                                return CachedArtworkWidget(
                                  songId: song.id.toString(),
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                  fallback: Icon(
                                    Icons.music_note_rounded,
                                    color: isDark
                                        ? Colors.white30
                                        : Colors.grey[600],
                                    size: 32,
                                  ),
                                );
                              }
                            },
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
                            style: TextStyle(
                              color: isDark ? Colors.white60 : Colors.black54,
                            ),
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
