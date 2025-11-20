import 'package:flutter_riverpod/flutter_riverpod.dart';

// User subscription status
enum SubscriptionStatus {
  free,
  premium,
}

// User model
class User {
  final String id;
  final String email;
  final String? name;
  final SubscriptionStatus subscriptionStatus;
  final DateTime? subscriptionExpiry;
  final Map<String, dynamic> onboardingAnswers;
  final Map<String, dynamic> profileData;
  final int weeklyDreamLimit;
  final int weeklyInterpretationLimit;
  final DateTime createdAt;
  final DateTime lastActiveAt;

  const User({
    required this.id,
    required this.email,
    this.name,
    required this.subscriptionStatus,
    this.subscriptionExpiry,
    required this.onboardingAnswers,
    required this.profileData,
    required this.weeklyDreamLimit,
    required this.weeklyInterpretationLimit,
    required this.createdAt,
    required this.lastActiveAt,
  });

  bool get isPremium => subscriptionStatus == SubscriptionStatus.premium;
  
  bool get isSubscriptionActive {
    if (!isPremium) return false;
    if (subscriptionExpiry == null) return true;
    return DateTime.now().isBefore(subscriptionExpiry!);
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    SubscriptionStatus? subscriptionStatus,
    DateTime? subscriptionExpiry,
    Map<String, dynamic>? onboardingAnswers,
    Map<String, dynamic>? profileData,
    int? weeklyDreamLimit,
    int? weeklyInterpretationLimit,
    DateTime? createdAt,
    DateTime? lastActiveAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      subscriptionExpiry: subscriptionExpiry ?? this.subscriptionExpiry,
      onboardingAnswers: onboardingAnswers ?? this.onboardingAnswers,
      profileData: profileData ?? this.profileData,
      weeklyDreamLimit: weeklyDreamLimit ?? this.weeklyDreamLimit,
      weeklyInterpretationLimit: weeklyInterpretationLimit ?? this.weeklyInterpretationLimit,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }
}

// User state provider
final userProvider = StateNotifierProvider<UserNotifier, AsyncValue<User?>>((ref) {
  return UserNotifier();
});

class UserNotifier extends StateNotifier<AsyncValue<User?>> {
  UserNotifier() : super(const AsyncValue.loading());

  // Mock user data for development
  void loadUser() {
    // TODO: Load user from backend/local storage
    final mockUser = User(
      id: '1',
      email: 'user@example.com',
      name: 'Test User',
      subscriptionStatus: SubscriptionStatus.free,
      onboardingAnswers: {
        'dream_frequency': 'weekly',
        'recall_ability': 'partial',
        'expectations': ['self_awareness', 'dream_insight'],
      },
      profileData: {
        'age': 25,
        'marital_status': 'single',
        'has_children': false,
      },
      weeklyDreamLimit: 1,
      weeklyInterpretationLimit: 1,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      lastActiveAt: DateTime.now(),
    );
    
    state = AsyncValue.data(mockUser);
  }

  void updateSubscription(SubscriptionStatus status, {DateTime? expiry}) {
    if (state.hasValue) {
      final user = state.value!;
      state = AsyncValue.data(user.copyWith(
        subscriptionStatus: status,
        subscriptionExpiry: expiry,
        weeklyDreamLimit: status == SubscriptionStatus.premium ? -1 : 1,
        weeklyInterpretationLimit: status == SubscriptionStatus.premium ? -1 : 1,
      ));
    }
  }

  void updateProfile(Map<String, dynamic> profileData) {
    if (state.hasValue) {
      final user = state.value!;
      state = AsyncValue.data(user.copyWith(
        profileData: {...user.profileData, ...profileData},
      ));
    }
  }

  void updateOnboardingAnswers(Map<String, dynamic> answers) {
    if (state.hasValue) {
      final user = state.value!;
      state = AsyncValue.data(user.copyWith(
        onboardingAnswers: {...user.onboardingAnswers, ...answers},
      ));
    }
  }
}

// Usage tracking providers
final weeklyDreamUsageProvider = StateProvider<int>((ref) => 0);
final weeklyInterpretationUsageProvider = StateProvider<int>((ref) => 0);

// Feature access providers
final canAddDreamProvider = Provider<bool>((ref) {
  final user = ref.watch(userProvider).value;
  final usage = ref.watch(weeklyDreamUsageProvider);
  
  if (user == null) return false;
  if (user.isPremium) return true;
  
  return usage < user.weeklyDreamLimit;
});

final canGetInterpretationProvider = Provider<bool>((ref) {
  final user = ref.watch(userProvider).value;
  final usage = ref.watch(weeklyInterpretationUsageProvider);
  
  if (user == null) return false;
  if (user.isPremium) return true;
  
  return usage < user.weeklyInterpretationLimit;
});

final canAccessInnerJourneyProvider = Provider<bool>((ref) {
  final user = ref.watch(userProvider).value;
  return user?.isPremium ?? false;
});

final canAccessAnalyticsProvider = Provider<bool>((ref) {
  final user = ref.watch(userProvider).value;
  return user?.isPremium ?? false;
});

final canAccessAllMeditationsProvider = Provider<bool>((ref) {
  final user = ref.watch(userProvider).value;
  return user?.isPremium ?? false;
});

final canAccessAllLibraryContentProvider = Provider<bool>((ref) {
  final user = ref.watch(userProvider).value;
  return user?.isPremium ?? false;
});
