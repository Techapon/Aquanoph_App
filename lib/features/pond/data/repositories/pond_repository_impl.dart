import 'package:aquanoph/features/pond/data/datasources/pond_remote_datasource.dart';
import 'package:aquanoph/features/pond/domain/entities/pond_draft.dart';
import 'package:aquanoph/features/pond/domain/entities/pond_entity.dart';
import 'package:aquanoph/features/pond/domain/repositories/pond_repository.dart';

class PondRepositoryImpl implements PondRepository {
  final PondRemoteDatasource datasource;
  PondRepositoryImpl(this.datasource);

  @override
  Future<List<PondEntity>> getPonds(String userId) async =>
      (await datasource.getPonds(userId)).map((m) => m.toEntity()).toList();

  @override
  Future<void> createPond(PondDraft draft) => datasource.createPond(draft);

  @override
  Future<void> updatePond(String pondId, {String? name, int? stockingCount, double? avgWeightG}) =>
      datasource.updatePond(pondId, name: name, stockingCount: stockingCount, avgWeightG: avgWeightG);
}
