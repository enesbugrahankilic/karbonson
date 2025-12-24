// lib/pages/register_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:firebase_auth/firebase_auth.dart';
import '../services/profile_service.dart';
import '../services/firebase_auth_service.dart';
import '../services/email_usage_service.dart';
import '../models/user_data.dart';
import '../theme/theme_colors.dart';
import '../widgets/language_selector_button.dart';
import 'tutorial_page.dart';
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
        if (kDebugMode)
          debugPrint('Checking email usage limitation for: $email');

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

        if (kDebugMode)
          debugPrint(
              'Email usage validation passed: ${emailUsageValidation.emailUsage?.usageCount ?? 0} uses');

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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text('Kayıt Ol',
            style: TextStyle(color: ThemeColors.getAppBarText(context))),
        iconTheme: IconThemeData(color: ThemeColors.getAppBarIcon(context)),
        actions: [
          const LanguageSelectorButton(),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFe0f7fa), Color(0xFF4CAF50)],
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
                              Icons.person_add,
                              size: 60,
                              color: const Color(0xFF4CAF50),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Yeni Hesap Oluştur',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: ThemeColors.getTitleText(context),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  // E-posta alanı
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      labelText: 'E-posta Adresi',
                                      filled: true,
                                      fillColor: ThemeColors.getInputBackground(
                                          context),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color:
                                                ThemeColors.getBorder(context)),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color:
                                                ThemeColors.getBorder(context)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                            color: Color(0xFF4CAF50), width: 2),
                                      ),
                                      prefixIcon: Icon(Icons.email,
                                          color: ThemeColors.getSecondaryText(
                                              context)),
                                      labelStyle: TextStyle(
                                          color: ThemeColors.getSecondaryText(
                                              context)),
                                    ),
                                    style: TextStyle(
                                        color: ThemeColors.getText(context)),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'E-posta adresi gerekli';
                                      }
                                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                          .hasMatch(value)) {
                                        return 'Geçerli bir e-posta adresi girin';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // Şifre alanı
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      labelText: 'Şifre',
                                      filled: true,
                                      fillColor: ThemeColors.getInputBackground(
                                          context),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color:
                                                ThemeColors.getBorder(context)),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color:
                                                ThemeColors.getBorder(context)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                            color: Color(0xFF4CAF50), width: 2),
                                      ),
                                      prefixIcon: Icon(Icons.lock,
                                          color: ThemeColors.getSecondaryText(
                                              context)),
                                      labelStyle: TextStyle(
                                          color: ThemeColors.getSecondaryText(
                                              context)),
                                    ),
                                    style: TextStyle(
                                        color: ThemeColors.getText(context)),
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
                                  const SizedBox(height: 16),

                                  // Şifre tekrar alanı
                                  TextFormField(
                                    controller: _confirmPasswordController,
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      labelText: 'Şifre Tekrar',
                                      filled: true,
                                      fillColor: ThemeColors.getInputBackground(
                                          context),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color:
                                                ThemeColors.getBorder(context)),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color:
                                                ThemeColors.getBorder(context)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                            color: Color(0xFF4CAF50), width: 2),
                                      ),
                                      prefixIcon: Icon(Icons.lock_outline,
                                          color: ThemeColors.getSecondaryText(
                                              context)),
                                      labelStyle: TextStyle(
                                          color: ThemeColors.getSecondaryText(
                                              context)),
                                    ),
                                    style: TextStyle(
                                        color: ThemeColors.getText(context)),
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
                                  const SizedBox(height: 16),

                                  // Takma ad alanı
                                  TextFormField(
                                    controller: _nicknameController,
                                    decoration: InputDecoration(
                                      labelText: 'Takma Adınız',
                                      filled: true,
                                      fillColor: ThemeColors.getInputBackground(
                                          context),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color:
                                                ThemeColors.getBorder(context)),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color:
                                                ThemeColors.getBorder(context)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                            color: Color(0xFF4CAF50), width: 2),
                                      ),
                                      prefixIcon: Icon(Icons.person,
                                          color: ThemeColors.getSecondaryText(
                                              context)),
                                      suffixIcon: IconButton(
                                        icon: Icon(Icons.casino,
                                            color:
                                                ThemeColors.getGreen(context)),
                                        onPressed: _suggestRandomName,
                                        tooltip: 'Rastgele isim öner',
                                      ),
                                      labelStyle: TextStyle(
                                          color: ThemeColors.getSecondaryText(
                                              context)),
                                    ),
                                    style: TextStyle(
                                        color: ThemeColors.getText(context)),
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
                            const SizedBox(height: 24),

                            // Kayıt ol butonu
                            ElevatedButton.icon(
                              onPressed: _isLoading ? null : _registerUser,
                              icon: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Icon(Icons.person_add),
                              label: Text(
                                  _isLoading ? 'Kayıt Oluyor...' : 'Kayıt Ol'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4CAF50),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Biyometri kurulum widget'ı (opsiyonel) - TODO: Implement
                            /*
                            BiometricSetupWidget(
                              onSetupCompleted: () {
                                if (kDebugMode) debugPrint('Biyometri kurulumu tamamlandı');
                              },
                              onSetupSkipped: () {
                                if (kDebugMode) debugPrint('Biyometri kurulumu atlandı');
                              },
                            ),
                            */
                            const SizedBox(height: 8),

                            // Giriş sayfasına yönlendir
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                'Zaten hesabınız var mı? Giriş Yapın',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
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
