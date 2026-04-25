import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/mock_data.dart';

@immutable
class ClaimResult {
  const ClaimResult({
    required this.bedId,
    required this.position,
    required this.currentStatus,
    required this.roomNumber,
    required this.availableBeds,
    required this.message,
    required this.alreadyClaimed,
  });

  final String bedId;
  final int position;
  final String currentStatus;
  final String roomNumber;
  final int availableBeds;
  final String message;
  final bool alreadyClaimed;
}

abstract interface class ConfirmationRepository {
  /// Citizen claims a single bed for themselves.
  Future<ClaimResult> claimBed(String bedId);
}

class ConfirmationRepositoryImpl implements ConfirmationRepository {
  ConfirmationRepositoryImpl(this._client);
  final ApiClient _client;

  @override
  Future<ClaimResult> claimBed(String bedId) async {
    final res = await _client.postJson(
      ApiEndpoints.confirmations,
      body: {'bed_id': bedId},
    );
    final data = res['data'] as Map<String, dynamic>;
    final bed = data['bed'] as Map<String, dynamic>;
    final room = data['room'] as Map<String, dynamic>;
    return ClaimResult(
      bedId: bed['id'] as String,
      position: (bed['position'] as num).toInt(),
      currentStatus: bed['current_status'] as String,
      roomNumber: room['number'] as String,
      availableBeds: (room['available_beds'] as num).toInt(),
      message: data['message'] as String? ?? 'Rahmat!',
      alreadyClaimed: data['already_claimed'] as bool? ?? false,
    );
  }
}

class MockConfirmationRepository implements ConfirmationRepository {
  const MockConfirmationRepository();

  @override
  Future<ClaimResult> claimBed(String bedId) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final result = MockData.claimBed(bedId);
    return ClaimResult(
      bedId: bedId,
      position: result.position,
      currentStatus: 'BAND',
      roomNumber: result.roomNumber,
      availableBeds: result.availableBeds,
      message: result.alreadyClaimed
          ? 'Bu karavot allaqachon sizning nomingizga band qilingan.'
          : 'Rahmat! Karavot sizning nomingizga band qilindi.',
      alreadyClaimed: result.alreadyClaimed,
    );
  }
}

final confirmationRepositoryProvider =
    Provider<ConfirmationRepository>((ref) {
  if (ApiEndpoints.kUseMock) return const MockConfirmationRepository();
  final client = ref.watch(apiClientProvider);
  return ConfirmationRepositoryImpl(client);
});
