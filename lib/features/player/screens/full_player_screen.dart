import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_player_provider.dart';
import '../widgets/cached_artwork_widget.dart';
import '../widgets/artwork_color_builder.dart';
import '../widgets/full_player/song_options_sheet.dart';
import 'lyrics_screen.dart';
import '../models/song_model.dart';
import '../widgets/full_player/position_indicator.dart';

class FullPlayerScreen extends StatefulWidget {
  const FullPlayerScreen({super.key});

  @override
  State<FullPlayerScreen> createState() => _FullPlayerScreenState();
}

class _FullPlayerScreenState extends State<FullPlayerScreen> {
  bool _isDragging = false;
  final double _dragPosition = 0.0;
  double _verticalDragStart = 0.0;
  double _horizontalDragStart = 0.0;

  void _showTimerToast(Duration duration) {
    final overlay = Overlay.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String toastText;
    if (duration.inSeconds == -1) {
      toastText = 'Sleep timer is off ';
    } else if (duration.inHours > 0 &&
        duration.inMinutes % 60 > 0 &&
        duration.inSeconds % 60 > 0) {
      toastText =
          'Timer set for ${duration.inHours}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')} ';
    } else if (duration.inHours > 0 && duration.inMinutes % 60 > 0) {
      toastText =
          'Timer set for ${duration.inHours}h ${(duration.inMinutes % 60)}m ';
    } else if (duration.inHours > 0) {
      toastText =
          'Timer set for ${duration.inHours} hour${duration.inHours > 1 ? 's' : ''} ';
    } else if (duration.inMinutes > 0 && duration.inSeconds % 60 > 0) {
      toastText =
          'Timer set for ${duration.inMinutes}m ${(duration.inSeconds % 60)}s ';
    } else if (duration.inMinutes > 0) {
      toastText =
          'Timer set for ${duration.inMinutes} minute${duration.inMinutes > 1 ? 's' : ''} ';
    } else if (duration.inSeconds > 0) {
      toastText =
          'Timer set for ${duration.inSeconds} second${duration.inSeconds > 1 ? 's' : ''} ';
    } else {
      toastText = 'Timer set';
    }
    final toast = OverlayEntry(
      builder: (context) => Positioned(
        top: 48,
        left: 32,
        right: 32,
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(maxWidth: 220),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF232323) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 7,
                  offset: Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: isDark
                    ? const Color(0xFFFFA726)
                    : const Color(0xFFFF7043),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  toastText,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const Text('⏰', style: TextStyle(fontSize: 15)),
              ],
            ),
          ),
        ),
      ),
    );
    overlay.insert(toast);
    Future.delayed(const Duration(seconds: 2), () {
      toast.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Selector<MusicPlayerProvider, Song?>(
      selector: (_, provider) => provider.currentSong,
      builder: (context, currentSong, _) {
        if (currentSong == null) {
          Navigator.of(context).pop();
          return const SizedBox.shrink();
        }
        double dragDistance = 0.0;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onVerticalDragStart: (details) {
            _verticalDragStart = details.globalPosition.dy;
            dragDistance = 0.0;
          },
          onVerticalDragUpdate: (details) {
            dragDistance = details.globalPosition.dy - _verticalDragStart;
          },
          onVerticalDragEnd: (details) {
            // Thresholds for swipe actions
            const closeThreshold = 80.0;
            const lyricsThreshold = -80.0;
            if (dragDistance > closeThreshold) {
              Navigator.of(context).pop();
            } else if (dragDistance < lyricsThreshold) {
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
                                    Color.lerp(
                                      dominantColor,
                                      vibrantColor,
                                      0.6,
                                    )!,
                                    vibrantColor,
                                    Color.lerp(
                                      vibrantColor,
                                      Colors.black,
                                      0.4,
                                    )!,
                                    const Color(0xFF000000),
                                  ]
                                : [
                                    Color.lerp(
                                      dominantColor,
                                      Colors.white,
                                      0.2,
                                    )!,
                                    dominantColor,
                                    Color.lerp(
                                      dominantColor,
                                      vibrantColor,
                                      0.5,
                                    )!,
                                    vibrantColor,
                                    Color.lerp(
                                      vibrantColor,
                                      Colors.black,
                                      0.2,
                                    )!,
                                  ],
                            stops: isDark
                                ? [0.0, 0.25, 0.5, 0.75, 1.0]
                                : [0.0, 0.2, 0.5, 0.75, 1.0],
                          ),
                        ),
                        child: _buildPlayerContent(
                          context,
                          Provider.of<MusicPlayerProvider>(
                            context,
                            listen: false,
                          ),
                          currentSong,
                          isDark,
                        ),
                      );
                    },
                  )
                : Container(),
          ),
        );
      },
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
                              SizedBox(
                                height: 22,
                                width: 200, // was 140, now more space
                                child: ShaderMask(
                                  shaderCallback: (Rect bounds) {
                                    return LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        Colors.transparent,
                                        Colors.white,
                                        Colors.white,
                                        Colors.transparent,
                                      ],
                                      stops: const [0.0, 0.08, 0.92, 1.0],
                                    ).createShader(bounds);
                                  },
                                  blendMode: BlendMode.dstIn,
                                  child: _MarqueeText(
                                    text: currentSong.album ?? '',
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white
                                          : Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    velocity: 32.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.equalizer_rounded,
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
                        child: Selector<MusicPlayerProvider, String?>(
                          selector: (_, provider) =>
                              provider.getCustomArtForSong(currentSong.id),
                          builder: (context, customArtPath, _) {
                            return Hero(
                              tag:
                                  'album_art_${currentSong.id}_${customArtPath ?? ''}',
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
                                      child: (() {
                                        if (customArtPath != null &&
                                            customArtPath.isNotEmpty) {
                                          return Image.file(
                                            File(customArtPath),
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                            errorBuilder:
                                                (
                                                  context,
                                                  error,
                                                  stackTrace,
                                                ) => Container(
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
                                          );
                                        } else if (currentSong.albumArt !=
                                            null) {
                                          return CachedArtworkWidget(
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
                                          );
                                        } else {
                                          return Container(
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
                                          );
                                        }
                                      }()),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
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
                                        fontSize: 18, // reduced from 22
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
                                        fontSize: 15, // reduced from 18
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  Selector<MusicPlayerProvider, bool>(
                                    selector: (_, provider) =>
                                        provider.isFavorite(currentSong.id),
                                    builder: (context, isFavorite, _) {
                                      return IconButton(
                                        onPressed: () {
                                          Provider.of<MusicPlayerProvider>(
                                            context,
                                            listen: false,
                                          ).toggleFavorite(currentSong.id);
                                        },
                                        icon: Icon(
                                          isFavorite
                                              ? Icons.favorite_rounded
                                              : Icons.favorite_border_rounded,
                                          color: Colors.white,
                                          size: 26,
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    onPressed: () {
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
                                          return SongOptionsSheet(
                                            song: currentSong,
                                            isDark: isDark,
                                            playerProvider: playerProvider,
                                            onShowTimerToast:
                                                _showTimerToast, // Pass the toast callback
                                          );
                                        },
                                      );
                                    },
                                    icon: Icon(
                                      Icons.more_vert_rounded,
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
                          // Slider above
                          PositionIndicator(
                            positionNotifier: playerProvider.positionNotifier,
                            duration: currentSong.duration,
                            isDark: isDark,
                            onSeek: (value) {
                              setState(() {
                                _isDragging = false;
                              });
                              playerProvider.seekTo(
                                Duration(milliseconds: value.toInt()),
                              );
                            },
                          ),
                          // Time below
                          ValueListenableBuilder<Duration>(
                            valueListenable: playerProvider.positionNotifier,
                            builder: (context, position, _) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .center, // Center both times
                                children: [
                                  Text(
                                    _formatDuration(position),
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 13,
                                    ),
                                  ),
                                  SizedBox(width: 240),
                                  Text(
                                    _formatDuration(currentSong.duration),
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              );
                            },
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
                          Selector<MusicPlayerProvider, bool>(
                            selector: (_, provider) => provider.isShuffle,
                            builder: (context, isShuffle, _) {
                              return IconButton(
                                onPressed: () => playerProvider.toggleShuffle(),
                                icon: Icon(
                                  Icons.shuffle_rounded,
                                  color: isShuffle
                                      ? (isDark
                                            ? const Color(0xFFFFA726)
                                            : Colors.white)
                                      : (isDark ? Colors.white : Colors.white)
                                            .withOpacity(0.5),
                                  size: 28,
                                ),
                                padding: EdgeInsets.zero,
                              );
                            },
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
                          Selector<MusicPlayerProvider, bool>(
                            selector: (_, provider) => provider.isPlaying,
                            builder: (context, isPlaying, _) {
                              return IconButton(
                                onPressed: () =>
                                    playerProvider.togglePlayPause(),
                                icon: Icon(
                                  isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  color: isDark ? Colors.white : Colors.white,
                                  size: 70,
                                ),
                                padding: EdgeInsets.zero,
                              );
                            },
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
                          Selector<MusicPlayerProvider, RepeatMode>(
                            selector: (_, provider) => provider.repeatMode,
                            builder: (context, repeatMode, _) {
                              return IconButton(
                                onPressed: () =>
                                    playerProvider.cycleRepeatMode(),
                                icon: Icon(
                                  repeatMode == RepeatMode.one
                                      ? Icons.repeat_one_rounded
                                      : Icons.repeat_rounded,
                                  color: repeatMode != RepeatMode.off
                                      ? (isDark
                                            ? const Color(0xFFFFA726)
                                            : Colors.white)
                                      : (isDark ? Colors.white : Colors.white)
                                            .withOpacity(0.5),
                                  size: 28,
                                ),
                                padding: EdgeInsets.zero,
                              );
                            },
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
    return '${duration.inHours > 0 ? '${twoDigits(duration.inHours)}:' : ''}$minutes:$seconds';
  }
}

class _MarqueeText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final double velocity;

  const _MarqueeText({
    Key? key,
    required this.text,
    required this.style,
    this.velocity = 32.0,
  }) : super(key: key);

  @override
  State<_MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<_MarqueeText>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final AnimationController _controller;
  double _textWidth = 0;
  double _containerWidth = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _startMarquee());
  }

  @override
  void didUpdateWidget(covariant _MarqueeText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      // Reset scroll position and restart animation when text changes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }
        _startMarquee();
      });
    }
  }

  void _startMarquee() async {
    setState(() {});
    await Future.delayed(const Duration(milliseconds: 100));
    final RenderBox? textBox = context.findRenderObject() as RenderBox?;
    if (textBox != null) {
      _containerWidth = textBox.size.width;
    }
    final painter = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    _textWidth = painter.width;
    if (_textWidth > _containerWidth) {
      final distance = _textWidth - _containerWidth;
      while (mounted) {
        await _scrollController.animateTo(
          distance,
          duration: Duration(
            milliseconds: (distance / widget.velocity * 1000).toInt(),
          ),
          curve: Curves.linear,
        );
        await Future.delayed(const Duration(milliseconds: 800));
        await _scrollController.animateTo(
          0,
          duration: Duration(
            milliseconds: (distance / widget.velocity * 1000).toInt(),
          ),
          curve: Curves.linear,
        );
        await Future.delayed(const Duration(milliseconds: 800));
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _containerWidth = constraints.maxWidth;
        final painter = TextPainter(
          text: TextSpan(text: widget.text, style: widget.style),
          maxLines: 1,
          textDirection: TextDirection.ltr,
        )..layout();
        final textWidth = painter.width;

        // If text fits, center it; otherwise scroll
        if (textWidth <= _containerWidth) {
          return Center(
            child: Text(
              widget.text,
              style: widget.style,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          );
        } else {
          return SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            child: Text(
              widget.text,
              style: widget.style,
              maxLines: 1,
              overflow: TextOverflow.visible,
            ),
          );
        }
      },
    );
  }
}
