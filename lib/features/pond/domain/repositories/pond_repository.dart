import 'package:aquanoph/features/pond/domain/entities/pond_draft.dart';
import 'package:aquanoph/features/pond/domain/entities/pond_entity.dart';

abstract class PondRepository {
  Future<List<PondEntity>> getPonds(String userId);
  Future<void> createPond(PondDraft draft);
  Future<void> updatePond(String pondId, {String? name, int? stockingCount, double? avgWeightG});
}
