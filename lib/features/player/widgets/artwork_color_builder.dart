import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:palette_generator/palette_generator.dart';

class ArtworkColorBuilder extends StatefulWidget {
  final String songId;
  final Widget Function(Color dominantColor, Color vibrantColor) builder;

  const ArtworkColorBuilder({
    super.key,
    required this.songId,
    required this.builder,
  });

  @override
  State<ArtworkColorBuilder> createState() => _ArtworkColorBuilderState();
}

class _ArtworkColorBuilderState extends State<ArtworkColorBuilder> {
  static final Map<String, ColorPair> _colorCache = {};
  Color _dominantColor = const Color(0xFF2D2D2D);
  Color _vibrantColor = const Color(0xFF1A1A1A);
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _extractColors();
  }

  @override
  void didUpdateWidget(ArtworkColorBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.songId != widget.songId) {
      _extractColors();
    }
  }

  Future<void> _extractColors() async {
    // Check cache first
    if (_colorCache.containsKey(widget.songId)) {
      final cached = _colorCache[widget.songId]!;
      if (mounted) {
        setState(() {
          _dominantColor = cached.dominant;
          _vibrantColor = cached.vibrant;
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final audioQuery = OnAudioQuery();
      final artwork = await audioQuery.queryArtwork(
        int.parse(widget.songId),
        ArtworkType.AUDIO,
        quality: 50,
        size: 300,
      );

      if (artwork != null && mounted) {
        final paletteGenerator = await PaletteGenerator.fromImageProvider(
          MemoryImage(artwork),
          maximumColorCount: 20,
        );

        // Extract multiple colors for better gradient
        Color color1 =
            paletteGenerator.dominantColor?.color ??
            paletteGenerator.vibrantColor?.color ??
            const Color(0xFF2D2D2D);

        Color color2 =
            paletteGenerator.darkVibrantColor?.color ??
            paletteGenerator.mutedColor?.color ??
            paletteGenerator.lightVibrantColor?.color ??
            const Color(0xFF1A1A1A);

        // Make sure colors are different enough
        if (_colorsSimilar(color1, color2)) {
          // Find a contrasting color
          color2 =
              paletteGenerator.lightMutedColor?.color ??
              paletteGenerator.darkMutedColor?.color ??
              Color.lerp(color1, Colors.black, 0.5)!;
        }

        // Keep colors more vibrant - less darkening for better visual appeal
        final dominantColor = Color.lerp(color1, Colors.black, 0.15)!;
        final vibrantColor = Color.lerp(color2, Colors.black, 0.20)!;

        // Cache the colors
        _colorCache[widget.songId] = ColorPair(
          dominant: dominantColor,
          vibrant: vibrantColor,
        );

        if (mounted) {
          setState(() {
            _dominantColor = dominantColor;
            _vibrantColor = vibrantColor;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error extracting colors: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _colorsSimilar(Color c1, Color c2) {
    final rDiff = (c1.red - c2.red).abs();
    final gDiff = (c1.green - c2.green).abs();
    final bDiff = (c1.blue - c2.blue).abs();
    return (rDiff + gDiff + bDiff) <
        100; // Similar if total difference is small
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(_dominantColor, _vibrantColor);
  }
}

class ColorPair {
  final Color dominant;
  final Color vibrant;

  ColorPair({required this.dominant, required this.vibrant});
}
