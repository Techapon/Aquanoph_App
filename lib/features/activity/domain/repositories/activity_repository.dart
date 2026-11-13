import 'package:aquanoph/features/activity/domain/entities/activity_entity.dart';

abstract class ActivityRepository {
  /// Activities whose start_time falls in [from, to) — the pond's local day.
  Future<List<ActivityEntity>> getDay(String pondId, DateTime from, DateTime to);
}
