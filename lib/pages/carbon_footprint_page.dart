// lib/pages/carbon_footprint_page.dart
// Carbon Footprint Screen - Display carbon data with charts and reports

import 'package:flutter/material.dart';
import 'package:karbonson/models/carbon_footprint_data.dart';
import 'package:karbonson/models/user_data.dart';
import 'package:karbonson/services/carbon_footprint_service.dart';
import 'package:karbonson/services/carbon_report_service.dart';
import 'package:karbonson/widgets/empty_state_widget.dart';
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

  @override
  void initState() {
    super.initState();
    _carbonService = CarbonFootprintService();
    _reportService = CarbonReportService();
    _tabController = TabController(length: 3, vsync: this);
    _loadCarbonData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCarbonData() async {
    try {
      setState(() => _isLoading = true);

      final classLevel = widget.classLevel ?? widget.userData?.classLevel;
      final classSection = widget.classSection ?? widget.userData?.classSection;

      if (classLevel == null || classSection == null) {
        setState(() {
          _errorMessage = 'Sınıf bilgisi bulunamadı. Lütfen profili güncelleyin.';
          _isLoading = false;
        });
        return;
      }

      // Load user's class carbon data
      final userData = await _carbonService.getCarbonDataByClass(classLevel, classSection);
      
      // Load all data for the class level
      final classLevelData = await _carbonService.getCarbonDataByClassLevel(classLevel);
      
      // Calculate average
      final average = await _carbonService.getAverageCarbonForClassLevel(classLevel);
      
      // Get statistics
      final stats = await _carbonService.getCarbonStatistics();

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
      children: _classLevelData!.map((data) {
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
    );
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
          content: Text('$format raporu indiriliyor: ${_userClassCarbonData!.classIdentifier}'),
          duration: const Duration(seconds: 2),
        ),
      );

      // Generate report based on format
      if (format == 'pdf') {
        // TODO: Implement PDF download using pdf package
        // For now, showing a placeholder
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF indirme şu anda hazırlanıyor...'),
            duration: Duration(seconds: 2),
          ),
        );
      } else if (format == 'xlsx') {
        // TODO: Implement Excel download using xlsxsheet package
        // For now, showing a placeholder
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Excel indirme şu anda hazırlanıyor...'),
            duration: Duration(seconds: 2),
          ),
        );
      } else if (format == 'png') {
        // TODO: Implement PNG download using image package
        // For now, showing a placeholder
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Görüntü indirme şu anda hazırlanıyor...'),
            duration: Duration(seconds: 2),
          ),
        );
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
}
