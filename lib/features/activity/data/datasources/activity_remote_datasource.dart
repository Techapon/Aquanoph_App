import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:aquanoph/core/exception/core_error_failure.dart';
import 'package:aquanoph/features/activity/data/models/activity_model.dart';

class ActivityRemoteDatasource {
  SupabaseClient get _client => Supabase.instance.client;

  /// v_activities [V: 010] rows of one UTC-instant window (pond-local day,
  /// bounds pre-computed by the caller — datasource stays timezone-agnostic).
  /// ponytail: filters on start_time only, so an aeration that started before
  /// midnight is missing from "today". Upgrade: two-day window + clip labels.
  Future<List<ActivityModel>> getDay(String pondId, DateTime from, DateTime to) async {
    try {
      final rows = await _client
          .from('v_activities')
          .select('id, type, status, start_time, end_time, fraction, quantity_kg, missed')
          .eq('pond_id', pondId)
          .gte('start_time', from.toIso8601String())
          .lt('start_time', to.toIso8601String())
          .order('start_time');
      return rows.map(ActivityModel.fromMap).toList();
    } on PostgrestException catch (e) {
      throw CoreFailure.databaseError(e.message);
    }
  }
}
