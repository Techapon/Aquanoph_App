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

  /// save_checklist: 1 transaction all-or-nothing (§7 ข้อ 2).
  /// changes: [{"op":"create","activity":{...}}, {"op":"update","activity":{...}}, {"op":"delete","id":"..."}]
  Future<void> saveChecklist(String pondId, List<Map<String, dynamic>> changes) async {
    try {
      await _client.rpc('save_checklist', params: {
        'p_pond_id': pondId,
        'p_changes': changes,
      });
    } on PostgrestException catch (e) {
      throw CoreFailure.databaseError(e.message);
    }
  }

  /// upsert_activity: returns id (new or existing).
  Future<String> upsertActivity(String pondId, Map<String, dynamic> activity) async {
    try {
      final res = await _client.rpc('upsert_activity', params: {
        'p_pond_id': pondId,
        'p_activity': activity,
      });
      return res as String? ?? '';
    } on PostgrestException catch (e) {
      throw CoreFailure.databaseError(e.message);
    }
  }

  /// delete_activity by id.
  Future<void> deleteActivity(String activityId) async {
    try {
      await _client.rpc('delete_activity', params: {
        'p_activity_id': activityId,
      });
    } on PostgrestException catch (e) {
      throw CoreFailure.databaseError(e.message);
    }
  }
}
