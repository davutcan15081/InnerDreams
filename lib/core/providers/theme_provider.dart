import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

// App theme type provider
final appThemeTypeProvider = StateNotifierProvider<AppThemeTypeNotifier, AppThemeType>((ref) {
  return AppThemeTypeNotifier();
});

class AppThemeTypeNotifier extends StateNotifier<AppThemeType> {
  AppThemeTypeNotifier() : super(AppThemeType.light) {
    _loadThemeType();
  }

  // Load theme type from SharedPreferences
  Future<void> _loadThemeType() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeTypeString = prefs.getString('app_theme_type');
      
      if (themeTypeString != null) {
        switch (themeTypeString) {
          case 'light':
            state = AppThemeType.light;
            break;
          case 'dark':
            state = AppThemeType.dark;
            break;
          case 'purpleDark':
            state = AppThemeType.purpleDark;
            break;
          case 'ocean':
            state = AppThemeType.ocean;
            break;
          case 'forest':
            state = AppThemeType.forest;
            break;
          case 'sunset':
            state = AppThemeType.sunset;
            break;
          case 'midnight':
            state = AppThemeType.midnight;
            break;
          case 'cherry':
            state = AppThemeType.cherry;
            break;
          default:
            state = AppThemeType.light;
            break;
        }
      }
    } catch (e) {
      print('App theme type load error: $e');
      state = AppThemeType.light;
    }
  }

  // Save theme type to SharedPreferences
  Future<void> _saveThemeType(AppThemeType themeType) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String themeTypeString;
      
      switch (themeType) {
        case AppThemeType.light:
          themeTypeString = 'light';
          break;
        case AppThemeType.dark:
          themeTypeString = 'dark';
          break;
        case AppThemeType.purpleDark:
          themeTypeString = 'purpleDark';
          break;
        case AppThemeType.ocean:
          themeTypeString = 'ocean';
          break;
        case AppThemeType.forest:
          themeTypeString = 'forest';
          break;
        case AppThemeType.sunset:
          themeTypeString = 'sunset';
          break;
        case AppThemeType.midnight:
          themeTypeString = 'midnight';
          break;
        case AppThemeType.cherry:
          themeTypeString = 'cherry';
          break;
      }
      
      await prefs.setString('app_theme_type', themeTypeString);
    } catch (e) {
      print('App theme type save error: $e');
    }
  }

  // Set theme type
  Future<void> setThemeType(AppThemeType themeType) async {
    state = themeType;
    await _saveThemeType(themeType);
  }

  // Get all available theme types
  List<AppThemeType> get allThemeTypes => AppThemeType.values;

  // Get theme name
  String getThemeName(AppThemeType themeType) => AppTheme.getThemeName(themeType);

  // Get theme description
  String getThemeDescription(AppThemeType themeType) => AppTheme.getThemeDescription(themeType);
}

// Theme data provider
final themeDataProvider = Provider<ThemeData>((ref) {
  final themeType = ref.watch(appThemeTypeProvider);
  return AppTheme.getTheme(themeType);
});

// Light theme data provider
final lightThemeDataProvider = Provider<ThemeData>((ref) {
  return AppTheme.lightTheme;
});

// Dark theme data provider
final darkThemeDataProvider = Provider<ThemeData>((ref) {
  return AppTheme.darkTheme;
});

// Purple dark theme data provider
final purpleDarkThemeDataProvider = Provider<ThemeData>((ref) {
  return AppTheme.purpleDarkTheme;
});

// Ocean theme data provider
final oceanThemeDataProvider = Provider<ThemeData>((ref) {
  return AppTheme.oceanTheme;
});

// Forest theme data provider
final forestThemeDataProvider = Provider<ThemeData>((ref) {
  return AppTheme.forestTheme;
});

// Sunset theme data provider
final sunsetThemeDataProvider = Provider<ThemeData>((ref) {
  return AppTheme.sunsetTheme;
});
