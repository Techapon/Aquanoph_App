import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:aquanoph/core/exception/core_error_failure.dart';
import 'package:aquanoph/features/recommendation/data/models/recommendation_model.dart';

class RecommendationRemoteDatasource {
  SupabaseClient get _client => Supabase.instance.client;

  /// v_recommendations [V: 010] filtered to what the app treats as "open":
  /// pending/snoozed and inside the validity window. Urgent first because
  /// 'u' > 'n' alphabetically -> descending order on `urgency`.
  Future<List<RecommendationModel>> getActive(String pondId) async {
    try {
      final rows = await _client
          .from('v_recommendations')
          .select('id, entry_id, urgency, title, reason, valid_until, created_at')
          .eq('pond_id', pondId)
          .inFilter('status', ['pending', 'snoozed'])
          .gt('valid_until', DateTime.now().toUtc().toIso8601String())
          .order('urgency', ascending: false)
          .order('valid_until');
      return rows.map(RecommendationModel.fromMap).toList();
    } on PostgrestException catch (e) {
      throw CoreFailure.databaseError(e.message);
    }
  }
}
