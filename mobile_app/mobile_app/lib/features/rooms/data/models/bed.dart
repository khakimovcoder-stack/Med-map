import 'package:flutter/foundation.dart';

/// Mirrors backend BedStatus enum.
class BedStatus {
  BedStatus._();
  static const String band = 'BAND';
  static const String bosh = 'BOSH';
  static const String nomalum = 'NOMALUM';

  static const List<String> all = [band, bosh, nomalum];

  static String labelUz(String status) {
    switch (status) {
      case band:
        return 'Band';
      case bosh:
        return 'Bo\'sh';
      default:
        return 'Noma\'lum';
    }
  }
}

class ConfirmationType {
  ConfirmationType._();
  static const String self = 'SELF';
  static const String neighbor = 'NEIGHBOR';
}

@immutable
class Bed {
  const Bed({
    required this.id,
    required this.position,
    required this.isNearWindow,
    required this.currentStatus,
    required this.confirmationCount,
    this.lastConfirmedAt,
  });

  final String id;
  final int position;
  final bool isNearWindow;
  final String currentStatus;
  final int confirmationCount;
  final DateTime? lastConfirmedAt;

  factory Bed.fromJson(Map<String, dynamic> json) {
    return Bed(
      id: json['id'] as String,
      position: (json['position'] as num?)?.toInt() ?? 0,
      isNearWindow: json['is_near_window'] as bool? ?? false,
      currentStatus: json['current_status'] as String? ?? BedStatus.nomalum,
      confirmationCount: (json['confirmation_count'] as num?)?.toInt() ?? 0,
      lastConfirmedAt: _parseDate(json['last_confirmed_at']),
    );
  }

  static DateTime? _parseDate(Object? raw) {
    if (raw is String && raw.isNotEmpty) return DateTime.tryParse(raw);
    return null;
  }
}
