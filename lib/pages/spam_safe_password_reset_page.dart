import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/spam_aware_email_service.dart';

/// Spam filtrelerine karşı optimize edilmiş şifre sıfırlama sayfası
class SpamSafePasswordResetPage extends StatefulWidget {
  const SpamSafePasswordResetPage({super.key});

  @override
  State<SpamSafePasswordResetPage> createState() =>
      _SpamSafePasswordResetPageState();
}

class _SpamSafePasswordResetPageState extends State<SpamSafePasswordResetPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Şifre Sıfırlama'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 40),

              // Başlık
              Text(
                'Şifrenizi mi unuttunuz?',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 16),

              // Açıklama
              Text(
                'E-posta adresinizi girin, size güvenli bir şifre sıfırlama bağlantısı gönderelim.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 32),

              // E-posta input
              _buildEmailField(),

              SizedBox(height: 24),

              // Gönder butonu
              _buildSendButton(),

              SizedBox(height: 16),

              // Spam önleme bilgisi
              _buildSpamInfoCard(),

              SizedBox(height: 24),

              // Geri dön
              _buildBackButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'E-posta adresi gereklidir';
        }

        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Geçerli bir e-posta adresi girin';
        }

        return null;
      },
      decoration: InputDecoration(
        labelText: 'E-posta Adresi',
        hintText: 'ornek@email.com',
        prefixIcon: Icon(Icons.email),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildSendButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handlePasswordReset,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: _isLoading ? 0 : 2,
      ),
      child: _isLoading
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 12),
                Text('Gönderiliyor...'),
              ],
            )
          : Text(
              'Şifre Sıfırlama Bağlantısı Gönder',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
    );
  }

  Widget _buildSpamInfoCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        border: Border.all(color: Colors.green[200]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.security, color: Colors.green[700], size: 20),
              SizedBox(width: 8),
              Text(
                'Spam Güvenli Gönderim',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            '• Gönderim sıklığı sınırlandırılmıştır\n'
            '• Spam filtreleri için optimize edilmiştir\n'
            '• Güvenli ve hızlı teslim garantili',
            style: TextStyle(color: Colors.green[700], fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return TextButton.icon(
      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
      icon: Icon(Icons.arrow_back, size: 20),
      label: Text('Giriş Sayfasına Dön'),
      style: TextButton.styleFrom(
        foregroundColor: Colors.blue[600],
        padding: EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Future<void> _handlePasswordReset() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Spam riski analizi
      final spamAnalysis = SpamRiskAnalyzer.analyzeContent(
        subject: 'Şifre Sıfırlama İsteği',
        body: 'Password reset request for ${_emailController.text}',
      );

      if (spamAnalysis.isHighRisk) {
        _showSpamWarningDialog(spamAnalysis);
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // E-posta gönderimi
      final success = await SpamAwareEmailService.sendPasswordResetSpamSafe(
        email: _emailController.text.trim(),
        context: context,
      );

      if (success) {
        EmailMonitoringService.logEmailSend(
          email: _emailController.text.trim(),
          type: EmailType.PASSWORD_RESET,
          success: true,
        );

        _showSuccessDialog();
      }
    } catch (e) {
      EmailMonitoringService.logEmailSend(
        email: _emailController.text.trim(),
        type: EmailType.PASSWORD_RESET,
        success: false,
        errorMessage: e.toString(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Beklenmeyen bir hata oluştu'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSpamWarningDialog(SpamAnalysis analysis) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Text('Spam Uyarısı'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'E-posta içeriğiniz spam riski taşıyor:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                analysis.riskDescription,
                style: TextStyle(color: Colors.orange[700]),
              ),
              SizedBox(height: 12),
              if (analysis.issues.isNotEmpty) ...[
                Text('Sorunlar:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                ...analysis.issues
                    .map((issue) =>
                        Text('• $issue', style: TextStyle(fontSize: 12)))
                    ,
                SizedBox(height: 8),
              ],
              Text(
                'Yine de göndermek istiyor musunuz?',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Düzenle'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _forceSendPasswordReset();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: Text('Yine de Gönder'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Başarılı'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Şifre sıfırlama bağlantısı e-postanıza gönderildi.',
              ),
              SizedBox(height: 8),
              Text(
                'Lütfen e-postanızı kontrol edin ve gelen kutunuzda "Spam" klasörünü de kontrol etmeyi unutmayın.',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text('Tamam'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _forceSendPasswordReset() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );

      EmailMonitoringService.logEmailSend(
        email: _emailController.text.trim(),
        type: EmailType.PASSWORD_RESET,
        success: true,
      );

      _showSuccessDialog();
    } catch (e) {
      EmailMonitoringService.logEmailSend(
        email: _emailController.text.trim(),
        type: EmailType.PASSWORD_RESET,
        success: false,
        errorMessage: e.toString(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gönderim başarısız: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

/// E-posta gönderim istatistiklerini gösteren admin sayfası
class EmailStatsPage extends StatelessWidget {
  const EmailStatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('E-posta İstatistikleri'),
        backgroundColor: Colors.blue[600],
      ),
      body: FutureBuilder<EmailStats>(
        future: Future.value(EmailMonitoringService.getStats()),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final stats = snapshot.data!;

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildStatCard(
                  'Toplam Gönderilen',
                  '${stats.totalSent}',
                  Icons.email,
                  Colors.blue,
                ),
                SizedBox(height: 16),
                _buildStatCard(
                  '24 Saatlik Gönderim',
                  '${stats.last24hSent}',
                  Icons.access_time,
                  Colors.green,
                ),
                SizedBox(height: 16),
                _buildStatCard(
                  'Benzersiz E-postalar',
                  '${stats.uniqueEmails}',
                  Icons.people,
                  Colors.purple,
                ),
                SizedBox(height: 24),
                _buildSuccessRateCard(stats),
                SizedBox(height: 24),
                _buildRecentFailuresCard(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessRateCard(EmailStats stats) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Başarı Oranları',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 16),
            _buildProgressBar('24 Saatlik Başarı', stats.last24hSuccessRate),
            SizedBox(height: 12),
            _buildProgressBar('7 Günlük Başarı', stats.last7dSuccessRate),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(String label, double percentage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        SizedBox(height: 8),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            percentage >= 90
                ? Colors.green
                : percentage >= 70
                    ? Colors.orange
                    : Colors.red,
          ),
          minHeight: 8,
        ),
      ],
    );
  }

  Widget _buildRecentFailuresCard(BuildContext context) {
    final failures = EmailMonitoringService.getRecentFailures(limit: 5);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Son Başarısızlıklar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 16),
            if (failures.isEmpty)
              Text('Son zamanlarda başarısızlık yok',
                  style: TextStyle(color: Colors.green))
            else
              ...failures.map((failure) => _buildFailureItem(failure)),
          ],
        ),
      ),
    );
  }

  Widget _buildFailureItem(EmailSendLog failure) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.red[50],
        border: Border.all(color: Colors.red[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            failure.email,
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          Text(
            failure.type.toString().split('.').last,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          if (failure.errorMessage != null)
            Text(
              failure.errorMessage!,
              style: TextStyle(fontSize: 11, color: Colors.red[700]),
            ),
        ],
      ),
    );
  }
}
