import 'dart:io';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

class CachedArtworkWidget extends StatefulWidget {
  final String albumArt; // Accepts albumArt string (URL, file path, or songId)
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget fallback;

  const CachedArtworkWidget({
    super.key,
    required this.albumArt,
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
  ImageProvider? _imageProvider;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadArtwork();
  }

  @override
  void didUpdateWidget(CachedArtworkWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.albumArt != widget.albumArt) {
      _loadArtwork();
    }
  }

  Future<void> _loadArtwork() async {
    final art = widget.albumArt;
    if (art.isEmpty) {
      setState(() {
        _imageProvider = null;
        _isLoading = false;
      });
      return;
    }
    // Network image
    if (art.startsWith('http')) {
      setState(() {
        _imageProvider = NetworkImage(art);
        _isLoading = false;
      });
      return;
    }
    // Local file
    if (art.startsWith('/') || art.contains(':\\')) {
      setState(() {
        _imageProvider = FileImage(File(art));
        _isLoading = false;
      });
      return;
    }
    // Fallback to songId artwork
    if (_imageCache.containsKey(art)) {
      setState(() {
        _imageProvider = _imageCache[art];
        _isLoading = false;
      });
      return;
    }
    try {
      final audioQuery = OnAudioQuery();
      final artwork = await audioQuery.queryArtwork(
        int.tryParse(art) ?? 0,
        ArtworkType.AUDIO,
        quality: 50,
        size: 400,
      );
      if (artwork != null && mounted) {
        _imageProvider = MemoryImage(artwork);
        _imageCache[art] = _imageProvider;
      }
    } catch (e) {
      _imageProvider = null;
      _imageCache[art] = null;
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _imageProvider == null) {
      return widget.fallback;
    }
    Widget imageWidget = Image(
      image: _imageProvider!,
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
      gaplessPlayback: true,
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
