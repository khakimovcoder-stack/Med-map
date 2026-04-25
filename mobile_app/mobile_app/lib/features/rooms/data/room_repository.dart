import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/mock_data.dart';
import 'models/room.dart';

abstract interface class RoomRepository {
  Future<FloorRoomsResponse> roomsForFloor(String floorId);
  Future<RoomDetail> detail(String roomId);
  Future<RoomDetail> byQrToken(String token);
}

class RoomRepositoryImpl implements RoomRepository {
  RoomRepositoryImpl(this._client);
  final ApiClient _client;

  @override
  Future<FloorRoomsResponse> roomsForFloor(String floorId) async {
    final res = await _client.getJson(ApiEndpoints.floorRooms(floorId));
    final data = res['data'] as Map<String, dynamic>;
    return FloorRoomsResponse.fromJson(data);
  }

  @override
  Future<RoomDetail> detail(String roomId) async {
    final res = await _client.getJson(ApiEndpoints.room(roomId));
    return RoomDetail.fromJson(res['data'] as Map<String, dynamic>);
  }

  @override
  Future<RoomDetail> byQrToken(String token) async {
    final res = await _client.getJson(ApiEndpoints.roomByQr(token));
    return RoomDetail.fromJson(res['data'] as Map<String, dynamic>);
  }
}

class MockRoomRepository implements RoomRepository {
  const MockRoomRepository();

  @override
  Future<FloorRoomsResponse> roomsForFloor(String floorId) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final rooms = MockData.roomsByFloor[floorId];
    if (rooms == null) {
      throw Exception('Floor not found');
    }
    final floorMeta = MockData.floorsByHospital.values
        .expand((l) => l)
        .firstWhere((f) => f['id'] == floorId);
    final hospId = _hospitalIdFromFloorId(floorId);
    final hosp = MockData.hospitals.firstWhere((h) => h['id'] == hospId);

    return FloorRoomsResponse.fromJson({
      'floor': {
        ...floorMeta,
        'hospital': {
          'id': hosp['id'],
          'name': hosp['short_name'],
        },
      },
      'rooms': rooms,
    });
  }

  @override
  Future<RoomDetail> detail(String roomId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final detail = MockData.roomDetailById[roomId];
    if (detail == null) throw Exception('Room not found');
    return RoomDetail.fromJson(detail);
  }

  @override
  Future<RoomDetail> byQrToken(String token) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final roomId = MockData.roomIdByQrToken[token];
    if (roomId == null) throw Exception('QR kod yaroqsiz');
    return detail(roomId);
  }

  String _hospitalIdFromFloorId(String floorId) {
    // floor-hosp-001-1 → hosp-001
    final parts = floorId.split('-');
    return '${parts[1]}-${parts[2]}';
  }
}

final roomRepositoryProvider = Provider<RoomRepository>((ref) {
  if (ApiEndpoints.kUseMock) return const MockRoomRepository();
  final client = ref.watch(apiClientProvider);
  return RoomRepositoryImpl(client);
});
