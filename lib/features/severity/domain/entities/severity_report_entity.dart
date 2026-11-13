import 'package:aquanoph/features/severity/domain/entities/pond_status_entity.dart';

/// One severity_reports row (per parameter per reading) — the latest per parameter
/// feeds the all-parameters dialog. 4 text columns are what the app shows [V: APP_SPEC §2.7/§4.6].
class SeverityReportEntity {
  final String parameter; // raw enum label: DO, pH, Temperature, NH3, NO2_N, Salinity
  final DateTime measuredAt; // UTC
  final double? value;
  final PondSeverity severity;
  final bool recovering; // generated column: zone optimal + severity stress
  final String? description;
  final String? detail;
  final String? appendDes; // DB column append_des
  final String? guidance;

  const SeverityReportEntity({
    required this.parameter,
    required this.measuredAt,
    required this.severity,
    this.value,
    this.recovering = false,
    this.description,
    this.detail,
    this.appendDes,
    this.guidance,
  });
}
