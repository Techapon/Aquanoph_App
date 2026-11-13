import 'package:aquanoph/core/utils/db_num.dart';
import 'package:aquanoph/features/severity/data/models/severity_label.dart';
import 'package:aquanoph/features/severity/domain/entities/severity_report_entity.dart';

/// Latest severity_reports row per parameter: fetch measured_at DESC, keep the
/// first row seen per parameter (no RPC/view needed — ponytail: if a pond ever
/// keeps >120 recent rows across params, add a DISTINCT ON view).
class SeverityReportModel {
  final String parameter;
  final DateTime measuredAt;
  final double? value;
  final String severityLabel;
  final bool recovering;
  final String? description;
  final String? detail;
  final String? appendDes;
  final String? guidance;

  const SeverityReportModel({
    required this.parameter,
    required this.measuredAt,
    required this.severityLabel,
    this.value,
    this.recovering = false,
    this.description,
    this.detail,
    this.appendDes,
    this.guidance,
  });

  static const columns = 'parameter,measured_at,value,severity,recovering,description,detail,append_des,guidance';

  factory SeverityReportModel.fromMap(Map<String, dynamic> map) => SeverityReportModel(
        parameter: map['parameter'] as String? ?? '',
        measuredAt: DateTime.tryParse(map['measured_at'] as String? ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
        value: asDouble(map['value']),
        severityLabel: map['severity'] as String? ?? '',
        recovering: map['recovering'] as bool? ?? false,
        description: map['description'] as String?,
        detail: map['detail'] as String?,
        appendDes: map['append_des'] as String?,
        guidance: map['guidance'] as String?,
      );

  /// [rows] must be ordered measured_at DESC.
  static List<SeverityReportModel> latestPerParameter(List<Map<String, dynamic>> rows) {
    final seen = <String>{};
    final out = <SeverityReportModel>[];
    for (final r in rows) {
      final m = SeverityReportModel.fromMap(r);
      if (m.parameter.isEmpty || !seen.add(m.parameter)) continue;
      out.add(m);
    }
    return out;
  }

  SeverityReportEntity toEntity() => SeverityReportEntity(
        parameter: parameter,
        measuredAt: measuredAt,
        value: value,
        severity: severityFromLabel(severityLabel),
        recovering: recovering,
        description: description,
        detail: detail,
        appendDes: appendDes,
        guidance: guidance,
      );
}
