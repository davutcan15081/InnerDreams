import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/locale_provider.dart';
import 'core/services/hybrid_app_initializer.dart';
import 'core/services/revenuecat_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Debug mode'da text overflow uyarılarını kapat
  debugPrint = (String? message, {int? wrapWidth}) {
    // Text overflow uyarılarını filtrele
    if (message != null && !message.contains('A RenderFlex overflowed')) {
      print(message);
    }
  };
  
  // Hibrit sistemi başlat
  try {
    await HybridAppInitializer.initializeApp();
  
    // RevenueCat'i başlat
    final revenueCatService = RevenueCatService();
    await revenueCatService.initialize();
    print('✅ RevenueCat başlatıldı');
  } catch (e) {
    print('Hibrit sistem başlatma hatası: $e');
  }
  
  runApp(
    const ProviderScope(
      child: InnerDreamsApp(),
    ),
  );
}

class InnerDreamsApp extends ConsumerWidget {
  const InnerDreamsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeData = ref.watch(themeDataProvider);
    final locale = ref.watch(localeDataProvider);
    
    return MaterialApp.router(
      title: 'InnerDreams',
      theme: themeData,
      locale: locale,
      supportedLocales: const [
        Locale('tr', 'TR'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale != null) {
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode) {
              return supportedLocale;
            }
          }
        }
        return supportedLocales.first;
      },
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: 1.0,
            boldText: false,
          ),
          child: child!,
        );
      },
    );
  }
}
