// lib/pages/quiz_settings_page.dart
// Modern Quiz Settings Page - Glass Morphism Design
import 'package:flutter/material.dart';
import '../models/question.dart';
import '../theme/theme_colors.dart';
import '../enums/app_language.dart';

class QuizSettingsPage extends StatefulWidget {
  final Function({
    required String category,
    required DifficultyLevel difficulty,
    required int questionCount,
    required AppLanguage language,
  }) onStartQuiz;

  const QuizSettingsPage({
    super.key,
    required this.onStartQuiz,
  });

  @override
  State<QuizSettingsPage> createState() => _QuizSettingsPageState();
}

class _QuizSettingsPageState extends State<QuizSettingsPage> {
  String _selectedCategory = 'Tümü';
  DifficultyLevel _selectedDifficulty = DifficultyLevel.medium;
  int _selectedQuestionCount = 15;

  // Kategori verileri
  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Tümü',
      'icon': Icons.public,
      'color': Colors.purple,
      'description': 'Tüm kategorilerden sorular',
      'questionCount': 25,
    },
    {
      'name': 'Enerji',
      'icon': Icons.bolt,
      'color': Colors.orange,
      'description': 'Enerji tasarrufu ve yenilenebilir enerji',
      'questionCount': 4,
    },
    {
      'name': 'Su',
      'icon': Icons.water_drop,
      'color': Colors.blue,
      'description': 'Su tasarrufu ve su kirliliği',
      'questionCount': 4,
    },
    {
      'name': 'Orman',
      'icon': Icons.forest,
      'color': Colors.green,
      'description': 'Orman koruma ve biyoçeşitlilik',
      'questionCount': 4,
    },
    {
      'name': 'Geri Dönüşüm',
      'icon': Icons.recycling,
      'color': Colors.teal,
      'description': 'Geri dönüşüm ve atık yönetimi',
      'questionCount': 4,
    },
    {
      'name': 'Ulaşım',
      'icon': Icons.directions_car,
      'color': Colors.indigo,
      'description': 'Sürdürülebilir ulaşım',
      'questionCount': 3,
    },
    {
      'name': 'Tüketim',
      'icon': Icons.shopping_cart,
      'color': Colors.pink,
      'description': 'Sürdürülebilir tüketim alışkanlıkları',
      'questionCount': 6,
    },
  ];

  // Zorluk seviyesi verileri
  final List<Map<String, dynamic>> _difficulties = [
    {
      'level': DifficultyLevel.easy,
      'name': 'Kolay',
      'icon': Icons.sentiment_very_satisfied,
      'color': Colors.green,
      'description': 'Temel çevre bilgisi',
      'multiplier': '1x Puan',
      'time': '~5-7 dk',
    },
    {
      'level': DifficultyLevel.medium,
      'name': 'Orta',
      'icon': Icons.sentiment_neutral,
      'color': Colors.orange,
      'description': 'Orta seviye çevre bilgisi',
      'multiplier': '2x Puan',
      'time': '~7-10 dk',
    },
    {
      'level': DifficultyLevel.hard,
      'name': 'Zor',
      'icon': Icons.sentiment_very_dissatisfied,
      'color': Colors.red,
      'description': 'İleri seviye çevre bilgisi',
      'multiplier': '3x Puan',
      'time': '~10-15 dk',
    },
  ];

  // Soru sayısı seçenekleri
  final List<Map<String, dynamic>> _questionCounts = [
    {'count': 5, 'label': 'Hızlı', 'time': '2-3 dk', 'color': Colors.cyan},
    {'count': 10, 'label': 'Standart', 'time': '5-6 dk', 'color': Colors.blue},
    {'count': 15, 'label': 'Kapsamlı', 'time': '7-8 dk', 'color': Colors.purple},
    {'count': 20, 'label': 'Uzun', 'time': '10-12 dk', 'color': Colors.deepPurple},
    {'count': 25, 'label': 'Tam', 'time': '12-15 dk', 'color': Colors.pink},
  ];

  int get _estimatedTime {
    final count = _questionCounts.firstWhere(
      (c) => c['count'] == _selectedQuestionCount,
    );
    final timeStr = count['time'] as String;
    final timeNum = int.parse(timeStr.split('-').first.replaceAll('~', ''));
    return timeNum;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

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
              // Header
              _buildHeader(context),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isMobile ? 16 : 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Kategori Seçimi
                      _buildSectionTitle(context, 'Kategori Seçin', Icons.category),
                      const SizedBox(height: 16),
                      _buildCategoryGrid(context, isMobile),
                      const SizedBox(height: 32),

                      // Zorluk Seviyesi
                      _buildSectionTitle(context, 'Zorluk Seviyesi', Icons.speed),
                      const SizedBox(height: 16),
                      _buildDifficultySelection(context),
                      const SizedBox(height: 32),

                      // Soru Sayısı
                      _buildSectionTitle(context, 'Soru Sayısı', Icons.numbers),
                      const SizedBox(height: 16),
                      _buildQuestionCountSelection(context),
                      const SizedBox(height: 32),

                      // Özet Kartı
                      _buildSummaryCard(context),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Başlat Butonu
              _buildStartButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quiz Oluştur',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ayarlarınızı seçip quize başlayın',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryGrid(BuildContext context, bool isMobile) {
    final crossAxisCount = isMobile ? 2 : 4;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: isMobile ? 0.9 : 1.1,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        final isSelected = _selectedCategory == category['name'];
        return _buildCategoryCard(category, isSelected);
      },
    );
  }

  Widget _buildCategoryCard(
    Map<String, dynamic> category,
    bool isSelected,
  ) {
    final color = category['color'] as Color;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category['name'] as String;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    color.withOpacity(0.8),
                    color.withOpacity(0.6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.white.withOpacity(0.2),
            width: isSelected ? 3 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.25)
                      : color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  category['icon'] as IconData,
                  color: isSelected ? Colors.white : color,
                  size: 28,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                category['name'] as String,
                style: TextStyle(
                  color: isSelected ? Colors.white : null,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${category['questionCount']} soru',
                style: TextStyle(
                  color: isSelected
                      ? Colors.white.withOpacity(0.8)
                      : Colors.white60,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultySelection(BuildContext context) {
    return Row(
      children: _difficulties.map((difficulty) {
        final isSelected = _selectedDifficulty == difficulty['level'];
        final color = difficulty['color'] as Color;

        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedDifficulty = difficulty['level'] as DifficultyLevel;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [
                          color.withOpacity(0.8),
                          color.withOpacity(0.6),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      )
                    : null,
                color: isSelected ? null : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? color : Colors.white.withOpacity(0.2),
                  width: isSelected ? 2 : 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : null,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                child: Column(
                  children: [
                    Icon(
                      difficulty['icon'] as IconData,
                      color: isSelected ? Colors.white : color,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      difficulty['name'] as String,
                      style: TextStyle(
                        color: isSelected ? Colors.white : null,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      difficulty['multiplier'] as String,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white.withOpacity(0.9)
                            : Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      difficulty['time'] as String,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white.withOpacity(0.7)
                            : Colors.white60,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuestionCountSelection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          // Slider
          Slider(
            value: _selectedQuestionCount.toDouble(),
            min: 5,
            max: 25,
            divisions: 4,
            activeColor: ThemeColors.getPrimaryButtonColor(context),
            inactiveColor: Colors.white.withOpacity(0.3),
            onChanged: (value) {
              setState(() {
                _selectedQuestionCount = value.toInt();
              });
            },
          ),

          // Seçenekler
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _questionCounts.map((option) {
              final isSelected = _selectedQuestionCount == option['count'];
              final color = option['color'] as Color;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedQuestionCount = option['count'] as int;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [color, color.withOpacity(0.7)],
                          )
                        : null,
                    color: isSelected ? null : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? color : Colors.white.withOpacity(0.2),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${option['count']}',
                        style: TextStyle(
                          color: isSelected ? Colors.white : null,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        option['label'] as String,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white.withOpacity(0.9)
                              : Colors.white60,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Tahmini süre
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: ThemeColors.getPrimaryButtonColor(context)
                  .withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: ThemeColors.getPrimaryButtonColor(context)
                    .withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.timer,
                  color: ThemeColors.getPrimaryButtonColor(context),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Tahmini Süre: $_estimatedTime dakika',
                  style: TextStyle(
                    color: ThemeColors.getPrimaryButtonColor(context),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    final selectedCategoryData = _categories.firstWhere(
      (cat) => cat['name'] == _selectedCategory,
    );
    final selectedDifficultyData = _difficulties.firstWhere(
      (diff) => diff['level'] == _selectedDifficulty,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.summarize, color: Colors.white, size: 24),
              const SizedBox(width: 10),
              Text(
                'Quiz Özeti',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSummaryRow(
            context,
            'Kategori',
            _selectedCategory,
            selectedCategoryData['icon'] as IconData,
            selectedCategoryData['color'] as Color,
          ),
          const SizedBox(height: 12),
          _buildSummaryRow(
            context,
            'Zorluk',
            '${selectedDifficultyData['name']} (${selectedDifficultyData['multiplier']})',
            selectedDifficultyData['icon'] as IconData,
            selectedDifficultyData['color'] as Color,
          ),
          const SizedBox(height: 12),
          _buildSummaryRow(
            context,
            'Soru Sayısı',
            '$_selectedQuestionCount soru (~$_estimatedTime dk)',
            Icons.quiz,
            ThemeColors.getPrimaryButtonColor(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _startQuiz,
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeColors.getPrimaryButtonColor(context),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
              shadowColor:
                  ThemeColors.getPrimaryButtonColor(context).withOpacity(0.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.play_arrow, size: 24),
                const SizedBox(width: 10),
                const Text(
                  'Quiz Başlat',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _startQuiz() {
    widget.onStartQuiz(
      category: _selectedCategory,
      difficulty: _selectedDifficulty,
      questionCount: _selectedQuestionCount,
      language: AppLanguage.turkish,
    );
  }
}

