import 'package:flutter/services.dart';

/// Formats raw 9-digit user input into "+998 XX XXX XX XX" while typing.
class UzPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final trimmed = digits.length > 9 ? digits.substring(0, 9) : digits;

    final buf = StringBuffer();
    for (var i = 0; i < trimmed.length; i++) {
      if (i == 2 || i == 5 || i == 7) buf.write(' ');
      buf.write(trimmed[i]);
    }
    final formatted = buf.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Returns a 9-digit subscriber number from any user input, or null if invalid.
String? extractUzSubscriber(String raw) {
  final digits = raw.replaceAll(RegExp(r'\D'), '');
  if (digits.length == 12 && digits.startsWith('998')) {
    return digits.substring(3);
  }
  if (digits.length == 9) return digits;
  return null;
}

/// Returns full E.164 +998XXXXXXXXX format, or null if input is invalid.
String? toE164Uz(String raw) {
  final sub = extractUzSubscriber(raw);
  if (sub == null) return null;
  return '+998$sub';
}

/// Pretty display for "+998 90 123 45 67".
String formatE164Uz(String e164) {
  if (!e164.startsWith('+998') || e164.length != 13) return e164;
  final s = e164.substring(4);
  return '+998 ${s.substring(0, 2)} ${s.substring(2, 5)} ${s.substring(5, 7)} ${s.substring(7, 9)}';
}
