import 'package:aquanoph/features/diagnostic/domain/entities/diagnostic_entity.dart';

abstract class DiagnosticRepository {
  /// Latest diagnostic episode per parameter (empty before the first episode).
  Future<List<DiagnosticEntity>> getDiagnostics(String pondId);
}
