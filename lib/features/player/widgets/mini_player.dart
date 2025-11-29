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
    final playerProvider = Provider.of<MusicPlayerProvider>(
      context,
      listen: false,
    );
    return Selector<MusicPlayerProvider, dynamic>(
      selector: (_, provider) => provider.currentSong,
      builder: (context, currentSong, _) {
        if (currentSong == null) {
          return const SizedBox.shrink();
        }
        return Selector<MusicPlayerProvider, String?>(
          selector: (_, provider) => provider.currentSong != null
              ? provider.getCustomArtForSong(provider.currentSong!.id)
              : null,
          builder: (context, customArtPath, _) {
            final currentSong = playerProvider.currentSong;
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
                          child: Column(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    // Album Art with Hero animation
                                    Hero(
                                      tag:
                                          'album_art_${currentSong.id}_${customArtPath ?? ''}',
                                      child: Material(
                                        type: MaterialType.transparency,
                                        child: Container(
                                          width: 70,
                                          height: 70,
                                          color: isDark
                                              ? const Color(0xFF3D3D3D)
                                              : Colors.white.withOpacity(0.3),
                                          child: (() {
                                            if (customArtPath != null &&
                                                customArtPath.isNotEmpty) {
                                              return Image.file(
                                                File(customArtPath),
                                                fit: BoxFit.cover,
                                                width: 70,
                                                height: 70,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) => const Icon(
                                                      Icons.music_note_rounded,
                                                      color: Colors.white,
                                                      size: 32,
                                                    ),
                                              );
                                            } else if (currentSong.albumArt !=
                                                null) {
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
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              currentSong.title ?? '',
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
                                              currentSong.artist ?? '',
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(
                                                  0.8,
                                                ),
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
                                    Selector<MusicPlayerProvider, bool>(
                                      selector: (_, provider) =>
                                          provider.isPlaying,
                                      builder: (context, isPlaying, _) {
                                        return IconButton(
                                          onPressed: () =>
                                              playerProvider.togglePlayPause(),
                                          icon: Icon(
                                            isPlaying
                                                ? Icons.pause_rounded
                                                : Icons.play_arrow_rounded,
                                            color: Colors.white,
                                            size: 32,
                                          ),
                                        );
                                      },
                                    ),
                                    // Next Button
                                    Selector<MusicPlayerProvider, dynamic>(
                                      selector: (_, provider) =>
                                          provider.currentSong,
                                      builder: (context, _, __) {
                                        return IconButton(
                                          onPressed: () =>
                                              playerProvider.nextSong(),
                                          icon: const Icon(
                                            Icons.skip_next_rounded,
                                            color: Colors.white,
                                            size: 28,
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 4),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  : Container(),
            );
          },
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '${duration.inHours > 0 ? '${twoDigits(duration.inHours)}:' : ''}$minutes:$seconds';
  }
}

class PositionIndicator extends StatelessWidget {
  final ValueNotifier<Duration> positionNotifier;
  final Duration duration;
  final bool isDark;
  final Function(double) onSeek;

  const PositionIndicator({
    required this.positionNotifier,
    required this.duration,
    required this.isDark,
    required this.onSeek,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Duration>(
      valueListenable: positionNotifier,
      builder: (context, position, _) {
        return Slider(
          value: position.inMilliseconds.toDouble(),
          min: 0.0,
          max: duration.inMilliseconds.toDouble(),
          activeColor: isDark
              ? const Color(0xFFFFA726)
              : const Color(0xFFFF7043),
          inactiveColor: isDark ? Colors.white24 : Colors.black12,
          onChanged: onSeek,
        );
      },
    );
  }
}
