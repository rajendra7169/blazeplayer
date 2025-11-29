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
    Key? key,
  }) : super(key: key);

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
