import 'package:flutter/material.dart';
import '../theme/theme_colors.dart';

/// Email Verification Redirect Page for unverified users
/// Shown after password reset when user's email is not verified
class EmailVerificationRedirectPage extends StatefulWidget {
  const EmailVerificationRedirectPage({super.key});

  @override
  State<EmailVerificationRedirectPage> createState() => _EmailVerificationRedirectPageState();
}

class _EmailVerificationRedirectPageState extends State<EmailVerificationRedirectPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _loadingController;
  late Animation<double> _loadingAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Fade animation for page entrance
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    ));
    _animationController.forward();

    // Loading animation for progress indicator
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _loadingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _loadingController,
      curve: Curves.easeInOut,
    ));
    _loadingController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: ThemeColors.getGradientColors(context),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    color: ThemeColors.getContainerBackground(context),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header with animation
                          AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(0, (1 - _fadeAnimation.value) * 30),
                                child: Icon(
                                  Icons.mark_email_read_outlined,
                                  size: 80,
                                  color: ThemeColors.getGreen(context),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'E-posta Doğrulama Gerekli',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: ThemeColors.getText(context),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Şifre sıfırlama işlemi tamamlandı, ancak e-posta adresiniz henüz doğrulanmamış.',
                            style: TextStyle(
                              fontSize: 16,
                              color: ThemeColors.getSecondaryText(context),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          
                          // Information box
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.blue.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.blue,
                                  size: 32,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Sonraki Adımlar:',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  '1. E-posta kutunuzu kontrol edin\n2. Doğrulama linkine tıklayın\n3. Hesabınızı doğruladıktan sonra giriş yapabilirsiniz',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.blue,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          
                          // Action buttons
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).popUntil((route) => route.isFirst);
                              },
                              icon: const Icon(Icons.check_circle),
                              label: const Text('Anladım'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ThemeColors.getPrimaryButtonColor(context),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              icon: const Icon(Icons.arrow_back),
                              label: const Text('Giriş Sayfasına Dön'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: ThemeColors.getPrimaryButtonColor(context),
                                side: BorderSide(
                                  color: ThemeColors.getPrimaryButtonColor(context),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
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
        ),
      ),
    );
  }
}