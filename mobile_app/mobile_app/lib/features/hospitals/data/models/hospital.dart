import 'package:flutter/foundation.dart';

@immutable
class Hospital {
  const Hospital({
    required this.id,
    required this.name,
    required this.shortName,
    required this.city,
    required this.address,
    required this.phone,
    required this.totalBeds,
    required this.availableBeds,
    this.region,
    this.latitude,
    this.longitude,
    this.floorsCount,
  });

  final String id;
  final String name;
  final String shortName;
  final String city;
  final String address;
  final String phone;
  final int totalBeds;
  final int availableBeds;
  final String? region;
  final double? latitude;
  final double? longitude;
  final int? floorsCount;

  factory Hospital.fromJson(Map<String, dynamic> json) {
    return Hospital(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      shortName: json['short_name'] as String? ?? '',
      city: json['city'] as String? ?? '',
      address: json['address'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      totalBeds: (json['total_beds'] as num?)?.toInt() ?? 0,
      availableBeds: (json['available_beds'] as num?)?.toInt() ?? 0,
      region: json['region'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      floorsCount: (json['floors_count'] as num?)?.toInt(),
    );
  }
}

@immutable
class HospitalDetail {
  const HospitalDetail({
    required this.hospital,
    required this.floors,
  });

  final Hospital hospital;
  final List<FloorSummary> floors;

  factory HospitalDetail.fromJson(Map<String, dynamic> json) {
    final floorsRaw = (json['floors'] as List?) ?? const [];
    return HospitalDetail(
      hospital: Hospital.fromJson(json),
      floors: floorsRaw
          .whereType<Map<String, dynamic>>()
          .map(FloorSummary.fromJson)
          .toList(growable: false),
    );
  }
}

@immutable
class FloorSummary {
  const FloorSummary({
    required this.id,
    required this.number,
    required this.totalBeds,
    required this.availableBeds,
    this.name,
    this.roomsCount,
  });

  final String id;
  final int number;
  final int totalBeds;
  final int availableBeds;
  final String? name;
  final int? roomsCount;

  factory FloorSummary.fromJson(Map<String, dynamic> json) {
    return FloorSummary(
      id: json['id'] as String,
      number: (json['number'] as num?)?.toInt() ?? 0,
      totalBeds: (json['total_beds'] as num?)?.toInt() ?? 0,
      availableBeds: (json['available_beds'] as num?)?.toInt() ?? 0,
      name: json['name'] as String?,
      roomsCount: (json['rooms_count'] as num?)?.toInt(),
    );
  }
}
