// lib/models/email_verification_status.dart

class EmailVerificationStatus {
  final String uid;
  final bool emailVerified;
  final DateTime? lastSentAt;
  final int attemptCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const EmailVerificationStatus({
    required this.uid,
    required this.emailVerified,
    this.lastSentAt,
    this.attemptCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EmailVerificationStatus.fromJson(Map<String, dynamic> json) {
    return EmailVerificationStatus(
      uid: json['uid'] as String,
      emailVerified: json['emailVerified'] as bool,
      lastSentAt: json['lastSentAt'] != null 
          ? DateTime.parse(json['lastSentAt'] as String)
          : null,
      attemptCount: json['attemptCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'emailVerified': emailVerified,
      'lastSentAt': lastSentAt?.toIso8601String(),
      'attemptCount': attemptCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  EmailVerificationStatus copyWith({
    String? uid,
    bool? emailVerified,
    DateTime? lastSentAt,
    int? attemptCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EmailVerificationStatus(
      uid: uid ?? this.uid,
      emailVerified: emailVerified ?? this.emailVerified,
      lastSentAt: lastSentAt ?? this.lastSentAt,
      attemptCount: attemptCount ?? this.attemptCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EmailVerificationStatus &&
        other.uid == uid &&
        other.emailVerified == emailVerified &&
        other.lastSentAt == lastSentAt &&
        other.attemptCount == attemptCount &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(uid, emailVerified, lastSentAt, attemptCount, createdAt, updatedAt);
  }

  @override
  String toString() {
    return 'EmailVerificationStatus(uid: $uid, emailVerified: $emailVerified, lastSentAt: $lastSentAt, attemptCount: $attemptCount)';
  }
}