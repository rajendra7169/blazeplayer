import 'package:flutter/material.dart';

class SongInfoSheet extends StatelessWidget {
  final dynamic song;
  final bool isDark;
  const SongInfoSheet({super.key, required this.song, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final info = [
      {'Title': song.title},
      {'Format': song.filePath.split('.').last.toUpperCase()},
      {'Size': 'Unknown'},
      {'Duration': _formatDuration(song.duration)},
      {'Album': song.album ?? ''},
      {'Artist': song.artist ?? ''},
      {'Genre': song.genre ?? ''},
      {'File Name': song.filePath.split('/').last},
      {'Location': song.filePath},
      // Add more fields if available in your Song model
    ];
    return Padding(
      padding: const EdgeInsets.only(top: 24, left: 20, right: 20, bottom: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Song Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 18),
          ...info.map((item) {
            final key = item.keys.first;
            final value = item[key]?.toString() ?? '';
            return Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 10,
              ), // increased spacing
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 140,
                    child: Text(
                      key,
                      style: TextStyle(
                        color: isDark
                            ? Colors.white
                            : Colors.black87, 
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      value,
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                        fontSize: 16,
                        fontFamily: 'Roboto',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Container(
                  height: 54,
                  margin: const EdgeInsets.only(right: 12),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: isDark
                          ? const Color(0xFF232323)
                          : Colors.white,
                      foregroundColor: isDark ? Colors.white : Colors.black87,
                      side: BorderSide(
                        color: isDark
                            ? const Color(0xFFFFA726)
                            : const Color(0xFFFF7043),
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {},
                    child: const Text(
                      'EDIT',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 54,
                  margin: const EdgeInsets.only(left: 12),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? const Color(0xFFFFA726)
                          : const Color(0xFFFF7043),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32), // add margin below buttons
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
