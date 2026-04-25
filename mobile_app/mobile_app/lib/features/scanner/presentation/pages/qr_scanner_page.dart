import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../rooms/data/room_repository.dart';

class QrScannerPage extends ConsumerStatefulWidget {
  const QrScannerPage({super.key});

  @override
  ConsumerState<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends ConsumerState<QrScannerPage> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );
  bool _processing = false;
  bool _torchOn = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _extractToken(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final lower = raw.trim();
    // Accept either a full URL …/r/{token} or just the token.
    final urlMatch = RegExp(r'\/r\/([A-Za-z0-9_\-]+)').firstMatch(lower);
    if (urlMatch != null) return urlMatch.group(1);
    if (RegExp(r'^[A-Za-z0-9_\-]+$').hasMatch(lower) && lower.length >= 4) {
      return lower;
    }
    return null;
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_processing) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    final token = _extractToken(raw);
    if (token == null) return;

    setState(() => _processing = true);
    await _controller.stop();

    try {
      final repo = ref.read(roomRepositoryProvider);
      final room = await repo.byQrToken(token);
      if (!mounted) return;
      // Take patient straight into confirm flow.
      context.pushReplacement('/patient/room/${room.id}');
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('QR yaroqsiz: $e')),
      );
      await _controller.start();
      if (mounted) setState(() => _processing = false);
    }
  }

  Future<void> _toggleTorch() async {
    await _controller.toggleTorch();
    if (mounted) setState(() => _torchOn = !_torchOn);
  }

  Future<void> _enterTokenManually() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('QR token kiriting'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'qr-room-...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Davom etish'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      await _onDetect(
        BarcodeCapture(barcodes: [Barcode(rawValue: result)]),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error, child) =>
                _ScannerError(error: error),
          ),
          // Dimming overlay with cutout
          IgnorePointer(
            child: CustomPaint(
              size: Size.infinite,
              painter: _ScannerOverlayPainter(),
            ),
          ),
          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _CircleButton(
                      icon: LucideIcons.x,
                      onTap: () => context.canPop()
                          ? context.pop()
                          : context.go('/'),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'QR kodni skaner qiling',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    _CircleButton(
                      icon: _torchOn ? LucideIcons.zapOff : LucideIcons.zap,
                      onTap: _toggleTorch,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Bottom controls
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.qrCode,
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Eshikdagi QR kodni ramka ichiga joylashtiring',
                              style: TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: _enterTokenManually,
                      icon: const Icon(LucideIcons.keyboard, size: 16),
                      label: const Text('Tokenni qo\'lda kiritish'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white54),
                        backgroundColor: Colors.black.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_processing)
            Container(
              color: Colors.black.withValues(alpha: 0.6),
              alignment: Alignment.center,
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'Palata aniqlanmoqda...',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.55),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cutoutSize = size.width * 0.7;
    final rect = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: cutoutSize,
      height: cutoutSize,
    );
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(20));

    final overlay = Paint()..color = Colors.black.withValues(alpha: 0.55);
    final path = Path()
      ..addRect(Offset.zero & size)
      ..addRRect(rrect)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, overlay);

    final border = Paint()
      ..color = AppColors.bluePrimary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Corner brackets
    const cornerLen = 28.0;
    final tl = rect.topLeft;
    final tr = rect.topRight;
    final bl = rect.bottomLeft;
    final br = rect.bottomRight;

    canvas.drawLine(tl, tl + const Offset(cornerLen, 0), border);
    canvas.drawLine(tl, tl + const Offset(0, cornerLen), border);
    canvas.drawLine(tr, tr + const Offset(-cornerLen, 0), border);
    canvas.drawLine(tr, tr + const Offset(0, cornerLen), border);
    canvas.drawLine(bl, bl + const Offset(cornerLen, 0), border);
    canvas.drawLine(bl, bl + const Offset(0, -cornerLen), border);
    canvas.drawLine(br, br + const Offset(-cornerLen, 0), border);
    canvas.drawLine(br, br + const Offset(0, -cornerLen), border);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ScannerError extends StatelessWidget {
  const _ScannerError({required this.error});
  final MobileScannerException error;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            LucideIcons.cameraOff,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: 12),
          const Text(
            'Kameraga ruxsat berilmadi',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            error.errorDetails?.message ?? error.errorCode.toString(),
            style: const TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
