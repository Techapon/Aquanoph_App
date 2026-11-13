import 'package:aquanoph/features/diagnostic/domain/entities/diagnostic_entity.dart';
import 'package:aquanoph/features/diagnostic/domain/repositories/diagnostic_repository.dart';

class GetDiagnosticsUsecase {
  final DiagnosticRepository repo;
  GetDiagnosticsUsecase(this.repo);

  Future<List<DiagnosticEntity>> call(String pondId) =>
      repo.getDiagnostics(pondId);
}
