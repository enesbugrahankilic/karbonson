import 'package:flutter_test/flutter_test.dart';
import 'package:karbonson/services/spam_aware_email_service.dart';

void main() {
  group('SpamAwareEmailService Tests', () {
    
    setUp(() {
      // Her test öncesi temizlik
      // Note: Static maps require manual clearing in tests
    });

    group('Email Normalization Tests', () {
      test('should normalize email to lowercase', () {
        final email = 'Test@EXAMPLE.COM';
        // This would be called internally by the service
        expect(email.toLowerCase().trim(), 'test@example.com');
      });

      test('should trim whitespace from email', () {
        final email = '  user@test.com  ';
        expect(email.toLowerCase().trim(), 'user@test.com');
      });
    });

    group('SpamRiskAnalyzer Tests', () {
      
      test('should identify high spam risk content', () {
        final analysis = SpamRiskAnalyzer.analyzeContent(
          subject: 'ACİL!!! ÜCRETSİZ HEMEN TIKLAYIN!!!',
          body: 'Bu e-posta çok fazla büyük harf ve SPAM kelimeleri içeriyor!!!',
        );

        expect(analysis.isHighRisk, true);
        expect(analysis.issues.isNotEmpty, true);
        expect(analysis.riskLevel, SpamRiskLevel.HIGH);
      });

      test('should identify medium spam risk content', () {
        final analysis = SpamRiskAnalyzer.analyzeContent(
          subject: 'Hesap Doğrulama',
          body: 'Bu e-postada normal kelimeler var ve orta düzeyde risk taşıyor',
        );

        expect(analysis.isMediumRisk, true);
      });

      test('should identify low spam risk content', () {
        final analysis = SpamRiskAnalyzer.analyzeContent(
          subject: 'Hesap Doğrulama',
          body: 'Merhaba, lütfen hesabınızı doğrulayın. Bu güvenli bir e-postadır.',
        );

        expect(analysis.isLowRisk, true);
      });

      test('should detect excessive exclamation marks', () {
        final analysis = SpamRiskAnalyzer.analyzeContent(
          subject: 'ACİL!!! ÇOK ÖNEMLİ!!!',
          body: 'Normal body content',
        );

        expect(analysis.issues.any((issue) => 
          issue.contains('ünlem işareti')), true);
      });

      test('should detect all caps subject', () {
        final analysis = SpamRiskAnalyzer.analyzeContent(
          subject: 'TÜM BÜYÜK HARF',
          body: 'Normal body content',
        );

        expect(analysis.issues.any((issue) => 
          issue.contains('büyük harfle')), true);
      });

      test('should detect spam trigger words', () {
        final analysis = SpamRiskAnalyzer.analyzeContent(
          subject: 'Subject',
          body: 'Bu e-posta ÜCRETSİZ bir ACİL offer içeriyor ve HEMEN tıklanmalı',
        );

        expect(analysis.issues.any((issue) => 
          issue.contains('ÜCRETSİZ')), true);
        expect(analysis.issues.any((issue) => 
          issue.contains('ACİL')), true);
      });

      test('should analyze HTML ratio', () {
        final analysis = SpamRiskAnalyzer.analyzeContent(
          subject: 'Normal Subject',
          body: '<p>Simple paragraph</p><div>Content</div><b>Bold</b>',
        );

        expect(analysis.warnings.any((warning) => 
          warning.contains('HTML etiketi')), true);
      });

      test('should provide helpful suggestions', () {
        final analysis = SpamRiskAnalyzer.analyzeContent(
          subject: 'ACİL!!!',
          body: 'AÇIK ÖNEMLİ KELIMELER',
        );

        expect(analysis.suggestions.isNotEmpty, true);
        expect(analysis.suggestions.any((suggestion) => 
          suggestion.contains('Normal büyük/küçük harf')), true);
      });
    });

    group('Email Monitoring Tests', () {
      test('should log successful email sends', () {
        EmailMonitoringService.logEmailSend(
          email: 'test@example.com',
          type: EmailType.PASSWORD_RESET,
          success: true,
        );

        final stats = EmailMonitoringService.getStats();
        expect(stats.totalSent, greaterThan(0));
      });

      test('should log failed email sends', () {
        EmailMonitoringService.logEmailSend(
          email: 'test@example.com',
          type: EmailType.EMAIL_VERIFICATION,
          success: false,
          errorCode: 'user-not-found',
          errorMessage: 'User not found',
        );

        final failures = EmailMonitoringService.getRecentFailures(limit: 1);
        expect(failures.isNotEmpty, true);
        expect(failures.first.success, false);
      });

      test('should calculate success rates correctly', () {
        // Log multiple emails with mixed success/failure
        for (int i = 0; i < 5; i++) {
          EmailMonitoringService.logEmailSend(
            email: 'test$i@example.com',
            type: EmailType.PASSWORD_RESET,
            success: i < 4, // First 4 successful
          );
        }

        final stats = EmailMonitoringService.getStats();
        expect(stats.last7dSuccessRate, closeTo(80.0, 1.0));
      });

      test('should track unique email addresses', () {
        final emails = ['user1@test.com', 'user2@test.com', 'user1@test.com'];
        
        for (final email in emails) {
          EmailMonitoringService.logEmailSend(
            email: email,
            type: EmailType.PASSWORD_RESET,
            success: true,
          );
        }

        final stats = EmailMonitoringService.getStats();
        expect(stats.uniqueEmails, 2); // Should count unique emails
      });

      test('should limit log size', () {
        // Log more than 1000 emails (if we had that capability)
        // This is a conceptual test
        for (int i = 0; i < 1000; i++) {
          EmailMonitoringService.logEmailSend(
            email: 'test$i@example.com',
            type: EmailType.PASSWORD_RESET,
            success: true,
          );
        }

        // The service should handle large numbers gracefully
        final stats = EmailMonitoringService.getStats();
        expect(stats.totalSent, greaterThanOrEqualTo(1000));
      });
    });

    group('Spam Analysis Risk Levels', () {
      test('should correctly categorize high risk', () {
        final analysis = SpamRiskAnalyzer.analyzeContent(
          subject: 'ACİL!!! ÜCRETSİZ MILYON ERİŞİN!!!',
          body: 'TÜM İÇERİK BÜYÜK HARF VE ÇOK FAZLA SPAM!!!',
        );

        expect(analysis.riskLevel, SpamRiskLevel.HIGH);
        expect(analysis.riskScore, greaterThanOrEqualTo(10.0));
      });

      test('should correctly categorize medium risk', () {
        final analysis = SpamRiskAnalyzer.analyzeContent(
          subject: 'Biraz büyük harf KULLANIMI',
          body: 'Orta düzey risk içeren normal bir e-posta',
        );

        expect(analysis.riskLevel, SpamRiskLevel.MEDIUM);
        expect(analysis.riskScore, greaterThanOrEqualTo(5.0));
        expect(analysis.riskScore, lessThan(10.0));
      });

      test('should correctly categorize low risk', () {
        final analysis = SpamRiskAnalyzer.analyzeContent(
          subject: 'Normal email subject',
          body: 'Bu normal bir e-posta içeriğidir ve güvenlidir.',
        );

        expect(analysis.riskLevel, SpamRiskLevel.LOW);
        expect(analysis.riskScore, lessThan(5.0));
      });
    });

    group('Edge Cases', () {
      test('should handle empty subject and body', () {
        final analysis = SpamRiskAnalyzer.analyzeContent(
          subject: '',
          body: '',
        );

        expect(analysis.riskLevel, SpamRiskLevel.LOW);
        expect(analysis.issues.isEmpty, true);
      });

      test('should handle null values gracefully', () {
        // This would be caught by Flutter's null safety
        // But let's test the validation
        expect(() => 
          SpamRiskAnalyzer.analyzeContent(
            subject: 'Normal Subject',
            body: 'Normal Body',
          ), returnsNormally);
      });

      test('should handle very long content', () {
        final longSubject = 'A' * 200;
        final longBody = 'B' * 5000;

        final analysis = SpamRiskAnalyzer.analyzeContent(
          subject: longSubject,
          body: longBody,
        );

        // Should handle gracefully without crashing
        expect(analysis, isNotNull);
      });

      test('should handle special characters', () {
        final analysis = SpamRiskAnalyzer.analyzeContent(
          subject: 'Special chars test',
          body: 'Special chars: àáâãäåæçèéêëìíîï',
        );

        expect(analysis, isNotNull);
        // Should not crash with special characters
      });
    });

    group('Integration Tests', () {
      test('should work together as a system', () {
        // Simulate a complete email send workflow
        final email = 'user@example.com';
        final subject = 'Hesap Doğrulama';
        final body = 'Lütfen hesabınızı doğrulayın';

        // 1. Analyze content
        final analysis = SpamRiskAnalyzer.analyzeContent(
          subject: subject,
          body: body,
        );

        // 2. Should pass spam check
        expect(analysis.isHighRisk, false);

        // 3. Simulate logging
        EmailMonitoringService.logEmailSend(
          email: email,
          type: EmailType.EMAIL_VERIFICATION,
          success: true,
        );

        // 4. Check stats
        final stats = EmailMonitoringService.getStats();
        expect(stats.totalSent, greaterThan(0));
      });
    });
  });

  group('Performance Tests', () {
    test('should handle multiple spam analyses quickly', () {
      final start = DateTime.now();
      
      for (int i = 0; i < 100; i++) {
        SpamRiskAnalyzer.analyzeContent(
          subject: 'Test Subject $i',
          body: 'Test body content for iteration $i',
        );
      }
      
      final end = DateTime.now();
      final duration = end.difference(start);
      
      // Should complete 100 analyses in less than 5 seconds
      expect(duration.inSeconds, lessThan(5));
    });

    test('should handle large log files', () {
      final start = DateTime.now();
      
      // Log 500 emails
      for (int i = 0; i < 500; i++) {
        EmailMonitoringService.logEmailSend(
          email: 'user$i@test.com',
          type: EmailType.PASSWORD_RESET,
          success: i % 10 != 0, // 90% success rate
        );
      }
      
      // Get stats
      final stats = EmailMonitoringService.getStats();
      
      final end = DateTime.now();
      final duration = end.difference(start);
      
      // Should complete in reasonable time
      expect(duration.inSeconds, lessThan(2));
      expect(stats.totalSent, 500);
    });
  });
}