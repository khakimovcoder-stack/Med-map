// Lightweight Uzbek-friendly formatters used across the UI.

export function formatRelativeMinutes(minutes) {
  if (minutes == null) return "Hali yangilanmagan";
  if (minutes < 1) return 'Hozirgina';
  if (minutes === 1) return '1 daqiqa oldin';
  if (minutes < 60) return `${minutes} daqiqa oldin`;
  const hours = Math.floor(minutes / 60);
  if (hours === 1) return '1 soat oldin';
  if (hours < 24) return `${hours} soat oldin`;
  const days = Math.floor(hours / 24);
  if (days === 1) return '1 kun oldin';
  return `${days} kun oldin`;
}

export function minutesSince(isoString) {
  if (!isoString) return null;
  const ts = new Date(isoString).getTime();
  if (Number.isNaN(ts)) return null;
  return Math.max(0, Math.round((Date.now() - ts) / 60000));
}

export function formatPhone(phone) {
  if (!phone) return '';
  // +998 XX XXX XX XX
  const digits = phone.replace(/\D/g, '');
  if (digits.length === 12 && digits.startsWith('998')) {
    return `+${digits.slice(0, 3)} ${digits.slice(3, 5)} ${digits.slice(5, 8)} ${digits.slice(8, 10)} ${digits.slice(10)}`;
  }
  return phone;
}
