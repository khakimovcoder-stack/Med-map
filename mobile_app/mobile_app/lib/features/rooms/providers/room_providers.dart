import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/room.dart';
import '../data/room_repository.dart';

final floorRoomsProvider =
    FutureProvider.autoDispose.family<FloorRoomsResponse, String>(
  (ref, floorId) =>
      ref.watch(roomRepositoryProvider).roomsForFloor(floorId),
);

final roomDetailProvider =
    FutureProvider.autoDispose.family<RoomDetail, String>(
  (ref, roomId) => ref.watch(roomRepositoryProvider).detail(roomId),
);

final roomByQrProvider =
    FutureProvider.autoDispose.family<RoomDetail, String>(
  (ref, token) => ref.watch(roomRepositoryProvider).byQrToken(token),
);
