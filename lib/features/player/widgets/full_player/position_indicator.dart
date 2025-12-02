import 'package:flutter/material.dart';

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
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Duration>(
      valueListenable: positionNotifier,
      builder: (context, position, _) {
        return Slider(
          value: position.inMilliseconds
              .clamp(0, duration.inMilliseconds)
              .toDouble(),
          min: 0.0,
          max: duration.inMilliseconds.toDouble(),
          activeColor: Colors.white,
          inactiveColor: Colors.white24,
          onChanged: onSeek,
        );
      },
    );
  }
}
