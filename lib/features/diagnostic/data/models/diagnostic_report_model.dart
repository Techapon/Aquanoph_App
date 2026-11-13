import 'package:aquanoph/features/diagnostic/domain/entities/diagnostic_entity.dart';

/// Latest diagnostic_reports row per parameter (same pattern as SeverityReportModel).
class DiagnosticReportModel {
  final String parameter;
  final DateTime onsetAt;
  final DateTime? endAt;
  final String statusLabel;
  final bool noClearCause;
  final String? title;
  final List<String> causes;
  final String? footer;
  final String? revisedLabel;

  const DiagnosticReportModel({
    required this.parameter,
    required this.onsetAt,
    required this.statusLabel,
    this.endAt,
    this.noClearCause = false,
    this.title,
    this.causes = const [],
    this.footer,
    this.revisedLabel,
  });

  static const columns = 'parameter,onset_at,end_at,status,no_clear_cause,text';

  factory DiagnosticReportModel.fromMap(Map<String, dynamic> map) {
    final text = map['text']; // jsonb cache from renderDiagnostic
    final m = text is Map
        ? text.cast<String, dynamic>()
        : const <String, dynamic>{};
    return DiagnosticReportModel(
      parameter: map['parameter'] as String? ?? '',
      onsetAt:
          DateTime.tryParse(map['onset_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      endAt: map['end_at'] == null
          ? null
          : DateTime.tryParse(map['end_at'] as String),
      statusLabel: map['status'] as String? ?? '',
      noClearCause: map['no_clear_cause'] as bool? ?? false,
      title: m['title'] as String?,
      causes: (m['causes'] as List?)?.whereType<String>().toList() ?? const [],
      footer: m['footer'] as String?,
      revisedLabel: m['revisedLabel'] as String?,
    );
  }

  /// [rows] must be ordered onset_at DESC.
  static List<DiagnosticReportModel> latestPerParameter(
    List<Map<String, dynamic>> rows,
  ) {
    final seen = <String>{};
    final out = <DiagnosticReportModel>[];
    for (final r in rows) {
      final m = DiagnosticReportModel.fromMap(r);
      if (m.parameter.isEmpty || !seen.add(m.parameter)) continue;
      out.add(m);
    }
    return out;
  }

  DiagnosticEntity toEntity() => DiagnosticEntity(
    parameter: parameter,
    onsetAt: onsetAt,
    endAt: endAt,
    open: statusLabel == 'open' || (endAt == null && statusLabel.isEmpty),
    noClearCause: noClearCause,
    title: title,
    causes: causes,
    footer: footer,
    revisedLabel: revisedLabel,
  );
}
