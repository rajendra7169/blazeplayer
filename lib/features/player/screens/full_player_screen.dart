import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_player_provider.dart';
import '../widgets/cached_artwork_widget.dart';
import '../widgets/artwork_color_builder.dart';
import 'lyrics_screen.dart';

class FullPlayerScreen extends StatefulWidget {
  const FullPlayerScreen({super.key});

  @override
  State<FullPlayerScreen> createState() => _FullPlayerScreenState();
}

class _FullPlayerScreenState extends State<FullPlayerScreen> {
  bool _isDragging = false;
  double _dragPosition = 0.0;
  double _verticalDragStart = 0.0;
  double _horizontalDragStart = 0.0;

  @override
  Widget build(BuildContext context) {
    final playerProvider = context.watch<MusicPlayerProvider>();
    final currentSong = playerProvider.currentSong;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (currentSong == null) {
      Navigator.of(context).pop();
      return const SizedBox.shrink();
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragStart: (details) {
        _verticalDragStart = details.globalPosition.dy;
      },
      onVerticalDragUpdate: (details) {
        // Track vertical movement
        final delta = details.globalPosition.dy - _verticalDragStart;
        // Only allow vertical gestures if moving more vertically than horizontally
        if (delta.abs() > 10) {
          setState(() {});
        }
      },
      onVerticalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;

        // Swipe down to close (velocity > 300)
        if (velocity > 300) {
          Navigator.of(context).pop();
        }
        // Swipe up to open lyrics (velocity < -300)
        else if (velocity < -300) {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const LyricsScreen(),
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
              transitionDuration: const Duration(milliseconds: 300),
            ),
          );
        }
      },
      child: Material(
        color: Colors.transparent,
        child: currentSong.albumArt != null
            ? ArtworkColorBuilder(
                songId: currentSong.albumArt!,
                builder: (dominantColor, vibrantColor) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [
                                dominantColor,
                                Color.lerp(dominantColor, vibrantColor, 0.6)!,
                                vibrantColor,
                                Color.lerp(vibrantColor, Colors.black, 0.4)!,
                                const Color(0xFF000000),
                              ]
                            : [
                                Color.lerp(dominantColor, Colors.white, 0.2)!,
                                dominantColor,
                                Color.lerp(dominantColor, vibrantColor, 0.5)!,
                                vibrantColor,
                                Color.lerp(vibrantColor, Colors.black, 0.2)!,
                              ],
                        stops: isDark
                            ? [0.0, 0.25, 0.5, 0.75, 1.0]
                            : [0.0, 0.2, 0.5, 0.75, 1.0],
                      ),
                    ),
                    child: _buildPlayerContent(
                      context,
                      playerProvider,
                      currentSong,
                      isDark,
                    ),
                  );
                },
              )
            : Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDark
                        ? [
                            const Color(0xFF2D2D2D),
                            const Color(0xFF1A1A1A),
                            const Color(0xFF000000),
                          ]
                        : [
                            const Color(0xFFE8B4B8),
                            const Color(0xFFB8A4C9),
                            const Color(0xFF8B7B9B),
                          ],
                  ),
                ),
                child: _buildPlayerContent(
                  context,
                  playerProvider,
                  currentSong,
                  isDark,
                ),
              ),
      ), // Close Material and GestureDetector
    );
  }

  Widget _buildPlayerContent(
    BuildContext context,
    MusicPlayerProvider playerProvider,
    dynamic currentSong,
    bool isDark,
  ) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        color: isDark
            ? Colors.black.withOpacity(0.4)
            : Colors.black.withOpacity(0.4),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    // Top Bar with minimize button
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: isDark ? Colors.white : Colors.white,
                              size: 32,
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                'PLAYING FROM',
                                style: TextStyle(
                                  color: (isDark ? Colors.white : Colors.white)
                                      .withOpacity(0.7),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                currentSong.album,
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.more_horiz_rounded,
                              color: isDark ? Colors.white : Colors.white,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Album Art with Hero animation and Swipe Gestures
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: GestureDetector(
                        onHorizontalDragStart: (details) {
                          _horizontalDragStart = details.globalPosition.dx;
                        },
                        onHorizontalDragEnd: (details) {
                          final velocity = details.primaryVelocity ?? 0;

                          // Swipe right (previous song) - velocity > 400
                          if (velocity > 400) {
                            playerProvider.previousSong();
                          }
                          // Swipe left (next song) - velocity < -400
                          else if (velocity < -400) {
                            playerProvider.nextSong();
                          }
                        },
                        child: Hero(
                          tag: 'album_art_${currentSong.id}',
                          child: RepaintBoundary(
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.4),
                                      blurRadius: 30,
                                      offset: const Offset(0, 15),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: currentSong.albumArt != null
                                      ? CachedArtworkWidget(
                                          songId: currentSong.albumArt!,
                                          fit: BoxFit.cover,
                                          borderRadius: BorderRadius.zero,
                                          fallback: Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  const Color(
                                                    0xFFFFA726,
                                                  ).withOpacity(0.7),
                                                  const Color(
                                                    0xFFFF7043,
                                                  ).withOpacity(0.7),
                                                ],
                                              ),
                                            ),
                                            child: const Icon(
                                              Icons.music_note_rounded,
                                              color: Colors.white,
                                              size: 120,
                                            ),
                                          ),
                                        )
                                      : Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                const Color(
                                                  0xFFFFA726,
                                                ).withOpacity(0.7),
                                                const Color(
                                                  0xFFFF7043,
                                                ).withOpacity(0.7),
                                              ],
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.music_note_rounded,
                                            color: Colors.white,
                                            size: 120,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Song Title and Artist
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      currentSong.title,
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white
                                            : Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      currentSong.artist,
                                      style: TextStyle(
                                        color:
                                            (isDark
                                                    ? Colors.white
                                                    : Colors.white)
                                                .withOpacity(0.7),
                                        fontSize: 18,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {},
                                    icon: Icon(
                                      Icons.star_border_rounded,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.white,
                                      size: 26,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {},
                                    icon: Icon(
                                      Icons.more_horiz_rounded,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.white,
                                      size: 26,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Progress Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        children: [
                          SliderTheme(
                            data: SliderThemeData(
                              trackHeight: 5,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 7,
                              ),
                              overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 18,
                              ),
                              activeTrackColor: isDark
                                  ? Colors.white
                                  : Colors.white,
                              inactiveTrackColor:
                                  (isDark ? Colors.white : Colors.white)
                                      .withOpacity(0.3),
                              thumbColor: isDark ? Colors.white : Colors.white,
                              overlayColor:
                                  (isDark ? Colors.white : Colors.white)
                                      .withOpacity(0.2),
                            ),
                            child: Slider(
                              value: _isDragging
                                  ? _dragPosition
                                  : playerProvider.currentPosition.inSeconds
                                        .toDouble()
                                        .clamp(
                                          0.0,
                                          currentSong.duration.inSeconds
                                              .toDouble(),
                                        )
                                        .toDouble(),
                              max: currentSong.duration.inSeconds.toDouble() > 0
                                  ? currentSong.duration.inSeconds.toDouble()
                                  : 0.1,
                              onChanged: (value) {
                                setState(() {
                                  _isDragging = true;
                                  _dragPosition = value;
                                });
                              },
                              onChangeEnd: (value) {
                                playerProvider.seekTo(
                                  Duration(seconds: value.toInt()),
                                );
                                setState(() {
                                  _isDragging = false;
                                });
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDuration(
                                    _isDragging
                                        ? Duration(
                                            seconds: _dragPosition.toInt(),
                                          )
                                        : playerProvider.currentPosition,
                                  ),
                                  style: TextStyle(
                                    color:
                                        (isDark ? Colors.white : Colors.white)
                                            .withOpacity(0.7),
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '-${_formatDuration(_isDragging ? Duration(seconds: (currentSong.duration.inSeconds - _dragPosition.toInt())) : currentSong.duration - playerProvider.currentPosition)}',
                                  style: TextStyle(
                                    color:
                                        (isDark ? Colors.white : Colors.white)
                                            .withOpacity(0.7),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Playback Controls - Apple Music Style
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Shuffle Button (Left)
                          IconButton(
                            onPressed: () => playerProvider.toggleShuffle(),
                            icon: Icon(
                              Icons.shuffle_rounded,
                              color: playerProvider.isShuffle
                                  ? (isDark
                                        ? const Color(0xFFFFA726)
                                        : Colors.white)
                                  : (isDark ? Colors.white : Colors.white)
                                        .withOpacity(0.5),
                              size: 28,
                            ),
                            padding: EdgeInsets.zero,
                          ),

                          // Previous Button
                          IconButton(
                            onPressed: () => playerProvider.previousSong(),
                            icon: Icon(
                              Icons.skip_previous_rounded,
                              color: isDark ? Colors.white : Colors.white,
                              size: 50,
                            ),
                            padding: EdgeInsets.zero,
                          ),

                          // Play/Pause Button - Large
                          IconButton(
                            onPressed: () => playerProvider.togglePlayPause(),
                            icon: Icon(
                              playerProvider.isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: isDark ? Colors.white : Colors.white,
                              size: 70,
                            ),
                            padding: EdgeInsets.zero,
                          ),

                          // Next Button
                          IconButton(
                            onPressed: () => playerProvider.nextSong(),
                            icon: Icon(
                              Icons.skip_next_rounded,
                              color: isDark ? Colors.white : Colors.white,
                              size: 50,
                            ),
                            padding: EdgeInsets.zero,
                          ),

                          // Repeat Button (Right)
                          IconButton(
                            onPressed: () => playerProvider.cycleRepeatMode(),
                            icon: Icon(
                              playerProvider.repeatMode == RepeatMode.one
                                  ? Icons.repeat_one_rounded
                                  : Icons.repeat_rounded,
                              color: playerProvider.repeatMode != RepeatMode.off
                                  ? (isDark
                                        ? const Color(0xFFFFA726)
                                        : Colors.white)
                                  : (isDark ? Colors.white : Colors.white)
                                        .withOpacity(0.5),
                              size: 28,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 60),

                    // Bottom Icons - Library, Lyrics, Up Next
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 60),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Up Next Icon (Left)
                          IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.queue_music_rounded,
                              color: (isDark ? Colors.white : Colors.white)
                                  .withOpacity(0.8),
                              size: 26,
                            ),
                          ),
                          // Lyrics Button (Middle) - with swipe up icon and text
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  pageBuilder:
                                      (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                      ) => const LyricsScreen(),
                                  transitionsBuilder:
                                      (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                        child,
                                      ) {
                                        const begin = Offset(0.0, 1.0);
                                        const end = Offset.zero;
                                        const curve = Curves.easeOutCubic;
                                        var tween = Tween(
                                          begin: begin,
                                          end: end,
                                        ).chain(CurveTween(curve: curve));
                                        var offsetAnimation = animation.drive(
                                          tween,
                                        );
                                        return SlideTransition(
                                          position: offsetAnimation,
                                          child: child,
                                        );
                                      },
                                  transitionDuration: const Duration(
                                    milliseconds: 400,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Transform.translate(
                                    offset: const Offset(0, -18),
                                    child: Icon(
                                      Icons.keyboard_arrow_up_rounded,
                                      color:
                                          (isDark ? Colors.white : Colors.white)
                                              .withOpacity(0.8),
                                      size: 28,
                                    ),
                                  ),
                                  Transform.translate(
                                    offset: const Offset(0, -16),
                                    child: Text(
                                      'Lyrics',
                                      style: TextStyle(
                                        color:
                                            (isDark
                                                    ? Colors.white
                                                    : Colors.white)
                                                .withOpacity(0.8),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Library Icon (Right)
                          IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.library_music_rounded,
                              color: (isDark ? Colors.white : Colors.white)
                                  .withOpacity(0.8),
                              size: 26,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
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
