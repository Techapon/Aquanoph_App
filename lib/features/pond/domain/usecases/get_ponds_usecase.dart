import 'package:aquanoph/features/pond/domain/entities/pond_entity.dart';
import 'package:aquanoph/features/pond/domain/repositories/pond_repository.dart';

class GetPondsUsecase {
  final PondRepository repo;
  GetPondsUsecase(this.repo);

  Future<List<PondEntity>> call(String userId) => repo.getPonds(userId);
}
