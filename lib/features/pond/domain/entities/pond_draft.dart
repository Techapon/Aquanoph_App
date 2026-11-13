/// Input for the create_pond RPC (wizard has no id yet).
/// species is NOT part of the RPC (DB default nile_tilapia) — [V: function signature 2026-11-13].
class PondDraft {
  final String name;
  final double areaM2;
  final double avgDepthM;
  final int stockingCount;
  final double avgWeightG;
  final DateTime stockingDate;
  final String deviceId;
  final String timezone;

  const PondDraft({
    required this.name,
    required this.areaM2,
    required this.avgDepthM,
    required this.stockingCount,
    required this.avgWeightG,
    required this.stockingDate,
    required this.deviceId,
    required this.timezone,
  });
}
