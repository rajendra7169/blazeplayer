import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../player/models/song_model.dart';
import '../player/providers/music_player_provider.dart';
import '../player/widgets/cached_artwork_widget.dart';
import '../player/widgets/mini_player.dart';

class MusicSearchDelegate extends SearchDelegate {
  List<String> _recentSearches = [];
  bool _recentLoaded = false;

  MusicSearchDelegate() {
    _initRecentSearches();
  }

  void _initRecentSearches() {
    if (!_recentLoaded) {
      _loadRecentSearches();
      _recentLoaded = true;
    }
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final loaded = prefs.getStringList('recent_searches') ?? [];
    _recentSearches.clear();
    _recentSearches.addAll(loaded);
  }

  Future<void> _saveRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('recent_searches', _recentSearches);
  }

  @override
  String get searchFieldLabel => 'Search songs, albums, artists...';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: _buildSearchResults(context)),
        Consumer<MusicPlayerProvider>(
          builder: (context, playerProvider, _) {
            if (playerProvider.currentSong == null) return SizedBox.shrink();
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
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final playerProvider = Provider.of<MusicPlayerProvider>(
      context,
      listen: false,
    );
    // Ensure songs are loaded before showing suggestions
    if (playerProvider.allSongs.isEmpty) {
      Future.microtask(() async {
        await playerProvider.fetchLocalSongs();
      });
      return Center(child: Text('Loading songs...'));
    }
    Widget content;
    if (query.isEmpty && _recentSearches.isNotEmpty) {
      content = Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Searches',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _recentSearches.length > 10
                    ? 10
                    : _recentSearches.length,
                itemBuilder: (context, index) {
                  final song = playerProvider.allSongs.firstWhere(
                    (s) => s.id == _recentSearches[index],
                    orElse: () => playerProvider.allSongs.first,
                  );
                  return GestureDetector(
                    onTap: () {
                      playerProvider.playWithContext(
                        song,
                        playerProvider.allSongs,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Column(
                        children: [
                          CachedArtworkWidget(
                            songId: song.id,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            fallback: Icon(
                              Icons.music_note,
                              color: Colors.grey,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: 64,
                            child: Text(
                              song.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    } else {
      content = _buildSearchResults(context);
    }
    return Stack(
      children: [
        Positioned.fill(child: content),
        Consumer<MusicPlayerProvider>(
          builder: (context, playerProvider, _) {
            if (playerProvider.currentSong == null) return SizedBox.shrink();
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
  }

  Widget _buildSearchResults(BuildContext context) {
    final playerProvider = Provider.of<MusicPlayerProvider>(
      context,
      listen: false,
    );
    // Use allSongs getter for complete device-wide search
    final songs = playerProvider.allSongs;
    // Build albums and artists from songs
    final albumMap = <String, List<Song>>{};
    final artistMap = <String, List<Song>>{};
    for (final song in songs) {
      albumMap.putIfAbsent(song.album, () => []).add(song);
      artistMap.putIfAbsent(song.artist, () => []).add(song);
    }
    final albumResults = albumMap.entries
        .where((entry) => entry.key.toLowerCase().contains(query.toLowerCase()))
        .toList();
    final artistResults = artistMap.entries
        .where((entry) => entry.key.toLowerCase().contains(query.toLowerCase()))
        .toList();
    final songResults = songs
        .where(
          (song) =>
              song.title.toLowerCase().contains(query.toLowerCase()) ||
              song.artist.toLowerCase().contains(query.toLowerCase()) ||
              song.album.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();

    if (query.isEmpty) {
      return Center(child: Text('Type to search songs, albums, or artists.'));
    }

    return ListView(
      children: [
        if (songResults.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Songs', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ...songResults.map(
            (song) => ListTile(
              leading: CachedArtworkWidget(
                songId: song.id,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                fallback: Icon(Icons.music_note, color: Colors.grey, size: 28),
              ),
              title: Text(song.title),
              subtitle: Text(song.artist),
              onTap: () async {
                if (!_recentSearches.contains(song.id)) {
                  _recentSearches.insert(0, song.id);
                  if (_recentSearches.length > 10) {
                    _recentSearches = _recentSearches.sublist(0, 10);
                  }
                  await _saveRecentSearches();
                }
                playerProvider.playWithContext(song, playerProvider.allSongs);
                close(context, song);
              },
            ),
          ),
        ],
        if (albumResults.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Albums',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ...albumResults.map(
            (entry) => ListTile(
              leading: Icon(Icons.album),
              title: Text(entry.key),
              subtitle: Text('${entry.value.length} songs'),
              onTap: () {
                // Optionally show album details
                close(context, entry.key);
              },
            ),
          ),
        ],
        if (artistResults.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Artists',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ...artistResults.map(
            (entry) => ListTile(
              leading: Icon(Icons.person),
              title: Text(entry.key),
              subtitle: Text('${entry.value.length} songs'),
              onTap: () {
                // Optionally show artist details
                close(context, entry.key);
              },
            ),
          ),
        ],
        if (songResults.isEmpty &&
            albumResults.isNotEmpty &&
            artistResults.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(child: Text('No results found.')),
          ),
      ],
    );
  }
}
