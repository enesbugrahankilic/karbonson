import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/profile_service.dart';
import '../services/authentication_state_service.dart';
import '../theme/design_system.dart';
import '../theme/theme_colors.dart';
import '../widgets/page_templates.dart';
import 'register_page.dart';
import 'welcome_page.dart';
import 'forgot_password_page.dart';

class LoginPage extends StatefulWidget {
   const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ProfileService _profileService = ProfileService();
  final AuthenticationStateService _authStateService = AuthenticationStateService();
  bool _isLoading = false;
  String? _errorMessage;
  bool _showPassword = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Fade animation for the entire form
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    // Slide animation for the card
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    // Scale animation for the logo
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Start animations
    _fadeController.forward();
    _scaleController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _slideController.forward();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'E-posta ve şifre gerekli');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (userCredential.user != null) {
        // Validate token immediately after login
        try {
          final tokenRefreshed = await _authStateService.refreshTokenIfNeeded();
          if (!tokenRefreshed) {
            setState(() => _errorMessage = 'Oturum başlatılırken sorun oluştu. Lütfen tekrar deneyin.');
            return;
          }
        } catch (tokenError) {
          if (kDebugMode) {
            debugPrint('Token validation failed after login: $tokenError');
          }
          setState(() => _errorMessage = 'Oturum doğrulanırken sorun oluştu. Lütfen tekrar deneyin.');
          return;
        }

        final nickname = await _profileService.getCurrentNickname() ??
            userCredential.user?.email?.split('@')[0] ??
            'Kullanıcı';

        await _authStateService.setAuthenticatedUser(
          nickname: nickname,
          uid: userCredential.user!.uid,
        );

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => WelcomePage(
                userName: nickname,
                isGuest: false,
              ),
            ),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'user-not-found') {
          _errorMessage = 'Kullanıcı bulunamadı';
        } else if (e.code == 'wrong-password') {
          _errorMessage = 'Şifre yanlış';
        } else if (e.code == 'invalid-email') {
          _errorMessage = 'Geçersiz e-posta formatı';
        } else if (e.code == 'user-disabled') {
          _errorMessage = 'Bu hesap devre dışı bırakılmış';
        } else if (e.code == 'too-many-requests') {
          _errorMessage = 'Çok fazla başarısız giriş denemesi. Lütfen daha sonra tekrar deneyin';
        } else if (e.code == 'network-request-failed') {
          _errorMessage = 'İnternet bağlantısı sorunu. Bağlantınızı kontrol edin.';
        } else if (e.code == 'invalid-credential') {
          _errorMessage = 'Geçersiz giriş bilgileri';
        } else {
          _errorMessage = 'Giriş hatası: ${e.message}';
        }
      });
    } catch (e) {
      setState(() => _errorMessage = 'Beklenmeyen hata: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateToForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ForgotPasswordPage(),
      ),
    );
  }

  void _guestLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const WelcomePage(
          userName: 'Misafir',
          isGuest: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StandardAppBar(
        title: const Text('Giriş Yap'),
        showBackButton: true,
        onBackPressed: () => Navigator.pop(context),
      ),
      body: Container(
        decoration: DesignSystem.getPageContainerDecoration(context),
        child: PageBody(
          scrollable: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo and title section with enhanced animations
              FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    children: [
                      // Enhanced gradient circle with animation
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).primaryColor,
                              Theme.of(context).primaryColor.withValues(alpha: 0.6),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).primaryColor.withValues(alpha: 0.4),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                              spreadRadius: 2,
                            ),
                            BoxShadow(
                              color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                              blurRadius: 60,
                              offset: const Offset(0, 30),
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.eco,
                          size: 56,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Title with enhanced styling
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            Colors.white,
                            Colors.white.withValues(alpha: 0.95),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: Text(
                          'KarbonSon',
                          style: DesignSystem.getDisplaySmall(context).copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                offset: const Offset(0, 3),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Subtitle with better spacing
                      Text(
                        'Çevre Dostu Quiz Uygulaması',
                        style: DesignSystem.getBodyMedium(context).copyWith(
                          color: ThemeColors.getTextOnColoredBackground(context).withValues(alpha: 0.95),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      // Motivational tagline
                      const SizedBox(height: 6),
                      Text(
                        'Bilgi ile Gezegeni Koru',
                        style: DesignSystem.getBodySmall(context).copyWith(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          letterSpacing: 0.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 36),

              // Login form card with enhanced styling
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: DesignSystem.glassCard(
                    context,
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Centered form title
                        Text(
                          'Hesabınıza Giriş Yapın',
                          style: DesignSystem.getHeadlineSmall(context).copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 22,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        Text(
                          'E-posta ve şifrenizle başlayın',
                          style: DesignSystem.getBodySmall(context).copyWith(
                            color: Colors.grey[600],
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 24),

                        // Error message with better styling
                        if (_errorMessage != null) ...[
                          _buildErrorAlert(),
                          const SizedBox(height: 20),
                        ],

                        // Email field with enhanced styling
                        _buildEmailField(),

                        const SizedBox(height: 18),

                        // Password field with show/hide toggle
                        _buildPasswordField(),

                        const SizedBox(height: 12),

                        // Forgot password link with better styling
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _navigateToForgotPassword,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                              minimumSize: const Size(0, 28),
                            ),
                            child: Text(
                              'Şifremi Unuttum?',
                              style: DesignSystem.getBodySmall(context).copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Enhanced login button
                        _buildLoginButton(),

                        const SizedBox(height: 20),

                        // Divider
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.grey.withValues(alpha: 0.3))),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'veya',
                                style: DesignSystem.getBodySmall(context).copyWith(
                                  color: Colors.grey[600],
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.grey.withValues(alpha: 0.3))),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Register link with better styling
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                            border: Border.all(
                              color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Hesabın yok mu? ',
                                style: DesignSystem.getBodyMedium(context).copyWith(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => RegisterPage()),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
                                  minimumSize: const Size(0, 20),
                                ),
                                child: Text(
                                  'Kaydol',
                                  style: DesignSystem.getBodyMedium(context).copyWith(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Theme.of(context).primaryColor,
                                    decorationThickness: 2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Guest mode button
                        Container(
                          padding: const EdgeInsets.all(11),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                            border: Border.all(
                              color: Colors.amber.withValues(alpha: 0.2),
                              width: 1.5,
                            ),
                          ),
                          child: InkWell(
                            onTap: _guestLogin,
                            borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.waving_hand,
                                  color: Colors.amber[700],
                                  size: 17,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Misafir Olarak Giriş Yap',
                                  style: DesignSystem.getBodyMedium(context).copyWith(
                                    color: Colors.amber[700],
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// Build error alert widget
  Widget _buildErrorAlert() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(DesignSystem.radiusM),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: DesignSystem.getBodyMedium(context).copyWith(
                color: Colors.red.shade700,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build email input field
  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      decoration: DesignSystem.getInputDecoration(
        context,
        labelText: 'E-posta Adresi',
        hintText: 'ornek@email.com',
        prefixIcon: Icon(
          Icons.email_outlined,
          color: Theme.of(context).primaryColor.withValues(alpha: 0.7),
        ),
      ),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      enabled: !_isLoading,
      style: DesignSystem.getBodyMedium(context).copyWith(
        fontWeight: FontWeight.w500,
      ),
    );
  }

  /// Build password input field with show/hide toggle
  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      decoration: DesignSystem.getInputDecoration(
        context,
        labelText: 'Şifre',
        hintText: 'Şifrenizi girin',
        prefixIcon: Icon(
          Icons.lock_outlined,
          color: Theme.of(context).primaryColor.withValues(alpha: 0.7),
        ),
        suffixIcon: IconButton(
          onPressed: () => setState(() => _showPassword = !_showPassword),
          icon: Icon(
            _showPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: Theme.of(context).primaryColor.withValues(alpha: 0.6),
          ),
        ),
      ),
      obscureText: !_showPassword,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _login(),
      enabled: !_isLoading,
      style: DesignSystem.getBodyMedium(context).copyWith(
        fontWeight: FontWeight.w500,
      ),
    );
  }

  /// Build enhanced login button
  Widget _buildLoginButton() {
    return SizedBox(
      height: 60,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(DesignSystem.radiusM),
          gradient: LinearGradient(
            colors: _isLoading
                ? [Colors.grey[400]!, Colors.grey[500]!]
                : [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withValues(alpha: 0.8),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: _isLoading
              ? null
              : [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                    spreadRadius: 2,
                  ),
                ],
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _login,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignSystem.radiusM),
            ),
          ),
          child: _isLoading
              ? DesignSystem.modernProgressIndicator(
                  context,
                  color: Colors.white,
                  strokeWidth: 3,
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.login, size: 22),
                    const SizedBox(width: 12),
                    Text(
                      'Giriş Yap',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    ],
                  ),
          ),
        ),
      );
    }
  }

