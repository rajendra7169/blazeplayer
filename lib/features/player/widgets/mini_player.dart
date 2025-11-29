import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_player_provider.dart';
import '../screens/full_player_screen.dart';
import 'cached_artwork_widget.dart';
import 'artwork_color_builder.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Selector<MusicPlayerProvider, dynamic>(
      selector: (_, provider) => provider.currentSong,
      builder: (context, currentSong, _) {
        if (currentSong == null) {
          return const SizedBox.shrink();
        }
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              PageRouteBuilder(
                opaque: false,
                barrierColor: Colors.black.withOpacity(0.0),
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const FullPlayerScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      const begin = Offset(0.0, 1.0);
                      const end = Offset.zero;
                      const curve = Curves.easeOutCubic;
                      var tween = Tween(
                        begin: begin,
                        end: end,
                      ).chain(CurveTween(curve: curve));
                      var offsetAnimation = animation.drive(tween);
                      return SlideTransition(
                        position: offsetAnimation,
                        child: child,
                      );
                    },
                transitionDuration: const Duration(milliseconds: 400),
              ),
            );
          },
          child: currentSong.albumArt != null
              ? ArtworkColorBuilder(
                  songId: currentSong.albumArt!,
                  builder: (dominantColor, vibrantColor) {
                    return Container(
                      height: 70,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [dominantColor, vibrantColor],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                      child: _buildMiniPlayerContent(
                        context,
                        currentSong,
                        Provider.of<MusicPlayerProvider>(
                          context,
                          listen: false,
                        ),
                        isDark,
                      ),
                    );
                  },
                )
              : Container(),
        );
      },
    );
  }

  Widget _buildMiniPlayerContent(
    BuildContext context,
    dynamic currentSong,
    MusicPlayerProvider playerProvider,
    bool isDark,
  ) {
    return Row(
      children: [
        // Album Art with Hero animation
        Hero(
          tag: 'album_art_${currentSong.id}',
          child: Material(
            type: MaterialType.transparency,
            child: Container(
              width: 70,
              height: 70,
              color: isDark
                  ? const Color(0xFF3D3D3D)
                  : Colors.white.withOpacity(0.3),
              child: (() {
                final customArtPath = playerProvider.getCustomArtForSong(
                  currentSong.id,
                );
                if (customArtPath != null && customArtPath.isNotEmpty) {
                  return Image.file(
                    File(customArtPath),
                    fit: BoxFit.cover,
                    width: 70,
                    height: 70,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.music_note_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  );
                } else if (currentSong.albumArt != null) {
                  return CachedArtworkWidget(
                    songId: currentSong.albumArt!,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    fallback: const Icon(
                      Icons.music_note_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  );
                } else {
                  return const Icon(
                    Icons.music_note_rounded,
                    color: Colors.white,
                    size: 32,
                  );
                }
              })(),
            ),
          ),
        ),
        // Song Info
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentSong.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  currentSong.artist,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
        // Play/Pause Button
        IconButton(
          onPressed: () => playerProvider.togglePlayPause(),
          icon: Icon(
            playerProvider.isPlaying
                ? Icons.pause_rounded
                : Icons.play_arrow_rounded,
            color: Colors.white,
            size: 32,
          ),
        ),
        // Next Button
        IconButton(
          onPressed: () => playerProvider.nextSong(),
          icon: const Icon(
            Icons.skip_next_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}
