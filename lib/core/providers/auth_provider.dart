import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

// User model for auth
class AuthUser {
  final String id;
  final String email;
  final String? name;
  final String role;
  final bool isAdmin;
  final int? createdAt;

  const AuthUser({
    required this.id,
    required this.email,
    this.name,
    this.role = 'user',
    this.isAdmin = false,
    this.createdAt,
  });

  factory AuthUser.fromMap(Map<String, dynamic> map) {
    return AuthUser(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'],
      role: map['role'] ?? 'user',
      isAdmin: map['isAdmin'] ?? false,
      createdAt: map['createdAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'isAdmin': isAdmin,
      'createdAt': createdAt,
    };
  }
}

// Auth State provider
final authStateProvider = StateNotifierProvider<AuthNotifier, AsyncValue<AuthUser?>>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AsyncValue<AuthUser?>> {
  AuthNotifier() : super(const AsyncValue.loading()) {
    _init();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  void _init() {
    // Listen to auth state changes - GEÇİCİ OLARAK DEVRE DIŞI
    // _auth.authStateChanges().listen((User? user) {
    //   print('Auth state changed: ${user?.uid}');
    //   if (user != null) {
    //     print('User logged in, loading data...');
    //     _loadUserData(user.uid);
    //   } else {
    //     print('User logged out');
    //     state = const AsyncValue.data(null);
    //   }
    // });
    
    // Geçici olarak state'i null olarak ayarla
    state = const AsyncValue.data(null);
  }

  Future<void> _loadUserData(String uid) async {
    try {
      print('Loading user data for uid: $uid');
      final doc = await _firestore.collection('users').doc(uid).get();
      
      if (doc.exists) {
        print('User document exists, processing data...');
        final data = doc.data();
        print('Raw data: $data');
        
        if (data != null) {
          // createdAt alanını güvenli şekilde işle
          int? createdAt;
          if (data['createdAt'] != null) {
            print('createdAt type: ${data['createdAt'].runtimeType}');
            if (data['createdAt'] is int) {
              createdAt = data['createdAt'];
            } else if (data['createdAt'] is Timestamp) {
              createdAt = (data['createdAt'] as Timestamp).millisecondsSinceEpoch;
            } else {
              createdAt = DateTime.now().millisecondsSinceEpoch;
            }
          }
          
          // Güvenli veri oluştur
          final safeData = {
            'id': data['id'] ?? uid,
            'email': data['email'] ?? '',
            'name': data['name'],
            'role': data['role'] ?? 'user',
            'isAdmin': data['isAdmin'] ?? false,
            'createdAt': createdAt,
          };
          
          print('Safe data: $safeData');
          final user = AuthUser.fromMap(safeData);
          print('Created user: $user');
          state = AsyncValue.data(user);
        } else {
          print('Data is null');
          state = const AsyncValue.data(null);
        }
      } else {
        print('User document does not exist');
        state = const AsyncValue.data(null);
      }
    } catch (e, stackTrace) {
      print('Load user data error: $e');
      print('Stack trace: $stackTrace');
      
      // PigeonUserDetails hatası oluşursa, state'i güvenli hale getir
      if (e.toString().contains('PigeonUserDetails')) {
        print('PigeonUserDetails hatası yakalandı, state güvenli hale getiriliyor');
        state = const AsyncValue.data(null);
      } else {
        state = AsyncValue.error(e, stackTrace);
      }
    }
  }

  // Sign up method
  Future<bool> signUp(String email, String password) async {
    try {
      state = const AsyncValue.loading();
      
      // Create user with Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        final user = userCredential.user!;
        
        // Create user data
        final userData = AuthUser(
          id: user.uid,
          email: user.email ?? '',
          name: user.displayName,
          role: 'user',
          isAdmin: false,
          createdAt: DateTime.now().millisecondsSinceEpoch,
        );
        
        // Save to Firestore
        await _firestore.collection('users').doc(user.uid).set(userData.toMap());
        
        // Force sign out immediately
        await _auth.signOut();
        
        // Clear state
        state = const AsyncValue.data(null);
        
        print('User registered successfully and signed out: $email');
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      print('SignUp FirebaseAuth error: ${e.code} - ${e.message}');
      // Force sign out even on error
      await _auth.signOut();
      state = const AsyncValue.data(null);
      // Re-throw the exception so it can be caught in the UI
      rethrow;
    } catch (e) {
      print('SignUp general error: $e');
      // Force sign out even on error
      await _auth.signOut();
      state = const AsyncValue.data(null);
      return false;
    }
  }

  // Sign in method
  Future<bool> signIn(String email, String password) async {
    try {
      state = const AsyncValue.loading();
      
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        // User data will be loaded by authStateChanges listener
        return true;
      }
      return false;
    } catch (e) {
      print('SignIn error: $e');
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  // Google Sign In
  Future<bool> signInWithGoogle() async {
    try {
      state = const AsyncValue.loading();
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return false;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        final user = userCredential.user!;
        
        // Check if user exists in Firestore
        final doc = await _firestore.collection('users').doc(user.uid).get();
        
        if (!doc.exists) {
          // Create new user data
          final userData = AuthUser(
            id: user.uid,
            email: user.email ?? '',
            name: user.displayName,
            role: 'user',
            isAdmin: false,
            createdAt: DateTime.now().millisecondsSinceEpoch,
          );
          
          await _firestore.collection('users').doc(user.uid).set(userData.toMap());
        }
        
        return true;
      }
      return false;
    } catch (e) {
      print('Google SignIn error: $e');
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  // Sign out method
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      state = const AsyncValue.data(null);
      print('User signed out successfully');
    } catch (e) {
      print('SignOut error: $e');
      state = const AsyncValue.data(null);
    }
  }

  // Get current user
  AuthUser? get currentUser {
    return state.when(
      data: (user) => user,
      loading: () => null,
      error: (_, __) => null,
    );
  }

  // Check if user is logged in
  bool get isLoggedIn {
    return state.when(
      data: (user) => user != null,
      loading: () => false,
      error: (_, __) => false,
    );
  }
}