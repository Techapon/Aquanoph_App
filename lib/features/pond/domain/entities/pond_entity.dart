/// Pond entity — facts only (derived volume/biomass are computed getters).
/// Schema: docs/APP_SPEC_ALIGNMENT.md §2.3 (app may edit name / stocking_count / avg_weight_g only).
class PondEntity {
  final String id;
  final String name;
  final double areaM2;
  final double avgDepthM;
  final String species; // enum value e.g. 'nile_tilapia'
  final int stockingCount;
  final double avgWeightG;
  final DateTime? stockingDate;
  final String deviceId;
  final String timezone; // IANA id
  final DateTime? createdAt;

  PondEntity({
    required this.id,
    required this.name,
    required this.areaM2,
    required this.avgDepthM,
    required this.species,
    required this.stockingCount,
    required this.avgWeightG,
    this.stockingDate,
    required this.deviceId,
    required this.timezone,
    this.createdAt,
  });

  double get volumeM3 => areaM2 * avgDepthM;
  double get biomassKg => stockingCount * avgWeightG / 1000;
}
