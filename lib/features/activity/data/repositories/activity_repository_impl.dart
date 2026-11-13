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
}
