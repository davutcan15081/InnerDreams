import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/firebase_storage_service.dart';
import '../../../premium/presentation/pages/premium_page.dart';
import 'privacy_policy_page.dart';
import 'profile_edit_page.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _weeklyReminder = true;
  bool _refreshProfile = false;
  final FirebaseStorageService _storageService = FirebaseStorageService();

  @override
  Widget build(BuildContext context) {
    final currentThemeType = ref.watch(appThemeTypeProvider);
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () => context.pop(),
          ),
        ),
        title: Row(
          children: [
            Icon(
              Icons.settings,
              color: Theme.of(context).colorScheme.onSurface,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              ref.watch(localeProvider).getString('settings'),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
                ),
                child: Icon(
                  Icons.person,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            _buildProfileSection(),
            const SizedBox(height: 22),
            
            // Appearance Section
            _buildAppearanceSection(),
            const SizedBox(height: 22),
            
            // Notifications Section
            _buildNotificationsSection(),
            const SizedBox(height: 22),
            
            // Language Section
            _buildLanguageSection(),
            const SizedBox(height: 22),
            
            // Account Section
            _buildAccountSection(),
            const SizedBox(height: 22),
            
            // Support Section
            _buildSupportSection(),
            const SizedBox(height: 22),
            
            // Danger Zone
            _buildDangerZone(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          // Profile Avatar
          FutureBuilder<Map<String, dynamic>?>(
            key: ValueKey('profile_avatar_$_refreshProfile'),
            future: _storageService.loadUserProfile(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                );
              }
              
              final userData = snapshot.data;
              final profileImageUrl = userData?['profileImageUrl'];
              
              return Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(38),
                  child: profileImageUrl != null
                      ? Image.network(
                          profileImageUrl,
                          fit: BoxFit.cover,
                          width: 80,
                          height: 80,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.person,
                              size: 40,
                              color: Theme.of(context).colorScheme.primary,
                            );
                          },
                        )
                      : Icon(
                          Icons.person,
                          size: 40,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          
          // Profile Info
          FutureBuilder<Map<String, dynamic>?>(
            key: ValueKey('profile_info_$_refreshProfile'),
            future: _storageService.loadUserProfile(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Column(
                  children: [
                    Text(
                      ref.watch(localeProvider).getString('loading'),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ref.watch(localeProvider).getString('loading'),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                );
              }
              
              final userData = snapshot.data;
              final userName = userData?['name'] ?? ref.watch(localeProvider).getString('user');
              final userEmail = userData?['email'] ?? 'user@example.com';
              
              return Column(
                children: [
                  Text(
                    userName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userEmail,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          
          // Premium Test Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                print('Premium Test Button Pressed!');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PremiumPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                ref.watch(localeProvider).getString('test_premium'),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // Edit Profile Button
          OutlinedButton.icon(
            onPressed: _editProfile,
            icon: const Icon(Icons.edit),
            label: Text(ref.watch(localeProvider).getString('edit_profile')),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
              side: BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceSection() {
    final currentThemeType = ref.watch(appThemeTypeProvider);
    
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ref.watch(localeProvider).getString('appearance'),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Theme Selection
          _buildSettingTile(
            icon: Icons.palette,
            title: ref.watch(localeProvider).getString('theme_selection'),
            subtitle: AppTheme.getThemeName(currentThemeType),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _selectTheme,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection() {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ref.watch(localeProvider).getString('notifications'),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Notifications Toggle
          _buildSettingTile(
            icon: Icons.notifications,
            title: ref.watch(localeProvider).getString('notifications'),
            subtitle: ref.watch(localeProvider).getString('notifications_desc'),
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Weekly Reminder
          _buildSettingTile(
            icon: Icons.schedule,
            title: ref.watch(localeProvider).getString('weekly_reminder'),
            subtitle: ref.watch(localeProvider).getString('weekly_reminder_desc'),
            trailing: Switch(
              value: _weeklyReminder,
              onChanged: (value) {
                setState(() {
                  _weeklyReminder = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSection() {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ref.watch(localeProvider).getString('language'),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildSettingTile(
            icon: Icons.language,
            title: ref.watch(localeProvider).getString('language'),
            subtitle: ref.watch(localeProvider) == AppLocale.turkish ? 'Türkçe' : 'English',
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _selectLanguage,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection() {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ref.watch(localeProvider).getString('account'),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildSettingTile(
            icon: Icons.lock,
            title: ref.watch(localeProvider).getString('change_password'),
            subtitle: ref.watch(localeProvider).getString('change_password_desc'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _changePassword,
          ),
          
          const SizedBox(height: 16),
          
          _buildSettingTile(
            icon: Icons.download,
            title: ref.watch(localeProvider).getString('download_data'),
            subtitle: ref.watch(localeProvider).getString('download_data_desc'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _downloadData,
          ),
          
          const SizedBox(height: 16),
          
          _buildSettingTile(
            icon: Icons.privacy_tip,
            title: ref.watch(localeProvider).getString('privacy_policy'),
            subtitle: ref.watch(localeProvider).getString('privacy_policy_desc'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _viewPrivacyPolicy,
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSection() {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ref.watch(localeProvider).getString('support'),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildSettingTile(
            icon: Icons.help,
            title: ref.watch(localeProvider).getString('help_center'),
            subtitle: ref.watch(localeProvider).getString('help_center_desc'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _viewHelp,
          ),
          
          const SizedBox(height: 16),
          
          _buildSettingTile(
            icon: Icons.support_agent,
            title: ref.watch(localeProvider).getString('contact'),
            subtitle: ref.watch(localeProvider).getString('contact_desc'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _contactSupport,
          ),
          
          const SizedBox(height: 16),
          
          _buildSettingTile(
            icon: Icons.star_rate,
            title: ref.watch(localeProvider).getString('rate_app'),
            subtitle: ref.watch(localeProvider).getString('rate_app_desc'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _rateApp,
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZone() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ref.watch(localeProvider).getString('danger_zone'),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildSettingTile(
            icon: Icons.delete_forever,
            title: ref.watch(localeProvider).getString('delete_account'),
            subtitle: ref.watch(localeProvider).getString('delete_account_desc'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _deleteAccount,
            textColor: Theme.of(context).colorScheme.error,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? textColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: textColor ?? Theme.of(context).colorScheme.primary,
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
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
        ),
      ),
    );
  }

  void _editProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfileEditPage(),
      ),
    );
    
    // Profil düzenleme sayfasından döndükten sonra sayfayı yenile
    setState(() {
      _refreshProfile = !_refreshProfile;
    });
  }

  void _toggleDarkMode(bool isDark) {
    // This method is no longer needed as we use the provider directly
  }

  void _selectTheme() {
    final currentThemeType = ref.read(appThemeTypeProvider);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
             title: Text(
               ref.watch(localeProvider).getString('theme_selection'),
               style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
             ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400, // Sabit yükseklik
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: AppThemeType.values.map((themeType) {
              final isSelected = currentThemeType == themeType;
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected 
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: ListTile(
                  leading: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _getThemeColor(themeType),
                      shape: BoxShape.circle,
                    ),
                  ),
                         title: Text(
                           ref.watch(localeProvider).getString('${themeType.name}_theme'),
                           style: TextStyle(
                             color: Theme.of(context).colorScheme.onSurface,
                             fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                           ),
                         ),
                         subtitle: Text(
                           ref.watch(localeProvider).getString('${themeType.name}_theme_desc'),
                           style: TextStyle(
                             color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                             fontSize: 12,
                           ),
                         ),
                  trailing: isSelected 
                      ? Icon(
                          Icons.check_circle,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  onTap: () {
                    ref.read(appThemeTypeProvider.notifier).setThemeType(themeType);
                    Navigator.pop(context);
                  },
                ),
              );
            }).toList(),
            ),
          ),
        ),
        actions: [
               TextButton(
                 onPressed: () => Navigator.pop(context),
                 child: Text(
                   ref.watch(localeProvider).getString('close'),
                   style: TextStyle(color: Theme.of(context).colorScheme.primary),
                 ),
               ),
        ],
      ),
    );
  }

  Color _getThemeColor(AppThemeType themeType) {
    switch (themeType) {
      case AppThemeType.light:
        return const Color(0xFF8B5CF6); // Mor
      case AppThemeType.dark:
        return const Color(0xFF1A1A2E); // Koyu gri
      case AppThemeType.purpleDark:
        return const Color(0xFFFFD700); // Altın
      case AppThemeType.ocean:
        return const Color(0xFF00BFFF); // Okyanus mavisi
      case AppThemeType.forest:
        return const Color(0xFF32CD32); // Lime yeşili
      case AppThemeType.sunset:
        return const Color(0xFFFF8C00); // Koyu turuncu
      case AppThemeType.midnight:
        return const Color(0xFF2C1810); // Gece yarısı
      case AppThemeType.cherry:
        return const Color(0xFFDC143C); // Kiraz kırmızısı
    }
  }

  void _selectLanguage() {
    final currentLocale = ref.read(localeProvider);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          ref.watch(localeProvider).getString('language'),
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Text('🇹🇷'),
              title: const Text('Türkçe'),
              selected: currentLocale == AppLocale.turkish,
              onTap: () {
                ref.read(localeProvider.notifier).setLocale(AppLocale.turkish);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Text('🇺🇸'),
              title: const Text('English'),
              selected: currentLocale == AppLocale.english,
              onTap: () {
                ref.read(localeProvider.notifier).setLocale(AppLocale.english);
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              ref.watch(localeProvider).getString('close'),
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _changePassword() {
    // TODO: Navigate to change password
  }

  void _downloadData() {
    // TODO: Implement data download
  }

  void _viewPrivacyPolicy() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PrivacyPolicyPage(),
      ),
    );
  }

  void _viewHelp() {
    // TODO: Navigate to help center
  }

  void _contactSupport() {
    // TODO: Navigate to contact support
  }

  void _rateApp() {
    // TODO: Open app store rating
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(ref.watch(localeProvider).getString('delete_account_title')),
        content: Text(ref.watch(localeProvider).getString('delete_account_warning')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(ref.watch(localeProvider).getString('cancel')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement account deletion
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(ref.watch(localeProvider).getString('delete')),
          ),
        ],
      ),
    );
  }
}
