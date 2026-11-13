import 'package:aquanoph/features/severity/domain/entities/pond_status_entity.dart';

/// DB `severity_level` enum label -> app enum. Unknown label = `unknown`, never guessed.
const severityLabelMap = {
  'optimal': PondSeverity.optimal,
  'stress': PondSeverity.stress,
  'elevated_risk': PondSeverity.elevatedRisk,
  'critical': PondSeverity.critical,
};

PondSeverity severityFromLabel(String? label) => severityLabelMap[label] ?? PondSeverity.unknown;
