/// One diagnostic episode (diagnostic_reports row) for a parameter.
/// Text comes from the renderDiagnostic jsonb cache — app reads, never renders [V: APP_SPEC §2.8].
class DiagnosticEntity {
  final String parameter;
  final DateTime onsetAt; // UTC
  final DateTime? endAt; // null = still open
  final bool open;
  final bool noClearCause;
  final String? title;
  final List<String> causes;
  final String? footer;
  final String? revisedLabel;

  const DiagnosticEntity({
    required this.parameter,
    required this.onsetAt,
    required this.open,
    this.endAt,
    this.noClearCause = false,
    this.title,
    this.causes = const [],
    this.footer,
    this.revisedLabel,
  });
}
