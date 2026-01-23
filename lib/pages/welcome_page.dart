import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/design_system.dart';
import '../theme/theme_colors.dart';
import '../widgets/page_templates.dart';
import 'profile_page.dart';
import 'how_to_play_page.dart';

class WelcomePage extends StatefulWidget {
  final String userName;
  final bool isGuest;

  const WelcomePage({
    super.key,
    required this.userName,
    this.isGuest = false,
  });

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _fadeController.forward();
        _scaleController.forward();
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) _slideController.forward();
        });
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _continueToApp() async {
    if (widget.isGuest) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const GuestHomePage(),
        ),
      );
      return;
    }

    // Check if user has seen How to Play
    final prefs = await SharedPreferences.getInstance();
    final hasSeenHowToPlay = prefs.getBool('hasSeenHowToPlay') ?? false;

    if (!hasSeenHowToPlay) {
      // First time user, show How to Play
      await prefs.setBool('hasSeenHowToPlay', true);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HowToPlayPage(),
        ),
      );
    } else {
      // Returning user, go to Profile
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ProfilePage(),
        ),
      );
    }
  }

  void _skipWelcome() {
    _continueToApp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: DesignSystem.getPageContainerDecoration(context),
        child: SafeArea(
          child: PageBody(
            scrollable: true,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  // Skip button
                  Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: _skipWelcome,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: Text(
                        'Geç',
                        style: DesignSystem.getBodyMedium(context).copyWith(
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Welcome content
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        // Welcome icon with scale animation
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).primaryColor,
                                  Theme.of(context).primaryColor.withOpacity(0.6),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).primaryColor.withOpacity(0.4),
                                  blurRadius: 30,
                                  offset: const Offset(0, 15),
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              widget.isGuest ? Icons.waving_hand : Icons.celebration,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: 36),

                        // Welcome message
                        SlideTransition(
                          position: _slideAnimation,
                          child: Column(
                            children: [
                              Text(
                                'Hoşgeldin!',
                                style: DesignSystem.getDisplaySmall(context).copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 36,
                                  letterSpacing: 1.2,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 16),

                              // User name greeting
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(DesignSystem.radiusL),
                                  border: Border.all(
                                    color: ThemeColors.getTextOnColoredBackground(context).withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  widget.isGuest
                                      ? 'Misafir Modu Aktif'
                                      : '${widget.userName}',
                                  style: DesignSystem.getHeadlineSmall(context).copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 20,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),

                              const SizedBox(height: 32),

                              // Description
                              Text(
                                widget.isGuest
                                    ? 'Eğlenceli çevre bilgisi quizlerine katıl ve gezegeni korumaya yardımcı ol'
                                    : 'KarbonSon\'a hoşgeldin! Çevre bilgisi quizlerine katılarak puan kazanabilirsin',
                                style: DesignSystem.getBodyMedium(context).copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 17,
                                  height: 1.6,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 32),

                              // Features list
                              Column(
                                children: [
                                  _buildFeatureItem(
                                    icon: Icons.quiz,
                                    title: 'Eğitici Quizler',
                                    description: 'Çevre ve karbon ayak izi hakkında öğren',
                                  ),
                                  const SizedBox(height: 16),
                                  _buildFeatureItem(
                                    icon: Icons.star,
                                    title: 'Puan Kazanma',
                                    description: 'Soruları doğru cevapla ve başarı elde et',
                                  ),
                                  const SizedBox(height: 16),
                                  _buildFeatureItem(
                                    icon: Icons.eco,
                                    title: 'Çevreyi Koru',
                                    description: 'Bilgin ile gezegeni koruyor ol',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Action buttons
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Primary button
                        SizedBox(
                          height: 60,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).primaryColor,
                                  Theme.of(context).primaryColor.withOpacity(0.8),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _continueToApp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    widget.isGuest ? Icons.play_arrow : Icons.arrow_forward,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    widget.isGuest ? 'Oyun Oyna' : 'Başla',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(DesignSystem.radiusM),
        border: Border.all(
          color: ThemeColors.getTextOnColoredBackground(context).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: DesignSystem.getBodyMedium(context).copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: DesignSystem.getBodySmall(context).copyWith(
                    color: Colors.white.withOpacity(0.75),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Guest Home Page - Misafir modunda oyunları oynayabileceği sayfa
class GuestHomePage extends StatefulWidget {
  const GuestHomePage({super.key});

  @override
  State<GuestHomePage> createState() => _GuestHomePageState();
}

class _GuestHomePageState extends State<GuestHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KarbonSon - Misafir Modu'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
      ),
      body: Container(
        decoration: DesignSystem.getPageContainerDecoration(context),
        child: PageBody(
          scrollable: true,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(DesignSystem.radiusL),
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.waving_hand,
                            size: 28,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Misafir Modu',
                            style: DesignSystem.getHeadlineSmall(context).copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 22,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Eğlenceli quizlere katılarak çevre hakkında öğren. Misafir modunda oynadığın quizler kaydedilmez ama yine de eğlenebilirsin!',
                        style: DesignSystem.getBodyMedium(context).copyWith(
                          fontSize: 14,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Available games section
                Text(
                  'Oyunlar',
                  style: DesignSystem.getHeadlineSmall(context).copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),

                const SizedBox(height: 16),

                // Game cards
                _buildGameCard(
                  context,
                  icon: Icons.quiz,
                  title: 'Hızlı Quiz',
                  description: 'Karbon ayak izi hakkında 5 soru cevapla',
                  color: Colors.blue,
                  onTap: () => _navigateToQuiz(context),
                ),

                const SizedBox(height: 12),

                _buildGameCard(
                  context,
                  icon: Icons.lightbulb,
                  title: 'Çevre Bilgisi',
                  description: 'Dünya hakkında ilginç bilgiler öğren',
                  color: Colors.green,
                  onTap: () => _navigateToQuiz(context),
                ),

                const SizedBox(height: 12),

                _buildGameCard(
                  context,
                  icon: Icons.trending_up,
                  title: 'Zorluk Seviyeleri',
                  description: 'Farklı zorluk seviyelerinde quiz oyna',
                  color: Colors.orange,
                  onTap: () => _navigateToQuiz(context),
                ),

                const SizedBox(height: 32),

                // Login button
                SizedBox(
                  height: 56,
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).primaryColor.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.login, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Giriş Yap veya Kaydol',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
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
      ),
    );
  }

  Widget _buildGameCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(DesignSystem.radiusM),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: DesignSystem.getBodyMedium(context).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: DesignSystem.getBodySmall(context).copyWith(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: color,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToQuiz(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Quiz sayfasına yönlendiriliyorsunuz...'),
        duration: Duration(milliseconds: 800),
      ),
    );
    // Quiz sayfasına navigate et
  }
}
