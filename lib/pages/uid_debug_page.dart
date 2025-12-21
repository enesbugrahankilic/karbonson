// lib/pages/uid_debug_page.dart
// UID Verification and Cleanup Debug Page
// Provides UI for running UID verification and cleanup operations

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/uid_verification_service.dart';
import '../widgets/home_button.dart';

class UIDDebugPage extends StatefulWidget {
  const UIDDebugPage({super.key});

  @override
  State<UIDDebugPage> createState() => _UIDDebugPageState();
}

class _UIDDebugPageState extends State<UIDDebugPage> {
  final UIDVerificationService _uidService = UIDVerificationService();

  bool _isRunningHealthCheck = false;
  bool _isRunningFullCleanup = false;
  UIDHealthReport? _lastHealthReport;
  UIDCleanupStatistics? _lastCleanupStats;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const HomeButton(),
        title: const Text('UID Debug & Cleanup'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildQuickHealthCheck(),
              const SizedBox(height: 20),
              _buildFullCleanup(),
              const SizedBox(height: 20),
              _buildResultsDisplay(),
              const SizedBox(height: 20),
              _buildInfoCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🔧 UID Verification & Cleanup',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Bu sayfa Firestore verilerinizdeki UID tutarsızlıklarını tespit eder ve düzeltir. '
              'UID merkeziyeti sisteminizin temel taşıdır.',
            ),
            const SizedBox(height: 8),
            const Text(
              '⚠️ ÖNEMLİ: Bu işlemler verilerinizi etkileyebilir. Önce sağlık kontrolü yapın.',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickHealthCheck() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.health_and_safety, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Hızlı Sağlık Kontrolü',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Firestore verilerinizdeki UID tutarsızlıklarını hızlıca kontrol eder. '
              'Daha az yoğun kaynak kullanır.',
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isRunningHealthCheck ? null : _runQuickHealthCheck,
              icon: _isRunningHealthCheck
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.search),
              label: Text(_isRunningHealthCheck
                  ? 'Kontrol ediliyor...'
                  : 'Sağlık Kontrolü Başlat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullCleanup() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.cleaning_services, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Kapsamlı UID Temizleme',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Tüm Firestore koleksiyonlarını tarar, UID tutarsızlıklarını düzeltir ve '
              'geçersiz verileri temizler. Bu işlem uzun sürebilir.',
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade300),
              ),
              child: const Text(
                '🔴 Bu işlem geri alınamaz! Önce yedek alın.',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isRunningFullCleanup ? null : _runFullCleanup,
              icon: _isRunningFullCleanup
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.delete_sweep),
              label: Text(_isRunningFullCleanup
                  ? 'Temizleniyor...'
                  : 'Kapsamlı Temizleme Başlat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsDisplay() {
    return Column(
      children: [
        if (_lastHealthReport != null) _buildHealthReportCard(),
        if (_lastCleanupStats != null) _buildCleanupStatsCard(),
      ],
    );
  }

  Widget _buildHealthReportCard() {
    final report = _lastHealthReport!;

    return Card(
      color: report.isHealthy ? Colors.green.shade50 : Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  report.isHealthy ? Icons.check_circle : Icons.warning,
                  color: report.isHealthy ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  'Sağlık Kontrolü Sonuçları',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(report.summary),
            const SizedBox(height: 8),
            if (report.needsFullCleanup)
              ElevatedButton(
                onPressed: _runFullCleanup,
                child: const Text('Kapsamlı Temizleme Öneriliyor'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCleanupStatsCard() {
    final stats = _lastCleanupStats!;

    return Card(
      color: stats.hasIssues ? Colors.red.shade50 : Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  stats.hasIssues ? Icons.warning : Icons.check_circle,
                  color: stats.hasIssues ? Colors.red : Colors.green,
                ),
                const SizedBox(width: 8),
                Text(
                  'Temizleme Sonuçları',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(stats.summary),
            const SizedBox(height: 16),
            if (stats.hasIssues)
              const Text(
                '✅ Temizleme işlemi tamamlandı. Verileriniz artık UID merkeziyeti standardlarına uygun.',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'UID Merkeziyeti Hakkında',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'UID merkeziyeti, Firebase Auth UID\'lerinin Firestore document ID\'leri '
              'olarak kullanılması prensibine dayanır. Bu sistem şunları sağlar:',
            ),
            const SizedBox(height: 8),
            const Text('• Veri bütünlüğü ve güvenlik'),
            const Text('• Hızlı sorgular ve performans'),
            const Text('• Otomatik veri temizleme'),
            const Text('• Kolay arkadaşlık ve bildirim sistemi'),
            const SizedBox(height: 12),
            const Text(
              '⚠️ Bu sistem olmadan arkadaşlık istekleri, bildirimler ve oyun odaları '
              'doğru çalışmaz.',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _runQuickHealthCheck() async {
    setState(() {
      _isRunningHealthCheck = true;
    });

    try {
      final report = await _uidService.performQuickUIDHealthCheck();
      setState(() {
        _lastHealthReport = report;
        _isRunningHealthCheck = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Sağlık kontrolü tamamlandı: ${report.isHealthy ? "Sağlıklı" : "İyileştirme gerekli"}'),
            backgroundColor: report.isHealthy ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isRunningHealthCheck = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _runFullCleanup() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kapsamlı Temizleme Onayı'),
        content: const Text(
          'Bu işlem geri alınamaz! Firestore verilerinizdeki UID tutarsızlıkları düzeltilecek ve '
          'geçersiz veriler silinecektir. Devam etmek istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Evet, Temizle',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isRunningFullCleanup = true;
    });

    try {
      final stats = await _uidService.performComprehensiveUIDCleanup();
      setState(() {
        _lastCleanupStats = stats..completedAt = DateTime.now();
        _isRunningFullCleanup = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Temizleme tamamlandı. ${stats.hasIssues ? "Düzeltmeler yapıldı." : "Veriler sağlıklı."}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isRunningFullCleanup = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
