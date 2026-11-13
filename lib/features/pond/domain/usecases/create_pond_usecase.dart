import 'package:aquanoph/features/pond/domain/entities/pond_draft.dart';
import 'package:aquanoph/features/pond/domain/repositories/pond_repository.dart';

class CreatePondUsecase {
  final PondRepository repo;
  CreatePondUsecase(this.repo);

  Future<void> call(PondDraft draft) => repo.createPond(draft);
}
