import 'package:flutter/material.dart';

class PlaylistOptionsSheet extends StatelessWidget {
  final String playlistName;
  final int songCount;
  final String? coverImagePath;
  final VoidCallback? onRename;
  final VoidCallback? onChangeCover;
  final VoidCallback? onDelete;

  const PlaylistOptionsSheet({
    super.key,
    required this.playlistName,
    required this.songCount,
    this.coverImagePath,
    this.onRename,
    this.onChangeCover,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark
        ? const Color(0xFFFFA726)
        : const Color(0xFFFF7043);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with playlist info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: accentColor,
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
                          child: const Icon(
                            Icons.queue_music_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                playlistName,
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
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Rename option
          ListTile(
            leading: Icon(
              Icons.edit_rounded,
              color: isDark ? Colors.white : Colors.black87,
            ),
            title: const Text('Rename'),
            onTap: onRename ?? () => Navigator.pop(context),
          ),

          // Change cover option
          ListTile(
            leading: Icon(
              Icons.image_rounded,
              color: isDark ? Colors.white : Colors.black87,
            ),
            title: const Text('Change cover'),
            onTap: onChangeCover ?? () => Navigator.pop(context),
          ),

          // Divider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Divider(
              thickness: 1,
              color: isDark ? Colors.white24 : Colors.black12,
            ),
          ),

          // Delete option
          ListTile(
            leading: const Icon(Icons.delete_rounded, color: Colors.red),
            title: const Text(
              'Delete playlist',
              style: TextStyle(color: Colors.red),
            ),
            onTap: onDelete ?? () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
