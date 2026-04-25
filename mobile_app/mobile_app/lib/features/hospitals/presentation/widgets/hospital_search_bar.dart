import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../providers/hospital_providers.dart';

class HospitalSearchBar extends ConsumerStatefulWidget {
  const HospitalSearchBar({super.key});

  @override
  ConsumerState<HospitalSearchBar> createState() => _HospitalSearchBarState();
}

class _HospitalSearchBarState extends ConsumerState<HospitalSearchBar> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(hospitalSearchQueryProvider.notifier).state = value.trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: _onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Shifoxonani qidiring (Toshkent, RIKM...)',
        prefixIcon: const Padding(
          padding: EdgeInsets.only(left: 14, right: 8),
          child: Icon(LucideIcons.search, size: 20, color: AppColors.gray500),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 44),
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(LucideIcons.x, size: 18),
                color: AppColors.gray500,
                onPressed: () {
                  _controller.clear();
                  ref.read(hospitalSearchQueryProvider.notifier).state = '';
                  setState(() {});
                },
              ),
      ),
    );
  }
}
