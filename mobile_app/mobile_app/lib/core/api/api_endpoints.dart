class ApiEndpoints {
  ApiEndpoints._();

  /// When true, repositories return hardcoded sample data and never hit the network.
  /// Toggle to false once the backend is reachable.
  static const bool kUseMock = false;

  /// Base URL for development & production.
  static String get baseUrl => 'https://med-map-production.up.railway.app/api/v1';

  // Hospitals
  static const String hospitals = '/hospitals/';
  static String hospital(String id) => '/hospitals/$id/';
  static String hospitalFloors(String id) => '/hospitals/$id/floors/';

  // Floors / rooms
  static String floorRooms(String id) => '/floors/$id/rooms/';
  static String room(String id) => '/rooms/$id/';
  static String roomByQr(String token) => '/rooms/by-qr/$token/';

  // Auth
  static const String oneIdStart = '/auth/oneid/start/';
  static const String oneIdVerify = '/auth/oneid/verify/';

  // Confirmations
  static const String confirmations = '/confirmations/';
}
