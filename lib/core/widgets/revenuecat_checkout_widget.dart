import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../services/revenuecat_service.dart';
import '../providers/locale_provider.dart';

class RevenueCatCheckoutWidget extends ConsumerStatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback onCancel;

  const RevenueCatCheckoutWidget({
    super.key,
    required this.onSuccess,
    required this.onCancel,
  });

  @override
  ConsumerState<RevenueCatCheckoutWidget> createState() => _RevenueCatCheckoutWidgetState();
}

class _RevenueCatCheckoutWidgetState extends ConsumerState<RevenueCatCheckoutWidget> {
  List<Package> _packages = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    try {
      final revenueCat = ref.read(revenueCatProvider);
      await revenueCat.initialize();
      
      final offerings = await revenueCat.getOfferings();
      
      setState(() {
        _packages = offerings?.current?.availablePackages ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _purchasePackage(Package package) async {
    try {
      final revenueCat = ref.read(revenueCatProvider);
      final success = await revenueCat.purchasePackage(package);
      
      if (success) {
        widget.onSuccess();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ref.watch(localeProvider).getString('purchase_failed'))),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${ref.watch(localeProvider).getString('error')}$e')),
      );
    }
  }

  Future<void> _restorePurchases() async {
    try {
      final revenueCat = ref.read(revenueCatProvider);
      final success = await revenueCat.restorePurchases();
      
      if (success) {
        widget.onSuccess();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ref.watch(localeProvider).getString('purchases_restored'))),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ref.watch(localeProvider).getString('no_purchases_to_restore'))),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${ref.watch(localeProvider).getString('restore_error')}$e')),
      );
    }
  }

  String _getPeriodText(Package package, WidgetRef ref) {
    switch (package.packageType) {
      case PackageType.monthly:
        return ref.watch(localeProvider).getString('monthly');
      case PackageType.threeMonth:
        return ref.watch(localeProvider).getString('three_month');
      case PackageType.annual:
        return ref.watch(localeProvider).getString('yearly');
      case PackageType.sixMonth:
        return ref.watch(localeProvider).getString('six_month');
      case PackageType.twoMonth:
        return ref.watch(localeProvider).getString('two_month');
      case PackageType.weekly:
        return ref.watch(localeProvider).getString('weekly');
      default:
        return '';
    }
  }

  String _getPackageTitle(Package package, WidgetRef ref) {
    switch (package.packageType) {
      case PackageType.monthly:
        return ref.watch(localeProvider).getString('monthly_premium');
      case PackageType.annual:
        return ref.watch(localeProvider).getString('annual_premium');
      case PackageType.weekly:
        return ref.watch(localeProvider).getString('weekly_premium');
      default:
        return ref.watch(localeProvider).getString('premium_package');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(ref.watch(localeProvider).getString('upgrade_to_premium')),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: widget.onCancel,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('${ref.watch(localeProvider).getString('error')}$_error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadPackages,
                        child: Text(ref.watch(localeProvider).getString('try_again')),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.purple.shade400, Colors.purple.shade600],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.diamond,
                              size: 48,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'InnerDreams Premium',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              ref.watch(localeProvider).getString('unlimited_ai_analysis'),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Features
                      Text(
                        ref.watch(localeProvider).getString('premium_features_list'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      _buildFeatureItem(ref.watch(localeProvider).getString('unlimited_dream_interpretation')),
                      _buildFeatureItem(ref.watch(localeProvider).getString('advanced_ai_analysis')),
                      _buildFeatureItem(ref.watch(localeProvider).getString('premium_content_library')),
                      _buildFeatureItem(ref.watch(localeProvider).getString('priority_support')),
                      _buildFeatureItem(ref.watch(localeProvider).getString('detailed_stats')),
                      _buildFeatureItem(ref.watch(localeProvider).getString('cloud_backup')),
                      
                      const SizedBox(height: 32),
                      
                      // Packages
                      Text(
                        ref.watch(localeProvider).getString('premium_packages'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      ..._packages.map((package) => _buildPackageCard(package)),
                      
                      const SizedBox(height: 24),
                      
                      // Restore Button
                      OutlinedButton.icon(
                        onPressed: _restorePurchases,
                        icon: const Icon(Icons.restore),
                        label: Text(ref.watch(localeProvider).getString('restore_purchases')),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              feature,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCard(Package package) {
    final product = package.storeProduct;
    final price = product.priceString;
    final period = _getPeriodText(package, ref);
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      child: InkWell(
        onTap: () => _purchasePackage(package),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: package.packageType == PackageType.annual 
                  ? Colors.purple 
                  : Colors.grey.shade300,
              width: package.packageType == PackageType.annual ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _getPackageTitle(package, ref),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (package.packageType == PackageType.annual)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        ref.watch(localeProvider).getString('best_deal'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Text(
                    price,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade600,
                    ),
                  ),
                  if (period.isNotEmpty)
                    Text(
                      period,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
              
              if (package.packageType == PackageType.annual)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    ref.watch(localeProvider).getString('save_40_percent'),
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// RevenueCat Checkout Provider
final revenueCatCheckoutProvider = Provider<RevenueCatService>((ref) {
  return RevenueCatService();
});

// Premium Upgrade Provider
final premiumUpgradeProvider = FutureProvider<void>((ref) async {
  final revenueCat = ref.read(revenueCatCheckoutProvider);
  await revenueCat.initialize();
});
