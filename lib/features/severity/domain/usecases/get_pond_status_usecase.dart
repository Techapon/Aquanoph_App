import 'package:aquanoph/features/severity/domain/entities/pond_status_entity.dart';
import 'package:aquanoph/features/severity/domain/repositories/severity_repository.dart';

class GetPondStatusUsecase {
  final SeverityRepository repo;
  GetPondStatusUsecase(this.repo);

  Future<PondStatusEntity?> call(String pondId) => repo.getPondStatus(pondId);
}
