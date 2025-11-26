import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_player_provider.dart';
import '../screens/full_player_screen.dart';
import 'cached_artwork_widget.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final playerProvider = context.watch<MusicPlayerProvider>();
    final currentSong = playerProvider.currentSong;

    if (currentSong == null) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

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
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF2D2D2D), const Color(0xFF1A1A1A)]
                : [
                    const Color(0xFFFFA726).withOpacity(0.9),
                    const Color(0xFFFF7043).withOpacity(0.9),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.3)
                  : const Color(0xFFFFA726).withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
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
                  child: currentSong.albumArt != null
                      ? CachedArtworkWidget(
                          songId: currentSong.albumArt!,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          fallback: const Icon(
                            Icons.music_note_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        )
                      : const Icon(
                          Icons.music_note_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
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
        ),
      ),
    );
  }
}
