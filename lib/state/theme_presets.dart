import 'package:flutter/material.dart';

enum ThemePreset {
  subtracks,
  spotify,
  pandora,
  youtube,
  classic,
  ocean,
  sunset,
  forest,
  custom,
}

class ThemePresetConfig {
  final String name;
  final String description;
  final Color seedColor;
  final bool enableDynamicColors;

  const ThemePresetConfig({
    required this.name,
    required this.description,
    required this.seedColor,
    this.enableDynamicColors = true,
  });
}

const Map<String, ThemePresetConfig> themePresets = {
  'subtracks': ThemePresetConfig(
    name: 'Subtracks Default',
    description: 'Original purple theme',
    seedColor: Color(0xFF6A1B9A), // Colors.purple[800]
    enableDynamicColors: true,
  ),
  'spotify': ThemePresetConfig(
    name: 'Spotify Inspired',
    description: 'Vibrant green theme',
    seedColor: Color(0xFF1DB954),
    enableDynamicColors: true,
  ),
  'pandora': ThemePresetConfig(
    name: 'Pandora Inspired',
    description: 'Classic blue theme',
    seedColor: Color(0xFF005483),
    enableDynamicColors: true,
  ),
  'youtube': ThemePresetConfig(
    name: 'YouTube Music',
    description: 'Bold red theme',
    seedColor: Color(0xFFD32F2F), // Colors.red[700]
    enableDynamicColors: true,
  ),
  'classic': ThemePresetConfig(
    name: 'Classic Dark',
    description: 'Neutral gray theme',
    seedColor: Color(0xFF424242), // Colors.grey[800]
    enableDynamicColors: true,
  ),
  'ocean': ThemePresetConfig(
    name: 'Ocean Wave',
    description: 'Calming teal theme',
    seedColor: Color(0xFF00796B), // Colors.teal[700]
    enableDynamicColors: true,
  ),
  'sunset': ThemePresetConfig(
    name: 'Sunset',
    description: 'Warm orange theme',
    seedColor: Color(0xFFEF6C00), // Colors.orange[800]
    enableDynamicColors: true,
  ),
  'forest': ThemePresetConfig(
    name: 'Forest',
    description: 'Natural green theme',
    seedColor: Color(0xFF558B2F), // Colors.lightGreen[800]
    enableDynamicColors: true,
  ),
};

ThemePresetConfig getThemePreset(String presetKey) {
  return themePresets[presetKey] ?? themePresets['subtracks']!;
}

Color getPresetSeedColor(String presetKey, [int? customColor]) {
  if (presetKey == 'custom' && customColor != null) {
    return Color(customColor);
  }
  return getThemePreset(presetKey).seedColor;
}
