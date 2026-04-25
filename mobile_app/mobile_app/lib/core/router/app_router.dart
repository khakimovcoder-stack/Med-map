import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/confirmation/presentation/pages/patient_confirm_page.dart';
import '../../features/hospitals/presentation/pages/hospital_detail_page.dart';
import '../../features/hospitals/presentation/pages/hospital_list_page.dart';
import '../../features/rooms/presentation/pages/floor_rooms_page.dart';
import '../../features/rooms/presentation/pages/room_detail_page.dart';
import '../../features/scanner/presentation/pages/qr_scanner_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HospitalListPage(),
      ),
      GoRoute(
        path: '/hospitals/:id',
        builder: (context, state) => HospitalDetailPage(
          hospitalId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/floors/:id',
        builder: (context, state) => FloorRoomsPage(
          floorId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/rooms/:id',
        builder: (context, state) => RoomDetailPage(
          roomId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/scan',
        builder: (context, state) => const QrScannerPage(),
      ),
      GoRoute(
        path: '/patient/room/:id',
        builder: (context, state) => PatientConfirmPage(
          roomId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Topilmadi')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 12),
              Text(state.error?.toString() ?? 'Sahifa topilmadi'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Bosh sahifa'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
});
