import 'package:flutter/material.dart';
import '../services/firebase_health_check_service.dart';
import '../services/watcher_mode_service.dart';
import '../theme/design_system.dart';
import '../widgets/page_templates.dart';

/// Firebase Health & Watcher Mode Debug Page
/// 
/// Test all modes and Firebase connections
class FirebaseDebugPage extends StatefulWidget {
  const FirebaseDebugPage({super.key});

  @override
  State<FirebaseDebugPage> createState() => _FirebaseDebugPageState();
}

class _FirebaseDebugPageState extends State<FirebaseDebugPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseHealthCheckService _healthCheckService = FirebaseHealthCheckService();
  final WatcherModeService _watcherService = WatcherModeService();

  FirebaseHealthReport? _healthReport;
  Map<String, dynamic>? _debugInfo;
  Map<String, dynamic>? _watcherStats;
  bool _isChecking = false;
  bool _isWatcherEnabled = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _performHealthCheck() async {
    setState(() => _isChecking = true);

    try {
      final report = await _healthCheckService.performHealthCheck();
      final debug = await _healthCheckService.getDebugInfo();

      setState(() {
        _healthReport = report;
        _debugInfo = debug;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Health check: ${report.status.name}'),
            backgroundColor: _getStatusColor(report.status),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Health check error: $e')),
        );
      }
    } finally {
      setState(() => _isChecking = false);
    }
  }

  Future<void> _toggleWatcherMode() async {
    if (_isWatcherEnabled) {
      await _watcherService.disable();
      _watcherStats = null;
    } else {
      await _watcherService.enable(
        sessionName: 'debug_session_${DateTime.now().millisecondsSinceEpoch}',
      );
      _watcherService.trackEvent(
        WatcherEventType.custom,
        'Watcher mode started',
        category: 'debug',
      );
    }

    setState(() {
      _isWatcherEnabled = _watcherService.isEnabled;
      if (_isWatcherEnabled) {
        _watcherStats = _watcherService.getStatistics();
      }
    });
  }

  Future<void> _attemptRecovery() async {
    setState(() => _isChecking = true);

    try {
      final success = await _healthCheckService.attemptRecovery();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Recovery successful' : 'Recovery attempted'),
            backgroundColor: success ? Colors.green : Colors.orange,
          ),
        );
      }

      // Re-check health
      await _performHealthCheck();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Recovery error: $e')),
        );
      }
    } finally {
      setState(() => _isChecking = false);
    }
  }

  Color _getStatusColor(FirebaseHealthStatus status) {
    switch (status) {
      case FirebaseHealthStatus.healthy:
        return Colors.green;
      case FirebaseHealthStatus.degraded:
        return Colors.orange;
      case FirebaseHealthStatus.unhealthy:
      case FirebaseHealthStatus.offline:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔧 Firebase Debug'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Health Check', icon: Icon(Icons.healing)),
            Tab(text: 'Watcher Mode', icon: Icon(Icons.visibility)),
            Tab(text: 'Debug Info', icon: Icon(Icons.bug_report)),
          ],
        ),
      ),
      body: Container(
        decoration: DesignSystem.getPageContainerDecoration(context),
        child: TabBarView(
          controller: _tabController,
          children: [
            // Health Check Tab
            _buildHealthCheckTab(),

            // Watcher Mode Tab
            _buildWatcherModeTab(),

            // Debug Info Tab
            _buildDebugInfoTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthCheckTab() {
    return PageBody(
      scrollable: true,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Health Check Button
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isChecking ? null : _performHealthCheck,
                icon: _isChecking
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                label: const Text('Run Health Check'),
              ),
            ),

            const SizedBox(height: 20),

            // Recovery Button
            if (_healthReport != null && !_healthReport!.isHealthy)
              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isChecking ? null : _attemptRecovery,
                  icon: const Icon(Icons.settings_backup_restore),
                  label: const Text('Attempt Recovery'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                ),
              ),

            if (_healthReport != null && !_healthReport!.isHealthy)
              const SizedBox(height: 16),

            // Status Card
            if (_healthReport != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _getStatusColor(_healthReport!.status).withOpacity(0.1),
                  border: Border.all(
                    color: _getStatusColor(_healthReport!.status),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getStatusIcon(_healthReport!.status),
                          color: _getStatusColor(_healthReport!.status),
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Status: ${_healthReport!.status.name.toUpperCase()}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Response: ${_healthReport!.responseTime.inMilliseconds}ms',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_healthReport!.issues.isNotEmpty) ...[
                      Text(
                        'Issues (${_healthReport!.issues.length})',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._healthReport!.issues
                          .map((issue) => Padding(
                            padding: const EdgeInsets.only(left: 16, bottom: 8),
                            child: Text('• $issue'),
                          ))
                          .toList(),
                      const SizedBox(height: 16),
                    ],
                    if (_healthReport!.recommendations.isNotEmpty) ...[
                      Text(
                        'Recommendations',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._healthReport!.recommendations
                          .map((rec) => Padding(
                            padding: const EdgeInsets.only(left: 16, bottom: 8),
                            child: Text('✓ $rec'),
                          ))
                          .toList(),
                    ],
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // Details
            if (_healthReport != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Details',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._buildDetailItems(_healthReport!.details),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWatcherModeTab() {
    return PageBody(
      scrollable: true,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Toggle Button
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _toggleWatcherMode,
                icon: Icon(_isWatcherEnabled ? Icons.visibility_off : Icons.visibility),
                label: Text(_isWatcherEnabled ? 'Disable Watcher' : 'Enable Watcher'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isWatcherEnabled ? Colors.red : Colors.green,
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (_isWatcherEnabled) ...[
              // Status
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 12),
                        Text(
                          'Watcher Mode Active',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Session: ${_watcherService.currentSession?.sessionId}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Statistics
              if (_watcherStats != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                    border: Border.all(color: Colors.blue.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Statistics',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._buildStatisticItems(_watcherStats!),
                    ],
                  ),
                ),
            ] else
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Icon(
                      Icons.visibility_off,
                      size: 64,
                      color: Colors.grey.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Watcher Mode Disabled',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebugInfoTab() {
    return PageBody(
      scrollable: true,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_debugInfo == null)
              const Center(
                child: Text('Run health check first to see debug info'),
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Debug Information',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._buildDebugItems(_debugInfo!),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDetailItems(Map<String, dynamic> details) {
    return details.entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          '${entry.key}: ${entry.value}',
          style: const TextStyle(fontSize: 12, fontFamily: 'Courier'),
        ),
      );
    }).toList();
  }

  List<Widget> _buildStatisticItems(Map<String, dynamic> stats) {
    return stats.entries.map((entry) {
      final value = entry.value;
      if (value is Map) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.key,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              ...(value).entries.map((e) {
                return Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 4),
                  child: Text(
                    '${e.key}: ${e.value}',
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              }).toList(),
            ],
          ),
        );
      }
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text('${entry.key}: $value'),
      );
    }).toList();
  }

  List<Widget> _buildDebugItems(Map<String, dynamic> debug) {
    return debug.entries.map((entry) {
      final value = entry.value;
      if (value is List) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.key,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              ...(value).map((item) {
                return Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 4),
                  child: Text('• $item', style: const TextStyle(fontSize: 12)),
                );
              }).toList(),
            ],
          ),
        );
      } else if (value is Map) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.key,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              ...(value).entries.map((e) {
                return Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 4),
                  child: Text(
                    '${e.key}: ${e.value}',
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              }).toList(),
            ],
          ),
        );
      }
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text('${entry.key}: $value'),
      );
    }).toList();
  }

  IconData _getStatusIcon(FirebaseHealthStatus status) {
    switch (status) {
      case FirebaseHealthStatus.healthy:
        return Icons.check_circle;
      case FirebaseHealthStatus.degraded:
        return Icons.warning;
      case FirebaseHealthStatus.unhealthy:
      case FirebaseHealthStatus.offline:
        return Icons.error;
      default:
        return Icons.help;
    }
  }
}
