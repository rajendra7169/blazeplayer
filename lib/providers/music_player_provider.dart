import 'package:flutter/material.dart';

class MusicPlayerProvider extends ChangeNotifier {
  Duration? _sleepTimerDuration;
  bool _isSleepTimerActive = false;
  Duration _sleepTimerRemaining = Duration.zero;

  Duration? get sleepTimerDuration => _sleepTimerDuration;
  bool get isSleepTimerActive => _isSleepTimerActive;
  Duration get sleepTimerRemaining => _sleepTimerRemaining;

  void setSleepTimer(Duration duration) {
    _sleepTimerDuration = duration;
    _sleepTimerRemaining = duration;
    _isSleepTimerActive = true;
    notifyListeners();
    // Start timer logic here
  }

  void cancelSleepTimer() {
    _isSleepTimerActive = false;
    _sleepTimerRemaining = Duration.zero;
    notifyListeners();
    // Cancel timer logic here
  }

  // Add other music player logic here
}
