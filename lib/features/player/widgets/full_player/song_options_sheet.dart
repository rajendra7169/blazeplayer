import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'song_info_sheet.dart';
import '../../providers/music_player_provider.dart';
import '../../widgets/cached_artwork_widget.dart';
import 'sleep_timer_sheet.dart';
import 'cover_preview_sheet.dart';
import 'in_app_webview_google_image.dart';
import 'package:path_provider/path_provider.dart';
import 'cover_cropper_screen.dart';
import 'edit_tags_page.dart';

class SongOptionsSheet extends StatefulWidget {
  final dynamic song;
  final bool isDark;
  final MusicPlayerProvider playerProvider;
  final void Function(Duration)? onShowTimerToast;
  const SongOptionsSheet({
    super.key,
    required this.song,
    required this.isDark,
    required this.playerProvider,
    this.onShowTimerToast,
  });

  @override
  State<SongOptionsSheet> createState() => _SongOptionsSheetState();
}

class _SongOptionsSheetState extends State<SongOptionsSheet> {
  double _volume = 1.0;

  @override
  Widget build(BuildContext context) {
    return Selector<MusicPlayerProvider, dynamic>(
      selector: (_, provider) => provider.currentSong,
      builder: (context, currentSong, _) {
        final song = widget.song;
        final isDark = widget.isDark;
        final playerProvider = widget.playerProvider;
        return Padding(
          padding: const EdgeInsets.only(
            top: 16,
            left: 16,
            right: 16,
            bottom: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        width: 56,
                        height: 56,
                        child: Selector<MusicPlayerProvider, String?>(
                          selector: (_, provider) =>
                              provider.getCustomArtForSong(song.id.toString()),
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
                                      color: Colors.white,
                                      size: 32,
                                    ),
                              );
                            } else {
                              return CachedArtworkWidget(
                                songId: song.albumArt ?? song.id.toString(),
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                                fallback: Icon(
                                  Icons.music_note_rounded,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            song.title,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            song.artist ?? 'Unknown Artist',
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black54,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.info_outline_rounded,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                      onPressed: () async {
                        Navigator.of(
                          context,
                        ).pop(); // Close the SongOptionsSheet first
                        await Future.delayed(const Duration(milliseconds: 200));
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: isDark
                              ? const Color(0xFF232323)
                              : Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(28),
                            ),
                          ),
                          builder: (context) {
                            return SongInfoSheet(song: song, isDark: isDark);
                          },
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.share_rounded,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                      onPressed: () async {
                        final shareText =
                            'Check out this song: ${song.title}\n${song.artist ?? ''}\n${song.album ?? ''}\n${song.filePath}';
                        try {
                          await Share.share(shareText);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Unable to share: $e')),
                          );
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _buildOption(
                  Icons.playlist_add_rounded,
                  'Add to playlist',
                  () {},
                ),
                _buildOption(Icons.person_rounded, 'Go to artist', () {}),
                _buildOption(Icons.album_rounded, 'Go to album', () {}),
                _buildOption(Icons.speed_rounded, 'Playback speed', () {}),
                _buildOption(Icons.timer_rounded, 'Sleep timer', () {
                  print('Sleep timer tapped');
                  Navigator.of(
                    context,
                  ).pop(); // Close the SongOptionsSheet first
                  Future.delayed(const Duration(milliseconds: 200)).then((_) {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: isDark
                          ? const Color(0xFF232323)
                          : Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                      ),
                      builder: (context) {
                        return SleepTimerSheet(
                          isDark: isDark,
                          onSetTimer: (duration) {
                            // TODO: handle timer set logic (e.g., stop playback after duration)
                          },
                          onShowTimerToast: widget.onShowTimerToast,
                        );
                      },
                    );
                  });
                }),
                _buildOption(Icons.edit_rounded, 'Edit tags', () {
                  Navigator.of(context).pop();
                  Future.delayed(const Duration(milliseconds: 200), () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            EditTagsPage(song: song, isDark: isDark),
                      ),
                    );
                  });
                }),
                _buildOption(Icons.image_rounded, 'Change cover', () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: isDark
                        ? const Color(0xFF232323)
                        : Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                    ),
                    builder: (context) {
                      return Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Set cover using:',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ListTile(
                              leading: Icon(
                                Icons.search_rounded,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                              title: Text(
                                'Search Online',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              onTap: () {
                                Navigator.of(context).pop();
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => InAppWebViewGoogleImage(
                                      query: song.title + ' Album cover',
                                      isDark: isDark,
                                      onImageSelected: (imageUrl) {
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: isDark
                                              ? const Color(0xFF232323)
                                              : Colors.white,
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(28),
                                            ),
                                          ),
                                          builder: (context) {
                                            return CoverPreviewSheet(
                                              imageUrl: imageUrl,
                                              isDark: isDark,
                                              onUse: () async {
                                                Navigator.of(context).pop();
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) => CoverCropperScreen(
                                                      imageUrl: imageUrl,
                                                      songId: song.id,
                                                      isDark: isDark,
                                                      onCropped: (croppedFile) async {
                                                        // Save cropped image and update provider
                                                        final dir =
                                                            await getApplicationDocumentsDirectory();
                                                        final filePath =
                                                            '${dir.path}/cover_${song.id}.jpg';
                                                        await croppedFile.copy(
                                                          filePath,
                                                        );
                                                        playerProvider
                                                            .setCustomArtForSong(
                                                              song.id,
                                                              filePath,
                                                            );
                                                        Navigator.of(
                                                          context,
                                                        ).pop();
                                                      },
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              leading: Icon(
                                Icons.photo_library_rounded,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                              title: Text(
                                'Local Image',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              onTap: () {
                                // TODO: Implement local image picker and preview sheet
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }),
                _buildOption(
                  Icons.ring_volume_rounded,
                  'Set as ringtone',
                  () {},
                ),
                _buildOption(Icons.delete_rounded, 'Delete song', () {}),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Icon(
                      Icons.volume_up_rounded,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                    Expanded(
                      child: Slider(
                        value: _volume,
                        min: 0.0,
                        max: 1.0,
                        activeColor: isDark
                            ? const Color(0xFFFFA726)
                            : const Color(0xFFFF7043),
                        inactiveColor: isDark ? Colors.white24 : Colors.black12,
                        onChanged: (value) {
                          setState(() {
                            _volume = value;
                          });
                          playerProvider.setVolume(value);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOption(IconData icon, String label, VoidCallback onTap) {
    final isDark = widget.isDark;
    return ListTile(
      leading: Icon(icon, color: isDark ? Colors.white : Colors.black87),
      title: Text(
        label,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 15,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      hoverColor: isDark ? Colors.white10 : Colors.black12,
    );
  }
}
