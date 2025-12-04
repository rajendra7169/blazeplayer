import 'package:flutter/material.dart';
import 'dart:io';
import 'package:blazeplayer/features/player/widgets/mini_player.dart';
import 'package:blazeplayer/features/player/widgets/playlist_screen/add_to_playlist_sheet.dart';
import 'package:provider/provider.dart';
import '../../player/providers/music_player_provider.dart';
import '../../player/models/song_model.dart';
import 'song_list_screen.dart';

class FolderScreen extends StatelessWidget {
  const FolderScreen({Key? key}) : super(key: key);

  // TODO: Replace with real folder fetching logic
  List<Map<String, dynamic>> getFolders(List allSongs) {
    // Group songs by folder path (up to last directory)
    final Map<String, List> folderMap = {};
    for (final song in allSongs) {
      final filePath = song.filePath;
      final folderPath = filePath.substring(0, filePath.lastIndexOf('/'));
      folderMap.putIfAbsent(folderPath, () => []).add(song);
    }
    return folderMap.entries
        .map(
          (entry) => {
            'name': entry.key.split('/').last,
            'songCount': entry.value.length,
            'location': entry.key,
            'songs': entry.value,
          },
        )
        .toList();
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
    final allSongs = context.watch<MusicPlayerProvider>().allSongs;
    final folders = getFolders(allSongs);
    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top + 48),
              // Big folder icon at top
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
                      Icons.folder_rounded,
                      color: accentColor,
                      size: 72,
                    ),
                  ),
                ),
              ),
              // Page title
              Center(
                child: Text(
                  'Folders',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              // Folder count
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Text(
                      '${folders.length} folders',
                      style: TextStyle(
                        color: isDark ? Colors.white60 : Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.folder_special_rounded,
                      color: accentColor,
                      size: 24,
                    ),
                  ],
                ),
              ),
              // Folder list
              Expanded(
                child: ListView.separated(
                  itemCount: folders.length,
                  separatorBuilder: (_, __) => Divider(),
                  itemBuilder: (context, index) {
                    final folder = folders[index];
                    final playerProvider = Provider.of<MusicPlayerProvider>(
                      context,
                      listen: false,
                    );
                    return ListTile(
                      leading: Icon(Icons.folder, color: accentColor, size: 40),
                      title: Text(
                        folder['name'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        '${folder['songCount']} songs',
                        style: TextStyle(
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.more_vert, color: accentColor),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            builder: (ctx) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: const Icon(
                                      Icons.play_arrow_rounded,
                                    ),
                                    title: const Text('Play'),
                                    onTap: () {
                                      Navigator.pop(ctx);
                                      if (folder['songs'].isNotEmpty) {
                                        playerProvider.setPlaylist(
                                          List.castFrom(folder['songs']),
                                        );
                                        playerProvider.playSong(
                                          folder['songs'][0],
                                        );
                                      }
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(
                                      Icons.skip_next_rounded,
                                    ),
                                    title: const Text('Play Next'),
                                    onTap: () {
                                      Navigator.pop(ctx);
                                      if (folder['songs'].isNotEmpty) {
                                        final idx = playerProvider.playlist
                                            .indexWhere(
                                              (s) =>
                                                  s.id ==
                                                  playerProvider
                                                      .currentSong
                                                      ?.id,
                                            );
                                        if (idx != -1) {
                                          final newPlaylist = List<Song>.from(
                                            playerProvider.playlist,
                                          );
                                          newPlaylist.insertAll(
                                            idx + 1,
                                            List<Song>.from(folder['songs']),
                                          );
                                          playerProvider.setPlaylist(
                                            newPlaylist,
                                          );
                                        }
                                      }
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(
                                      Icons.queue_music_rounded,
                                    ),
                                    title: const Text('Add to Queue'),
                                    onTap: () {
                                      Navigator.pop(ctx);
                                      if (folder['songs'].isNotEmpty) {
                                        final newPlaylist = List<Song>.from(
                                          playerProvider.playlist,
                                        );
                                        newPlaylist.addAll(
                                          List<Song>.from(folder['songs']),
                                        );
                                        playerProvider.setPlaylist(newPlaylist);
                                      }
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(
                                      Icons.playlist_add_rounded,
                                    ),
                                    title: const Text('Add to Playlist'),
                                    onTap: () {
                                      Navigator.pop(ctx);
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
                                          return AddToPlaylistSheet(
                                            favouriteCount: playerProvider
                                                .favouriteSongs
                                                .length,
                                            onCreateNew: (playlistName) {
                                              playerProvider.addMyPlaylist(
                                                playlistName,
                                                List<Song>.from(
                                                  folder['songs'],
                                                ),
                                              );
                                              Navigator.pop(context);
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Created playlist "$playlistName"',
                                                  ),
                                                  duration: const Duration(
                                                    seconds: 2,
                                                  ),
                                                ),
                                              );
                                            },
                                            onAddToFavourite: () {
                                              for (var song
                                                  in folder['songs']) {
                                                playerProvider.addToFavourite(
                                                  song.id,
                                                );
                                              }
                                              Navigator.pop(context);
                                            },
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  const Divider(),
                                  ListTile(
                                    leading: const Icon(
                                      Icons.delete_forever_rounded,
                                      color: Colors.red,
                                    ),
                                    title: const Text(
                                      'Delete Folder',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    onTap: () {
                                      Navigator.pop(ctx);
                                      showDialog(
                                        context: context,
                                        builder: (dialogCtx) => AlertDialog(
                                          title: const Text('Delete Folder?'),
                                          content: const Text(
                                            'All songs from this folder will be deleted from your device. Are you sure you want to delete this folder?',
                                          ),
                                          actions: [
                                            TextButton(
                                              child: const Text('Cancel'),
                                              onPressed: () =>
                                                  Navigator.pop(dialogCtx),
                                            ),
                                            TextButton(
                                              child: const Text(
                                                'Delete',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                              onPressed: () async {
                                                for (var song
                                                    in folder['songs']) {
                                                  try {
                                                    final file = File(
                                                      song.filePath,
                                                    );
                                                    if (await file.exists()) {
                                                      await file.delete();
                                                    }
                                                  } catch (e) {
                                                    // Handle error
                                                  }
                                                }
                                                Navigator.pop(dialogCtx);
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => SongListScreen(
                              title: folder['name'],
                              songs: List.castFrom(folder['songs']),
                              showSearch: true,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          // Floating MiniPlayer
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

class FolderListItem extends StatelessWidget {
  final String name;
  final int songCount;
  final String location;
  final VoidCallback? onOptionsTap;

  const FolderListItem({
    Key? key,
    required this.name,
    required this.songCount,
    required this.location,
    this.onOptionsTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.folder, color: Colors.blueGrey),
      title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$songCount songs'),
          Row(
            children: [
              Expanded(
                child: Text(
                  location,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: IconButton(
        icon: Icon(Icons.more_vert),
        onPressed: onOptionsTap,
      ),
    );
  }
}
