import 'package:aquanoph/features/diagnostic/data/datasources/diagnostic_remote_datasource.dart';
import 'package:aquanoph/features/diagnostic/domain/entities/diagnostic_entity.dart';
import 'package:aquanoph/features/diagnostic/domain/repositories/diagnostic_repository.dart';

class DiagnosticRepositoryImpl implements DiagnosticRepository {
  final DiagnosticRemoteDatasource datasource;
  DiagnosticRepositoryImpl(this.datasource);

  @override
  Future<List<DiagnosticEntity>> getDiagnostics(String pondId) async {
    final rows = await datasource.getLatestPerParameter(pondId);
    return rows.map((m) => m.toEntity()).toList();
  }
}
