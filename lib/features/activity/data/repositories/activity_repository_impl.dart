import 'package:aquanoph/features/activity/data/datasources/activity_remote_datasource.dart';
import 'package:aquanoph/features/activity/domain/entities/activity_entity.dart';
import 'package:aquanoph/features/activity/domain/repositories/activity_repository.dart';

class ActivityRepositoryImpl implements ActivityRepository {
  final ActivityRemoteDatasource datasource;
  ActivityRepositoryImpl(this.datasource);

  @override
  Future<List<ActivityEntity>> getDay(String pondId, DateTime from, DateTime to) async {
    final rows = await datasource.getDay(pondId, from, to);
    return rows.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> saveChecklist(String pondId, List<Map<String, dynamic>> changes) =>
      datasource.saveChecklist(pondId, changes);

  @override
  Future<String> upsertActivity(String pondId, Map<String, dynamic> activity) =>
      datasource.upsertActivity(pondId, activity);

  @override
  Future<void> deleteActivity(String activityId) => datasource.deleteActivity(activityId);
}
