// lib/pages/register_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:firebase_auth/firebase_auth.dart';
import '../services/profile_service.dart';
import '../services/firebase_auth_service.dart';
import '../services/email_usage_service.dart';
import '../models/user_data.dart';
import '../theme/theme_colors.dart';
import '../theme/design_system.dart';
import '../widgets/language_selector_button.dart';
import '../widgets/page_templates.dart';
import 'profile_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final EmailUsageService _emailUsageService = EmailUsageService();

  @override
  void initState() {
    super.initState();
    // Sayfa açıldığında rastgele bir isim öner
    _suggestRandomName();
  }

  // Rastgele isim öneren metot
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

  void _suggestRandomName() {
    final random =
        DateTime.now().millisecondsSinceEpoch % _availableNames.length;
    final suggestion = _availableNames[random];
    setState(() {
      _nicknameController.text = suggestion;
    });
  }

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final email = _emailController.text.trim();
        final password = _passwordController.text.trim();
        final nickname = _nicknameController.text.trim();

        if (kDebugMode) debugPrint('Starting registration for: $email');

        // Check email usage limitation (maximum 2 uses)
        if (kDebugMode) {
          debugPrint('Checking email usage limitation for: $email');
        }

        final emailUsageValidation =
            await _emailUsageService.canEmailBeUsed(email);
        if (!emailUsageValidation.isValid) {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(emailUsageValidation.error),
              backgroundColor: Colors.red,
            ),
          );

          setState(() => _isLoading = false);
          return;
        }

        if (kDebugMode) {
          debugPrint(
              'Email usage validation passed: ${emailUsageValidation.emailUsage?.usageCount ?? 0} uses');
        }

        // Check nickname uniqueness before creating user
        if (kDebugMode) debugPrint('Checking nickname uniqueness: $nickname');

        NicknameValidationResult nicknameValidation;
        try {
          nicknameValidation =
              await NicknameValidator.validateWithUniqueness(nickname)
                  .timeout(const Duration(seconds: 8));
        } catch (e) {
          if (kDebugMode) debugPrint('Error checking nickname uniqueness: $e');
          if (!mounted) return;

          String errorMsg = 'Takma ad kontrolü sırasında hata oluştu. ';

          if (e.toString().contains('timeout')) {
            errorMsg +=
                'Bağlantı zaman aşımı. İnternet bağlantınızı kontrol edin.';
          } else if (e.toString().contains('network')) {
            errorMsg +=
                'Ağ bağlantısı sorunu. İnternet bağlantınızı kontrol edin.';
          } else {
            errorMsg +=
                'Lütfen internet bağlantınızı kontrol edin ve tekrar deneyin.';
          }

          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMsg),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Tekrar Dene',
                textColor: Colors.white,
                onPressed: _registerUser,
              ),
            ),
          );

          setState(() => _isLoading = false);
          return;
        }

        if (!nicknameValidation.isValid) {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(nicknameValidation.error),
              backgroundColor: Colors.red,
            ),
          );

          setState(() => _isLoading = false);
          return;
        }

        if (kDebugMode) debugPrint('Nickname uniqueness confirmed');

        // Firebase Authentication ile kayıt ol (Enhanced with retry mechanism)
        UserCredential? userCredential;
        try {
          userCredential =
              await FirebaseAuthService.createUserWithEmailAndPasswordWithRetry(
            email: email,
            password: password,
          );

          if (userCredential == null) {
            throw FirebaseAuthException(
              code: 'internal-error',
              message: 'Failed to create user after multiple attempts',
            );
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('Firebase Auth creation failed: $e');
            debugPrint('Exception type: ${e.runtimeType}');
            debugPrint('Exception toString: ${e.toString()}');
          }
          rethrow; // Let the outer catch block handle FirebaseAuthException
        }

        final User? user = userCredential.user;

        if (user != null) {
          if (kDebugMode) debugPrint('Firebase user created: ${user.uid}');

          // Firestore'a kullanıcı profilini kaydet
          final profileService = ProfileService();
          await profileService.initializeProfile(
            nickname: nickname,
            user: user,
          );

          if (kDebugMode) debugPrint('User profile created in Firestore');

          // Record email usage
          await _emailUsageService.recordEmailUsage(email, user.uid);

          if (kDebugMode) debugPrint('Email usage recorded successfully');

          if (!mounted) return;

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kayıt başarılı! Hoş geldiniz!'),
              backgroundColor: Colors.green,
            ),
          );

          // Yeni kullanıcıları profil sayfasına yönlendir
          if (!mounted) return;

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const ProfilePage(),
            ),
          );
        }
      } on FirebaseAuthException catch (e) {
        if (kDebugMode) {
          debugPrint('Firebase Auth error: ${e.code} - ${e.message}');
          debugPrint('Full exception: $e');
        }

        // Use enhanced error handling from FirebaseAuthService
        final errorMessage =
            FirebaseAuthService.handleAuthError(e, context: 'email_signup');

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Tekrar Dene',
              textColor: Colors.white,
              onPressed: _registerUser,
            ),
          ),
        );
      } catch (e, stackTrace) {
        if (kDebugMode) {
          debugPrint('Unexpected registration error: $e');
          debugPrint('Exception type: ${e.runtimeType}');
          debugPrint('Stack trace: $stackTrace');
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Beklenmeyen bir hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StandardAppBar(
        title: const Text('Kayıt Ol'),
        onBackPressed: () => Navigator.pop(context),
        actions: [
          const LanguageSelectorButton(),
        ],
      ),
      body: PageBody(
        scrollable: true,
        child: Container(
          decoration: DesignSystem.getPageContainerDecoration(context),
          padding: const EdgeInsets.all(DesignSystem.spacingM),
          child: SafeArea(
            child: DesignSystem.responsiveContainer(
              context,
              mobile: _buildRegistrationForm(context),
              tablet: _buildRegistrationForm(context),
              desktop: _buildRegistrationForm(context),
              maxWidth: 600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegistrationForm(BuildContext context) {
    return Center(
      child: DesignSystem.card(
        context,
        padding: const EdgeInsets.all(DesignSystem.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.person_add,
              size: 64,
              color: ThemeColors.getPrimaryButtonColor(context),
            ),
            const SizedBox(height: DesignSystem.spacingM),
            Text(
              'Yeni Hesap Oluştur',
              textAlign: TextAlign.center,
              style: DesignSystem.getTitleLarge(context),
            ),
            const SizedBox(height: DesignSystem.spacingXl),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // E-posta alanı
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: DesignSystem.getInputDecoration(
                      context,
                      labelText: 'E-posta Adresi',
                      prefixIcon: const Icon(Icons.email),
                    ),
                    style: DesignSystem.getBodyLarge(context),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'E-posta adresi gerekli';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Geçerli bir e-posta adresi girin';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: DesignSystem.spacingM),

                  // Şifre alanı
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: DesignSystem.getInputDecoration(
                      context,
                      labelText: 'Şifre',
                      prefixIcon: const Icon(Icons.lock),
                    ),
                    style: DesignSystem.getBodyLarge(context),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Şifre gerekli';
                      }
                      if (value.length < 6) {
                        return 'Şifre en az 6 karakter olmalı';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: DesignSystem.spacingM),

                  // Şifre tekrar alanı
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: DesignSystem.getInputDecoration(
                      context,
                      labelText: 'Şifre Tekrar',
                      prefixIcon: const Icon(Icons.lock_outline),
                    ),
                    style: DesignSystem.getBodyLarge(context),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Şifre tekrarı gerekli';
                      }
                      if (value != _passwordController.text) {
                        return 'Şifreler eşleşmiyor';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: DesignSystem.spacingM),

                  // Takma ad alanı
                  TextFormField(
                    controller: _nicknameController,
                    decoration: DesignSystem.getInputDecoration(
                      context,
                      labelText: 'Takma Adınız',
                      prefixIcon: const Icon(Icons.person),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.casino,
                            color: ThemeColors.getGreen(context)),
                        onPressed: _suggestRandomName,
                        tooltip: 'Rastgele isim öner',
                      ),
                    ),
                    style: DesignSystem.getBodyLarge(context),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Takma ad gerekli';
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
            const SizedBox(height: DesignSystem.spacingXl),

            // Kayıt ol butonu
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _registerUser,
              icon: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: DesignSystem.modernProgressIndicator(context),
                    )
                  : const Icon(Icons.person_add),
              label: Text(
                _isLoading ? 'Kayıt Oluyor...' : 'Kayıt Ol',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              style: DesignSystem.getPrimaryButtonStyle(context),
            ),
            const SizedBox(height: DesignSystem.spacingM),

            // Giriş sayfasına yönlendir
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: DesignSystem.getTextButtonStyle(context),
              child: Text(
                'Zaten hesabınız var mı? Giriş Yapın',
                style: DesignSystem.getBodyMedium(context).copyWith(
                  color: ThemeColors.getPrimaryButtonColor(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
