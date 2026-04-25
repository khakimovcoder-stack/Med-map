/// Returns a human-friendly Uzbek "X daqiqa oldin" string.
String timeAgoUz(DateTime? when) {
  if (when == null) return 'Tasdiqlanmagan';
  final now = DateTime.now();
  final diff = now.difference(when.toLocal());

  if (diff.isNegative || diff.inSeconds < 30) return 'hozirgina';
  if (diff.inMinutes < 1) return '${diff.inSeconds} soniya oldin';
  if (diff.inMinutes < 60) return '${diff.inMinutes} daqiqa oldin';
  if (diff.inHours < 24) return '${diff.inHours} soat oldin';
  if (diff.inDays < 7) return '${diff.inDays} kun oldin';
  if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} hafta oldin';
  if (diff.inDays < 365) return '${(diff.inDays / 30).floor()} oy oldin';
  return '${(diff.inDays / 365).floor()} yil oldin';
}

String minutesAgoUz(int? minutes) {
  if (minutes == null) return 'Tasdiqlanmagan';
  if (minutes < 1) return 'hozirgina';
  if (minutes < 60) return '$minutes daqiqa oldin';
  if (minutes < 60 * 24) return '${(minutes / 60).floor()} soat oldin';
  return '${(minutes / (60 * 24)).floor()} kun oldin';
}
