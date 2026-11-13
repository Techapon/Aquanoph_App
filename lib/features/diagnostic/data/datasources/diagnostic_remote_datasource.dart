import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:aquanoph/core/exception/core_error_failure.dart';
import 'package:aquanoph/features/diagnostic/data/models/diagnostic_report_model.dart';

class DiagnosticRemoteDatasource {
  SupabaseClient get _client => Supabase.instance.client;

  /// Latest episode per parameter: onset DESC, dedupe client-side.
  /// limit 60 episodes across 6 params comfortably covers "latest" [A].
  Future<List<DiagnosticReportModel>> getLatestPerParameter(
    String pondId,
  ) async {
    try {
      final rows = await _client
          .from('diagnostic_reports')
          .select(DiagnosticReportModel.columns)
          .eq('pond_id', pondId)
          .order('onset_at', ascending: false)
          .limit(60);
      return DiagnosticReportModel.latestPerParameter(rows);
    } on PostgrestException catch (e) {
      throw CoreFailure.databaseError(e.message);
    }
  }
}
