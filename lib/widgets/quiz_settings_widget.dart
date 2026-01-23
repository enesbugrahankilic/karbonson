import 'package:flutter/material.dart';
import '../models/question.dart';
import '../theme/theme_colors.dart';
import '../theme/design_system.dart';
import '../theme/app_theme.dart';

class QuizSettingsWidget extends StatefulWidget {
  final Function({
    String? category,
    DifficultyLevel difficulty,
    int questionCount,
  }) onSettingsChanged;

  const QuizSettingsWidget({
    super.key,
    required this.onSettingsChanged,
  });

  @override
  State<QuizSettingsWidget> createState() => _QuizSettingsWidgetState();
}

class _QuizSettingsWidgetState extends State<QuizSettingsWidget>
    with TickerProviderStateMixin {
  String? _selectedCategory = 'Tümü';
  DifficultyLevel _selectedDifficulty = DifficultyLevel.easy;
  int _selectedQuestionCount = 15;

  late AnimationController _fadeController;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  // Kategori verileri
  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Tümü',
      'icon': Icons.all_inclusive,
      'color': Colors.purple,
      'description': 'Tüm kategorilerden sorular',
    },
    {
      'name': 'Enerji',
      'icon': Icons.flash_on,
      'color': Colors.orange,
      'description': 'Enerji tasarrufu ve yenilenebilir enerji',
    },
    {
      'name': 'Su',
      'icon': Icons.water_drop,
      'color': Colors.blue,
      'description': 'Su tasarrufu ve su kirliliği',
    },
    {
      'name': 'Orman',
      'icon': Icons.nature,
      'color': Colors.green,
      'description': 'Orman koruma ve biyoçeşitlilik',
    },
    {
      'name': 'Geri Dönüşüm',
      'icon': Icons.recycling,
      'color': Colors.teal,
      'description': 'Geri dönüşüm ve atık yönetimi',
    },
    {
      'name': 'Ulaşım',
      'icon': Icons.directions_car,
      'color': Colors.indigo,
      'description': 'Sürdürülebilir ulaşım',
    },
    {
      'name': 'Tüketim',
      'icon': Icons.shopping_cart,
      'color': Colors.pink,
      'description': 'Sürdürülebilir tüketim alışkanlıkları',
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
      'multiplier': '1x',
    },
    {
      'level': DifficultyLevel.medium,
      'name': 'Orta',
      'icon': Icons.sentiment_neutral,
      'color': Colors.orange,
      'description': 'Orta seviye çevre bilgisi',
      'multiplier': '2x',
    },
    {
      'level': DifficultyLevel.hard,
      'name': 'Zor',
      'icon': Icons.sentiment_very_dissatisfied,
      'color': Colors.red,
      'description': 'İleri seviye çevre bilgisi',
      'multiplier': '3x',
    },
  ];

  // Soru sayısı seçenekleri
  final List<Map<String, dynamic>> _questionCounts = [
    {'count': 5, 'time': '2-3', 'description': 'Hızlı Quiz'},
    {'count': 10, 'time': '~5', 'description': 'Standart Quiz'},
    {'count': 15, 'time': '7-8', 'description': 'Kapsamlı Quiz'},
    {'count': 20, 'time': '10-12', 'description': 'Uzun Quiz'},
    {'count': 25, 'time': '12-15', 'description': 'Detaylı Quiz'},
  ];

  void _notifySettingsChanged() {
    widget.onSettingsChanged(
      category: _selectedCategory,
      difficulty: _selectedDifficulty,
      questionCount: _selectedQuestionCount,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeController,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(_slideController),
        child: DesignSystem.glassCard(
          context,
          child: Padding(
            padding: const EdgeInsets.all(DesignSystem.spacingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Başlık
                DesignSystem.semantic(
                  context,
                  label: 'Quiz ayarları başlığı',
                  child: Text(
                    'Quiz Ayarları',
                    style: DesignSystem.getHeadlineSmall(context).copyWith(
                      color: ThemeColors.getTitleColor(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: DesignSystem.spacingXl),

                // Kategori Seçimi
                _buildSectionHeader('Kategori Seçin'),
                const SizedBox(height: DesignSystem.spacingM),
                _buildCategorySelection(),
                const SizedBox(height: DesignSystem.spacingXl),

                // Zorluk Seviyesi
                _buildSectionHeader('Zorluk Seviyesi'),
                const SizedBox(height: DesignSystem.spacingM),
                _buildDifficultySelection(),
                const SizedBox(height: DesignSystem.spacingXl),

                // Soru Sayısı
                _buildSectionHeader('Soru Sayısı'),
                const SizedBox(height: DesignSystem.spacingM),
                _buildQuestionCountSelection(),
                const SizedBox(height: DesignSystem.spacingXl),

                // Özet
                _buildSummaryCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    IconData getIconForSection(String title) {
      switch (title) {
        case 'Kategori Seçin':
          return Icons.category;
        case 'Zorluk Seviyesi':
          return Icons.trending_up;
        case 'Soru Sayısı':
          return Icons.format_list_numbered;
        default:
          return Icons.settings;
      }
    }

    return DesignSystem.semantic(
      context,
      label: '$title bölümü',
      child: Row(
        children: [
          Icon(
            getIconForSection(title),
            color: ThemeColors.getTitleColor(context),
            size: 24,
          ),
          const SizedBox(width: DesignSystem.spacingM),
          Text(
            title,
            style: DesignSystem.getTitleLarge(context).copyWith(
              color: ThemeColors.getTitleColor(context),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth < 600 ? 1 : 2; // Küçük ekranlarda 1 sütun, büyüklerde 2

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: DesignSystem.spacingM,
        mainAxisSpacing: DesignSystem.spacingM,
        childAspectRatio: 1.2,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        final isSelected = _selectedCategory == category['name'];

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedCategory = category['name'];
            });
            _notifySettingsChanged();
          },
          child: DesignSystem.semantic(
            context,
            label: '${category['name']} kategorisi seçimi',
            hint: category['description'],
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [
                          category['color'],
                          category['color'].withValues(alpha:  0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected ? null : Colors.white.withValues(alpha:  0.1),
                borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                border: Border.all(
                  color: isSelected
                      ? category['color']
                      : Colors.white.withValues(alpha:  0.3),
                  width: 2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: category['color'].withValues(alpha:  0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Padding(
                padding: const EdgeInsets.all(DesignSystem.spacingM),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      category['icon'],
                      size: 32,
                      color: isSelected ? Colors.white : category['color'],
                    ),
                    const SizedBox(height: DesignSystem.spacingS),
                    Text(
                      category['name'],
                      style: DesignSystem.getBodyLarge(context).copyWith(
                        color: isSelected ? Colors.white : null,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: DesignSystem.spacingXs),
                    Text(
                      category['description'],
                      style: DesignSystem.getBodySmall(context).copyWith(
                        color: isSelected
                            ? Colors.white.withValues(alpha:  0.9)
                            : null,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDifficultySelection() {
    return Wrap(
      spacing: DesignSystem.spacingS,
      runSpacing: DesignSystem.spacingS,
      alignment: WrapAlignment.center,
      children: _difficulties.map((difficulty) {
        final isSelected = _selectedDifficulty == difficulty['level'];

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedDifficulty = difficulty['level'];
            });
            _notifySettingsChanged();
          },
          child: DesignSystem.semantic(
            context,
            label: '${difficulty['name']} zorluk seviyesi',
            hint: difficulty['description'],
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              constraints: const BoxConstraints(minWidth: 100, maxWidth: 120),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [
                          difficulty['color'],
                          difficulty['color'].withValues(alpha:  0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected ? null : Colors.white.withValues(alpha:  0.1),
                borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                border: Border.all(
                  color: isSelected
                      ? difficulty['color']
                      : Colors.white.withValues(alpha:  0.3),
                  width: 2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: difficulty['color'].withValues(alpha:  0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Padding(
                padding: const EdgeInsets.all(DesignSystem.spacingM),
                child: Column(
                  children: [
                    Icon(
                      difficulty['icon'],
                      size: 28,
                      color: isSelected ? Colors.white : difficulty['color'],
                    ),
                    const SizedBox(height: DesignSystem.spacingS),
                    Text(
                      difficulty['name'],
                      style: DesignSystem.getBodyLarge(context).copyWith(
                        color: isSelected ? Colors.white : null,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: DesignSystem.spacingXs),
                    Text(
                      difficulty['multiplier'],
                      style: DesignSystem.getBodySmall(context).copyWith(
                        color: isSelected
                            ? Colors.white.withValues(alpha:  0.9)
                            : difficulty['color'],
                        fontWeight: FontWeight.bold,
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

  Widget _buildQuestionCountSelection() {
    return Column(
      children: _questionCounts.map((option) {
        final isSelected = _selectedQuestionCount == option['count'];
        final index = _questionCounts.indexOf(option);

        return Padding(
          padding: EdgeInsets.only(
            bottom: index < _questionCounts.length - 1
                ? DesignSystem.spacingS
                : 0,
          ),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedQuestionCount = option['count'];
              });
              _notifySettingsChanged();
            },
            child: DesignSystem.semantic(
              context,
              label: '${option['count']} soru seçimi',
              hint: '${option['time']} dakika süre',
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected
                      ? ThemeColors.getPrimaryButtonColor(context).withValues(alpha:  0.1)
                      : Colors.white.withValues(alpha:  0.05),
                  borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                  border: Border.all(
                    color: isSelected
                        ? ThemeColors.getPrimaryButtonColor(context)
                        : Colors.white.withValues(alpha:  0.3),
                    width: 2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(DesignSystem.spacingM),
                  child: Row(
                    children: [
                      Radio<String>(
                        value: option['count'].toString(),
                        groupValue: _selectedQuestionCount.toString(),
                        onChanged: (value) {
                          setState(() {
                            _selectedQuestionCount = int.parse(value!);
                          });
                          _notifySettingsChanged();
                        },
                        activeColor: ThemeColors.getPrimaryButtonColor(context),
                      ),
                      const SizedBox(width: DesignSystem.spacingM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${option['count']} Soru',
                              style: DesignSystem.getBodyLarge(context).copyWith(
                                color: isSelected
                                    ? ThemeColors.getPrimaryButtonColor(context)
                                    : null,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: DesignSystem.spacingXs),
                            Text(
                              '~${option['time']} dakika • ${option['description']}',
                              style: DesignSystem.getBodySmall(context).copyWith(
                                color: isSelected
                                    ? ThemeColors.getPrimaryButtonColor(context).withValues(alpha:  0.8)
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: ThemeColors.getPrimaryButtonColor(context),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSummaryCard() {
    // Null safety için orElse ile fallback değeri ekle
    final selectedCategoryData = _categories.firstWhere(
      (cat) => cat['name'] == (_selectedCategory ?? 'Tümü'),
      orElse: () => _categories.first,
    );
    final selectedDifficultyData = _difficulties.firstWhere(
      (diff) => diff['level'] == _selectedDifficulty,
      orElse: () => _difficulties[1], // Medium varsayılan
    );

    return Container(
      padding: const EdgeInsets.all(DesignSystem.spacingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ThemeColors.getSuccessColor(context).withValues(alpha: 0.15),
            ThemeColors.getSuccessColor(context).withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(DesignSystem.radiusL),
        border: Border.all(
          color: ThemeColors.getSuccessColor(context).withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.getSuccessColor(context).withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.summarize,
                color: ThemeColors.getSuccessColor(context),
                size: 24,
              ),
              const SizedBox(width: DesignSystem.spacingM),
              DesignSystem.semantic(
                context,
                label: 'Quiz özeti',
                child: Text(
                  'Quiz Özeti',
                  style: DesignSystem.getTitleMedium(context).copyWith(
                    color: ThemeColors.getSuccessColor(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignSystem.spacingM),
          _buildSummaryRow(
            'Kategori',
            _selectedCategory!,
            selectedCategoryData['icon'],
            selectedCategoryData['color'],
          ),
          const SizedBox(height: DesignSystem.spacingS),
          _buildSummaryRow(
            'Zorluk',
            '${selectedDifficultyData['name']} (${selectedDifficultyData['multiplier']})',
            selectedDifficultyData['icon'],
            selectedDifficultyData['color'],
          ),
          const SizedBox(height: DesignSystem.spacingS),
          _buildSummaryRow(
            'Soru Sayısı',
            '$_selectedQuestionCount Soru (~${_questionCounts.firstWhere((opt) => opt['count'] == _selectedQuestionCount)['time']} dakika)',
            Icons.quiz,
            ThemeColors.getPrimaryButtonColor(context),
          ),
          const SizedBox(height: DesignSystem.spacingM),
          Container(
            padding: const EdgeInsets.all(DesignSystem.spacingM),
            decoration: BoxDecoration(
              color: ThemeColors.getSuccessColor(context).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DesignSystem.radiusM),
              border: Border.all(
                color: ThemeColors.getSuccessColor(context).withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.play_circle_fill,
                  color: ThemeColors.getSuccessColor(context),
                  size: 20,
                ),
                const SizedBox(width: DesignSystem.spacingM),
                Expanded(
                  child: Text(
                    'Hazır! Quiz\'i başlatabilirsiniz.',
                    style: DesignSystem.getBodyMedium(context).copyWith(
                      color: ThemeColors.getSuccessColor(context),
                      fontWeight: FontWeight.w500,
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

  Widget _buildSummaryRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: color,
        ),
        const SizedBox(width: DesignSystem.spacingM),
        Text(
          '$label: ',
          style: DesignSystem.getBodyMedium(context).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: DesignSystem.getBodyMedium(context).copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
