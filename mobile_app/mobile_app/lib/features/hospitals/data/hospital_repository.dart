import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/mock_data.dart';
import 'models/hospital.dart';

abstract interface class HospitalRepository {
  Future<List<Hospital>> list({String? search});
  Future<HospitalDetail> detail(String id);
}

class HospitalRepositoryImpl implements HospitalRepository {
  HospitalRepositoryImpl(this._client);
  final ApiClient _client;

  @override
  Future<List<Hospital>> list({String? search}) async {
    final res = await _client.getJson(
      ApiEndpoints.hospitals,
      query: {
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );
    final list = (res['data'] as List?) ?? const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(Hospital.fromJson)
        .toList(growable: false);
  }

  @override
  Future<HospitalDetail> detail(String id) async {
    final res = await _client.getJson(ApiEndpoints.hospital(id));
    final data = res['data'] as Map<String, dynamic>;
    return HospitalDetail.fromJson(data);
  }
}

class MockHospitalRepository implements HospitalRepository {
  const MockHospitalRepository();

  @override
  Future<List<Hospital>> list({String? search}) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final all = MockData.hospitals;
    final query = search?.trim().toLowerCase() ?? '';
    Iterable<Map<String, dynamic>> filtered = all;
    if (query.isNotEmpty) {
      filtered = all.where((h) {
        return (h['name'] as String).toLowerCase().contains(query) ||
            (h['short_name'] as String).toLowerCase().contains(query) ||
            (h['city'] as String).toLowerCase().contains(query);
      });
    }
    return filtered.map(Hospital.fromJson).toList(growable: false);
  }

  @override
  Future<HospitalDetail> detail(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final hosp = MockData.hospitals.firstWhere(
      (h) => h['id'] == id,
      orElse: () => throw Exception('Hospital not found'),
    );
    final floors = MockData.floorsByHospital[id] ?? const [];
    return HospitalDetail.fromJson({
      ...hosp,
      'floors': floors,
    });
  }
}

final hospitalRepositoryProvider = Provider<HospitalRepository>((ref) {
  if (ApiEndpoints.kUseMock) return const MockHospitalRepository();
  final client = ref.watch(apiClientProvider);
  return HospitalRepositoryImpl(client);
});
