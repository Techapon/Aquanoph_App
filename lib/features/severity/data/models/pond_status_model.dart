import 'package:aquanoph/core/utils/db_num.dart';
import 'package:aquanoph/features/severity/domain/entities/pond_status_entity.dart';

const _severityLabels = {
  'optimal': PondSeverity.optimal,
  'stress': PondSeverity.stress,
  'elevated_risk': PondSeverity.elevatedRisk,
  'critical': PondSeverity.critical,
};

class PondStatusModel {
  final String pondId;
  final String parameter;
  final String severityLabel;
  final DateTime updatedAt;
  final String? description;
  final bool recovering;
  final double? value;

  const PondStatusModel({
    required this.pondId,
    required this.parameter,
    required this.severityLabel,
    required this.updatedAt,
    this.description,
    this.recovering = false,
    this.value,
  });

  /// statusRow = v_pond_status; reportRow = latest severity_reports of that parameter
  /// (may be null right after a view/table race — degrade to no text, not an error).
  factory PondStatusModel.fromMaps(Map<String, dynamic> statusRow, Map<String, dynamic>? reportRow) => PondStatusModel(
        pondId: statusRow['pond_id'] as String? ?? '',
        parameter: statusRow['parameter'] as String? ?? '',
        severityLabel: statusRow['severity'] as String? ?? '',
        updatedAt: DateTime.tryParse(statusRow['updated_at'] as String? ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
        description: reportRow?['description'] as String?,
        recovering: reportRow?['recovering'] as bool? ?? false,
        value: asDouble(reportRow?['value']),
      );

  PondSeverity get severity => _severityLabels[severityLabel] ?? PondSeverity.unknown;

  PondStatusEntity toEntity() => PondStatusEntity(
        pondId: pondId,
        parameter: parameter,
        severity: severity,
        recovering: recovering,
        updatedAt: updatedAt,
        description: description,
        value: value,
      );
}
