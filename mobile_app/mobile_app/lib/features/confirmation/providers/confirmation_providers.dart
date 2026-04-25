import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/confirmation_repository.dart';

/// State of the patient single-bed claim form.
class ClaimDraft {
  const ClaimDraft({this.selectedBedId});

  /// bed.id of the bed the citizen is about to book, or null if none yet.
  final String? selectedBedId;

  bool get hasSelection => selectedBedId != null;

  ClaimDraft copyWith({String? selectedBedId, bool clear = false}) {
    return ClaimDraft(
      selectedBedId: clear ? null : (selectedBedId ?? this.selectedBedId),
    );
  }
}

class ClaimDraftController extends StateNotifier<ClaimDraft> {
  ClaimDraftController() : super(const ClaimDraft());

  void select(String bedId) =>
      state = ClaimDraft(selectedBedId: bedId);

  void clear() => state = const ClaimDraft();
}

final claimDraftProvider =
    StateNotifierProvider.autoDispose<ClaimDraftController, ClaimDraft>(
  (ref) => ClaimDraftController(),
);

/// Submits a single-bed claim and returns the result.
final claimBedProvider = Provider<Future<ClaimResult> Function(String)>((ref) {
  final repo = ref.watch(confirmationRepositoryProvider);
  return repo.claimBed;
});
