import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../player/providers/music_player_provider.dart';
import '../../player/widgets/cached_artwork_widget.dart';
import '../../player/widgets/mini_player.dart';
import '../../player/widgets/modern_search_delegate.dart';
import '../../player/models/song_model.dart';

class SongListScreen extends StatefulWidget {
  final String title;
  final List<dynamic> songs;
  final bool showSearch;
  final bool isMoodPlaylist;

  const SongListScreen({
    super.key,
    required this.title,
    required this.songs,
    this.showSearch = true,
    this.isMoodPlaylist = false,
  });

  @override
  State<SongListScreen> createState() => _SongListScreenState();
}

// --- Modal sheet for adding songs to mood playlist ---

class _AddSongsToMoodSheet extends StatefulWidget {
  final String mood;
  const _AddSongsToMoodSheet({required this.mood});

  @override
  State<_AddSongsToMoodSheet> createState() => _AddSongsToMoodSheetState();
}

class _AddSongsToMoodSheetState extends State<_AddSongsToMoodSheet> {
  late List<Song> allSongs;
  Set<String> selectedSongIds = {};

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<MusicPlayerProvider>(context, listen: false);
    allSongs = provider.allSongs;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark
        ? const Color(0xFFFFA726)
        : const Color(0xFFFF7043);
    final cardColor = isDark
        ? const Color(0xFF2C2C2C)
        : const Color(0xFFF5F5F5);
    final screenHeight = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              const SizedBox(height: 24),
              Text(
                'Add songs to ${widget.mood} playlist',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 19,
                  color: accentColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              Expanded(
                child: ListView.builder(
                  itemCount: allSongs.length,
                  itemBuilder: (context, i) {
                    final song = allSongs[i];
                    final checked = selectedSongIds.contains(song.id);
                    Widget artworkWidget;
                    final artPath = song.albumArt;
                    // Debug print to help diagnose artwork path issues
                    // ignore: avoid_print
                    print('Artwork path for song "${song.title}": $artPath');
                    if (artPath != null &&
                        artPath.isNotEmpty &&
                        File(artPath).existsSync()) {
                      artworkWidget = SizedBox(
                        width: 44,
                        height: 44,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(artPath),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.white12
                                        : Colors.grey[300],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.music_note_rounded,
                                    color: accentColor,
                                    size: 24,
                                  ),
                                ),
                          ),
                        ),
                      );
                    } else {
                      artworkWidget = SizedBox(
                        width: 44,
                        height: 44,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white12 : Colors.grey[300],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.music_note_rounded,
                              color: accentColor,
                              size: 24,
                            ),
                          ),
                        ),
                      );
                    }
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white10 : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8, right: 8),
                            child: artworkWidget,
                          ),
                          Expanded(
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                song.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                song.artist,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Checkbox(
                                value: checked,
                                onChanged: (val) {
                                  setState(() {
                                    if (val == true) {
                                      selectedSongIds.add(song.id);
                                    } else {
                                      selectedSongIds.remove(song.id);
                                    }
                                  });
                                },
                                activeColor: accentColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  onPressed: () {
                    final provider = Provider.of<MusicPlayerProvider>(
                      context,
                      listen: false,
                    );
                    provider.addSongsToMood(
                      widget.mood,
                      selectedSongIds.toList(),
                    );
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Add Selected Songs',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _SongListScreenState extends State<SongListScreen> {
  String _searchQuery = '';
  List<dynamic> _filteredSongs = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _filteredSongs = widget.songs;
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top + 48),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
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
                              Icons
                                  .music_note_rounded, // changed from album to music icon
                              color: accentColor,
                              size: 72,
                            ),
                          ),
                        ),
                      ),
                      // Page title
                      Center(
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: 260,
                          ), // limit width for long names
                          child: Text(
                            widget.title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18, // smaller font size
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                              overflow: TextOverflow.ellipsis,
                            ),
                            maxLines: 2,
                          ),
                        ),
                      ),
                      // Song count
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
                            if (widget.isMoodPlaylist)
                              IconButton(
                                icon: Icon(
                                  Icons.add_circle_outline,
                                  color: accentColor,
                                ),
                                tooltip: 'Add songs to this playlist',
                                onPressed: () async {
                                  await showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (context) {
                                      return _AddSongsToMoodSheet(
                                        mood: widget.title,
                                      );
                                    },
                                  );
                                },
                              )
                            else
                              Icon(
                                Icons.music_note_rounded,
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
                                  if (_filteredSongs.isNotEmpty) {
                                    final provider =
                                        Provider.of<MusicPlayerProvider>(
                                          context,
                                          listen: false,
                                        );
                                    provider.shuffleAndPlay(
                                      _filteredSongs.cast<Song>(),
                                    );
                                  }
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                                    final provider =
                                        Provider.of<MusicPlayerProvider>(
                                          context,
                                          listen: false,
                                        );
                                    provider.setPlaylist(
                                      _filteredSongs.cast<Song>(),
                                    );
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
                          return ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Selector<MusicPlayerProvider, String?>(
                                selector: (_, provider) =>
                                    provider.getCustomArtForSong(songId),
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
                                  } else {
                                    return CachedArtworkWidget(
                                      songId: songId,
                                      width: 56,
                                      height: 56,
                                      fit: BoxFit.cover,
                                      borderRadius: BorderRadius.circular(16),
                                      fallback: Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? Colors.white12
                                              : Colors.grey[300],
                                          borderRadius: BorderRadius.circular(
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
                              song.artist ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                Icons.more_vert_rounded,
                                color: isDark
                                    ? Colors.white54
                                    : Colors.black45, // match recommended style
                              ),
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) => SizedBox(
                                    height: 180,
                                    child: Center(
                                      child: Text(
                                        'Song options for "${song.title}"',
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            onTap: () {
                              final provider = Provider.of<MusicPlayerProvider>(
                                context,
                                listen: false,
                              );
                              provider.playWithContext(
                                song,
                                _filteredSongs.cast<Song>(),
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
          ),
          // Back and Search buttons at top
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
                      if (widget.showSearch)
                        IconButton(
                          icon: Icon(
                            Icons.search_rounded,
                            color: isDark ? Colors.white70 : Colors.black54,
                            size: 22,
                          ),
                          onPressed: () {
                            showSearch(
                              context: context,
                              delegate: ModernSearchDelegate<dynamic>(
                                items: widget.songs,
                                getTitle: (song) => song.title,
                                getSubtitle: (song) => song.artist,
                                getAlbum: (song) => song.album,
                                getArtist: (song) => song.artist,
                                getType: (song) => 'song',
                                onItemTap: (song) {
                                  final provider =
                                      Provider.of<MusicPlayerProvider>(
                                        context,
                                        listen: false,
                                      );
                                  provider.playWithContext(
                                    song,
                                    widget.songs.cast<Song>(),
                                  );
                                },
                                onQueryChanged: (query) {
                                  setState(() => _searchQuery = query);
                                  _applyFilter(widget.songs);
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
