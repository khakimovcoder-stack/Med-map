import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/phone_formatter.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../data/models/auth_session.dart';
import '../../providers/auth_providers.dart';
import '../../data/auth_repository.dart';

/// Bottom-sheet modal that walks the user through OneID phone + OTP.
/// Returns the verified [AuthSession] on success, or null if cancelled.
Future<AuthSession?> showOneIdModal(BuildContext context) {
  return showModalBottomSheet<AuthSession>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => const _OneIdModal(),
  );
}

class _OneIdModal extends ConsumerStatefulWidget {
  const _OneIdModal();

  @override
  ConsumerState<_OneIdModal> createState() => _OneIdModalState();
}

enum _Step { phone, otp }

class _OneIdModalState extends ConsumerState<_OneIdModal> {
  _Step _step = _Step.phone;
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _otpCtrl = TextEditingController();
  bool _busy = false;
  String? _error;
  OneIdStartResult? _session;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    final e164 = toE164Uz(_phoneCtrl.text);
    if (e164 == null) {
      setState(() => _error = 'Telefon raqamni to\'liq kiriting');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final repo = ref.read(authRepositoryProvider);
      final session = await repo.start(e164);
      if (!mounted) return;
      setState(() {
        _session = session;
        _step = _Step.otp;
      });
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _verify() async {
    final session = _session;
    if (session == null) return;
    if (_otpCtrl.text.length != 6) {
      setState(() => _error = 'Kod 6 raqamdan iborat bo\'lishi kerak');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final repo = ref.read(authRepositoryProvider);
      final auth = await repo.verify(
        sessionId: session.sessionId,
        otp: _otpCtrl.text,
      );
      await ref.read(authControllerProvider.notifier).applySession(auth);
      if (!mounted) return;
      Navigator.of(context).pop(auth);
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewInsets = MediaQuery.of(context).viewInsets;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(top: 8, bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.gray200,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.bluePrimary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      LucideIcons.shieldCheck,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'OneID orqali tasdiqlash',
                        style: theme.textTheme.titleMedium,
                      ),
                      Text(
                        'Davlat identifikatsiya tizimi',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_step == _Step.phone) _buildPhoneStep(theme),
              if (_step == _Step.otp) _buildOtpStep(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneStep(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Telefon raqamingizni kiriting',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.gray500,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.gray200),
              ),
              child: const Row(
                children: [
                  Text('🇺🇿', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 6),
                  Text(
                    '+998',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                autofocus: true,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  UzPhoneFormatter(),
                ],
                style: const TextStyle(fontSize: 18, letterSpacing: 1),
                decoration: const InputDecoration(
                  hintText: '90 123 45 67',
                ),
              ),
            ),
          ],
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          _ErrorMessage(text: _error!),
        ],
        const SizedBox(height: 20),
        PrimaryButton(
          label: 'Davom etish',
          isLoading: _busy,
          onPressed: _busy ? null : _start,
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'Mock rejim — istalgan O\'zbekiston raqami qabul qilinadi',
            style: theme.textTheme.bodySmall,
          ),
        ),
      ],
    );
  }

  Widget _buildOtpStep(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${formatE164Uz(_session?.phone ?? '')} raqamiga kod yuborildi',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _otpCtrl,
          keyboardType: TextInputType.number,
          maxLength: 6,
          autofocus: true,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 28,
            letterSpacing: 12,
            fontWeight: FontWeight.w700,
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            counterText: '',
            hintText: '------',
            hintStyle: TextStyle(letterSpacing: 12),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.yellowLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            children: [
              Icon(
                LucideIcons.info,
                size: 14,
                color: AppColors.yellowWarning,
              ),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Mock rejim: kod har doim 123456',
                  style: TextStyle(
                    color: AppColors.yellowWarning,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          _ErrorMessage(text: _error!),
        ],
        const SizedBox(height: 20),
        PrimaryButton(
          label: 'Tasdiqlash',
          icon: LucideIcons.shieldCheck,
          isLoading: _busy,
          onPressed: _busy ? null : _verify,
        ),
        const SizedBox(height: 8),
        Center(
          child: TextButton(
            onPressed: _busy
                ? null
                : () {
                    setState(() {
                      _step = _Step.phone;
                      _otpCtrl.clear();
                      _error = null;
                    });
                  },
            child: const Text('Boshqa raqam kiritish'),
          ),
        ),
      ],
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.redLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            LucideIcons.alertCircle,
            color: AppColors.redDanger,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.redDanger,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
