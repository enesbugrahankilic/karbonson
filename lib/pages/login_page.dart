import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:provider/provider.dart';
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
import '../theme/design_system.dart';
import '../theme/app_theme.dart';
import '../provides/language_provider.dart';
import '../widgets/login_dialog.dart';


import '../widgets/language_selector_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final TextEditingController _nicknameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final ProfileService _profileService = ProfileService();

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _buttonController;

  // Registration status
  bool _isRegistered = false;
  bool _isCheckingRegistration = true;
  bool _hasCheckedPersistentAuth = false;
  bool _isAuthStateListenerActive = false;

  // Kapsamlı isim önerisi listesi
  final List<String> _availableNames = [
    // A
    'AtıkAzaltıcı', 'AğaçDikeni', 'ArıKoruyucu', 'AydınlıkGezegen',
    'AtmosferSavunucusu',
    // B
    'BiyoDost', 'BilinçliGezgin', 'BarışçıDoğa', 'BitkiSever', 'BiyoEnerji',
    // C
    'CevreBilinci', 'CevreKoruyucu', 'CevreTeknolojisi', 'CevreciZihin',
    'CevreKalkanı',
    // Ç
    'ÇevreDostu', 'ÇiçekKahramanı', 'ÇamKoruyucu', 'ÇevreGönüllüsü',
    'ÇölYeşertici',
    // D
    'DoğaKoruyucu', 'DönüşümElçisi', 'DoğalDenge', 'DenizTemizliği',
    'DamladaHayat',
    // E
    'EkoSavaşçı', 'EkoKartal', 'EkoGönüllü', 'EkoZihin', 'EkoYenilikçi',
    // F
    'FidanDikici', 'FotosentezGücü', 'FırtınaDostu', 'FosilsizGelecek',
    'FilizEnerjisi',
    // G
    'GeriDönüşümcü', 'GezegenSavunucusu', 'GüneşEnerjisi', 'GelecekYeşil',
    'GökYeşili',
    // Ğ
    'GüneşRüzgarı', 'GıdaZinciri', 'GökkuşağıProjesi', 'GüçlüDoğa',
    'GelişimYeşili',
    // H
    'HavaKoruyucu', 'HayatKaynağı', 'HidroEnerji', 'HedefSıfırAtık',
    'HuzurluGezegen',
    // I
    'IsıKoruyucu', 'IşıkElçisi', 'IlımanDoğa', 'IsıDengesi', 'IlıkYaşam',
    // İ
    'İklimKahramanı', 'İleriGeriDönüşüm', 'İnsancaGelecek', 'İklimBilinci',
    'İyileşenDünya',
    // J
    'JeoEnerji', 'JeoIsıKaynağı', 'JeoBilimci', 'JeoDoğa', 'JeoSistem',
    // K
    'KarbonSıfır', 'KüreselDenge', 'KaynakKoruyucu', 'KarbonsuzGelecek',
    'KorunanDoğa',
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
    'PlastikAvcısı', 'PanelEnerji', 'PozitifDoğa', 'PetrolsüzGelecek',
    'PlanlıYaşam',
    // R
    'RüzgarKahramanı', 'RenkliGezegen', 'RefahYeşil', 'RahatDoğa',
    'RüzgarDostu',
    // S
    'SıfırAtık', 'SuBekçisi', 'SürdürülebilirHayat', 'SuKoruyucu', 'SessizDoğa',
    // Ş
    'ŞeffafEnerji', 'ŞelaleKoruyucu', 'ŞarjlıDoğa', 'ŞifalıBitki', 'ŞekilYeşil',
    // T
    'ToprakSever', 'TemizEnerji', 'TÜBİTAK_Proje', 'TohumKoruyucu',
    'TarımTeknoloji',
    // U
    'UmutYeşili', 'UyumluDoğa', 'UyananGezegen', 'UzayEkosistemi',
    'UlaşılabilirEnerji',
    // Ü
    'ÜretkenEkosistem', 'ÜstEnerji', 'ÜçüncüYaşam', 'ÜmitDoğa', 'ÜrünDostu',
    // V
    'VerimliToprak', 'VizyonerDoğa', 'VarlıkGezegeni', 'VakitYeşil',
    'VeriEnerjisi',
    // Y
    'YeşilAyak', 'YeşilIşık', 'YeşilYürek', 'YaşamKaynağı', 'YenilenebilirRuh',
    // Z
    'ZehirsizHayat', 'ZararsızDoğa', 'ZümrütGezegen', 'ZekaYeşili', 'ZenginDoğa'
  ];

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Start animations
    _fadeController.forward();
    _slideController.forward();
    _buttonController.forward();

    // Listen for language changes and rebuild
    context.read<LanguageProvider>().addListener(() {
      if (mounted) setState(() {});
    });

    // Check for persistent authentication state first
    _checkPersistentAuth();

    // Check for cached username first, then suggest random if none found
    _loadCachedUsername();

    // Check registration status to conditionally show profile button
    _checkRegistrationStatus();
  }

  // Rastgele isim öneren metot
  void _suggestRandomName() {
    final random = Random();
    final suggestion = _availableNames[random.nextInt(_availableNames.length)];
    setState(() {
      _nicknameController.text = suggestion;
    });
  }

  /// Check if user has persistent authentication and navigate accordingly
  /// Only runs during page initialization to avoid interfering with manual navigation
  Future<void> _checkPersistentAuth() async {
    // Only check once during page initialization
    if (_hasCheckedPersistentAuth) return;

    try {
      final authStateService = AuthenticationStateService();
      final isAuth = await authStateService.isCurrentUserAuthenticated();

      if (kDebugMode) {
        debugPrint(
            'LoginPage: Persistent auth check - is authenticated: $isAuth');
        debugPrint('Auth state: ${authStateService.getDebugInfo()}');
      }

      // Mark as checked to prevent re-execution
      _hasCheckedPersistentAuth = true;

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
      // Still mark as checked even if there's an error to prevent retries
      _hasCheckedPersistentAuth = true;
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
        return DesignSystem.semantic(
          context,
          label: '$modeName giriş gereksinimi dialog',
          hint:
              '$modeName moduna erişim için giriş yapılması gerektiğini belirten dialog',
          child: AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignSystem.radiusL)),
            title: DesignSystem.semantic(
              context,
              label: '$modeName için Giriş Gerekli başlığı',
              child: Text('$modeName için Giriş Gerekli'),
            ),
            content: DesignSystem.semantic(
              context,
              label: 'Dialog içeriği',
              child: const Text(
                'Çok oyunculu ve düello modları için hesabınıza giriş yapmanız gerekiyor. '
                'Bu, arkadaşlarınızla oynamanız ve ilerlemenizi kaydetmeniz için önemlidir.',
              ),
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
                style: DesignSystem.getPrimaryButtonStyle(context),
                child: const Text('Giriş Yap'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RegisterPage()),
                  );
                },
                child: const Text('Kayıt Ol'),
              ),
            ],
          ),
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
      
      if (kDebugMode) {
        debugPrint('Registration status updated: $isRegistered');
      }
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

      // Show loading state using design system
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => DesignSystem.semantic(
          context,
          label: 'Yükleniyor dialog',
          hint: 'Oyun başlatılıyor, lütfen bekleyin',
          child: AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignSystem.radiusL)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DesignSystem.loadingIndicator(context,
                    message: 'Oyun başlatılıyor...'),
              ],
            ),
          ),
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
              debugPrint(
                  'User profile initialized successfully for: $nickname');
            }
          } catch (profileError) {
            if (kDebugMode) {
              debugPrint('Profile initialization failed: $profileError');
              debugPrint('Error type: ${profileError.runtimeType}');
            }

            // Show user-friendly error message but still allow game to continue
            if (!mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                    'Profil oluşturulurken bir sorun oluştu, ancak oyuna devam edebilirsiniz.'),
                backgroundColor: ThemeColors.getWarningColor(context),
                duration: const Duration(seconds: 3),
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
          debugPrint(
              'Firebase Auth error in _startGame: ${e.code} - ${e.message}');
        }

        // Show user-friendly error message
        final errorMessage =
            FirebaseAuthService.handleAuthError(e, context: 'anonymous_signin');

        if (!mounted) return;

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return DesignSystem.semantic(
              context,
              label: 'Giriş hatası dialog',
              hint: 'Giriş yapılırken hata oluştuğunu belirten hata dialog',
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignSystem.radiusL)),
                title: DesignSystem.semantic(
                  context,
                  label: 'Giriş Hatası başlığı',
                  child: const Text('Giriş Hatası'),
                ),
                content: DesignSystem.semantic(
                  context,
                  label: 'Hata mesajı',
                  child: Text(errorMessage),
                ),
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
              ),
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
            return DesignSystem.semantic(
              context,
              label: 'Beklenmeyen hata dialog',
              hint: 'Beklenmeyen bir hata oluştuğunu belirten dialog',
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignSystem.radiusL)),
                title: DesignSystem.semantic(
                  context,
                  label: 'Beklenmeyen Hata başlığı',
                  child: const Text('Beklenmeyen Hata'),
                ),
                content: DesignSystem.semantic(
                  context,
                  label: 'Hata açıklaması',
                  child: const Text(
                      'Giriş yapılırken beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.'),
                ),
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
              ),
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
        return DesignSystem.semantic(
          context,
          label: 'Oyun yardım dialog',
          hint: 'Oyun hakkında yardım bilgilerini içeren yardım dialog',
          child: AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignSystem.radiusXl)),
            backgroundColor: ThemeColors.getDialogBackground(context),
            title: DesignSystem.semantic(
              context,
              label: 'Oyun Yardım başlığı',
              child: Row(
                children: [
                  Icon(Icons.help_outline,
                      color: ThemeColors.getPrimaryButtonColor(context),
                      size: 28),
                  const SizedBox(width: DesignSystem.spacingS),
                  Text(
                    'Oyun Yardım',
                    style: DesignSystem.getTitleMedium(context).copyWith(
                      color: ThemeColors.getTitleColor(context),
                    ),
                  ),
                ],
              ),
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
                child: DesignSystem.semantic(
                  context,
                  label: 'Kapat butonu',
                  child: Text(
                    'Kapat',
                    style: DesignSystem.getBodyMedium(context).copyWith(
                      color: ThemeColors.getSecondaryText(context),
                    ),
                  ),
                ),
              ),
            ],
          ),
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
        final verificationStatus =
            await profileService.getEmailVerificationStatus();

        // Get user nickname
        final nickname = await profileService.getCurrentNickname() ??
            user.email?.split('@')[0] ??
            'Kullanıcı';

        // Set authentication state
        final authStateService = AuthenticationStateService();
        await authStateService.setAuthenticatedUser(
          nickname: nickname,
          uid: user.uid,
        );

        // Re-check registration status after successful login
        await _checkRegistrationStatus();

        // If email is not verified, show verification dialog first
        if (verificationStatus.hasEmail && !verificationStatus.isVerified) {
          if (!mounted) return;
          final shouldVerify = await showDialog<bool>(
            context: context,
            builder: (context) => DesignSystem.semantic(
              context,
              label: 'E-posta doğrulama dialog',
              hint: 'E-posta doğrulaması gerektiğini belirten dialog',
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignSystem.radiusL)),
                title: const Text('E-posta Doğrulama Gerekli'),
                content: const Text(
                    'Hesabınızın tüm özelliklerinden yararlanabilmek için e-posta adresinizi doğrulamanız gerekiyor.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Daha Sonra'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: DesignSystem.getPrimaryButtonStyle(context),
                    child: const Text('Doğrula'),
                  ),
                ],
              ),
            ),
          );

          if (shouldVerify == true && mounted) {
            // Navigate to email verification page
            Navigator.of(context)
                .push(
              MaterialPageRoute(
                builder: (context) => const EmailVerificationPage(),
              ),
            )
                .then((isVerified) {
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
        return DesignSystem.semantic(
          context,
          label: 'Çıkış onay dialog',
          hint:
              'Çıkış yapmak istediğinizi onaylamanız gerektiğini belirten dialog',
          child: AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignSystem.radiusL)),
            title: DesignSystem.semantic(
              context,
              label: 'Çıkış Yap başlığı',
              child: const Text('Çıkış Yap'),
            ),
            content: DesignSystem.semantic(
              context,
              label: 'Dialog içeriği',
              child: const Text(
                  'Hesabınızdan çıkış yapmak istediğinizden emin misiniz?'),
            ),
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
                  backgroundColor: ThemeColors.getErrorColor(context),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Çıkış Yap'),
              ),
            ],
          ),
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
          SnackBar(
            content: const Text('Çıkış yapıldı'),
            backgroundColor: ThemeColors.getSuccessColor(context),
            duration: const Duration(seconds: 2),
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
            backgroundColor: ThemeColors.getErrorColor(context),
          ),
        );
      }
    }
  }

  Widget _buildHelpSection(String icon, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DesignSystem.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: DesignSystem.spacingS),
              Expanded(
                child: Text(
                  title,
                  style: DesignSystem.getTitleMedium(context).copyWith(
                    color: ThemeColors.getTitleColor(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignSystem.spacingS),
          Container(
            padding: const EdgeInsets.all(DesignSystem.spacingM),
            decoration: BoxDecoration(
              color: ThemeColors.getCardBackgroundLight(context)
                  .withOpacity( 0.8),
              borderRadius: BorderRadius.circular(DesignSystem.radiusS),
              border: Border.all(
                color: ThemeColors.getBorder(context),
                width: 1,
              ),
            ),
            child: Text(
              content,
              style: DesignSystem.getBodyMedium(context).copyWith(
                color: ThemeColors.getText(context),
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
    _fadeController.dispose();
    _slideController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth < 600;
    final isLargeScreen = screenWidth > 800;

    // Responsive text sizes
    final titleFontSize = isSmallScreen ? 20.0 : (isMediumScreen ? 24.0 : (isLargeScreen ? 32.0 : 28.0));
    final bodyTextSize = isSmallScreen ? 14.0 : (isMediumScreen ? 16.0 : 18.0);
    final smallTextSize = isSmallScreen ? 12.0 : 14.0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          DesignSystem.semantic(
            context,
            label: 'Yardım butonu',
            hint: 'Oyun yardımını gösterir',
            child: IconButton(
              icon: Icon(Icons.help_outline,
                  color: ThemeColors.getAppBarIcon(context)),
              onPressed: _showHelpDialog,
              tooltip: 'Oyun Yardımı',
            ),
          ),
          const LanguageSelectorButton(),
        ],
      ),
      body: Container(
        decoration: DesignSystem.getPageContainerDecoration(context),
        child: SafeArea(
          child: Center(
            child: Scrollbar(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isSmallScreen ? 12.0 : DesignSystem.spacingM),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isLargeScreen ? 600 : 500,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      FadeTransition(
                        opacity: _fadeController,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.3),
                            end: Offset.zero,
                          ).animate(_slideController),
                          child: DesignSystem.glassCard(
                            context,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // App Icon with modern styling
                                Container(
                                  padding: const EdgeInsets.all(
                                      DesignSystem.spacingM),
                                  decoration: BoxDecoration(
                                    color: ThemeColors.getPrimaryButtonColor(
                                            context)
                                        .withOpacity( 0.1),
                                    borderRadius: BorderRadius.circular(
                                        DesignSystem.radiusL),
                                  ),
                                  child: Icon(
                                    Icons.eco,
                                    size: 60,
                                    color: ThemeColors.getGreen(context),
                                  ),
                                ),
                                const SizedBox(height: DesignSystem.spacingL),

                                // Title with modern typography
                                Text(
                                  'Oyuna Başla',
                                  textAlign: TextAlign.center,
                                  style: AppTheme.getGameTitleStyle(context).copyWith(
                                    fontSize: titleFontSize,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: DesignSystem.spacingL),

                                // Form using design system
                                Form(
                                  key: _formKey,
                                  child: Column(
                                    children: [
                                      TextFormField(
                                        controller: _nicknameController,
                                        decoration:
                                            DesignSystem.getInputDecoration(
                                          context,
                                          labelText: 'Adınız',
                                          hintText: 'Takma adınızı girin',
                                          prefixIcon: Icon(Icons.person,
                                              color:
                                                  ThemeColors.getSecondaryText(
                                                      context)),
                                          suffixIcon: IconButton(
                                            icon: Icon(Icons.casino,
                                                color: ThemeColors
                                                    .getPrimaryButtonColor(
                                                        context)),
                                            onPressed: _suggestRandomName,
                                            tooltip: 'Rastgele isim öner',
                                          ),
                                        ),
                                        style:
                                            DesignSystem.getBodyLarge(context).copyWith(
                                              fontSize: bodyTextSize,
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
                                    ],
                                  ),
                                ),
                                const SizedBox(height: DesignSystem.spacingM),

                                // Ana Sayfa Butonları - UI Odaklı ve Kolay Erişim
                                _buildMainActionButtons(context),
                                const SizedBox(height: DesignSystem.spacingM),

                                // Oyun Modları
                                _buildGameModeButton(
                                  icon: Icons.play_arrow,
                                  label: 'Tek Oyun',
                                  color: ThemeColors.getPrimaryButtonColor(
                                      context),
                                  onPressed: _startGame,
                                  animationDelay: 0,
                                ),
                                const SizedBox(height: DesignSystem.spacingS),

                                _buildGameModeButton(
                                  icon: Icons.group,
                                  label: 'Çok Oyunculu',
                                  color: ThemeColors.getSecondaryButtonColor(
                                      context),
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      _shouldRequireLogin()
                                          .then((requiresLogin) async {
                                        if (requiresLogin && !_isRegistered) {
                                          await _showLoginRequirementDialog(
                                              'Çok Oyunculu');
                                          return;
                                        }

                                        final authStateService =
                                            AuthenticationStateService();
                                        authStateService
                                            .getGameNickname()
                                            .then((gameNickname) {
                                          Future.delayed(Duration.zero, () {
                                            if (mounted) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (BuildContext context) =>
                                                          MultiplayerLobbyPage(
                                                              userNickname:
                                                                  gameNickname),
                                                ),
                                              );
                                            }
                                          });
                                        });
                                      });
                                    }
                                  },
                                  animationDelay: 100,
                                ),
                                const SizedBox(height: DesignSystem.spacingS),

                                _buildGameModeButton(
                                  icon: Icons.security,
                                  label: 'Düello',
                                  color: ThemeColors.getAccentButtonColor(context),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const DuelPage(),
                                      ),
                                    );
                                  },
                                  animationDelay: 200,
                                ),
                                const SizedBox(height: DesignSystem.spacingM),
                              ],
                            ),
                          ),
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

  /// Ana sayfa için UI odaklı butonlar
  Widget _buildMainActionButtons(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final isSmallScreen = screenWidth < 360;
    
    // Kullanıcı zaten giriş yapmışsa farklı butonlar göster
    final authStateService = AuthenticationStateService();
    final isLoggedIn = authStateService.hasAuthAccount;
    
    return Column(
      children: [
        if (isLoggedIn) ...[
          // Giriş yapmış kullanıcılar için butonlar
          _buildLoggedInUserButtons(context, isSmallScreen),
        ] else ...[
          // Giriş yapmamış kullanıcılar için butonlar
          _buildGuestUserButtons(context, isSmallScreen),
        ],
        SizedBox(height: DesignSystem.spacingS),
        
        // İkinci sıra butonları - her zaman göster
        Row(
          children: [
            Expanded(
              child: _buildSecondaryButton(
                context,
                icon: Icons.settings,
                label: 'Ayarlar',
                color: ThemeColors.getAccentButtonColor(context),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SettingsPage()),
                  );
                },
              ),
            ),
            SizedBox(width: DesignSystem.spacingS),
            if (isLoggedIn)
              Expanded(
                child: _buildSecondaryButton(
                  context,
                  icon: Icons.person,
                  label: 'Profil',
                  color: Colors.purple,
                  onPressed: () {
                    if (!mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ProfilePage()),
                    );
                  },
                ),
              )
            else
              Expanded(
                child: _buildSecondaryButton(
                  context,
                  icon: Icons.people,
                  label: 'Arkadaşlar',
                  color: ThemeColors.getInfoColor(context),
                  onPressed: () {
                    authStateService.getGameNickname().then((gameNickname) {
                      Future.delayed(Duration.zero, () {
                        if (mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  FriendsPage(userNickname: gameNickname),
                            ),
                          );
                        }
                      });
                    });
                  },
                ),
              ),
            if (isLoggedIn)
              Expanded(
                child: _buildSecondaryButton(
                  context,
                  icon: Icons.logout,
                  label: 'Çıkış',
                  color: ThemeColors.getErrorColor(context),
                  onPressed: _showLogoutDialog,
                ),
              ),
            SizedBox(width: DesignSystem.spacingS),
            Expanded(
              child: _buildSecondaryButton(
                context,
                icon: Icons.leaderboard,
                label: 'Liderlik',
                color: ThemeColors.getWarningColor(context),
                onPressed: _viewLeaderboard,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoggedInUserButtons(BuildContext context, bool isSmallScreen) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // Gelişmiş profil sayfasına git
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ProfilePage()),
              );
            },
            icon: Icon(Icons.person, size: 20),
            label: Text('Profilim',
                style:
                    TextStyle(fontSize: isSmallScreen ? 12 : 14, fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignSystem.radiusM),
              ),
              elevation: 2,
            ),
          ),
        ),
        SizedBox(width: DesignSystem.spacingS),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // Çıkış yap
              _showLogoutDialog();
            },
            icon: Icon(Icons.logout, size: 20),
            label: Text('Çıkış Yap',
                style:
                    TextStyle(fontSize: isSmallScreen ? 12 : 14, fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeColors.getErrorColor(context),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignSystem.radiusM),
              ),
              elevation: 2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGuestUserButtons(BuildContext context, bool isSmallScreen) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // Giriş Yap dialog'ını aç
              _showLoginDialog();
            },
            icon: Icon(Icons.login, size: 20),
            label: Text('Giriş Yap',
                style:
                    TextStyle(fontSize: isSmallScreen ? 12 : 14, fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeColors.getPrimaryButtonColor(context),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignSystem.radiusM),
              ),
              elevation: 2,
            ),
          ),
        ),
        SizedBox(width: DesignSystem.spacingS),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // Kayıt ol sayfasına git
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const RegisterPage()),
              );
            },
            icon: Icon(Icons.person_add, size: 20),
            label: Text('Kayıt Ol',
                style:
                    TextStyle(fontSize: isSmallScreen ? 12 : 14, fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeColors.getSecondaryButtonColor(context),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignSystem.radiusM),
              ),
              elevation: 2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGameModeButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
    int animationDelay = 0,
  }) {
    return AnimatedBuilder(
      animation: _buttonController,
      builder: (context, child) {
        final animation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: _buttonController,
          curve: Interval(
            animationDelay / 1000,
            1.0,
            curve: Curves.easeOutBack,
          ),
        ));

        return Transform.scale(
          scale: animation.value,
          child: ElevatedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: 20),
            label: Text(label,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(vertical: DesignSystem.spacingM),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignSystem.radiusM),
              ),
              elevation: DesignSystem.elevationS,
              shadowColor: color.withOpacity( 0.3),
              minimumSize: const Size.fromHeight(48),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSecondaryButton(BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final isSmallScreen = screenWidth < 360;
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: color),
      label: Text(label,
          style: TextStyle(
              fontSize: isSmallScreen ? 12 : 14, color: color, fontWeight: FontWeight.w500),
          maxLines: 1,
          overflow: TextOverflow.ellipsis),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: DesignSystem.spacingM),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignSystem.radiusM)),
        backgroundColor: ThemeColors.getCardBackgroundLight(context),
      ),
    );
  }
}
