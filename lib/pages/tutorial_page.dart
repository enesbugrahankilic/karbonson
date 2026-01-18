import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/theme_colors.dart';

class TutorialPage extends StatefulWidget {
  const TutorialPage({super.key});

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _tutorialPages = [
    {
      'title': 'Eco Game\'e Hoş Geldiniz!',
      'content':
          'Çevre bilincini artıran eğlenceli bir tahta oyununa hazır mısınız? Zar atarak ilerleyin, quiz sorularını yanıtlayın ve en yüksek skoru elde etmeye çalışın!',
      'icon': '🎉',
    },
    {
      'title': 'Oyun Amacı',
      'content':
          'Hedefiniz tahtadaki "Bitiş" karesine ulaşmak! Zar atarak ilerlerken quiz sorularını yanıtlayın, bonus ve ceza karelerinden puan kazanın veya kaybedin.',
      'icon': '🎯',
    },
    {
      'title': 'Tahta Kareleri',
      'content':
          '• Başlangıç: Oyunun başladığı yer\n• Quiz: Soru yanıtlayın, doğru cevap puan kazandırır\n• Bonus: Ekstra puan kazanın\n• Ceza: Puan kaybı\n• Bitiş: Oyunu tamamlayın',
      'icon': '🎲',
    },
    {
      'title': 'Puanlama Sistemi',
      'content':
          'Quiz puanlarınız toplanır, ancak geçen süreye göre ceza uygulanır. Daha hızlı bitirirseniz daha yüksek skor elde edersiniz!',
      'icon': '📊',
    },
    {
      'title': 'Tek Oyuncu Modu',
      'content':
          'Tek başınıza oynayın. Zar atın, ilerleyin ve quiz sorularını yanıtlayın. Skorunuz kaydedilir ve liderlik tablosunda yer alabilirsiniz.',
      'icon': '👤',
    },
    {
      'title': 'Çok Oyuncu Modu',
      'content':
          'Arkadaşlarınızla birlikte oynayın! Sırayla zar atın, birbirinizi geçmeye çalışın. Oda oluşturun veya katılın.',
      'icon': '👥',
    },
    {
      'title': 'Nasıl Başlanır?',
      'content':
          'Giriş yapın, tek oyuncu veya çok oyuncu modunu seçin. Zar at butonuna tıklayarak oyuna başlayın. İyi eğlenceler!',
      'icon': '🚀',
    },
  ];

  void _nextPage() {
    if (_currentPage < _tutorialPages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeTutorial();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenTutorial', true);

    if (!mounted) return;

    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: ThemeColors.getGradientColors(context),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  itemCount: _tutorialPages.length,
                  itemBuilder: (context, index) {
                    final page = _tutorialPages[index];
                    return Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            page['icon']!,
                            style: const TextStyle(fontSize: 64),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            page['title']!,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          Card(
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey[800]!.withOpacity( 0.95)
                                    : Colors.white.withOpacity( 0.95),
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Text(
                                page['content']!,
                                style: TextStyle(
                                  fontSize: 18,
                                  height: 1.5,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _tutorialPages.length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentPage == index
                                ? (Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.white)
                                : (Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white.withOpacity( 0.5)
                                    : Colors.white.withOpacity( 0.5)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (_currentPage > 0)
                          ElevatedButton(
                            onPressed: _previousPage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[700]!.withOpacity( 0.8)
                                  : Colors.white.withOpacity( 0.8),
                              foregroundColor: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black87,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: const Text('Geri'),
                          )
                        else
                          const SizedBox(width: 80),
                        ElevatedButton(
                          onPressed: _nextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: Text(
                            _currentPage == _tutorialPages.length - 1
                                ? 'Oyuna Başla!'
                                : 'İleri',
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
    );
  }
}
