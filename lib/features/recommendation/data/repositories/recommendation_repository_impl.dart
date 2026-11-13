import 'package:aquanoph/features/recommendation/data/datasources/recommendation_remote_datasource.dart';
import 'package:aquanoph/features/recommendation/domain/entities/recommendation_entity.dart';
import 'package:aquanoph/features/recommendation/domain/repositories/recommendation_repository.dart';

class RecommendationRepositoryImpl implements RecommendationRepository {
  final RecommendationRemoteDatasource datasource;
  RecommendationRepositoryImpl(this.datasource);

  @override
  Future<List<RecommendationEntity>> getActive(String pondId) async {
    final rows = await datasource.getActive(pondId);
    return rows.map((m) => m.toEntity()).toList();
  }
}
