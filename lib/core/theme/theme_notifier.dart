import 'package:flutter/material.dart';

class ThemeNotifier extends ValueNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system);

  void setDark() => value = ThemeMode.dark;
  void setLight() => value = ThemeMode.light;
}
