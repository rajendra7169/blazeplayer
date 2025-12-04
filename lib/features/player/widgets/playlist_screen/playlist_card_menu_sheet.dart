import 'package:flutter/material.dart';

class PlaylistCardMenuSheet extends StatelessWidget {
  final IconData cardIcon;
  final Color cardColor;
  final String title;
  final int songCount;
  final VoidCallback? onPlay;
  final VoidCallback? onPlayNext;
  final VoidCallback? onAddToQueue;
  final VoidCallback? onAddToPlaylist;
  const PlaylistCardMenuSheet({
    super.key,
    required this.cardIcon,
    required this.cardColor,
    required this.title,
    required this.songCount,
    this.onPlay,
    this.onPlayNext,
    this.onAddToQueue,
    this.onAddToPlaylist,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(cardIcon, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$songCount songs',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: Icon(
              Icons.play_arrow_rounded,
              color: isDark ? Colors.white : Colors.black87,
            ),
            title: const Text('Play'),
            onTap: onPlay ?? () => Navigator.pop(context),
          ),
          ListTile(
            leading: Icon(
              Icons.skip_next_rounded,
              color: isDark ? Colors.white : Colors.black87,
            ),
            title: const Text('Play next'),
            onTap: onPlayNext ?? () => Navigator.pop(context),
          ),
          ListTile(
            leading: Icon(
              Icons.queue_music_rounded,
              color: isDark ? Colors.white : Colors.black87,
            ),
            title: const Text('Add to queue'),
            onTap: onAddToQueue ?? () => Navigator.pop(context),
          ),
          ListTile(
            leading: Icon(
              Icons.playlist_add_rounded,
              color: isDark ? Colors.white : Colors.black87,
            ),
            title: const Text('Add to playlist'),
            onTap: onAddToPlaylist ?? () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
