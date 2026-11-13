/// Severity levels from DB enum `severity_level` (migration 001) [V].
/// `unknown` = label we never saw in DB — never guess a real level for it.
enum PondSeverity { optimal, stress, elevatedRisk, critical, unknown }

/// Representative water-quality state of one pond for the home screen.
/// From view v_pond_status (highest severity across params, tie -> param_priority)
/// + text/recovering from the latest severity_reports row of that parameter.
class PondStatusEntity {
  final String pondId;
  final String parameter; // raw enum label: DO, NH3, NO2_N, pH, Temperature, Salinity
  final PondSeverity severity;
  final bool recovering; // Recovery Hold: zone optimal + severity stress [V: generated column]
  final DateTime updatedAt;
  final String? description; // severity 4-field text: description (home summary line)
  final double? value; // latest reading of the representative parameter

  const PondStatusEntity({
    required this.pondId,
    required this.parameter,
    required this.severity,
    required this.recovering,
    required this.updatedAt,
    this.description,
    this.value,
  });

  /// Home badge rule (DESIGN_TOKENS obs #3): Recovery Hold collapses to one gradient badge.
  bool get showRecoveryBadge => recovering && severity == PondSeverity.stress;
}
