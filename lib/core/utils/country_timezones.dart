/// Country-name <-> IANA timezone id mapping for the app UI.
/// The backend/DB always store IANA ids (CLAUDE.md §4.3 — localTime() needs them);
/// this is display-only sugar. Curated list of aquaculture-relevant countries [A].
const countryToTimezone = <String, String>{
  'Thailand': 'Asia/Bangkok',
  'Vietnam': 'Asia/Ho_Chi_Minh',
  'Indonesia': 'Asia/Jakarta',
  'Malaysia': 'Asia/Kuala_Lumpur',
  'Singapore': 'Asia/Singapore',
  'Philippines': 'Asia/Manila',
  'Myanmar': 'Asia/Yangon',
  'Bangladesh': 'Asia/Dhaka',
  'India': 'Asia/Kolkata',
  'China': 'Asia/Shanghai',
  'Japan': 'Asia/Tokyo',
  'UTC': 'UTC',
};

/// Unknown country -> UTC (safe fallback; picker only offers known keys anyway).
String timezoneFor(String country) => countryToTimezone[country] ?? 'UTC';

/// Reverse lookup; ids outside the map (any valid IANA in the DB) show as-is — no fabricated country.
String countryFor(String iana) {
  for (final e in countryToTimezone.entries) {
    if (e.value == iana) return e.key;
  }
  return iana;
}
