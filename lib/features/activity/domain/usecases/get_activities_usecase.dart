import 'package:aquanoph/features/activity/domain/entities/activity_entity.dart';
import 'package:aquanoph/features/activity/domain/repositories/activity_repository.dart';

class GetActivitiesUsecase {
  final ActivityRepository repo;
  GetActivitiesUsecase(this.repo);

  Future<List<ActivityEntity>> call(String pondId, DateTime from, DateTime to) => repo.getDay(pondId, from, to);
}
