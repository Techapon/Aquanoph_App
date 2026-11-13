/// Pond-local wall-clock helpers without an IANA package (no intl/timezone dep).
/// All curated picker zones are DST-free, so a fixed offset per id is exact.
/// ponytail: unknown ids fall back to device local — wrong if the phone's zone
/// differs from the pond's. Upgrade path: add `timezone` package when the
/// country list grows past DST-free zones or ponds get real coordinates.
library;

const ianaUtcOffset = <String, Duration>{
  'Asia/Bangkok': Duration(hours: 7),
  'Asia/Ho_Chi_Minh': Duration(hours: 7),
  'Asia/Jakarta': Duration(hours: 7),
  'Asia/Kuala_Lumpur': Duration(hours: 8),
  'Asia/Singapore': Duration(hours: 8),
  'Asia/Manila': Duration(hours: 8),
  'Asia/Yangon': Duration(hours: 6, minutes: 30),
  'Asia/Dhaka': Duration(hours: 6),
  'Asia/Kolkata': Duration(hours: 5, minutes: 30),
  'Asia/Shanghai': Duration(hours: 8),
  'Asia/Tokyo': Duration(hours: 9),
  'UTC': Duration.zero,
};

/// Wall-clock time at the pond for a UTC instant. Result is naive (ignore its
/// own zone field); treat it as "what a clock on the pond shows".
DateTime pondLocal(DateTime utc, String iana) {
  final off = ianaUtcOffset[iana];
  if (off == null) return utc.toLocal();
  return utc.toUtc().add(off);
}

/// UTC bounds of the pond's local calendar day containing [nowUtc].
({DateTime from, DateTime to}) pondDayUtc(DateTime nowUtc, String iana) {
  final local = pondLocal(nowUtc, iana);
  final timeOfDay = Duration(hours: local.hour, minutes: local.minute, seconds: local.second, milliseconds: local.millisecond, microseconds: local.microsecond);
  final from = nowUtc.subtract(timeOfDay); // midnight at the pond, in UTC
  return (from: from, to: from.add(const Duration(days: 1)));
}

/// "9:30 AM" (append '.' at callsites where the design shows the trailing dot).
String formatClock(DateTime local) {
  final h = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final m = local.minute.toString().padLeft(2, '0');
  return '$h:$m ${local.hour < 12 ? 'AM' : 'PM'}';
}

const _shortMonths = ['Jan.', 'Feb.', 'Mar.', 'Apr.', 'May', 'Jun.', 'Jul.', 'Aug.', 'Sep.', 'Oct.', 'Nov.', 'Dec.'];

/// "20 Aug. 2026" — design's date style on the parameters dialog.
String formatDayDate(DateTime local) => '${local.day} ${_shortMonths[local.month - 1]} ${local.year}';
