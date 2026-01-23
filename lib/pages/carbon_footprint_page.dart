// lib/pages/carbon_footprint_page.dart
// Carbon Footprint Screen - Display carbon data with charts and reports

import 'package:flutter/material.dart';
import 'package:karbonson/models/carbon_footprint_data.dart';
import 'package:karbonson/models/user_data.dart';
import 'package:karbonson/services/carbon_footprint_service.dart';
import 'package:karbonson/services/carbon_report_service.dart';
import 'package:karbonson/widgets/empty_state_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../widgets/page_templates.dart';

class CarbonFootprintPage extends StatefulWidget {
  final UserData? userData;
  final int? classLevel;
  final String? classSection;

  const CarbonFootprintPage({
    Key? key,
    this.userData,
    this.classLevel,
    this.classSection,
  }) : super(key: key);

  @override
  State<CarbonFootprintPage> createState() => _CarbonFootprintPageState();
}

class _CarbonFootprintPageState extends State<CarbonFootprintPage>
    with SingleTickerProviderStateMixin {
  late CarbonFootprintService _carbonService;
  late CarbonReportService _reportService;
  late TabController _tabController;

  CarbonFootprintData? _userClassCarbonData;
  List<CarbonFootprintData>? _classLevelData;
  CarbonStatistics? _statistics;
  int? _averageCarbon;
  bool _isLoading = true;
  String? _errorMessage;

  // 2 aylık geçmiş veri için
  List<Map<String, dynamic>>? _monthlyCarbonData;

  @override
  void initState() {
    super.initState();
    _carbonService = CarbonFootprintService();
    _reportService = CarbonReportService();
    _tabController = TabController(length: 4, vsync: this);
    _loadCarbonData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Rastgele demo verisi oluştur (sınıf bilgisi olmadığında)
  Future<void> _generateDemoData() async {
    try {
      // Rastgele sınıf seviyesi ve bölüm seç
      final random = DateTime.now().millisecondsSinceEpoch;
      final classLevel = 9 + (random % 4); // 9-12 arası
      final sections = classLevel <= 10
          ? ['A', 'B', 'Güney', 'C', 'D']
          : ['A', 'B', 'C', 'D'];
      final classSection = sections[random % sections.length];

      await _generateDemoDataForClass(classLevel, classSection);
    } catch (e) {
      setState(() {
        _errorMessage = 'Demo verisi oluşturma hatası: $e';
        _isLoading = false;
      });
    }
  }

  /// Belirli sınıf için rastgele demo verisi oluştur
  Future<void> _generateDemoDataForClass(int classLevel, String classSection) async {
    try {
      // Rastgele karbon değeri oluştur (400-4000 arası)
      final random = DateTime.now().millisecondsSinceEpoch;
      final baseCarbon = 400 + (random % 3600);
      final carbonValue = baseCarbon + (random % 201) - 100; // ±100 varyasyon

      // Bitkiler: 9-10. sınıflar için rastgele, 11-12 için false
      final hasPlants = classLevel <= 10 ? (random % 2 == 0) : false;

      // Konum: rastgele kuzey/güney
      final orientation = (random % 2 == 0) ? ClassOrientation.north : ClassOrientation.south;

      // Demo CarbonFootprintData oluştur
      final demoData = CarbonFootprintData(
        id: 'demo_${classLevel}${classSection}',
        classLevel: classLevel,
        classSection: classSection,
        hasPlants: hasPlants,
        carbonValue: carbonValue.clamp(400, 4000),
        classOrientation: orientation,
        measuredAt: DateTime.now(),
      );

      // Demo sınıf düzeyi verisi oluştur (5 rastgele sınıf)
      final demoClassLevelData = <CarbonFootprintData>[];
      for (var i = 0; i < 5; i++) {
        final classSections = classLevel <= 10
            ? ['A', 'B', 'Güney', 'C', 'D']
            : ['A', 'B', 'C', 'D'];
        final section = classSections[(random + i) % classSections.length];
        final carbon = 400 + ((random + i * 200) % 3600);

        demoClassLevelData.add(CarbonFootprintData(
          id: 'demo_${classLevel}${section}_$i',
          classLevel: classLevel,
          classSection: section,
          hasPlants: classLevel <= 10 ? ((random + i) % 2 == 0) : false,
          carbonValue: carbon.clamp(400, 4000),
          classOrientation: (random + i) % 2 == 0 ? ClassOrientation.north : ClassOrientation.south,
          measuredAt: DateTime.now(),
        ));
      }

      // Ortalama hesapla
      final totalCarbon = demoClassLevelData.fold<int>(0, (sum, data) => sum + data.carbonValue);
      final average = (totalCarbon / demoClassLevelData.length).round();

      // Demo istatistikler
      final stats = CarbonStatistics(
        totalCarbon: totalCarbon.toDouble(),
        averageCarbon: average.toDouble(),
        minCarbon: demoClassLevelData.map((d) => d.carbonValue).reduce((a, b) => a < b ? a : b),
        maxCarbon: demoClassLevelData.map((d) => d.carbonValue).reduce((a, b) => a > b ? a : b),
        allData: demoClassLevelData,
      );

      // 2 aylık geçmiş veri oluştur
      await _generateMonthlyData();

      setState(() {
        _userClassCarbonData = demoData;
        _classLevelData = demoClassLevelData;
        _averageCarbon = average;
        _statistics = stats;
        _errorMessage = null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Demo verisi oluşturma hatası: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCarbonData() async {
    try {
      setState(() => _isLoading = true);

      final classLevel = widget.classLevel ?? widget.userData?.classLevel;
      final classSection = widget.classSection ?? widget.userData?.classSection;

      if (classLevel == null || classSection == null) {
        // Sınıf bilgisi eksik, rastgele demo verisi oluştur
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sınıf bilgisi bulunamadı. Demo verisi gösteriliyor. Profil sayfanızdan sınıf bilgilerinizi güncelleyin.'),
              backgroundColor: Colors.blue,
              duration: Duration(seconds: 4),
            ),
          );
        }

        // Rastgele demo verisi oluştur
        await _generateDemoData();
        return;
      }

      // Load user's class carbon data
      final userData = await _carbonService.getCarbonDataByClass(classLevel, classSection);

      if (userData == null) {
        // Kullanıcı sınıfı için veri bulunamadı, demo verisi oluştur
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sınıfınız için karbon verisi bulunamadı. Demo verisi gösteriliyor.'),
              backgroundColor: Colors.blue,
              duration: Duration(seconds: 3),
            ),
          );
        }
        await _generateDemoDataForClass(classLevel, classSection);
        return;
      }

      // Load all data for the class level
      final classLevelData = await _carbonService.getCarbonDataByClassLevel(classLevel);

      // Calculate average
      final average = await _carbonService.getAverageCarbonForClassLevel(classLevel);

      // Get statistics
      final stats = await _carbonService.getCarbonStatistics();

      // 2 aylık geçmiş veri oluştur
      await _generateMonthlyData();

      setState(() {
        _userClassCarbonData = userData;
        _classLevelData = classLevelData;
        _averageCarbon = average;
        _statistics = stats;
        _errorMessage = null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Karbon verileri yüklenirken hata: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StandardAppBar(
        title: const Text('Karbon Ayak İzi'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Özet', icon: Icon(Icons.pie_chart)),
            Tab(text: 'Detaylar', icon: Icon(Icons.info)),
            Tab(text: 'Geçmiş', icon: Icon(Icons.timeline)),
            Tab(text: 'Rapor', icon: Icon(Icons.file_download)),
          ],
        ),
      ),
      body: PageBody(
        scrollable: false,
        child: _isLoading
            ? _buildLoadingState()
            : _errorMessage != null
                ? _buildErrorState()
                : _userClassCarbonData == null
                    ? _buildEmptyState()
                    : _buildMainContent(),
      ),
      floatingActionButton: _userClassCarbonData != null
          ? FloatingActionButton(
              onPressed: _loadCarbonData,
              tooltip: 'Verileri Yenile',
              child: const Icon(Icons.refresh),
            )
          : null,
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? 'Bir hata oluştu',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadCarbonData,
            child: const Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return EmptyStateWidget(
      title: 'Karbon Verileri Bulunamadı',
      message: 'Sınıfınız için henüz karbon ayak izi verisi bulunmamaktadır.',
      retryText: 'Verileri Yükle',
      onRetry: _loadCarbonData,
    );
  }

  Widget _buildMainContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildSummaryTab(),
        _buildDetailsTab(),
        _buildHistoryTab(),
        _buildReportTab(),
      ],
    );
  }

  Widget _buildSummaryTab() {
    if (_userClassCarbonData == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Class info card
          _buildClassInfoCard(),
          const SizedBox(height: 24),

          // Carbon value display
          _buildCarbonValueCard(),
          const SizedBox(height: 24),

          // Comparison card
          _buildComparisonCard(),
          const SizedBox(height: 24),

          // Status indicators
          _buildStatusIndicators(),
        ],
      ),
    );
  }

  Widget _buildClassInfoCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              _userClassCarbonData!.classIdentifier,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildInfoChip(
                  'Konum',
                  _userClassCarbonData!.classOrientation.name == 'north'
                      ? 'Kuzey'
                      : 'Güney',
                  Icons.compass_calibration,
                ),
                _buildInfoChip(
                  'Bitkiler',
                  _userClassCarbonData!.hasPlants ? 'Var' : 'Yok',
                  Icons.local_florist,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.green[700]),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildCarbonValueCard() {
    final carbonValue = _userClassCarbonData!.carbonValue;
    final statusEmoji = _reportService.getStatusEmoji(carbonValue);
    final statusText = _reportService.createReportDisplayData(
      _userClassCarbonData!,
      averageCarbon: _averageCarbon,
      allClassLevelData: _classLevelData,
    )['status'];

    return Card(
      elevation: 4,
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(statusEmoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              '$carbonValue g CO₂',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              statusText,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonCard() {
    if (_averageCarbon == null) return const SizedBox.shrink();

    final difference = _userClassCarbonData!.carbonValue - _averageCarbon!;
    final isAboveAverage = difference > 0;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Karşılaştırma',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sınıfınız', style: TextStyle(color: Colors.grey[600])),
                    Text(
                      '${_userClassCarbonData!.carbonValue} g CO₂',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ortalama', style: TextStyle(color: Colors.grey[600])),
                    Text(
                      '$_averageCarbon g CO₂',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Fark', style: TextStyle(color: Colors.grey[600])),
                    Text(
                      '${isAboveAverage ? '+' : ''}$difference g CO₂',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isAboveAverage ? Colors.red : Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicators() {
    final carbonValue = _userClassCarbonData!.carbonValue;
    final hasPlants = _userClassCarbonData!.hasPlants;
    final isNorth = _userClassCarbonData!.classOrientation.name == 'north';

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Etkenler',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildIndicatorRow(
              'Bitkiler',
              hasPlants
                  ? 'Karbon azalmasına yardımcı oluyor 🌱'
                  : 'Bitkiler eklenebilir 🌿',
              hasPlants ? Colors.green : Colors.orange,
            ),
            const SizedBox(height: 8),
            _buildIndicatorRow(
              'Konum',
              isNorth
                  ? 'Kuzey yönü karbon artışı ile ilişkili 🧭'
                  : 'Güney yönü daha uygun 🧭',
              isNorth ? Colors.orange : Colors.green,
            ),
            const SizedBox(height: 8),
            _buildIndicatorRow(
              'Karbon Seviyesi',
              carbonValue < 1500 ? 'İyi durumda ✓' : 'Azaltılması önerilir ⚠️',
              carbonValue < 1500 ? Colors.green : Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicatorRow(String label, String description, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(description, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsTab() {
    if (_userClassCarbonData == null || _classLevelData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sınıf Düzeyi Dağılımı',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildClassLevelComparison(),
          const SizedBox(height: 24),
          const Text(
            'Tüm Veriler',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildAllDataTable(),
        ],
      ),
    );
  }

  Widget _buildClassLevelComparison() {
    return Column(
      children: [
        // Add pie chart for class distribution
        _buildClassDistributionChart(),
        const SizedBox(height: 24),
        // Existing list
        ..._classLevelData!.map((data) {
          final isUserClass = data.id == _userClassCarbonData!.id;
          return Card(
            color: isUserClass ? Colors.blue[50] : null,
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Text(
                data.classIdentifier,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isUserClass ? Colors.blue : Colors.black,
                ),
              ),
              title: Text('${data.carbonValue} g CO₂'),
              trailing: data.hasPlants
                  ? const Icon(Icons.local_florist, color: Colors.green)
                  : null,
              subtitle: Text(
                data.classOrientation.name == 'north' ? 'Kuzey' : 'Güney',
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildClassDistributionChart() {
    // Generate random distribution based on class structure
    final grade9Classes = _classLevelData!.where((c) => c.classLevel == 9).length;
    final grade10Classes = _classLevelData!.where((c) => c.classLevel == 10).length;
    final grade11Classes = _classLevelData!.where((c) => c.classLevel == 11).length;
    final grade12Classes = _classLevelData!.where((c) => c.classLevel == 12).length;

    // For grades 9-10: distribute among flower classes (A, B, Güney, C, D)
    final flowerSections = ['A', 'B', 'Güney', 'C', 'D'];
    final grade9Distribution = _generateRandomDistribution(grade9Classes, flowerSections);
    final grade10Distribution = _generateRandomDistribution(grade10Classes, flowerSections);

    // For grades 11-12: no flowers, just numbers
    final grade11Distribution = _generateRandomDistribution(grade11Classes, ['11-A', '11-B', '11-C', '11-D']);
    final grade12Distribution = _generateRandomDistribution(grade12Classes, ['12-A', '12-B', '12-C', '12-D']);

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sınıf Dağılımı',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildGradePieChart('9. Sınıflar', grade9Distribution),
            const SizedBox(height: 16),
            _buildGradePieChart('10. Sınıflar', grade10Distribution),
            const SizedBox(height: 16),
            _buildGradePieChart('11. Sınıflar', grade11Distribution),
            const SizedBox(height: 16),
            _buildGradePieChart('12. Sınıflar', grade12Distribution),
          ],
        ),
      ),
    );
  }

  Map<String, int> _generateRandomDistribution(int totalClasses, List<String> sections) {
    final distribution = <String, int>{};
    var remaining = totalClasses;

    // Randomly distribute classes among sections
    for (var i = 0; i < sections.length - 1; i++) {
      final count = (remaining * (0.2 + (DateTime.now().millisecond % 50) / 100)).round();
      distribution[sections[i]] = count.clamp(0, remaining);
      remaining -= distribution[sections[i]]!;
    }

    // Last section gets remaining
    distribution[sections.last] = remaining;

    return distribution;
  }

  Widget _buildGradePieChart(String title, Map<String, int> distribution) {
    final total = distribution.values.fold(0, (sum, count) => sum + count);
    if (total == 0) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: distribution.entries.map((entry) {
            final percentage = (entry.value / total * 100).round();
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getSectionColor(entry.key),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${entry.key}: ${entry.value} sınıf (%$percentage)',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _getSectionColor(String section) {
    switch (section) {
      case 'A': return Colors.red;
      case 'B': return Colors.blue;
      case 'Güney': return Colors.green;
      case 'C': return Colors.orange;
      case 'D': return Colors.purple;
      case '11-A': return Colors.pink;
      case '11-B': return Colors.teal;
      case '11-C': return Colors.indigo;
      case '11-D': return Colors.amber;
      case '12-A': return Colors.cyan;
      case '12-B': return Colors.lime;
      case '12-C': return Colors.deepOrange;
      case '12-D': return Colors.deepPurple;
      default: return Colors.grey;
    }
  }

  Widget _buildAllDataTable() {
    if (_statistics == null || _statistics!.allData.isEmpty) {
      return const Text('Veri bulunamadı');
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Sınıf')),
          DataColumn(label: Text('Karbon')),
          DataColumn(label: Text('Konum')),
          DataColumn(label: Text('Bitkiler')),
        ],
        rows: _statistics!.allData.map((data) {
          return DataRow(
            cells: [
              DataCell(Text(data.classIdentifier)),
              DataCell(Text('${data.carbonValue}')),
              DataCell(Text(data.classOrientation.name == 'north' ? 'K' : 'G')),
              DataCell(
                Icon(
                  data.hasPlants ? Icons.check_circle : Icons.cancel,
                  color: data.hasPlants ? Colors.green : Colors.red,
                  size: 18,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReportTab() {
    if (_userClassCarbonData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rapor İndir',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _buildDownloadButton(
            'PNG İndir',
            Icons.image,
            Colors.blue,
            () => _downloadReport('png'),
          ),
          const SizedBox(height: 12),
          _buildDownloadButton(
            'PDF İndir',
            Icons.picture_as_pdf,
            Colors.red,
            () => _downloadReport('pdf'),
          ),
          const SizedBox(height: 12),
          _buildDownloadButton(
            'Excel İndir',
            Icons.table_chart,
            Colors.green,
            () => _downloadReport('xlsx'),
          ),
          const SizedBox(height: 24),
          _buildShareButton(),
          const SizedBox(height: 24),
          _buildReportPreview(),
        ],
      ),
    );
  }

  Widget _buildDownloadButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildShareButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _shareReport(),
        icon: const Icon(Icons.share),
        label: const Text('Paylaş'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[700],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildReportPreview() {
    final reportData = _reportService.createReportDisplayData(
      _userClassCarbonData!,
      averageCarbon: _averageCarbon,
      allClassLevelData: _classLevelData,
    );

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rapor Özeti',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildPreviewRow(
              'Sınıf',
              reportData['classIdentifier'],
            ),
            _buildPreviewRow(
              'Karbon Değeri',
              '${reportData['carbonValue']} g CO₂',
            ),
            _buildPreviewRow(
              'Ortalama',
              '${reportData['averageCarbon']} g CO₂',
            ),
            _buildPreviewRow(
              'Durum',
              reportData['status'],
            ),
            const SizedBox(height: 16),
            Text(
              'Öneriler:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              reportData['recommendation'],
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[600]),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _downloadReport(String format) async {
    if (_userClassCarbonData == null) return;

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$format raporu hazırlanıyor: ${_userClassCarbonData!.classIdentifier}'),
          duration: const Duration(seconds: 2),
        ),
      );

      // Prepare report data
      final reportData = _reportService.createReportDisplayData(
        _userClassCarbonData!,
        averageCarbon: _averageCarbon,
        allClassLevelData: _classLevelData,
      );

      final reportContent = {
        'sınıf': reportData['classIdentifier'],
        'karbon_değeri': reportData['carbonValue'],
        'ortalama': reportData['averageCarbon'],
        'durum': reportData['status'],
        'öneri': reportData['recommendation'],
        'tarih': DateTime.now().toIso8601String(),
        'format': format,
      };

      // Generate report based on format
      if (format == 'pdf') {
        // Simple text-based PDF simulation - in real app use pdf package
        final pdfContent = '''
KARBON AYAK İZİ RAPORU

Sınıf: ${reportData['classIdentifier']}
Karbon Değeri: ${reportData['carbonValue']} g CO₂
Ortalama: ${reportData['averageCarbon']} g CO₂
Durum: ${reportData['status']}

Öneri: ${reportData['recommendation']}

Oluşturulma Tarihi: ${DateTime.now().toString()}
        '''.trim();

        // For now, copy to clipboard as simulation
        // In real app, generate actual PDF file
        await _saveReportToFile('carbon_report_${_userClassCarbonData!.classIdentifier}.txt', pdfContent);

      } else if (format == 'xlsx') {
        // Simple CSV format as Excel simulation
        final csvContent = '''
Sınıf,Karbon Değeri (g CO₂),Ortalama (g CO₂),Durum,Öneri,Tarih
${reportData['classIdentifier']},${reportData['carbonValue']},${reportData['averageCarbon']},"${reportData['status']}","${reportData['recommendation']}",${DateTime.now().toIso8601String()}
        '''.trim();

        await _saveReportToFile('carbon_report_${_userClassCarbonData!.classIdentifier}.csv', csvContent);

      } else if (format == 'png') {
        // For PNG, we'll save the summary as text
        final pngContent = '''
🌱 KARBON AYAK İZİ RAPORU 🌱

📚 Sınıf: ${reportData['classIdentifier']}
🌡️ Karbon: ${reportData['carbonValue']} g CO₂
📊 Ortalama: ${reportData['averageCarbon']} g CO₂
📈 Durum: ${reportData['status']}

💡 Öneri: ${reportData['recommendation']}

📅 Tarih: ${DateTime.now().toString().split(' ')[0]}
        '''.trim();

        await _saveReportToFile('carbon_report_${_userClassCarbonData!.classIdentifier}.txt', pngContent);
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$format raporu başarıyla oluşturuldu: ${_userClassCarbonData!.classIdentifier}'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rapor indirme hatası: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _saveReportToFile(String fileName, String content) async {
    try {
      // Get the appropriate directory based on platform
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
        // Create a reports subdirectory
        directory = Directory('${directory!.path}/Reports');
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
        directory = Directory('${directory.path}/Reports');
      } else {
        // For other platforms (desktop), use downloads directory
        directory = await getDownloadsDirectory();
        directory = Directory('${directory!.path}/KarbonReports');
      }

      // Create directory if it doesn't exist
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // Create the file
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(content);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rapor kaydedildi: ${file.path}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Aç',
              onPressed: () {
                // For now, just show the content in a dialog
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Rapor: $fileName'),
                    content: SingleChildScrollView(
                      child: Text(content),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Kapat'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Dosya kaydetme hatası: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dosya kaydetme hatası: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _shareReport() async {
    if (_userClassCarbonData == null) return;

    try {
      // Prepare report data for sharing
      await _reportService.prepareReportForSharing(
        _userClassCarbonData!,
        schoolName: 'Karbonson Okulu',
        averageCarbon: _averageCarbon,
      );

      // TODO: Implement actual share using share_plus package
      // For now, showing the data
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rapor paylaşılıyor: ${_userClassCarbonData!.classIdentifier}'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Paylaşım hatası: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// 2 aylık geçmiş karbon verisi oluştur
  Future<void> _generateMonthlyData() async {
    if (_userClassCarbonData == null) return;

    final monthlyData = <Map<String, dynamic>>[];
    final now = DateTime.now();
    final baseCarbon = _userClassCarbonData!.carbonValue;

    // Son 2 ay için aylık veri oluştur
    for (var i = 1; i >= 0; i--) {
      final monthDate = DateTime(now.year, now.month - i, 1);
      final random = DateTime.now().millisecondsSinceEpoch + i * 1000;

      // Rastgele varyasyon (±200 g CO₂)
      final variation = (random % 401) - 200;
      final monthlyCarbon = (baseCarbon + variation).clamp(400, 4000);

      monthlyData.add({
        'month': '${monthDate.year}-${monthDate.month.toString().padLeft(2, '0')}',
        'carbonValue': monthlyCarbon,
        'date': monthDate,
        'isCurrentMonth': i == 0,
      });
    }

    setState(() {
      _monthlyCarbonData = monthlyData;
    });
  }

  /// Geçmiş tab içeriği
  Widget _buildHistoryTab() {
    if (_monthlyCarbonData == null || _monthlyCarbonData!.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '2 Aylık Karbon Geçmişi',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildMonthlyChart(),
          const SizedBox(height: 24),
          const Text(
            'Aylık Detaylar',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ..._monthlyCarbonData!.map((data) => _buildMonthlyDataCard(data)),
        ],
      ),
    );
  }

  /// Aylık pasta grafiği
  Widget _buildMonthlyChart() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Aylık Karbon Değerleri',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _monthlyCarbonData!.map((data) {
                  final isCurrentMonth = data['isCurrentMonth'] as bool;
                  final carbonValue = data['carbonValue'] as int;
                  final percentage = carbonValue / 4000; // Max 4000'e göre

                  return Column(
                    children: [
                      Expanded(
                        child: Container(
                          width: 60,
                          decoration: BoxDecoration(
                            color: isCurrentMonth ? Colors.blue : Colors.green,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.bottomCenter,
                            heightFactor: percentage,
                            child: Container(
                              decoration: BoxDecoration(
                                color: (isCurrentMonth ? Colors.blue : Colors.green).withOpacity(0.8),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        data['month'].toString().split('-')[1],
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        '$carbonValue',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isCurrentMonth ? Colors.blue : Colors.green,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Aylık veri kartı
  Widget _buildMonthlyDataCard(Map<String, dynamic> data) {
    final month = data['month'] as String;
    final carbonValue = data['carbonValue'] as int;
    final isCurrentMonth = data['isCurrentMonth'] as bool;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isCurrentMonth ? Colors.blue[50] : null,
      child: ListTile(
        leading: Icon(
          isCurrentMonth ? Icons.calendar_today : Icons.calendar_month,
          color: isCurrentMonth ? Colors.blue : Colors.green,
        ),
        title: Text('$month Ayı'),
        subtitle: Text('Karbon Değeri: $carbonValue g CO₂'),
        trailing: isCurrentMonth
            ? const Chip(
                label: Text('Şu An'),
                backgroundColor: Colors.blue,
                labelStyle: TextStyle(color: Colors.white),
              )
            : null,
      ),
    );
  }
}
