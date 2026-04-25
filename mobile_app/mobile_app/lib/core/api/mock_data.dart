import 'dart:math';

/// Deterministic mock data used when [ApiEndpoints.kUseMock] is true.
/// The shape mirrors docs/API_CONTRACT.md exactly.
class MockData {
  MockData._();

  static final _seedRng = Random(42);

  // 3 hospitals from DATA_MODELS.md → Seed Data.
  static final List<Map<String, dynamic>> hospitals = _buildHospitals();

  static final Map<String, List<Map<String, dynamic>>> floorsByHospital =
      _buildFloors();

  static final Map<String, List<Map<String, dynamic>>> roomsByFloor =
      _buildRooms();

  static final Map<String, Map<String, dynamic>> roomDetailById =
      _buildRoomDetails();

  static final Map<String, String> roomIdByQrToken = _buildQrIndex();

  // -------------------------------------------------------------------------
  // Builders
  // -------------------------------------------------------------------------
  static List<Map<String, dynamic>> _buildHospitals() {
    return [
      {
        'id': 'hosp-001',
        'name': 'Respublika Ixtisoslashtirilgan Kardiologiya Markazi',
        'short_name': 'RIKM',
        'city': 'Toshkent',
        'region': 'Toshkent shahri',
        'address': 'Toshkent sh., Yunusobod tumani, A. Qodiriy 4',
        'phone': '+998712345678',
        'latitude': 41.311081,
        'longitude': 69.240562,
        'total_beds': 160,
        'available_beds': 47,
        'floors_count': 4,
      },
      {
        'id': 'hosp-002',
        'name': 'Samarqand Viloyat Ko\'p Tarmoqli Tibbiy Markazi',
        'short_name': 'SVKTM',
        'city': 'Samarqand',
        'region': 'Samarqand viloyati',
        'address': 'Samarqand sh., Universitet xiyoboni 18',
        'phone': '+998662345678',
        'latitude': 39.654200,
        'longitude': 66.959740,
        'total_beds': 160,
        'available_beds': 38,
        'floors_count': 4,
      },
      {
        'id': 'hosp-003',
        'name': 'Buxoro Viloyat Sho\'ba Shifoxonasi',
        'short_name': 'BVSh',
        'city': 'Buxoro',
        'region': 'Buxoro viloyati',
        'address': 'Buxoro sh., Mustaqillik ko\'chasi 5',
        'phone': '+998652345678',
        'latitude': 39.767200,
        'longitude': 64.421300,
        'total_beds': 160,
        'available_beds': 52,
        'floors_count': 4,
      },
    ];
  }

  static Map<String, List<Map<String, dynamic>>> _buildFloors() {
    final result = <String, List<Map<String, dynamic>>>{};
    const floorNames = {
      1: 'Qabulxona qavati',
      2: 'Terapiya qavati',
      3: 'Jarrohlik qavati',
      4: 'Reanimatsiya qavati',
    };
    for (final h in hospitals) {
      final floors = <Map<String, dynamic>>[];
      for (var n = 1; n <= 4; n++) {
        final available = 6 + _seedRng.nextInt(10);
        floors.add({
          'id': 'floor-${h['id']}-$n',
          'number': n,
          'name': floorNames[n],
          'total_beds': 40,
          'available_beds': available,
          'rooms_count': 10,
        });
      }
      result[h['id'] as String] = floors;
    }
    return result;
  }

  static Map<String, List<Map<String, dynamic>>> _buildRooms() {
    final result = <String, List<Map<String, dynamic>>>{};
    for (final entry in floorsByHospital.entries) {
      for (final floor in entry.value) {
        final floorId = floor['id'] as String;
        final floorNumber = floor['number'] as int;
        final rooms = <Map<String, dynamic>>[];
        for (var i = 1; i <= 10; i++) {
          final number = '$floorNumber${i.toString().padLeft(2, '0')}';
          // 60% have at least one free bed.
          final freeRoll = _seedRng.nextDouble();
          int available;
          if (freeRoll < 0.55) {
            available = 1 + _seedRng.nextInt(3); // 1..3
          } else if (freeRoll < 0.85) {
            available = 0;
          } else {
            available = 0; // unknown — handled by status_color below
          }
          final isUnknown = freeRoll >= 0.85;
          final statusColor = isUnknown
              ? 'gray'
              : (available > 0 ? 'green' : 'red');
          final statusLabel = isUnknown
              ? 'Noma\'lum'
              : (available > 0 ? '$available bo\'sh' : 'To\'liq band');
          final minutes = isUnknown ? null : 1 + _seedRng.nextInt(120);
          rooms.add({
            'id': 'room-$floorId-$number',
            'number': number,
            'capacity': 4,
            'available_beds': available,
            'status_color': statusColor,
            'status_label': statusLabel,
            'last_updated_at': minutes == null
                ? null
                : DateTime.now()
                    .subtract(Duration(minutes: minutes))
                    .toUtc()
                    .toIso8601String(),
            'minutes_since_update': minutes,
          });
        }
        result[floorId] = rooms;
      }
    }
    return result;
  }

  static Map<String, Map<String, dynamic>> _buildRoomDetails() {
    final result = <String, Map<String, dynamic>>{};

    String hospitalIdForFloor(String floorId) {
      // floor-hosp-001-1 → hosp-001
      final parts = floorId.split('-');
      return '${parts[1]}-${parts[2]}';
    }

    for (final entry in roomsByFloor.entries) {
      final floorId = entry.key;
      final floorMeta = floorsByHospital.values
          .expand((l) => l)
          .firstWhere((f) => f['id'] == floorId);
      final hospId = hospitalIdForFloor(floorId);
      final hospital = hospitals.firstWhere((h) => h['id'] == hospId);

      for (final room in entry.value) {
        final roomId = room['id'] as String;
        final available = room['available_beds'] as int;
        final isUnknown = room['status_color'] == 'gray';

        // Build 4 beds. Positions 1,2 near window.
        final statuses = <String>[];
        if (isUnknown) {
          statuses.addAll(['NOMALUM', 'NOMALUM', 'NOMALUM', 'NOMALUM']);
        } else {
          for (var i = 0; i < 4; i++) {
            statuses.add(i < available ? 'BOSH' : 'BAND');
          }
          // Shuffle so the empty bed isn't always position 1.
          statuses.shuffle(_seedRng);
        }

        final beds = <Map<String, dynamic>>[];
        for (var p = 1; p <= 4; p++) {
          final minutes = isUnknown ? null : 1 + _seedRng.nextInt(120);
          beds.add({
            'id': 'bed-$roomId-$p',
            'position': p,
            'is_near_window': p <= 2,
            'current_status': statuses[p - 1],
            'last_confirmed_at': minutes == null
                ? null
                : DateTime.now()
                    .subtract(Duration(minutes: minutes))
                    .toUtc()
                    .toIso8601String(),
            'confirmation_count': isUnknown ? 0 : 1 + _seedRng.nextInt(3),
          });
        }

        final qrToken = 'qr-$roomId';
        result[roomId] = {
          'id': roomId,
          'number': room['number'],
          'capacity': 4,
          'has_window': true,
          'description': null,
          'qr_code_token': qrToken,
          'floor': {
            'id': floorMeta['id'],
            'number': floorMeta['number'],
            'name': floorMeta['name'],
          },
          'hospital': {
            'id': hospital['id'],
            'name': hospital['name'],
            'short_name': hospital['short_name'],
          },
          'available_beds': available,
          'total_beds': 4,
          'beds': beds,
          'confirmation_summary': {
            'total_confirmations_24h': isUnknown ? 0 : 3 + _seedRng.nextInt(8),
            'unique_users_24h': isUnknown ? 0 : 1 + _seedRng.nextInt(4),
            'last_updated_at': isUnknown
                ? null
                : DateTime.now()
                    .subtract(Duration(minutes: 1 + _seedRng.nextInt(30)))
                    .toUtc()
                    .toIso8601String(),
            'minutes_since_update':
                isUnknown ? null : 1 + _seedRng.nextInt(30),
          },
        };
      }
    }
    return result;
  }

  static Map<String, String> _buildQrIndex() {
    final out = <String, String>{};
    for (final entry in roomDetailById.entries) {
      out[entry.value['qr_code_token'] as String] = entry.key;
    }
    return out;
  }

  // -------------------------------------------------------------------------
  // Mutators (so confirmations actually update visible state in mock mode)
  // -------------------------------------------------------------------------
  /// Single-bed claim: marks the chosen bed as BAND, returns summary.
  static MockClaimResult claimBed(String bedId) {
    for (final entry in roomDetailById.entries) {
      final detail = entry.value;
      final bedsList = detail['beds'] as List<dynamic>;
      final idx = bedsList.indexWhere((b) => (b as Map)['id'] == bedId);
      if (idx < 0) continue;

      final bed = bedsList[idx] as Map<String, dynamic>;
      final wasBand = bed['current_status'] == 'BAND';
      bedsList[idx] = {
        ...bed,
        'current_status': 'BAND',
        'last_confirmed_at': DateTime.now().toUtc().toIso8601String(),
        'confirmation_count': 1,
      };
      var available = 0;
      for (final b in bedsList) {
        if ((b as Map)['current_status'] != 'BAND') available++;
      }
      detail['available_beds'] = available;
      return MockClaimResult(
        position: (bed['position'] as num).toInt(),
        roomNumber: detail['number'] as String,
        availableBeds: available,
        alreadyClaimed: wasBand,
      );
    }
    throw Exception('Karavot topilmadi');
  }

  static void applyConfirmation({
    required String roomId,
    required List<Map<String, dynamic>> beds,
  }) {
    final detail = roomDetailById[roomId];
    if (detail == null) return;
    final bedsList = detail['beds'] as List<dynamic>;
    var available = 0;
    for (final update in beds) {
      final position = update['position'] as int;
      final newStatus = update['status_reported'] as String;
      final idx = bedsList.indexWhere((b) => (b as Map)['position'] == position);
      if (idx >= 0) {
        final current = bedsList[idx] as Map<String, dynamic>;
        bedsList[idx] = {
          ...current,
          'current_status': newStatus,
          'last_confirmed_at': DateTime.now().toUtc().toIso8601String(),
          'confirmation_count':
              ((current['confirmation_count'] as num?)?.toInt() ?? 0) + 1,
        };
      }
    }
    for (final b in bedsList) {
      if ((b as Map)['current_status'] == 'BOSH') available++;
    }
    detail['available_beds'] = available;
    detail['confirmation_summary'] = {
      'total_confirmations_24h':
          ((detail['confirmation_summary']
                          as Map?)?['total_confirmations_24h']
                      as num?)
                  ?.toInt() ??
              0 + beds.length,
      'unique_users_24h': ((detail['confirmation_summary']
                          as Map?)?['unique_users_24h']
                      as num?)
                  ?.toInt() ??
              1 + 1,
      'last_updated_at': DateTime.now().toUtc().toIso8601String(),
      'minutes_since_update': 0,
    };
  }
}

class MockClaimResult {
  const MockClaimResult({
    required this.position,
    required this.roomNumber,
    required this.availableBeds,
    required this.alreadyClaimed,
  });

  final int position;
  final String roomNumber;
  final int availableBeds;
  final bool alreadyClaimed;
}
