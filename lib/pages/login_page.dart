// lib/pages/login_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'board_game_page.dart';
import 'leaderboard_page.dart';
import 'multiplayer_lobby_page.dart';
import 'friends_page.dart';
import 'profile_page.dart';
import 'register_page.dart';
import 'settings_page.dart';
import 'duel_page.dart';
import 'email_verification_page.dart';
import '../services/profile_service.dart';
import '../services/firebase_auth_service.dart';
import '../services/authentication_state_service.dart';
import '../theme/theme_colors.dart';

import '../widgets/login_dialog.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _nicknameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final ProfileService _profileService = ProfileService();
  
  // Registration status
  bool _isRegistered = false;
  bool _isCheckingRegistration = true;

  // Kapsamlı isim önerisi listesi
  final List<String> _availableNames = [
    // A
    'AtıkAzaltıcı', 'AğaçDikeni', 'ArıKoruyucu', 'AydınlıkGezegen', 'AtmosferSavunucusu',
    // B
    'BiyoDost', 'BilinçliGezgin', 'BarışçıDoğa', 'BitkiSever', 'BiyoEnerji',
    // C
    'CevreBilinci', 'CevreKoruyucu', 'CevreTeknolojisi', 'CevreciZihin', 'CevreKalkanı',
    // Ç
    'ÇevreDostu', 'ÇiçekKahramanı', 'ÇamKoruyucu', 'ÇevreGönüllüsü', 'ÇölYeşertici',
    // D
    'DoğaKoruyucu', 'DönüşümElçisi', 'DoğalDenge', 'DenizTemizliği', 'DamladaHayat',
    // E
    'EkoSavaşçı', 'EkoKartal', 'EkoGönüllü', 'EkoZihin', 'EkoYenilikçi',
    // F
    'FidanDikici', 'FotosentezGücü', 'FırtınaDostu', 'FosilsizGelecek', 'FilizEnerjisi',
    // G
    'GeriDönüşümcü', 'GezegenSavunucusu', 'GüneşEnerjisi', 'GelecekYeşil', 'GökYeşili',
    // Ğ
    'GüneşRüzgarı', 'GıdaZinciri', 'GökkuşağıProjesi', 'GüçlüDoğa', 'GelişimYeşili',
    // H
    'HavaKoruyucu', 'HayatKaynağı', 'HidroEnerji', 'HedefSıfırAtık', 'HuzurluGezegen',
    // I
    'IsıKoruyucu', 'IşıkElçisi', 'IlımanDoğa', 'IsıDengesi', 'IlıkYaşam',
    // İ
    'İklimKahramanı', 'İleriGeriDönüşüm', 'İnsancaGelecek', 'İklimBilinci', 'İyileşenDünya',
    // J
    'JeoEnerji', 'JeoIsıKaynağı', 'JeoBilimci', 'JeoDoğa', 'JeoSistem',
    // K
    'KarbonSıfır', 'KüreselDenge', 'KaynakKoruyucu', 'KarbonsuzGelecek', 'KorunanDoğa',
    // L
    'LikitGüneş', 'LambaEnerji', 'LojistikYeşil', 'LiderEko', 'LimonYeşili',
    // M
    'MaviGezegen', 'MikroEkosistem', 'MilliEnerji', 'MaviDalga', 'ModernDoğa',
    // N
    'NefesAlanDünya', 'NemDostu', 'NesilYeşil', 'NadirEkosistem', 'NoktaAtık',
    // O
    'OrmanKralı', 'OkyanusDostu', 'OrganikRuh', 'OrmanBekçisi', 'OzonKoruyucu',
    // Ö
    'ÖncüDoğa', 'ÖzgürGezegen', 'ÖrtüBitkisi', 'ÖzenliYaşam', 'ÖmrüYeşil',
    // P
    'PlastikAvcısı', 'PanelEnerji', 'PozitifDoğa', 'PetrolsüzGelecek', 'PlanlıYaşam',
    // R
    'RüzgarKahramanı', 'RenkliGezegen', 'RefahYeşil', 'RahatDoğa', 'RüzgarDostu',
    // S
    'SıfırAtık', 'SuBekçisi', 'SürdürülebilirHayat', 'SuKoruyucu', 'SessizDoğa',
    // Ş
    'ŞeffafEnerji', 'ŞelaleKoruyucu', 'ŞarjlıDoğa', 'ŞifalıBitki', 'ŞekilYeşil',
    // T
    'ToprakSever', 'TemizEnerji', 'TÜBİTAK_Proje', 'TohumKoruyucu', 'TarımTeknoloji',
    // U
    'UmutYeşili', 'UyumluDoğa', 'UyananGezegen', 'UzayEkosistemi', 'UlaşılabilirEnerji',
    // Ü
    'ÜretkenEkosistem', 'ÜstEnerji', 'ÜçüncüYaşam', 'ÜmitDoğa', 'ÜrünDostu',
    // V
    'VerimliToprak', 'VizyonerDoğa', 'VarlıkGezegeni', 'VakitYeşil', 'VeriEnerjisi',
    // Y
    'YeşilAyak', 'YeşilIşık', 'YeşilYürek', 'YaşamKaynağı', 'YenilenebilirRuh',
    // Z
    'ZehirsizHayat', 'ZararsızDoğa', 'ZümrütGezegen', 'ZekaYeşili', 'ZenginDoğa'
  ];
  
  // Rastgele isim öneren metot
  void _suggestRandomName() {
    final random = Random();
    final suggestion = _availableNames[random.nextInt(_availableNames.length)];
    setState(() {
      _nicknameController.text = suggestion;
    });
  }

  @override
  void initState() {
    super.initState();
    // Check for persistent authentication state first
    _checkPersistentAuth();
    
    // Check for cached username first, then suggest random if none found
    _loadCachedUsername();
    
    // Check registration status to conditionally show profile button
    _checkRegistrationStatus();
  }

  /// Check if user has persistent authentication and navigate accordingly
  Future<void> _checkPersistentAuth() async {
    try {
      final authStateService = AuthenticationStateService();
      final isAuth = await authStateService.isCurrentUserAuthenticated();
      
      if (kDebugMode) {
        debugPrint('LoginPage: Persistent auth check - is authenticated: $isAuth');
        debugPrint('Auth state: ${authStateService.getDebugInfo()}');
      }
      
      if (isAuth && mounted) {
        // User is already authenticated, navigate to profile page
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const ProfilePage(),
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('LoginPage: Error checking persistent auth: $e');
      }
    }
  }

  Future<void> _loadCachedUsername() async {
    try {
      final cachedUsername = await _profileService.getCurrentNickname();
      if (cachedUsername != null && cachedUsername.isNotEmpty) {
        if (!mounted) return;
        setState(() {
          _nicknameController.text = cachedUsername;
        });
      } else {
        // Only suggest random name if no cached username exists
        _suggestRandomName();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading cached username: $e');
      }
      // Fallback to random name suggestion
      _suggestRandomName();
    }
  }

  /// Check if user should be required to login (for multiplayer/duel modes)
  Future<bool> _shouldRequireLogin() async {
    try {
      // Check if user has played before (has cached username)
      final cachedUsername = await _profileService.getCurrentNickname();
      return cachedUsername != null && cachedUsername.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Show login requirement dialog for multiplayer/duel modes
  Future<void> _showLoginRequirementDialog(String modeName) async {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('$modeName için Giriş Gerekli'),
          content: const Text(
            'Çok oyunculu ve düello modları için hesabınıza giriş yapmanız gerekiyor. '
            'Bu, arkadaşlarınızla oynamanız ve ilerlemenizi kaydetmeniz için önemlidir.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showLoginDialog();
              },
              child: const Text('Giriş Yap'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterPage()),
                );
              },
              child: const Text('Kayıt Ol'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _checkRegistrationStatus() async {
    try {
      // Check if user has a real email account (not anonymous)
      final isRegistered = await _profileService.isUserRegistered();
      if (!mounted) return;
      setState(() {
        _isRegistered = isRegistered;
        _isCheckingRegistration = false;
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error checking registration status: $e');
      }
      if (!mounted) return;
      setState(() {
        _isRegistered = false;
        _isCheckingRegistration = false;
      });
    }
  }

  Future<void> _startGame() async {
    if (_formKey.currentState!.validate()) {
      final nickname = _nicknameController.text;
      
      // Cache the username for future use
      await _profileService.cacheNickname(nickname);
      
      // Show loading state
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      try {
        // Enhanced anonymous sign-in with retry mechanism and better error handling
        final user = await FirebaseAuthService.signInAnonymouslyWithRetry();

        if (user != null) {
          if (kDebugMode) {
            debugPrint('Anonymous sign-in successful for user: ${user.uid}');
          }

          // Initialize user profile with UID centrality
          final profileService = ProfileService();
          
          try {
            // Create or update user profile with UID as document ID
            await profileService.initializeProfile(
              nickname: nickname,
              user: user, // Pass user to avoid race condition
            );
            
            if (kDebugMode) {
              debugPrint('User profile initialized successfully for: $nickname');
            }
          } catch (profileError) {
            if (kDebugMode) {
              debugPrint('Profile initialization failed: $profileError');
              debugPrint('Error type: ${profileError.runtimeType}');
            }
            
            // Show user-friendly error message but still allow game to continue
            if (!mounted) return;
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profil oluşturulurken bir sorun oluştu, ancak oyuna devam edebilirsiniz.'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 3),
              ),
            );
          }

          if (!mounted) return;

          // Close loading dialog
          Navigator.of(context, rootNavigator: true).pop();

          // Get authenticated nickname from global state service
          final authStateService = AuthenticationStateService();
          final gameNickname = await authStateService.getGameNickname();
          
          // Navigate - pages will use global authentication state
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => BoardGamePage(userNickname: gameNickname),
            ),
          );
        } else {
          throw FirebaseAuthException(
            code: 'internal-error',
            message: 'Failed to create anonymous user after multiple attempts',
          );
        }
      } on FirebaseAuthException catch (e) {
        // Close loading dialog
        if (mounted) {
          Navigator.of(context, rootNavigator: true).pop();
        }

        if (kDebugMode) {
          debugPrint('Firebase Auth error in _startGame: ${e.code} - ${e.message}');
        }

        // Show user-friendly error message
        final errorMessage = FirebaseAuthService.handleAuthError(e, context: 'anonymous_signin');
        
        if (!mounted) return;
        
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Giriş Hatası'),
              content: Text(errorMessage),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Tamam'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _startGame(); // Retry
                  },
                  child: const Text('Tekrar Dene'),
                ),
              ],
            );
          },
        );

      } catch (e, stackTrace) {
        // Close loading dialog
        if (mounted) {
          Navigator.of(context, rootNavigator: true).pop();
        }

        // Log the error and stacktrace for debugging
        if (kDebugMode) {
          debugPrint('Unexpected login error (type=${e.runtimeType}): $e');
          debugPrint('$stackTrace');
        }

        if (!mounted) return;

        // Show generic error message for unexpected errors
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Beklenmeyen Hata'),
              content: const Text('Giriş yapılırken beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Tamam'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _startGame(); // Retry
                  },
                  child: const Text('Tekrar Dene'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  void _viewLeaderboard() {
    // Liderlik tablosuna takma ad göndermeye gerek yok, çünkü oyun bitmedi.
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LeaderboardPage()),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: isDarkMode 
              ? ThemeColors.getDialogBackground(context) 
              : Colors.white,
          title: Row(
            children: [
              const Icon(Icons.help_outline, color: Color(0xFF4CAF50), size: 28),
              const SizedBox(width: 8),
              Text(
                'Oyun Yardım',
                style: TextStyle(
                  color: isDarkMode 
                      ? Colors.white 
                      : Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                _buildHelpSection(
                  '🎉',
                  'Eco Game\'e Hoş Geldiniz!',
                  'Çevre bilincini artıran eğlenceli bir tahta oyununa hazır mısınız? Zar atarak ilerleyin, quiz sorularını yanıtlayın ve en yüksek skoru elde etmeye çalışın!',
                ),
                _buildHelpSection(
                  '🎯',
                  'Oyun Amacı',
                  'Hedefiniz tahtadaki "Bitiş" karesine ulaşmak! Zar atarak ilerlerken quiz sorularını yanıtlayın, bonus ve ceza karelerinden puan kazanın veya kaybedin.',
                ),
                _buildHelpSection(
                  '🎲',
                  'Tahta Kareleri',
                  '• Başlangıç: Oyunun başladığı yer\n• Quiz: Soru yanıtlayın, doğru cevap puan kazandırır\n• Bonus: Ekstra puan kazanın\n• Ceza: Puan kaybı\n• Bitiş: Oyunu tamamlayın',
                ),
                _buildHelpSection(
                  '📊',
                  'Puanlama Sistemi',
                  'Quiz puanlarınız toplanır, ancak geçen süreye göre ceza uygulanır. Daha hızlı bitirirseniz daha yüksek skor elde edersiniz!',
                ),
                _buildHelpSection(
                  '👤',
                  'Tek Oyuncu Modu',
                  'Tek başınıza oynayın. Zar atın, ilerleyin ve quiz sorularını yanıtlayın. Skorunuz kaydedilir ve liderlik tablosunda yer alabilirsiniz.',
                ),
                _buildHelpSection(
                  '👥',
                  'Çok Oyuncu Modu',
                  'Arkadaşlarınızla birlikte oynayın! Sırayla zar atın, birbirinizi geçmeye çalışın. Oda oluşturun veya katılın.',
                ),
                _buildHelpSection(
                  '🚀',
                  'Nasıl Başlanır?',
                  'Giriş yapın, tek oyuncu veya çok oyuncu modunu seçin. Zar at butonuna tıklayarak oyuna başlayın. İyi eğlenceler!',
                ),
                _buildHelpSection(
                  '⚔️',
                  'Düello Modu',
                  'İki oyuncu arasında hızlı cevap yarışı! 5 soruda en çok doğru cevabı veren kazanır. Hız bonusu ile daha fazla puan kazanabilirsiniz.',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Kapat',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white70 
                      : Colors.black54,
                ),
              ),
            ),
          ],
        );
      },
    );
  }



  void _showLoginDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const LoginDialog(),
    );

    if (result == true && mounted) {
      // Get current user and navigate to profile page
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Check email verification status
        final profileService = ProfileService();
        final verificationStatus = await profileService.getEmailVerificationStatus();
        
        // Get user nickname
        final nickname = await profileService.getCurrentNickname() ?? user.email?.split('@')[0] ?? 'Kullanıcı';
        
        // Set authentication state
        final authStateService = AuthenticationStateService();
        await authStateService.setAuthenticatedUser(
          nickname: nickname,
          uid: user.uid,
        );

        // If email is not verified, show verification dialog first
        if (verificationStatus.hasEmail && !verificationStatus.isVerified) {
          if (!mounted) return;
          final shouldVerify = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('E-posta Doğrulama Gerekli'),
              content: const Text('Hesabınızın tüm özelliklerinden yararlanabilmek için e-posta adresinizi doğrulamanız gerekiyor.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Daha Sonra'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Doğrula'),
                ),
              ],
            ),
          );
          
          if (shouldVerify == true && mounted) {
            // Navigate to email verification page
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EmailVerificationPage(),
              ),
            ).then((isVerified) {
              if (isVerified == true && mounted) {
                // Email verified, navigate to profile
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfilePage(),
                  ),
                );
              }
            });
            return;
          }
        }

        // Email is verified or not required, navigate to profile
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const ProfilePage(),
            ),
          );
        }
      }
    }
  }

  /// Show logout confirmation dialog
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Çıkış Yap'),
          content: const Text('Hesabınızdan çıkış yapmak istediğinizden emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performLogout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Çıkış Yap'),
            ),
          ],
        );
      },
    );
  }

  /// Perform logout and clear authentication state
  Future<void> _performLogout() async {
    try {
      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();
      
      // Clear authentication state
      final authStateService = AuthenticationStateService();
      authStateService.clearAuthenticationState();
      
      // Authentication state and Firebase signout is sufficient for logout
      
      if (kDebugMode) {
        debugPrint('User logged out successfully');
      }
      
      // Show confirmation message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Çıkış yapıldı'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
      
      // Refresh the page to update UI
      if (mounted) {
        setState(() {
          _isRegistered = false;
          _isCheckingRegistration = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Logout error: $e');
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Çıkış yapılırken hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildHelpSection(String icon, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white 
                        : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.grey[700]!.withValues(alpha: 0.8)
                  : Colors.grey[50]!.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.grey[600]!
                    : Colors.grey[300]!,
              ),
            ),
            child: Text(
              content,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white 
                    : Colors.black87,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline, color: ThemeColors.getAppBarIcon(context)),
            onPressed: _showHelpDialog,
            tooltip: 'Oyun Yardımı',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: ThemeColors.getGradientColors(context),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Scrollbar(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: ThemeColors.getContainerBackground(context),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: ThemeColors.getShadow(context),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Icon(
                              Icons.eco,
                              size: 60,
                              color: ThemeColors.getGreen(context),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Oyuna Başla',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: ThemeColors.getText(context),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Form(
                              key: _formKey,
                              child: TextFormField(
                                controller: _nicknameController,
                                decoration: InputDecoration(
                                  labelText: 'Adınız',
                                  filled: true,
                                  fillColor: ThemeColors.getInputBackground(context),
                                  labelStyle: TextStyle(color: ThemeColors.getGreen(context)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: ThemeColors.getBorder(context)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: ThemeColors.getBorder(context)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                                  ),
                                  prefixIcon: Icon(Icons.person, color: ThemeColors.getSecondaryText(context)),
                                  suffixIcon: IconButton(
                                    icon: Icon(Icons.casino, color: Theme.of(context).colorScheme.primary),
                                    onPressed: _suggestRandomName,
                                    tooltip: 'Rastgele isim öner',
                                  ),
                                ),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: ThemeColors.getText(context),
                                  fontWeight: FontWeight.w500,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Lütfen bir takma ad girin';
                                  }
                                  if (value.length < 3) {
                                    return 'Takma ad en az 3 karakter olmalı';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: _startGame,
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Tek Oyun'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ThemeColors.getPrimaryButtonColor(context),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  // Check if login is required
                                  _shouldRequireLogin().then((requiresLogin) async {
                                    if (requiresLogin && !_isRegistered) {
                                      await _showLoginRequirementDialog('Çok Oyunculu');
                                      return;
                                    }
                                    
                                    // Get authenticated nickname from global state service
                                    final authStateService = AuthenticationStateService();
                                    authStateService.getGameNickname().then((gameNickname) {
                                      // Use widget callback to safely navigate
                                      WidgetsBinding.instance.addPostFrameCallback((_) {
                                        if (mounted) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (BuildContext context) => MultiplayerLobbyPage(userNickname: gameNickname),
                                            ),
                                          );
                                        }
                                      });
                                    });
                                  });
                                }
                              },
                              icon: const Icon(Icons.group),
                              label: const Text('Çok Oyunculu'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ThemeColors.getSecondaryButtonColor(context),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  // Check if login is required
                                  _shouldRequireLogin().then((requiresLogin) async {
                                    if (requiresLogin && !_isRegistered) {
                                      await _showLoginRequirementDialog('Düello');
                                      return;
                                    }
                                    
                                    // Use widget callback to safely navigate
                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      if (mounted) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (BuildContext context) => const DuelPage(),
                                          ),
                                        );
                                      }
                                    });
                                  });
                                }
                              },
                              icon: const Icon(Icons.security),
                              label: const Text('Düello'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ThemeColors.getAccentButtonColor(context),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                // Use different layouts based on screen width
                                if (constraints.maxWidth < 400) {
                                  // Small screens: use vertical layout
                                  return Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextButton.icon(
                                              onPressed: () {
                                                // Get authenticated nickname from global state service
                                                final authStateService = AuthenticationStateService();
                                                authStateService.getGameNickname().then((gameNickname) {
                                                  // Use widget callback to safely navigate
                                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                                    if (mounted) {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (BuildContext context) => FriendsPage(userNickname: gameNickname),
                                                        ),
                                                      );
                                                    }
                                                  });
                                                });
                                              },
                                              icon: const Icon(Icons.people, size: 16),
                                              label: const Text('Arkadaşlar', style: TextStyle(fontSize: 12)),
                                              style: TextButton.styleFrom(
                                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                backgroundColor: ThemeColors.getCardBackgroundLight(context),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          if (_isRegistered && !_isCheckingRegistration)
                                            Expanded(
                                              child: TextButton.icon(
                                                onPressed: () {
                                                  if (!mounted) return;
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => const ProfilePage(),
                                                    ),
                                                  );
                                                },
                                                icon: const Icon(Icons.person, size: 16, color: Colors.purple),
                                                label: const Text('Profil', style: TextStyle(fontSize: 12, color: Colors.purple)),
                                                style: TextButton.styleFrom(
                                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                  backgroundColor: ThemeColors.getCardBackgroundLight(context),
                                                ),
                                              ),
                                            ),
                                          if (!_isRegistered || _isCheckingRegistration)
                                            const Expanded(
                                              child: SizedBox.shrink(),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      SizedBox(
                                        width: double.infinity,
                                        child: TextButton.icon(
                                          onPressed: _viewLeaderboard,
                                          icon: const Icon(Icons.leaderboard, size: 16, color: Colors.blue),
                                          label: const Text('Liderlik Tablosu', style: TextStyle(fontSize: 12, color: Colors.blue)),
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(vertical: 8),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            backgroundColor: ThemeColors.getButtonBackground(context),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                } else {
                                  // Medium and large screens: use horizontal layout
                                  return Row(
                                    children: [
                                      Expanded(
                                        child: TextButton.icon(
                                          onPressed: () {
                                            // Get authenticated nickname from global state service
                                            final authStateService = AuthenticationStateService();
                                            authStateService.getGameNickname().then((gameNickname) {
                                              // Use widget callback to safely navigate
                                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                                if (mounted) {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (BuildContext context) => FriendsPage(userNickname: gameNickname),
                                                    ),
                                                  );
                                                }
                                              });
                                            });
                                          },
                                          icon: const Icon(Icons.people, size: 18),
                                          label: const Text('Arkadaşlar', style: TextStyle(fontSize: 14)),
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            backgroundColor: ThemeColors.getButtonBackground(context),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      if (_isRegistered && !_isCheckingRegistration)
                                        Expanded(
                                          child: TextButton.icon(
                                            onPressed: () {
                                              if (!mounted) return;
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => const ProfilePage(),
                                                ),
                                              );
                                            },
                                            icon: const Icon(Icons.person, size: 18, color: Colors.purple),
                                            label: const Text('Profil', style: TextStyle(fontSize: 14, color: Colors.purple)),
                                            style: TextButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                              backgroundColor: Colors.grey[100],
                                            ),
                                          ),
                                        ),
                                      if (!_isRegistered || _isCheckingRegistration)
                                        const Expanded(
                                          child: SizedBox.shrink(),
                                        ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: TextButton.icon(
                                          onPressed: _viewLeaderboard,
                                          icon: const Icon(Icons.leaderboard, size: 18, color: Colors.blue),
                                          label: const Text('Liderlik', style: TextStyle(fontSize: 14, color: Colors.blue)),
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            backgroundColor: ThemeColors.getButtonBackground(context),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                            
                            // Login, Çıkış Yap, Kayıt ol ve Ayarlar butonları
                            if (_isRegistered && !_isCheckingRegistration)
                              // Show logout button for registered users
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  TextButton(
                                    onPressed: _showLogoutDialog,
                                    child: Text(
                                      'Çıkış Yap',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.red,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const SettingsPage(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'Ayarlar',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: ThemeColors.getSecondaryText(context),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            else
                              // Show login/register buttons for non-registered users
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  TextButton(
                                    onPressed: () => _showLoginDialog(),
                                    child: Text(
                                      'Giriş Yap',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: ThemeColors.getSuccessColor(context),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const RegisterPage(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'Kayıt Ol',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: ThemeColors.getInfoColor(context),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const SettingsPage(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'Ayarlar',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: ThemeColors.getSecondaryText(context),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}