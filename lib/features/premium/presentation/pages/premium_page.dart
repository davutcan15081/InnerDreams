import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/user_provider.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/widgets/revenuecat_checkout_widget.dart';
import '../../../../core/services/revenuecat_service.dart';

class PremiumPage extends ConsumerWidget {
  const PremiumPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(ref.watch(localeProvider).getString('upgrade_to_premium_page')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header
            _buildHeader(context, ref),
            const SizedBox(height: 30),
            
            // Features
            _buildFeatures(context, ref),
            const SizedBox(height: 30),
            
            // Pricing
            _buildPricing(context, ref),
            const SizedBox(height: 30),
            
            // Upgrade Button
            _buildUpgradeButton(context, ref),
            const SizedBox(height: 20),
            
            // Terms
            _buildTerms(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.secondary.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.star,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            ref.watch(localeProvider).getString('premium_power'),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            ref.watch(localeProvider).getString('premium_subtitle'),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatures(BuildContext context, WidgetRef ref) {
    final features = [
      {
        'icon': Icons.nights_stay,
        'title': ref.watch(localeProvider).getString('unlimited_dreams'),
        'description': ref.watch(localeProvider).getString('unlimited_dreams_desc'),
        'color': Colors.purple,
      },
      {
        'icon': Icons.psychology,
        'title': ref.watch(localeProvider).getString('unlimited_interpretation'),
        'description': ref.watch(localeProvider).getString('unlimited_interpretation_desc'),
        'color': Colors.blue,
      },
      {
        'icon': Icons.explore,
        'title': ref.watch(localeProvider).getString('inner_journey_premium'),
        'description': ref.watch(localeProvider).getString('inner_journey_premium_desc'),
        'color': Colors.green,
      },
      {
        'icon': Icons.analytics,
        'title': ref.watch(localeProvider).getString('detailed_statistics'),
        'description': ref.watch(localeProvider).getString('detailed_statistics_desc'),
        'color': Colors.orange,
      },
      {
        'icon': Icons.library_books,
        'title': ref.watch(localeProvider).getString('full_library'),
        'description': ref.watch(localeProvider).getString('full_library_desc'),
        'color': Colors.teal,
      },
      {
        'icon': Icons.map,
        'title': ref.watch(localeProvider).getString('dream_map'),
        'description': ref.watch(localeProvider).getString('dream_map_desc'),
        'color': Colors.red,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ref.watch(localeProvider).getString('premium_features'),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        ...features.map((feature) => _buildFeatureCard(
          context,
          feature['icon'] as IconData,
          feature['title'] as String,
          feature['description'] as String,
          feature['color'] as Color,
        )),
      ],
    );
  }

  Widget _buildFeatureCard(BuildContext context, IconData icon, String title, String description, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.check_circle,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildPricing(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            ref.watch(localeProvider).getString('premium_membership'),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '₺29',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Text(
                ref.watch(localeProvider).getString('monthly'),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              ref.watch(localeProvider).getString('first_week_free'),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _upgradeToPremium(context, ref),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          ref.watch(localeProvider).getString('upgrade_to_premium_page'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTerms(BuildContext context, WidgetRef ref) {
    return Text(
      ref.watch(localeProvider).getString('subscription_terms'),
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
      ),
      textAlign: TextAlign.center,
    );
  }

  void _upgradeToPremium(BuildContext context, WidgetRef ref) {
    print('_upgradeToPremium called!');
    
    // User'ı yükle
    ref.read(userProvider.notifier).loadUser();
    
    final userAsync = ref.read(userProvider);
    
    // Kullanıcı verisi yüklenmemişse bekle
    userAsync.when(
      data: (user) {
        print('User data: $user');
        if (user != null) {
          print('Opening RevenueCat Checkout...');
          // RevenueCat Checkout sayfasını aç
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => RevenueCatCheckoutWidget(
                onSuccess: () async {
                  print('Payment successful!');
                  // RevenueCat ile kullanıcı ID'sini ayarla
                  final revenueCat = ref.read(revenueCatProvider);
                  await revenueCat.setUserId(user.id);
                  
                  // Başarı durumunda ana sayfaya dön
                  context.go('/');
                },
                onCancel: () {
                  print('Payment cancelled!');
                  // İptal durumunda premium sayfasında kal
                },
              ),
            ),
          );
        } else {
          print('User is null!');
        }
      },
      loading: () {
        // Loading durumunda bekle
      },
      error: (error, stack) {
        // Hata durumunda mesaj göster
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${ref.watch(localeProvider).getString('user_info_error')}$error')),
        );
      },
    );
  }
}
