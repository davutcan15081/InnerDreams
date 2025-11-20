import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/presentation/pages/auth_page.dart';
import '../../features/premium/presentation/pages/premium_page.dart';
import '../../features/education/presentation/pages/education_page.dart';
import '../../features/sessions/presentation/pages/sessions_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/history/presentation/pages/history_page.dart';
import '../../features/hybrid/presentation/pages/hybrid_panel_page.dart';
import '../../features/writer/presentation/pages/writer_panel_page.dart';
import '../../features/doctor/presentation/pages/doctor_panel_page.dart';
import '../navigation/main_navigation.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/auth',
    redirect: (context, state) async {
      final currentPath = state.matchedLocation;
      
      // Eğer auth sayfasındaysa, orada kal
      if (currentPath == '/auth') {
        return null;
      }
      
      // Session kontrolü yap
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      
      if (!isLoggedIn) {
        return '/auth';
      }
      
      // Role göre yönlendirme
      final userRole = prefs.getString('user_role') ?? 'user';
      
      // Eğer kullanıcı zaten doğru sayfadaysa, yönlendirme yapma
      if (userRole == 'doctor' && currentPath.startsWith('/doctor')) {
        return null;
      } else if (userRole == 'writer' && currentPath.startsWith('/writer')) {
        return null;
      } else if (userRole == 'hybrid' && currentPath.startsWith('/hybrid')) {
        return null;
      } else if (userRole == 'user' && currentPath.startsWith('/home')) {
        return null;
      }
      
      // Role göre yönlendirme
      if (userRole == 'doctor') {
        return '/doctor';
      } else if (userRole == 'writer') {
        return '/writer';
      } else if (userRole == 'hybrid') {
        return '/hybrid';
      } else {
        return '/home';
      }
    },
    routes: [
      // Splash Route
      GoRoute(
        path: '/splash',
        builder: (context, state) => Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                ),
                const SizedBox(height: 16),
                Text(
                  'Yükleniyor...',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      
      // Auth Route
      GoRoute(
        path: '/auth',
        builder: (context, state) => const InnerDreamsLoginPage(),
      ),
      
      // Main App Routes
      GoRoute(
        path: '/home',
        builder: (context, state) => const MainNavigation(),
      ),
      
      GoRoute(
        path: '/premium',
        builder: (context, state) => const PremiumPage(),
      ),
      
      GoRoute(
        path: '/sessions',
        builder: (context, state) => const SessionsPage(),
      ),
      
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
      
      GoRoute(
        path: '/history',
        builder: (context, state) => const HistoryPage(),
      ),
      
      // Admin Panel Routes
      GoRoute(
        path: '/hybrid',
        builder: (context, state) => const HybridPanelPage(),
      ),
      
      GoRoute(
        path: '/writer',
        builder: (context, state) => const WriterPanelPage(),
      ),
      
      GoRoute(
        path: '/doctor',
        builder: (context, state) => const DoctorPanelPage(),
      ),
    ],
  );
});