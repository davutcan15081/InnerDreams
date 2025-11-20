import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/services/firebase_storage_service.dart';

class InnerDreamsLoginPage extends ConsumerStatefulWidget {
  const InnerDreamsLoginPage({super.key});
  
  @override
  ConsumerState<InnerDreamsLoginPage> createState() => _InnerDreamsLoginPageState();
}

class _InnerDreamsLoginPageState extends ConsumerState<InnerDreamsLoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoginMode = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidPassword(String password) {
    return password.length >= 6;
  }

  bool _passwordsMatch() {
    return _passwordController.text == _confirmPasswordController.text;
  }

  // Şifre hash'leme fonksiyonu
  bool _isFormValid() {
    if (_emailController.text.trim().isEmpty) {
      _showErrorDialog('E-posta adresi boş olamaz!');
      return false;
    }
    if (!_isValidEmail(_emailController.text.trim())) {
      _showErrorDialog(ref.watch(localeProvider).getString('invalid_email'));
      return false;
    }
    if (_passwordController.text.isEmpty) {
      _showErrorDialog('Şifre boş olamaz!');
      return false;
    }
    if (!_isValidPassword(_passwordController.text)) {
      _showErrorDialog(ref.watch(localeProvider).getString('password_too_short'));
      return false;
    }
    if (!_isLoginMode && _confirmPasswordController.text.isEmpty) {
      _showErrorDialog('Şifre onayı boş olamaz!');
      return false;
    }
    if (!_isLoginMode && !_passwordsMatch()) {
      _showErrorDialog(ref.watch(localeProvider).getString('passwords_dont_match'));
      return false;
    }
    return true;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.error_outline, color: Colors.red, size: 24),
              SizedBox(width: 8),
              Text('Hata', style: TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.w600)),
            ],
          ),
          content: Text(message, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Tamam', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 14, fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.check_circle_outline, color: Colors.green, size: 24),
              SizedBox(width: 8),
              Text('Başarılı', style: TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.w600)),
            ],
          ),
          content: Text(message, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Tamam', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 14, fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }

  void _showSwitchToLoginDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary, size: 24),
              SizedBox(width: 8),
              Text('Bilgi', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 18, fontWeight: FontWeight.w600)),
            ],
          ),
          content: Text('Bu e-posta adresi zaten kayıtlı. Giriş yapmayı deneyin.', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _isLoginMode = true;
                });
              },
              child: Text('Giriş Yap', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 14, fontWeight: FontWeight.w600)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal', style: TextStyle(color: Colors.grey, fontSize: 14)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleLogin() async {
    if (_isLoading) return;
    if (!_isFormValid()) return;

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      
      // Firebase Authentication ile giriş yap
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        final user = userCredential.user!;
        print('✅ Firebase Auth ile giriş başarılı: ${user.uid}');
        
        // Firestore'dan kullanıcı bilgilerini al
        try {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          if (userDoc.exists) {
            final userData = userDoc.data()!;
            print('✅ Firestore\'dan kullanıcı verisi alındı: ${user.uid}');
            
            // Kullanıcı bilgilerini Firebase Storage'a sakla
            if (mounted) {
              try {
                final storageService = FirebaseStorageService();
                await storageService.saveUserProfile(
                  name: userData['name'] ?? user.displayName ?? 'Kullanıcı',
                  email: email,
                  bio: userData['bio'] ?? '',
                );
                print('✅ Firebase Storage\'a profil bilgileri kaydedildi');
              } catch (storageError) {
                print('❌ Firebase Storage hatası: $storageError');
                print('⚠️ Firebase Storage hatası göz ardı ediliyor...');
              }
              
              // SharedPreferences'a sadece login durumunu sakla
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('user_email', email);
              await prefs.setString('user_name', userData['name'] ?? user.displayName ?? 'Kullanıcı');
              await prefs.setString('user_role', userData['role'] ?? 'user');
              await prefs.setBool('is_logged_in', true);
              
              // Role göre yönlendirme
              String redirectPath = '/home';
              if (userData['role'] == 'doctor') {
                redirectPath = '/doctor';
              } else if (userData['role'] == 'writer') {
                redirectPath = '/writer';
              } else if (userData['role'] == 'hybrid') {
                redirectPath = '/hybrid';
              }
              
              _showSuccessDialog('Giriş başarılı! Yönlendiriliyorsunuz...');
              
              Future.delayed(const Duration(seconds: 1), () {
                if (mounted) {
                  context.go(redirectPath);
                }
              });
            }
          } else {
            // Firestore'da kullanıcı yoksa, varsayılan bilgilerle oluştur
            print('⚠️ Firestore\'da kullanıcı bulunamadı, varsayılan bilgilerle oluşturuluyor...');
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .set({
                  'id': user.uid,
                  'email': email,
                  'name': user.displayName ?? 'Kullanıcı',
                  'role': 'user',
                  'isAdmin': false,
                  'createdAt': DateTime.now().millisecondsSinceEpoch,
                  'updatedAt': DateTime.now().millisecondsSinceEpoch,
                });
            
            if (mounted) {
              try {
                final storageService = FirebaseStorageService();
                await storageService.saveUserProfile(
                  name: user.displayName ?? 'Kullanıcı',
                  email: email,
                  bio: '',
                );
                print('✅ Firebase Storage\'a profil bilgileri kaydedildi');
              } catch (storageError) {
                print('❌ Firebase Storage hatası: $storageError');
                print('⚠️ Firebase Storage hatası göz ardı ediliyor...');
              }
              
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('user_email', email);
              await prefs.setString('user_name', user.displayName ?? 'Kullanıcı');
              await prefs.setString('user_role', 'user');
              await prefs.setBool('is_logged_in', true);
              
              _showSuccessDialog('Giriş başarılı! Yönlendiriliyorsunuz...');
              
              Future.delayed(const Duration(seconds: 1), () {
                if (mounted) {
                  context.go('/home');
                }
              });
            }
          }
        } catch (firestoreError) {
          print('❌ Firestore okuma hatası: $firestoreError');
          // Firestore hatası olsa bile varsayılan bilgilerle devam et
          if (mounted) {
            try {
              final storageService = FirebaseStorageService();
              await storageService.saveUserProfile(
                name: user.displayName ?? 'Kullanıcı',
                email: email,
                bio: '',
              );
              print('✅ Firebase Storage\'a profil bilgileri kaydedildi');
            } catch (storageError) {
              print('❌ Firebase Storage hatası: $storageError');
              print('⚠️ Firebase Storage hatası göz ardı ediliyor...');
            }
            
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('user_email', email);
            await prefs.setString('user_name', user.displayName ?? 'Kullanıcı');
            await prefs.setString('user_role', 'user');
            await prefs.setBool('is_logged_in', true);
            
            _showSuccessDialog('Giriş başarılı! Yönlendiriliyorsunuz...');
            
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) {
                context.go('/home');
              }
            });
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String errorMessage = 'Giriş hatası: ';
        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'Bu e-posta adresi ile kayıtlı kullanıcı bulunamadı.';
            break;
          case 'wrong-password':
            errorMessage = 'Şifre hatalı.';
            break;
          case 'invalid-email':
            errorMessage = 'Geçersiz e-posta adresi.';
            break;
          case 'user-disabled':
            errorMessage = 'Bu hesap devre dışı bırakılmış.';
            break;
          case 'too-many-requests':
            errorMessage = 'Çok fazla başarısız giriş denemesi. Lütfen daha sonra tekrar deneyin.';
            break;
          default:
            errorMessage = 'Giriş sırasında hata oluştu: ${e.message}';
        }
        _showErrorDialog(errorMessage);
      }
    } catch (e) {
      if (mounted) {
        print('Login error: $e');
        _showErrorDialog('Giriş sırasında beklenmeyen bir hata oluştu: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleRegister() async {
    if (_isLoading) return;
    if (!_isFormValid()) return;

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      
      // Firebase Authentication ile kullanıcı oluştur
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        final user = userCredential.user!;
        print('✅ Firebase Auth kullanıcı oluşturuldu: ${user.uid}');
        
        // Firestore'da kullanıcı bilgilerini sakla
        try {
          print('🔄 Firestore\'a yazma işlemi başlatılıyor...');
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
                'id': user.uid,
                'email': email,
                'name': user.displayName ?? 'Kullanıcı',
                'role': 'user',
                'isAdmin': false,
                'createdAt': DateTime.now().millisecondsSinceEpoch,
                'updatedAt': DateTime.now().millisecondsSinceEpoch,
              });
          print('✅ Firestore\'a kullanıcı verisi yazıldı: ${user.uid}');
        } catch (firestoreError) {
          print('❌ Firestore yazma hatası: $firestoreError');
          print('❌ Firestore error type: ${firestoreError.runtimeType}');
          // Firestore hatası olsa bile devam et
        }

        // Kullanıcı bilgilerini Firebase Storage'a sakla
        if (mounted) {
          try {
            print('🔄 Firebase Storage\'a profil bilgileri yazılıyor...');
            
            final storageService = FirebaseStorageService();
            await storageService.saveUserProfile(
              name: user.displayName ?? 'Kullanıcı',
              email: email,
              bio: '',
            );
            
            print('✅ Firebase Storage\'a profil bilgileri kaydedildi');
          } catch (storageError) {
            print('❌ Firebase Storage yazma hatası: $storageError');
            print('⚠️ Firebase Storage hatası göz ardı ediliyor, devam ediliyor...');
            // Storage hatası olsa bile devam et - kritik değil
          }
          
          _showSuccessDialog('Kayıt başarılı! Şimdi giriş yapabilirsiniz.');
          
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                _isLoginMode = true;
                _emailController.clear();
                _passwordController.clear();
                _confirmPasswordController.clear();
              });
            }
          });
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String errorMessage = 'Kayıt hatası: ';
        switch (e.code) {
          case 'weak-password':
            errorMessage = 'Şifre çok zayıf. En az 6 karakter olmalı.';
            break;
          case 'email-already-in-use':
            errorMessage = 'Bu e-posta adresi zaten kayıtlı. Giriş yapmayı deneyin.';
            break;
          case 'invalid-email':
            errorMessage = 'Geçersiz e-posta adresi.';
            break;
          default:
            errorMessage = 'Kayıt sırasında hata oluştu: ${e.message}';
        }
        _showErrorDialog(errorMessage);
      }
    } catch (e) {
      if (mounted) {
        print('Registration error: $e');
        _showErrorDialog('Kayıt sırasında beklenmeyen bir hata oluştu: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final success = await ref.read(authStateProvider.notifier).signInWithGoogle();

      if (success && mounted) {
        _showSuccessDialog('Google ile giriş başarılı!');
        
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            context.go('/home');
          }
        });
      } else if (mounted) {
        _showErrorDialog('Google ile giriş başarısız.');
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Google ile giriş sırasında hata oluştu: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              const SizedBox(height: 8),
              _buildLogo(),
              const SizedBox(height: 8),
              _buildAppTitle(),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  child: _buildAuthCard(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 100,
      height: 100,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/astroloji_logo.png'),
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildAppTitle() {
    return Column(
      children: [
        Text(
          ref.watch(localeProvider).getString('welcome'),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          ref.watch(localeProvider).getString('welcome_subtitle'),
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.w300,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAuthCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.surfaceVariant,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFormTitle(),
          const SizedBox(height: 12),
          _buildEmailField(),
          const SizedBox(height: 10),
          _buildPasswordField(),
          if (!_isLoginMode) ...[
            const SizedBox(height: 10),
            _buildConfirmPasswordField(),
          ],
          const SizedBox(height: 16),
          _buildAuthButton(),
          const SizedBox(height: 12),
          _buildDivider(),
          const SizedBox(height: 12),
          _buildSocialButtons(),
          const SizedBox(height: 8),
          _buildSwitchModeButton(),
        ],
      ),
    );
  }

  Widget _buildFormTitle() {
    return Column(
      children: [
        Text(
          _isLoginMode ? ref.watch(localeProvider).getString('login') : ref.watch(localeProvider).getString('register'),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isLoginMode ? 'Hesabınıza giriş yapın' : 'Yeni hesap oluşturun',
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.surfaceVariant,
            Theme.of(context).colorScheme.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16),
        decoration: InputDecoration(
          labelText: ref.watch(localeProvider).getString('email'),
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          prefixIcon: Icon(Icons.email_outlined, color: Theme.of(context).colorScheme.primary, size: 20),
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.surfaceVariant,
            Theme.of(context).colorScheme.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16),
        decoration: InputDecoration(
          labelText: ref.watch(localeProvider).getString('password'),
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          prefixIcon: Icon(Icons.lock_outlined, color: Theme.of(context).colorScheme.primary, size: 20),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
              size: 20,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildConfirmPasswordField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.surfaceVariant,
            Theme.of(context).colorScheme.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _confirmPasswordController,
        obscureText: _obscureConfirmPassword,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16),
        decoration: InputDecoration(
          labelText: ref.watch(localeProvider).getString('confirm_password'),
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          prefixIcon: Icon(Icons.lock_outlined, color: Theme.of(context).colorScheme.primary, size: 20),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
              size: 20,
            ),
            onPressed: () {
              setState(() {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              });
            },
          ),
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildAuthButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : (_isLoginMode ? _handleLogin : _handleRegister),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.onPrimary),
                ),
              )
            : Text(
                _isLoginMode ? ref.watch(localeProvider).getString('login') : ref.watch(localeProvider).getString('register'),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: Colors.grey.withOpacity(0.3))),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text('veya', style: TextStyle(color: Colors.grey, fontSize: 12)),
        ),
        Expanded(child: Container(height: 1, color: Colors.grey.withOpacity(0.3))),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Column(
      children: [
        _buildGoogleButton(),
        const SizedBox(height: 10),
        _buildAppleButton(),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2D1B69), Color(0xFF1A1A2E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: OutlinedButton(
        onPressed: _isLoading ? null : _handleGoogleSignIn,
        style: OutlinedButton.styleFrom(
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              child: const Center(
                child: Text(
                  'G',
                  style: TextStyle(
                    color: Color(0xFFEA4335),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            const Text(
              'Google ile Giriş',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppleButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2D1B69), Color(0xFF1A1A2E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: OutlinedButton(
        onPressed: _isLoading ? null : () {
          _showErrorDialog('Apple ile giriş henüz aktif değil.');
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.apple, color: Colors.white, size: 28),
            const SizedBox(width: 16),
            const Text(
              'Apple ile Giriş',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchModeButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _isLoginMode ? 'Hesabınız yok mu?' : 'Zaten hesabınız var mı?',
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              _isLoginMode = !_isLoginMode;
              _emailController.clear();
              _passwordController.clear();
              _confirmPasswordController.clear();
            });
          },
          style: TextButton.styleFrom(
            minimumSize: Size.zero,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            _isLoginMode ? ref.watch(localeProvider).getString('create_account') : ref.watch(localeProvider).getString('login'),
            style: const TextStyle(
              color: Color(0xFF8B5CF6),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

}