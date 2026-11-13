import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:aquanoph/core/exception/core_error_failure.dart';
import 'package:aquanoph/features/severity/data/models/pond_status_model.dart';

class SeverityRemoteDatasource {
  SupabaseClient get _client => Supabase.instance.client;

  /// Representative severity from v_pond_status [V: 010] + text/`recovering` from the
  /// latest severity_reports row of that parameter. Null = no analysis output yet.
  Future<PondStatusModel?> getPondStatus(String pondId) async {
    try {
      final status = await _client
          .from('v_pond_status')
          .select('pond_id, parameter, severity, updated_at')
          .eq('pond_id', pondId)
          .maybeSingle();
      if (status == null) return null;
      final report = await _client
          .from('severity_reports')
          .select('description, value, recovering')
          .eq('pond_id', pondId)
          .eq('parameter', status['parameter'])
          .order('measured_at', ascending: false)
          .limit(1)
          .maybeSingle();
      return PondStatusModel.fromMaps(status, report);
    } on PostgrestException catch (e) {
      throw CoreFailure.databaseError(e.message);
    }
  }
}
