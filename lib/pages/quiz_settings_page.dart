// lib/pages/quiz_settings_page.dart
// Redesigned Quiz Settings Page - Wide Widgets with Scrollable Layout
import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/quiz_settings_service.dart';
import '../theme/theme_colors.dart';
import '../theme/design_system.dart';
import '../enums/app_language.dart';
import '../widgets/page_templates.dart';

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
  AppLanguage _selectedLanguage = AppLanguage.turkish;

  // Kategori verileri
  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Tümü',
      'icon': Icons.public,
      'color': Colors.purple,
      'description': 'Tüm kategorilerden sorular',
      'questionCount': 1000,
    },
    {
      'name': 'Enerji',
      'icon': Icons.bolt,
      'color': Colors.orange,
      'description': 'Enerji tasarrufu ve yenilenebilir enerji',
      'questionCount': 200,
    },
    {
      'name': 'Su',
      'icon': Icons.water_drop,
      'color': Colors.blue,
      'description': 'Su tasarrufu ve su kirliliği',
      'questionCount': 200,
    },
    {
      'name': 'Orman',
      'icon': Icons.forest,
      'color': Colors.green,
      'description': 'Orman koruma ve biyoçeşitlilik',
      'questionCount': 100,
    },
    {
      'name': 'Geri Dönüşüm',
      'icon': Icons.recycling,
      'color': Colors.teal,
      'description': 'Geri dönüşüm ve atık yönetimi',
      'questionCount': 100,
    },
    {
      'name': 'Ulaşım',
      'icon': Icons.directions_car,
      'color': Colors.indigo,
      'description': 'Sürdürülebilir ulaşım',
      'questionCount': 100,
    },
    {
      'name': 'Tüketim',
      'icon': Icons.shopping_cart,
      'color': Colors.pink,
      'description': 'Sürdürülebilir tüketim alışkanlıkları',
      'questionCount': 100,
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

  // Dil seçenekleri
  final List<Map<String, dynamic>> _languages = [
    {
      'language': AppLanguage.turkish,
      'name': 'Türkçe',
      'flag': '🇹🇷',
      'description': 'Türkçe sorular',
      'color': Colors.red,
    },
    {
      'language': AppLanguage.english,
      'name': 'English',
      'flag': '🇺🇸',
      'description': 'English questions',
      'color': Colors.blue,
    },
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
  void initState() {
    super.initState();
    _loadSavedSettings();
  }

  Future<void> _loadSavedSettings() async {
    try {
      final hasSettings = await QuizSettingsService().hasQuizSettings();
      if (hasSettings) {
        final settings = await QuizSettingsService().getQuizSettings();
        if (settings != null && mounted) {
          setState(() {
            _selectedCategory = settings.category ?? 'Tümü';
            _selectedDifficulty = settings.difficulty ?? DifficultyLevel.medium;
            _selectedLanguage = settings.language;
          });
        }
      }
    } catch (e) {
      // Ignore errors, use defaults
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StandardAppBar(
        title: const Text('Quiz Ayarları'),
        onBackPressed: () => Navigator.pop(context),
      ),
      body: PageBody(
        scrollable: true,
        child: Column(
          children: [
            // Header
            _buildHeader(context),

            // Content
            Padding(
              padding: const EdgeInsets.all(DesignSystem.spacingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    // Kategori Seçimi - Wide Card
                    _buildSectionTitle(context, 'Kategori Seçin', Icons.category),
                    const SizedBox(height: DesignSystem.spacingM),
                    _buildCategorySelection(context),
                    const SizedBox(height: DesignSystem.spacingXl),

                    // Zorluk Seviyesi - Wide Cards
                    _buildSectionTitle(context, 'Zorluk Seviyesi', Icons.speed),
                    const SizedBox(height: DesignSystem.spacingM),
                    _buildDifficultySelection(context),
                    const SizedBox(height: DesignSystem.spacingXl),

                    // Soru Sayısı - Wide Tiles
                    _buildSectionTitle(context, 'Soru Sayısı', Icons.numbers),
                    const SizedBox(height: DesignSystem.spacingM),
                    _buildQuestionCountSelection(context),
                    const SizedBox(height: DesignSystem.spacingXl),

                    // Dil Seçimi - Wide Cards
                    _buildSectionTitle(context, 'Dil Seçimi', Icons.language),
                    const SizedBox(height: DesignSystem.spacingM),
                    _buildLanguageSelection(context),
                    const SizedBox(height: DesignSystem.spacingXl),

                    // Özet Kartı - Full Width
                    _buildSummaryCard(context),
                    const SizedBox(height: DesignSystem.spacingXl),

                    // Başlat Butonu
                    _buildStartButton(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(DesignSystem.spacingL),
      child: Row(
        children: [
          DesignSystem.semantic(
            context,
            label: 'Geri git',
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back, color: ThemeColors.getTextOnColoredBackground(context)),
              iconSize: 28,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(
                width: 48.0,
                height: 48.0,
              ),
            ),
          ),
          const SizedBox(width: DesignSystem.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DesignSystem.semantic(
                  context,
                  label: 'Quiz oluştur başlığı',
                  child: Text(
                    'Quiz Oluştur',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
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
    return DesignSystem.semantic(
      context,
      label: '$title bölümü',
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(DesignSystem.spacingS),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(DesignSystem.radiusM),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: DesignSystem.spacingM),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    // Horizontal scroll for wide category selection
    return SizedBox(
      height: isTablet ? 140 : 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category['name'];
          final color = category['color'] as Color;

          return DesignSystem.semantic(
            context,
            label: '${category['name']} kategorisi',
            hint: '${category['questionCount']} soru - ${category['description']}',
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = category['name'] as String;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isTablet ? 140 : 120,
                margin: const EdgeInsets.only(right: DesignSystem.spacingM),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            color.withValues(alpha: 0.9),
                            color.withValues(alpha: 0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isSelected ? null : Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DesignSystem.radiusL),
                  border: Border.all(
                    color: isSelected ? color : Colors.white.withValues(alpha: 0.2),
                    width: isSelected ? 3 : 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: color.withValues(alpha: 0.5),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ]
                      : null,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(DesignSystem.spacingM),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.25)
                              : color.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          category['icon'] as IconData,
                          color: isSelected ? Colors.white : color,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: DesignSystem.spacingS),
                      Expanded(
                        child: Text(
                          category['name'] as String,
                          style: TextStyle(
                            color: isSelected ? Colors.white : null,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${category['questionCount']} soru',
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.8)
                              : Colors.white60,
                          fontSize: 11,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDifficultySelection(BuildContext context) {
    return Column(
      children: _difficulties.asMap().entries.map((entry) {
        final index = entry.key;
        final difficulty = entry.value;
        final isSelected = _selectedDifficulty == difficulty['level'];
        final color = difficulty['color'] as Color;
        final isFirst = index == 0;
        final isLast = index == _difficulties.length - 1;

        return DesignSystem.semantic(
          context,
          label: '${difficulty['name']} zorluk seviyesi',
          hint: '${difficulty['description']} - ${difficulty['multiplier']} - ${difficulty['time']}',
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedDifficulty = difficulty['level'] as DifficultyLevel;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: isFirst
                  ? EdgeInsets.zero
                  : const EdgeInsets.only(top: DesignSystem.spacingM),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [
                          color.withValues(alpha: 0.9),
                          color.withValues(alpha: 0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected ? null : Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(DesignSystem.radiusL),
                border: Border.all(
                  color: isSelected ? color : Colors.white.withValues(alpha: 0.15),
                  width: isSelected ? 2.5 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : null,
              ),
              child: Padding(
                padding: const EdgeInsets.all(DesignSystem.spacingL),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.25)
                            : color.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        difficulty['icon'] as IconData,
                        color: isSelected ? Colors.white : color,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: DesignSystem.spacingL),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            difficulty['name'] as String,
                            style: TextStyle(
                              color: isSelected ? Colors.white : null,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            difficulty['description'] as String,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.9)
                                  : Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          difficulty['multiplier'] as String,
                          style: TextStyle(
                            color: isSelected ? Colors.white : color,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          difficulty['time'] as String,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.8)
                                : Colors.white60,
                            fontSize: 13,
                          ),
                        ),
                      ],
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
    return Column(
      children: _questionCounts.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        final isSelected = _selectedQuestionCount == option['count'];
        final color = option['color'] as Color;
        final isFirst = index == 0;
        final isLast = index == _questionCounts.length - 1;

        return DesignSystem.semantic(
          context,
          label: '${option['count']} soru seçimi',
          hint: '${option['label']} quiz - ${option['time']}',
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedQuestionCount = option['count'] as int;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: isFirst
                  ? EdgeInsets.zero
                  : const EdgeInsets.only(top: DesignSystem.spacingM),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [
                          color.withValues(alpha: 0.9),
                          color.withValues(alpha: 0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected ? null : Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(DesignSystem.radiusL),
                border: Border.all(
                  color: isSelected ? color : Colors.white.withValues(alpha: 0.15),
                  width: isSelected ? 2.5 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : null,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignSystem.spacingL,
                  vertical: DesignSystem.spacingM,
                ),
                child: Row(
                  children: [
                    Radio<int>(
                      value: option['count'] as int,
                      groupValue: _selectedQuestionCount,
                      onChanged: (value) {
                        setState(() {
                          _selectedQuestionCount = value!;
                        });
                      },
                      activeColor: Colors.white,
                      fillColor: WidgetStateProperty.resolveWith<Color>(
                        (states) {
                          return isSelected ? Colors.white : color;
                        },
                      ),
                    ),
                    const SizedBox(width: DesignSystem.spacingM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${option['count']}',
                                style: TextStyle(
                                  color: isSelected ? Colors.white : color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Soru',
                                style: TextStyle(
                                  color: isSelected ? Colors.white : null,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            option['label'] as String,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.9)
                                  : Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: DesignSystem.spacingM,
                        vertical: DesignSystem.spacingS,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.2)
                            : color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.timer,
                            color: isSelected ? Colors.white : color,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            option['time'] as String,
                            style: TextStyle(
                              color: isSelected ? Colors.white : color,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
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
        );
      }).toList(),
    );
  }

  Widget _buildLanguageSelection(BuildContext context) {
    return Column(
      children: _languages.asMap().entries.map((entry) {
        final index = entry.key;
        final language = entry.value;
        final isSelected = _selectedLanguage == language['language'];
        final color = language['color'] as Color;
        final isFirst = index == 0;

        return DesignSystem.semantic(
          context,
          label: '${language['name']} dil seçimi',
          hint: language['description'] as String,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedLanguage = language['language'] as AppLanguage;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: isFirst
                  ? EdgeInsets.zero
                  : const EdgeInsets.only(top: DesignSystem.spacingM),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [
                          color.withValues(alpha: 0.9),
                          color.withValues(alpha: 0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected ? null : Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(DesignSystem.radiusL),
                border: Border.all(
                  color: isSelected ? color : Colors.white.withValues(alpha: 0.15),
                  width: isSelected ? 2.5 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : null,
              ),
              child: Padding(
                padding: const EdgeInsets.all(DesignSystem.spacingL),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.25)
                            : color.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        language['flag'] as String,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                    const SizedBox(width: DesignSystem.spacingL),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            language['name'] as String,
                            style: TextStyle(
                              color: isSelected ? Colors.white : null,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            language['description'] as String,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.9)
                                  : Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Radio<AppLanguage>(
                      value: language['language'] as AppLanguage,
                      groupValue: _selectedLanguage,
                      onChanged: (value) {
                        setState(() {
                          _selectedLanguage = value!;
                        });
                      },
                      activeColor: Colors.white,
                      fillColor: WidgetStateProperty.resolveWith<Color>(
                        (states) {
                          return isSelected ? Colors.white : color;
                        },
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

  Widget _buildSummaryCard(BuildContext context) {
    final selectedCategoryData = _categories.firstWhere(
      (cat) => cat['name'] == _selectedCategory,
    );
    final selectedDifficultyData = _difficulties.firstWhere(
      (diff) => diff['level'] == _selectedDifficulty,
    );
    final selectedLanguageData = _languages.firstWhere(
      (lang) => lang['language'] == _selectedLanguage,
    );

    return DesignSystem.glassCard(
      context,
      padding: const EdgeInsets.all(DesignSystem.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ThemeColors.getSuccessColor(context).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                ),
                child: Icon(
                  Icons.summarize,
                  color: ThemeColors.getSuccessColor(context),
                  size: 24,
                ),
              ),
              const SizedBox(width: DesignSystem.spacingM),
              Text(
                'Quiz Özeti',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: ThemeColors.getSuccessColor(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignSystem.spacingL),
          _buildSummaryRow(
            context,
            'Kategori',
            _selectedCategory,
            selectedCategoryData['icon'] as IconData,
            selectedCategoryData['color'] as Color,
          ),
          const SizedBox(height: DesignSystem.spacingM),
          _buildSummaryRow(
            context,
            'Zorluk',
            '${selectedDifficultyData['name']} (${selectedDifficultyData['multiplier']})',
            selectedDifficultyData['icon'] as IconData,
            selectedDifficultyData['color'] as Color,
          ),
          const SizedBox(height: DesignSystem.spacingM),
          _buildSummaryRow(
            context,
            'Soru Sayısı',
            '$_selectedQuestionCount soru (~$_estimatedTime dk)',
            Icons.quiz,
            ThemeColors.getPrimaryButtonColor(context),
          ),
          const SizedBox(height: DesignSystem.spacingM),
          _buildSummaryRow(
            context,
            'Dil',
            '${selectedLanguageData['flag']} ${selectedLanguageData['name']}',
            Icons.language,
            selectedLanguageData['color'] as Color,
          ),
          const SizedBox(height: DesignSystem.spacingL),
          Container(
            padding: const EdgeInsets.all(DesignSystem.spacingM),
            decoration: BoxDecoration(
              color: ThemeColors.getPrimaryButtonColor(context).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(DesignSystem.radiusM),
              border: Border.all(
                color: ThemeColors.getPrimaryButtonColor(context).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.play_circle_fill,
                  color: ThemeColors.getPrimaryButtonColor(context),
                  size: 24,
                ),
                const SizedBox(width: DesignSystem.spacingM),
                Expanded(
                  child: Text(
                    'Hazır! Quiz\'i başlatabilirsiniz.',
                    style: DesignSystem.getBodyLarge(context).copyWith(
                      color: ThemeColors.getPrimaryButtonColor(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
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
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(DesignSystem.radiusS),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: DesignSystem.spacingM),
        Text(
          '$label: ',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.spacingL),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _startQuiz,
            style: DesignSystem.getPrimaryButtonStyle(context).copyWith(
              minimumSize: const WidgetStatePropertyAll(
                Size.fromHeight(56),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.play_arrow, size: 26),
                const SizedBox(width: DesignSystem.spacingM),
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

  void _startQuiz() async {
    // ✅ Ayarları kaydet
    final settings = QuizSettings(
      category: _selectedCategory,
      difficulty: _selectedDifficulty,
      language: _selectedLanguage,
      mode: 'normal',
    );
    await QuizSettingsService().saveQuizSettings(settings);
    
    // Callback'i çağır
    widget.onStartQuiz(
      category: _selectedCategory,
      difficulty: _selectedDifficulty,
      questionCount: _selectedQuestionCount,
      language: _selectedLanguage,
    );
  }
}

