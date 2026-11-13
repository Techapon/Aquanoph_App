import 'package:aquanoph/features/recommendation/domain/entities/recommendation_entity.dart';
import 'package:aquanoph/features/recommendation/domain/repositories/recommendation_repository.dart';

class GetRecommendationsUsecase {
  final RecommendationRepository repo;
  GetRecommendationsUsecase(this.repo);

  Future<List<RecommendationEntity>> call(String pondId) => repo.getActive(pondId);
}
