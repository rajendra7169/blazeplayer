import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

class CachedArtworkWidget extends StatefulWidget {
  final String songId;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget fallback;

  const CachedArtworkWidget({
    super.key,
    required this.songId,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    required this.fallback,
  });

  @override
  State<CachedArtworkWidget> createState() => _CachedArtworkWidgetState();
}

class _CachedArtworkWidgetState extends State<CachedArtworkWidget> {
  static final Map<String, ImageProvider?> _imageCache = {};

  @override
  void initState() {
    super.initState();
    // Only load if not in cache
    if (!_imageCache.containsKey(widget.songId)) {
      _loadArtwork();
    }
  }

  @override
  void didUpdateWidget(CachedArtworkWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.songId != widget.songId) {
      if (!_imageCache.containsKey(widget.songId)) {
        _loadArtwork();
      }
    }
  }

  Future<void> _loadArtwork() async {
    try {
      final audioQuery = OnAudioQuery();
      final artwork = await audioQuery.queryArtwork(
        int.parse(widget.songId),
        ArtworkType.AUDIO,
        quality: 50,
        size: 400,
      );

      if (artwork != null && mounted) {
        final imageProvider = MemoryImage(artwork);
        _imageCache[widget.songId] = imageProvider;
        setState(() {});
      } else if (mounted) {
        _imageCache[widget.songId] = null;
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        _imageCache[widget.songId] = null;
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check cache synchronously - this prevents placeholder flashing
    final cachedImage = _imageCache[widget.songId];

    if (cachedImage == null && !_imageCache.containsKey(widget.songId)) {
      // Still loading, show fallback
      return widget.fallback;
    }

    if (cachedImage == null) {
      // Cached as null (no artwork), show fallback
      return widget.fallback;
    }

    // Cached image exists, display it
    Widget imageWidget = Image(
      image: cachedImage,
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
      gaplessPlayback: true, // Prevents blinking
      filterQuality: FilterQuality.low,
      errorBuilder: (context, error, stackTrace) => widget.fallback,
    );

    if (widget.borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: widget.borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}
