import 'package:aquanoph/features/activity/domain/entities/activity_entity.dart';

abstract class ActivityRepository {
  /// Activities whose start_time falls in [from, to) — the pond's local day.
  Future<List<ActivityEntity>> getDay(String pondId, DateTime from, DateTime to);

  /// Batch save (create/update/delete) in one transaction.
  Future<void> saveChecklist(String pondId, List<Map<String, dynamic>> changes);

  /// Upsert single activity; returns its id.
  Future<String> upsertActivity(String pondId, Map<String, dynamic> activity);

  /// Delete activity by id.
  Future<void> deleteActivity(String activityId);
}
