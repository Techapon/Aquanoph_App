import 'package:aquanoph/features/recommendation/domain/entities/recommendation_entity.dart';

abstract class RecommendationRepository {
  /// pending/snoozed recs still inside their validity window, urgent first.
  Future<List<RecommendationEntity>> getActive(String pondId);
}
