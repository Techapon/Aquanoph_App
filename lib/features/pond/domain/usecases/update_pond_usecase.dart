import 'package:aquanoph/features/pond/domain/repositories/pond_repository.dart';

class UpdatePondUsecase {
  final PondRepository repo;
  UpdatePondUsecase(this.repo);

  Future<void> call(String pondId, {String? name, int? stockingCount, double? avgWeightG}) =>
      repo.updatePond(pondId, name: name, stockingCount: stockingCount, avgWeightG: avgWeightG);
}
