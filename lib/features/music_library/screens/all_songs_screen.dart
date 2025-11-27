import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import '../../player/providers/music_player_provider.dart';
import '../../player/widgets/cached_artwork_widget.dart';
import '../../player/widgets/mini_player.dart';

class AllSongsScreen extends StatefulWidget {
  const AllSongsScreen({super.key});

  @override
  State<AllSongsScreen> createState() => _AllSongsScreenState();
}

class _AllSongsScreenState extends State<AllSongsScreen> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  List<SongModel> _songs = [];
  List<SongModel> _filteredSongs = [];
  bool _loading = true;
  String _searchQuery = '';
  String _sortType = 'A-Z';

  @override
  void initState() {
    super.initState();
    _fetchSongs();
  }

  Future<void> _fetchSongs() async {
    final songs = await _audioQuery.querySongs();
    setState(() {
      _songs = songs;
      _applyFilter();
      _loading = false;
    });
  }

  void _applyFilter() {
    List<SongModel> filtered = _songs;
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
      filtered.sort((a, b) => (b.dateAdded ?? 0).compareTo(a.dateAdded ?? 0));
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
          Column(
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
                            prefixIcon: Icon(Icons.search, color: accentColor),
                            border: InputBorder.none,
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
                            _applyFilter();
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white10 : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: accentColor, width: 1),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _sortType,
                          dropdownColor: isDark
                              ? const Color(0xFF232323)
                              : Colors.white,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                          icon: Icon(Icons.arrow_drop_down, color: accentColor),
                          items: const [
                            DropdownMenuItem(value: 'A-Z', child: Text('A-Z')),
                            DropdownMenuItem(
                              value: 'Date Added',
                              child: Text('Date Added'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              _sortType = value;
                              _applyFilter();
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredSongs.isEmpty
                    ? Center(
                        child: Text(
                          'No songs found.',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredSongs.length,
                        itemBuilder: (context, index) {
                          final song = _filteredSongs[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CachedArtworkWidget(
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
                                song.artist ?? 'Unknown Artist',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white60
                                      : Colors.black54,
                                ),
                              ),
                              onTap: () {
                                // TODO: Play song or open player
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
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
      ),
    );
  }
}
