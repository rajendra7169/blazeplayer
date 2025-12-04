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
  final ScrollController _scrollController = ScrollController();

  // Reusable placeholder widgets - created once and reused for all songs
  Widget? _lightPlaceholder;
  Widget? _darkPlaceholder;

  @override
  void initState() {
    super.initState();
    final playerProvider = Provider.of<MusicPlayerProvider>(
      context,
      listen: false,
    );
    // Pre-sort songs to avoid delay
    final songs = List<Song>.from(playerProvider.allSongs);
    songs.sort((a, b) => a.title.compareTo(b.title));
    _filteredSongs = songs;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
    final cardColor = isDark
        ? const Color(0xFF2C2C2C)
        : const Color(0xFFF5F5F5);
    final songs = Provider.of<MusicPlayerProvider>(context).allSongs;

    // Ensure placeholder is always initialized
    if (isDark && _darkPlaceholder == null) {
      _darkPlaceholder = Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white12,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.music_note_rounded,
          color: Colors.white30,
          size: 32,
        ),
      );
    }
    if (!isDark && _lightPlaceholder == null) {
      _lightPlaceholder = Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          Icons.music_note_rounded,
          color: Colors.grey[600],
          size: 32,
        ),
      );
    }
    final placeholder = isDark
        ? _darkPlaceholder ?? Container()
        : _lightPlaceholder ?? Container();

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).padding.top + 48),
                // Big music icon
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
                        Icons.music_note_rounded,
                        color: accentColor,
                        size: 72,
                      ),
                    ),
                  ),
                ),
                // Page title
                Center(
                  child: Container(
                    constraints: BoxConstraints(maxWidth: 260),
                    child: Text(
                      'All Songs',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 2,
                    ),
                  ),
                ),
                // Song count and sort icons
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
                          color: isDark ? Colors.white60 : Colors.black54,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        transitionBuilder: (child, animation) =>
                            ScaleTransition(scale: animation, child: child),
                        child: IconButton(
                          key: ValueKey(_sortType),
                          icon: Icon(
                            _sortType == 'A-Z'
                                ? Icons.sort_by_alpha_rounded
                                : Icons.calendar_today_rounded,
                            color: accentColor,
                            size: 24,
                          ),
                          tooltip: _sortType == 'A-Z'
                              ? 'Sort A-Z'
                              : 'Sort by Date Added',
                          onPressed: () {
                            setState(() {
                              _sortType = _sortType == 'A-Z'
                                  ? 'Date Added'
                                  : 'A-Z';
                              _applyFilter(songs);
                            });
                          },
                        ),
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
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                          ),
                          onPressed: () {
                            if (_filteredSongs.isNotEmpty) {
                              final provider = Provider.of<MusicPlayerProvider>(
                                context,
                                listen: false,
                              );
                              provider.shuffleAndPlay(_filteredSongs);
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.shuffle_rounded, color: accentColor),
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
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                          ),
                          onPressed: () {
                            if (_filteredSongs.isNotEmpty) {
                              final provider = Provider.of<MusicPlayerProvider>(
                                context,
                                listen: false,
                              );
                              provider.setPlaylist(_filteredSongs);
                              provider.playSong(_filteredSongs.first);
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
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
                // Song list
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(top: 8, bottom: 100),
                  itemCount: _filteredSongs.length,
                  itemBuilder: (context, index) {
                    final song = _filteredSongs[index];
                    final songId = song.id.toString();
                    return _SongListItem(
                      key: ValueKey(songId),
                      song: song,
                      songId: songId,
                      isDark: isDark,
                      placeholder: placeholder,
                    );
                  },
                ),
              ],
            ),
          ),
          // Top back and search icons
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
                          showSearch(
                            context: context,
                            delegate: _AllSongsSearchDelegate(
                              allSongs: songs,
                              onSongTap: (song) {
                                final provider =
                                    Provider.of<MusicPlayerProvider>(
                                      context,
                                      listen: false,
                                    );
                                provider.playWithContext(song, songs);
                              },
                              onQueryChanged: (query) {
                                setState(() {
                                  _searchQuery = query;
                                  _applyFilter(songs);
                                });
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
          // Mini player
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

class _SongListItem extends StatefulWidget {
  final Song song;
  final String songId;
  final bool isDark;
  final Widget placeholder;

  const _SongListItem({
    super.key,
    required this.song,
    required this.songId,
    required this.isDark,
    required this.placeholder,
  });

  @override
  State<_SongListItem> createState() => _SongListItemState();
}

class _SongListItemState extends State<_SongListItem>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Selector<MusicPlayerProvider, String?>(
          selector: (_, provider) =>
              provider.getCustomArtForSong(widget.songId),
          builder: (context, customArtPath, _) {
            if (customArtPath != null && customArtPath.isNotEmpty) {
              return Image.file(
                File(customArtPath),
                key: ValueKey(customArtPath),
                fit: BoxFit.cover,
                width: 56,
                height: 56,
                cacheWidth: 112,
                cacheHeight: 112,
                errorBuilder: (context, error, stackTrace) =>
                    widget.placeholder,
              );
            } else {
              return CachedArtworkWidget(
                songId: widget.songId,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(16),
                fallback: widget.placeholder,
              );
            }
          },
        ),
      ),
      title: Text(
        widget.song.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: widget.isDark ? Colors.white : Colors.black87,
        ),
      ),
      subtitle: Text(
        widget.song.artist,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: widget.isDark ? Colors.white60 : Colors.black54,
        ),
      ),
      trailing: IconButton(
        icon: Icon(
          Icons.more_vert_rounded,
          color: widget.isDark ? Colors.white54 : Colors.black45,
        ),
        onPressed: () {
          // TODO: Show more options for song
        },
      ),
      onTap: () {
        // Access the parent widget's state to get _filteredSongs
        final parentState = context
            .findAncestorStateOfType<_AllSongsScreenState>();
        final provider = Provider.of<MusicPlayerProvider>(
          context,
          listen: false,
        );
        if (parentState != null && parentState._filteredSongs.isNotEmpty) {
          provider.playWithContext(widget.song, parentState._filteredSongs);
        } else {
          provider.playSong(widget.song);
        }
      },
    );
  }
}

// Add _AllSongsSearchDelegate class below for search functionality
class _AllSongsSearchDelegate extends SearchDelegate<Song?> {
  final List<Song> allSongs;
  final ValueChanged<Song> onSongTap;
  final ValueChanged<String> onQueryChanged;

  _AllSongsSearchDelegate({
    required this.allSongs,
    required this.onSongTap,
    required this.onQueryChanged,
  }) : super(
         searchFieldLabel: 'Search songs...',
         keyboardType: TextInputType.text,
       );

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
          onQueryChanged(query);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = allSongs
        .where((song) => song.title.toLowerCase().contains(query.toLowerCase()))
        .toList();

    if (results.isEmpty) {
      return Center(
        child: Text(
          'No songs found',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white70
                : Colors.black54,
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final song = results[index];
        return ListTile(
          title: Text(
            song.title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black87,
            ),
          ),
          subtitle: Text(
            song.artist,
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white60
                  : Colors.black54,
            ),
          ),
          onTap: () {
            onSongTap(song);
            close(context, song);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = allSongs
        .where((song) => song.title.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final song = suggestions[index];
        return ListTile(
          title: Text(
            song.title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black87,
            ),
          ),
          subtitle: Text(
            song.artist,
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white60
                  : Colors.black54,
            ),
          ),
          onTap: () {
            onSongTap(song);
            close(context, song);
          },
        );
      },
    );
  }
}
