import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:aquanoph/core/exception/core_error_failure.dart';
import 'package:aquanoph/features/pond/data/models/pond_model.dart';
import 'package:aquanoph/features/pond/domain/entities/pond_draft.dart';

class PondRemoteDatasource {
  SupabaseClient get _client => Supabase.instance.client;

  static const _cols = 'id, name, area_m2, avg_depth_m, species, stocking_count, avg_weight_g, stocking_date, device_id, timezone, created_at';

  Future<List<PondModel>> getPonds(String userId) async {
    try {
      final rows = await _client.from('ponds').select(_cols).eq('user_id', userId).order('created_at');
      return rows.map((m) => PondModel.fromMap(m)).toList();
    } on PostgrestException catch (e) {
      throw CoreFailure.databaseError(e.message);
    }
  }

  /// RPC derives the owner from auth.uid() and the DB default sets species (nile_tilapia).
  /// Signature [V verified 2026-11-13]: create_pond(p_name text, p_area_m2 numeric, p_avg_depth_m numeric,
  ///   p_stocking_count int, p_avg_weight_g numeric, p_stocking_date date, p_device_id text, p_timezone text)
  Future<void> createPond(PondDraft draft) async {
    try {
      await _client.rpc('create_pond', params: {
        'p_name': draft.name,
        'p_area_m2': draft.areaM2,
        'p_avg_depth_m': draft.avgDepthM,
        'p_stocking_count': draft.stockingCount,
        'p_avg_weight_g': draft.avgWeightG,
        'p_stocking_date': draft.stockingDate.toIso8601String().substring(0, 10),
        'p_device_id': draft.deviceId,
        'p_timezone': draft.timezone,
      });
    } on PostgrestException catch (e) {
      throw CoreFailure.databaseError(e.message);
    }
  }

  /// Column grant allows only name / stocking_count / avg_weight_g (APP_SPEC_ALIGNMENT §2.3).
  Future<void> updatePond(String pondId, {String? name, int? stockingCount, double? avgWeightG}) async {
    try {
      final patch = <String, dynamic>{};
      if (name != null) patch['name'] = name;
      if (stockingCount != null) patch['stocking_count'] = stockingCount;
      if (avgWeightG != null) patch['avg_weight_g'] = avgWeightG;
      if (patch.isEmpty) return;
      await _client.from('ponds').update(patch).eq('id', pondId);
    } on PostgrestException catch (e) {
      throw CoreFailure.databaseError(e.message);
    }
  }
}
