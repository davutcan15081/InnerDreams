import 'package:flutter/material.dart';

enum AppThemeType {
  light,
  dark,
  purpleDark,
  ocean,
  forest,
  sunset,
  midnight,
  cherry,
}

class AppTheme {
  // Primary Colors - Modern Mor/Violet Paleti
  static const Color primaryColor = Color(0xFF8B5CF6);
  static const Color secondaryColor = Color(0xFFA855F7);
  static const Color tertiaryColor = Color(0xFFC084FC);
  static const Color accentColor = Color(0xFFE879F9);
  
  // Altın Vurgu Renkleri
  static const Color goldColor = Color(0xFFFFD700);
  static const Color lightGoldColor = Color(0xFFFFF8DC);
  static const Color roseGoldColor = Color(0xFFE6B8A2);
  
  // Status Colors - Modern Paleti
  static const Color errorColor = Color(0xFFEF4444);
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color infoColor = Color(0xFF3B82F6);
  
  // ============ AYDINLIK TEMA ============
  static const Color lightBackground = Color(0xFFFAF8FF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightOnSurface = Color(0xFF1E1B4B);
  static const Color lightOnBackground = Color(0xFF312E81);
  static const Color lightCardColor = Color(0xFFF5F3FF);
  static const Color lightBorderColor = Color(0xFFDDD6FE);
  
  // ============ KARANLIK TEMA ============
  static const Color darkBackground = Color(0xFF0F0F14);
  static const Color darkSurface = Color(0xFF18181B);
  static const Color darkOnSurface = Color(0xFFF4F4F5);
  static const Color darkOnBackground = Color(0xFFE4E4E7);
  static const Color darkCardColor = Color(0xFF27272A);
  static const Color darkBorderColor = Color(0xFF3F3F46);
  static const Color darkAccent = Color(0xFF8B5CF6);

  // ============ MOR KARANLIK TEMA ============
  static const Color purpleDarkBackground = Color(0xFF0A0A0F);
  static const Color purpleDarkSurface = Color(0xFF1C1625);
  static const Color purpleDarkOnSurface = Color(0xFFFFD700);
  static const Color purpleDarkOnBackground = Color(0xFFFFF8DC);
  static const Color purpleDarkCardColor = Color(0xFF2D1F3D);
  static const Color purpleDarkBorderColor = Color(0xFF7C3AED);
  static const Color purpleDarkAccent = Color(0xFF9333EA);

  // ============ OKYANUS TEMA ============
  static const Color oceanBackground = Color(0xFF001219);
  static const Color oceanSurface = Color(0xFF002838);
  static const Color oceanOnSurface = Color(0xFF7DD3FC);
  static const Color oceanOnBackground = Color(0xFFBAE6FD);
  static const Color oceanCardColor = Color(0xFF003D5C);
  static const Color oceanBorderColor = Color(0xFF0284C7);
  static const Color oceanAccent = Color(0xFF06B6D4);

  // ============ ORMAN TEMA ============
  static const Color forestBackground = Color(0xFF0C1810);
  static const Color forestSurface = Color(0xFF1A2E1A);
  static const Color forestOnSurface = Color(0xFF86EFAC);
  static const Color forestOnBackground = Color(0xFFBBF7D0);
  static const Color forestCardColor = Color(0xFF2D4A2D);
  static const Color forestBorderColor = Color(0xFF16A34A);
  static const Color forestAccent = Color(0xFF22C55E);

  // ============ GÜN BATIMI TEMA ============
  static const Color sunsetBackground = Color(0xFF1C0F0A);
  static const Color sunsetSurface = Color(0xFF2D1810);
  static const Color sunsetOnSurface = Color(0xFFFEBBAF);
  static const Color sunsetOnBackground = Color(0xFFFED7AA);
  static const Color sunsetCardColor = Color(0xFF3D2317);
  static const Color sunsetBorderColor = Color(0xFFEA580C);
  static const Color sunsetAccent = Color(0xFFF97316);

  // ============ GECE YARISI TEMA ============
  static const Color midnightBackground = Color(0xFF050B1F);
  static const Color midnightSurface = Color(0xFF0F1729);
  static const Color midnightOnSurface = Color(0xFF818CF8);
  static const Color midnightOnBackground = Color(0xFFC7D2FE);
  static const Color midnightCardColor = Color(0xFF1E293B);
  static const Color midnightBorderColor = Color(0xFF4F46E5);
  static const Color midnightAccent = Color(0xFF6366F1);

  // ============ KİRAZ ÇİÇEĞİ TEMA ============
  static const Color cherryBackground = Color(0xFF1A0614);
  static const Color cherrySurface = Color(0xFF2D0F26);
  static const Color cherryOnSurface = Color(0xFFFDA4AF);
  static const Color cherryOnBackground = Color(0xFFFECDD3);
  static const Color cherryCardColor = Color(0xFF3D1733);
  static const Color cherryBorderColor = Color(0xFFDB2777);
  static const Color cherryAccent = Color(0xFFEC4899);

  static ThemeData getTheme(AppThemeType themeType) {
    switch (themeType) {
      case AppThemeType.light:
        return lightTheme;
      case AppThemeType.dark:
        return darkTheme;
      case AppThemeType.purpleDark:
        return purpleDarkTheme;
      case AppThemeType.ocean:
        return oceanTheme;
      case AppThemeType.forest:
        return forestTheme;
      case AppThemeType.sunset:
        return sunsetTheme;
      case AppThemeType.midnight:
        return midnightTheme;
      case AppThemeType.cherry:
        return cherryTheme;
    }
  }

  static String getThemeName(AppThemeType themeType) {
    switch (themeType) {
      case AppThemeType.light:
        return 'Aydınlık';
      case AppThemeType.dark:
        return 'Karanlık';
      case AppThemeType.purpleDark:
        return 'Mor Gecesi';
      case AppThemeType.ocean:
        return 'Okyanus';
      case AppThemeType.forest:
        return 'Orman';
      case AppThemeType.sunset:
        return 'Gün Batımı';
      case AppThemeType.midnight:
        return 'Gece Yarısı';
      case AppThemeType.cherry:
        return 'Kiraz Çiçeği';
    }
  }

  static String getThemeDescription(AppThemeType themeType) {
    switch (themeType) {
      case AppThemeType.light:
        return 'Ferah lavanta ve beyaz tonları';
      case AppThemeType.dark:
        return 'Modern minimal karanlık tema';
      case AppThemeType.purpleDark:
        return 'Altın detaylı lüks mor tema';
      case AppThemeType.ocean:
        return 'Derin deniz mavisi tonları';
      case AppThemeType.forest:
        return 'Canlı yeşil doğa teması';
      case AppThemeType.sunset:
        return 'Sıcak turuncu gün batımı';
      case AppThemeType.midnight:
        return 'Gece gökyüzü indigo tonları';
      case AppThemeType.cherry:
        return 'Pembe kiraz çiçeği teması';
    }
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        background: lightBackground,
        surface: lightSurface,
        onSurface: lightOnSurface,
        onBackground: lightOnBackground,
        error: errorColor,
        tertiary: tertiaryColor,
        outline: lightBorderColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: lightSurface,
        foregroundColor: lightOnSurface,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: lightOnSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: lightCardColor,
        elevation: 2,
        shadowColor: primaryColor.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: lightBorderColor.withOpacity(0.5), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          shadowColor: primaryColor.withOpacity(0.4),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: lightBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: lightBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        filled: true,
        fillColor: lightSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: lightSurface,
        selectedItemColor: primaryColor,
        unselectedItemColor: lightOnSurface.withOpacity(0.5),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: darkAccent,
        brightness: Brightness.dark,
        background: darkBackground,
        surface: darkSurface,
        onSurface: darkOnSurface,
        onBackground: darkOnBackground,
        error: errorColor,
        tertiary: tertiaryColor,
        outline: darkBorderColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: darkOnSurface,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkOnSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkCardColor,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: darkBorderColor.withOpacity(0.3), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkAccent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkAccent,
          side: const BorderSide(color: darkAccent, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: darkBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: darkBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: darkAccent, width: 2),
        ),
        filled: true,
        fillColor: darkCardColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: darkAccent,
        unselectedItemColor: darkOnSurface.withOpacity(0.5),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  static ThemeData get purpleDarkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: purpleDarkAccent,
        brightness: Brightness.dark,
        background: purpleDarkBackground,
        surface: purpleDarkSurface,
        onSurface: purpleDarkOnSurface,
        onBackground: purpleDarkOnBackground,
        error: errorColor,
        tertiary: tertiaryColor,
        outline: purpleDarkBorderColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: purpleDarkSurface,
        foregroundColor: purpleDarkOnSurface,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: goldColor,
          letterSpacing: 1,
        ),
      ),
      cardTheme: CardThemeData(
        color: purpleDarkCardColor,
        elevation: 4,
        shadowColor: goldColor.withOpacity(0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: purpleDarkBorderColor.withOpacity(0.5), width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: purpleDarkAccent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: goldColor,
          side: const BorderSide(color: goldColor, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: purpleDarkBorderColor, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: purpleDarkBorderColor, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: goldColor, width: 2.5),
        ),
        filled: true,
        fillColor: purpleDarkCardColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: purpleDarkSurface,
        selectedItemColor: goldColor,
        unselectedItemColor: purpleDarkOnSurface.withOpacity(0.5),
        type: BottomNavigationBarType.fixed,
        elevation: 12,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }

  static ThemeData get oceanTheme {
    return _buildDarkTheme(
      accent: oceanAccent,
      background: oceanBackground,
      surface: oceanSurface,
      onSurface: oceanOnSurface,
      onBackground: oceanOnBackground,
      cardColor: oceanCardColor,
      borderColor: oceanBorderColor,
    );
  }

  static ThemeData get forestTheme {
    return _buildDarkTheme(
      accent: forestAccent,
      background: forestBackground,
      surface: forestSurface,
      onSurface: forestOnSurface,
      onBackground: forestOnBackground,
      cardColor: forestCardColor,
      borderColor: forestBorderColor,
    );
  }

  static ThemeData get sunsetTheme {
    return _buildDarkTheme(
      accent: sunsetAccent,
      background: sunsetBackground,
      surface: sunsetSurface,
      onSurface: sunsetOnSurface,
      onBackground: sunsetOnBackground,
      cardColor: sunsetCardColor,
      borderColor: sunsetBorderColor,
    );
  }

  static ThemeData get midnightTheme {
    return _buildDarkTheme(
      accent: midnightAccent,
      background: midnightBackground,
      surface: midnightSurface,
      onSurface: midnightOnSurface,
      onBackground: midnightOnBackground,
      cardColor: midnightCardColor,
      borderColor: midnightBorderColor,
    );
  }

  static ThemeData get cherryTheme {
    return _buildDarkTheme(
      accent: cherryAccent,
      background: cherryBackground,
      surface: cherrySurface,
      onSurface: cherryOnSurface,
      onBackground: cherryOnBackground,
      cardColor: cherryCardColor,
      borderColor: cherryBorderColor,
    );
  }

  static ThemeData _buildDarkTheme({
    required Color accent,
    required Color background,
    required Color surface,
    required Color onSurface,
    required Color onBackground,
    required Color cardColor,
    required Color borderColor,
  }) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        brightness: Brightness.dark,
        background: background,
        surface: surface,
        onSurface: onSurface,
        onBackground: onBackground,
        error: errorColor,
        tertiary: tertiaryColor,
        outline: borderColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: onSurface,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shadowColor: accent.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: borderColor.withOpacity(0.3), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accent,
          side: BorderSide(color: accent, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: accent, width: 2),
        ),
        filled: true,
        fillColor: cardColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: accent,
        unselectedItemColor: onSurface.withOpacity(0.5),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

}