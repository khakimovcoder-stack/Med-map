import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/hospital_repository.dart';
import '../data/models/hospital.dart';

/// Reactive search query for the hospital list page.
final hospitalSearchQueryProvider = StateProvider<String>((ref) => '');

final hospitalListProvider = FutureProvider.autoDispose<List<Hospital>>((ref) {
  final query = ref.watch(hospitalSearchQueryProvider);
  final repo = ref.watch(hospitalRepositoryProvider);
  return repo.list(search: query.isEmpty ? null : query);
});

final hospitalDetailProvider =
    FutureProvider.autoDispose.family<HospitalDetail, String>((ref, id) {
  return ref.watch(hospitalRepositoryProvider).detail(id);
});
