import 'package:flutter/foundation.dart';

import 'bed.dart';

@immutable
class RoomSummary {
  const RoomSummary({
    required this.id,
    required this.number,
    required this.capacity,
    required this.availableBeds,
    required this.statusColor,
    required this.statusLabel,
    this.lastUpdatedAt,
    this.minutesSinceUpdate,
  });

  final String id;
  final String number;
  final int capacity;
  final int availableBeds;
  /// `green` | `red` | `gray`
  final String statusColor;
  final String statusLabel;
  final DateTime? lastUpdatedAt;
  final int? minutesSinceUpdate;

  factory RoomSummary.fromJson(Map<String, dynamic> json) {
    return RoomSummary(
      id: json['id'] as String,
      number: json['number']?.toString() ?? '',
      capacity: (json['capacity'] as num?)?.toInt() ?? 4,
      availableBeds: (json['available_beds'] as num?)?.toInt() ?? 0,
      statusColor: json['status_color'] as String? ?? 'gray',
      statusLabel: json['status_label'] as String? ?? '',
      lastUpdatedAt: _parseDate(json['last_updated_at']),
      minutesSinceUpdate: (json['minutes_since_update'] as num?)?.toInt(),
    );
  }

  static DateTime? _parseDate(Object? raw) {
    if (raw is String && raw.isNotEmpty) return DateTime.tryParse(raw);
    return null;
  }
}

@immutable
class FloorRoomsResponse {
  const FloorRoomsResponse({
    required this.floor,
    required this.rooms,
  });

  final FloorContext floor;
  final List<RoomSummary> rooms;

  factory FloorRoomsResponse.fromJson(Map<String, dynamic> json) {
    final roomsRaw = (json['rooms'] as List?) ?? const [];
    return FloorRoomsResponse(
      floor: FloorContext.fromJson(json['floor'] as Map<String, dynamic>),
      rooms: roomsRaw
          .whereType<Map<String, dynamic>>()
          .map(RoomSummary.fromJson)
          .toList(growable: false),
    );
  }
}

@immutable
class FloorContext {
  const FloorContext({
    required this.id,
    required this.number,
    this.name,
    this.hospitalId,
    this.hospitalName,
  });

  final String id;
  final int number;
  final String? name;
  final String? hospitalId;
  final String? hospitalName;

  factory FloorContext.fromJson(Map<String, dynamic> json) {
    final hosp = json['hospital'];
    return FloorContext(
      id: json['id'] as String,
      number: (json['number'] as num?)?.toInt() ?? 0,
      name: json['name'] as String?,
      hospitalId: hosp is Map ? hosp['id'] as String? : null,
      hospitalName: hosp is Map
          ? (hosp['name'] as String? ?? hosp['short_name'] as String?)
          : null,
    );
  }
}

@immutable
class RoomDetail {
  const RoomDetail({
    required this.id,
    required this.number,
    required this.capacity,
    required this.hasWindow,
    required this.beds,
    required this.totalBeds,
    required this.availableBeds,
    required this.floor,
    required this.hospital,
    this.description,
    this.confirmationSummary,
  });

  final String id;
  final String number;
  final int capacity;
  final bool hasWindow;
  final List<Bed> beds;
  final int totalBeds;
  final int availableBeds;
  final FloorRef floor;
  final HospitalRef hospital;
  final String? description;
  final ConfirmationSummary? confirmationSummary;

  factory RoomDetail.fromJson(Map<String, dynamic> json) {
    final bedsRaw = (json['beds'] as List?) ?? const [];
    final summary = json['confirmation_summary'];
    return RoomDetail(
      id: json['id'] as String,
      number: json['number']?.toString() ?? '',
      capacity: (json['capacity'] as num?)?.toInt() ?? 4,
      hasWindow: json['has_window'] as bool? ?? true,
      beds: bedsRaw
          .whereType<Map<String, dynamic>>()
          .map(Bed.fromJson)
          .toList(growable: false),
      totalBeds: (json['total_beds'] as num?)?.toInt() ?? 0,
      availableBeds: (json['available_beds'] as num?)?.toInt() ?? 0,
      floor: FloorRef.fromJson(json['floor'] as Map<String, dynamic>? ?? const {}),
      hospital: HospitalRef.fromJson(
        json['hospital'] as Map<String, dynamic>? ?? const {},
      ),
      description: json['description'] as String?,
      confirmationSummary: summary is Map<String, dynamic>
          ? ConfirmationSummary.fromJson(summary)
          : null,
    );
  }
}

@immutable
class FloorRef {
  const FloorRef({required this.id, required this.number, this.name});
  final String id;
  final int number;
  final String? name;

  factory FloorRef.fromJson(Map<String, dynamic> json) => FloorRef(
        id: json['id'] as String? ?? '',
        number: (json['number'] as num?)?.toInt() ?? 0,
        name: json['name'] as String?,
      );
}

@immutable
class HospitalRef {
  const HospitalRef({
    required this.id,
    required this.name,
    required this.shortName,
  });
  final String id;
  final String name;
  final String shortName;

  factory HospitalRef.fromJson(Map<String, dynamic> json) => HospitalRef(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        shortName: json['short_name'] as String? ?? '',
      );
}

@immutable
class ConfirmationSummary {
  const ConfirmationSummary({
    required this.totalConfirmations24h,
    required this.uniqueUsers24h,
    this.lastUpdatedAt,
    this.minutesSinceUpdate,
  });

  final int totalConfirmations24h;
  final int uniqueUsers24h;
  final DateTime? lastUpdatedAt;
  final int? minutesSinceUpdate;

  factory ConfirmationSummary.fromJson(Map<String, dynamic> json) {
    final dateRaw = json['last_updated_at'];
    return ConfirmationSummary(
      totalConfirmations24h:
          (json['total_confirmations_24h'] as num?)?.toInt() ?? 0,
      uniqueUsers24h: (json['unique_users_24h'] as num?)?.toInt() ?? 0,
      lastUpdatedAt: dateRaw is String ? DateTime.tryParse(dateRaw) : null,
      minutesSinceUpdate: (json['minutes_since_update'] as num?)?.toInt(),
    );
  }
}
