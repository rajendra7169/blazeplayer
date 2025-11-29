import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/music_player_provider.dart';

class SleepTimerSheet extends StatefulWidget {
  final bool isDark;
  final Function(Duration) onSetTimer;
  final void Function(Duration)? onShowTimerToast;
  final Duration initialDuration;
  const SleepTimerSheet({
    super.key,
    required this.isDark,
    required this.onSetTimer,
    this.onShowTimerToast,
    this.initialDuration = Duration.zero,
  });

  @override
  State<SleepTimerSheet> createState() => _SleepTimerSheetState();
}

class _SleepTimerSheetState extends State<SleepTimerSheet>
    with SingleTickerProviderStateMixin {
  Duration _selectedDuration = Duration.zero;
  final List<int> fixedMinutes = [15, 30, 45, 60];
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<MusicPlayerProvider>(context, listen: false);
    // Defensive: fallback to initialDuration if getter missing or null
    try {
      if (provider.isSleepTimerActive && provider.sleepTimerDuration != null) {
        _selectedDuration = provider.sleepTimerDuration!;
      } else {
        _selectedDuration = widget.initialDuration;
      }
    } catch (e) {
      _selectedDuration = widget.initialDuration;
    }
    _startLiveCountdown();
  }

  void _startLiveCountdown() {
    _countdownTimer?.cancel();
    final provider = Provider.of<MusicPlayerProvider>(context, listen: false);
    if (provider.isSleepTimerActive) {
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
        if (!provider.isSleepTimerActive) {
          _countdownTimer?.cancel();
        }
      });
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _setTimer(Duration duration) {
    final provider = Provider.of<MusicPlayerProvider>(context, listen: false);
    provider.setSleepTimer(duration);
    Navigator.of(context).pop();
    widget.onShowTimerToast?.call(duration);
  }

  void _endTimer() {
    final provider = Provider.of<MusicPlayerProvider>(context, listen: false);
    provider.cancelSleepTimer();
    Navigator.of(context).pop();
    widget.onShowTimerToast?.call(Duration(seconds: -1));
  }

  void _resetTimer() {
    final provider = Provider.of<MusicPlayerProvider>(context, listen: false);
    provider.cancelSleepTimer();
    setState(() {
      _selectedDuration = widget.initialDuration;
      // Optionally, you can reset other state if needed
    });
    // No need to pop and reopen the sheet
  }

  Widget _buildTimePicker() {
    int hours = _selectedDuration.inHours;
    int minutes = _selectedDuration.inMinutes % 60;
    int seconds = _selectedDuration.inSeconds % 60;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildPicker(hours, 23, (val) {
              setState(() {
                _selectedDuration = Duration(
                  hours: val,
                  minutes: minutes,
                  seconds: seconds,
                );
              });
            }),
            const SizedBox(width: 12),
            _buildPicker(minutes, 59, (val) {
              setState(() {
                _selectedDuration = Duration(
                  hours: hours,
                  minutes: val,
                  seconds: seconds,
                );
              });
            }),
            const SizedBox(width: 12),
            _buildPicker(seconds, 59, (val) {
              setState(() {
                _selectedDuration = Duration(
                  hours: hours,
                  minutes: minutes,
                  seconds: val,
                );
              });
            }),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
          style: TextStyle(
            fontSize: 44,
            fontWeight: FontWeight.bold,
            color: widget.isDark ? Colors.white : Colors.black87,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildPicker(int value, int max, ValueChanged<int> onChanged) {
    return SizedBox(
      width: 72,
      height: 200,
      child: ListWheelScrollView.useDelegate(
        itemExtent: 48,
        diameterRatio: 1.2,
        perspective: 0.005,
        physics: FixedExtentScrollPhysics(),
        onSelectedItemChanged: onChanged,
        childDelegate: ListWheelChildBuilderDelegate(
          builder: (context, idx) {
            if (idx < 0 || idx > max) return null;
            double opacity;
            double fontSize;
            FontWeight fontWeight;
            int distance = (idx - value).abs();
            if (distance == 0) {
              opacity = 1.0;
              fontSize = 38;
              fontWeight = FontWeight.bold;
            } else if (distance == 1) {
              opacity = 0.5;
              fontSize = 22;
              fontWeight = FontWeight.normal;
            } else if (distance == 2) {
              opacity = 0.25;
              fontSize = 16;
              fontWeight = FontWeight.normal;
            } else {
              opacity = 0.12;
              fontSize = 14;
              fontWeight = FontWeight.normal;
            }
            return Center(
              child: Opacity(
                opacity: opacity,
                child: Text(
                  idx.toString().padLeft(2, '0'),
                  style: TextStyle(
                    fontSize: fontSize,
                    color: widget.isDark ? Colors.white : Colors.black87,
                    fontWeight: fontWeight,
                  ),
                ),
              ),
            );
          },
          childCount: max + 1,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MusicPlayerProvider>(context);
    final themeColor = widget.isDark
        ? const Color(0xFFFFA726)
        : const Color(0xFFFF7043);
    final isTimerActive = provider.isSleepTimerActive;
    final countdown = provider.sleepTimerRemaining;
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Stop music after',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: widget.isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          if (!isTimerActive) ...[
            _buildTimePicker(),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: fixedMinutes
                  .map(
                    (min) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedDuration.inMinutes == min
                              ? themeColor
                              : (widget.isDark
                                    ? const Color(0xFF181818)
                                    : const Color(0xFFF2F2F2)),
                          foregroundColor: _selectedDuration.inMinutes == min
                              ? Colors.white
                              : (widget.isDark ? Colors.white : Colors.black87),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          elevation: _selectedDuration.inMinutes == min ? 2 : 4,
                          shadowColor: _selectedDuration.inMinutes == min
                              ? themeColor.withOpacity(0.3)
                              : Colors.black26,
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedDuration = Duration(minutes: min);
                          });
                        },
                        child: Text(
                          '${min}m',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Container(
                    height: 54,
                    margin: const EdgeInsets.only(right: 12),
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: widget.isDark
                            ? const Color(0xFF232323)
                            : Colors.white,
                        foregroundColor: widget.isDark
                            ? Colors.white
                            : Colors.black87,
                        side: BorderSide(
                          color: widget.isDark
                              ? const Color(0xFFFFA726)
                              : const Color(0xFFFF7043),
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'CANCEL',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 54,
                    margin: const EdgeInsets.only(left: 12),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.isDark
                            ? const Color(0xFFFFA726)
                            : const Color(0xFFFF7043),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      onPressed: _selectedDuration > Duration.zero
                          ? () => _setTimer(_selectedDuration)
                          : null,
                      child: const Text(
                        'START',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 8),
            Text(
              '${countdown.inHours.toString().padLeft(2, '0')}:${(countdown.inMinutes % 60).toString().padLeft(2, '0')}:${(countdown.inSeconds % 60).toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.bold,
                color: widget.isDark ? Colors.white : Colors.black87,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Container(
                    height: 54,
                    margin: const EdgeInsets.only(right: 12),
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: widget.isDark
                            ? const Color(0xFF232323)
                            : Colors.white,
                        foregroundColor: widget.isDark
                            ? Colors.white
                            : Colors.black87,
                        side: BorderSide(
                          color: widget.isDark
                              ? const Color(0xFFFFA726)
                              : const Color(0xFFFF7043),
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _endTimer,
                      child: const Text(
                        'END',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 54,
                    margin: const EdgeInsets.only(left: 12),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.isDark
                            ? const Color(0xFFFFA726)
                            : const Color(0xFFFF7043),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      onPressed: _resetTimer,
                      child: const Text(
                        'RESET',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
