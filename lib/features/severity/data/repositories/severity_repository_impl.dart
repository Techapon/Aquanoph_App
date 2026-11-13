import 'package:aquanoph/features/severity/data/datasources/severity_remote_datasource.dart';
import 'package:aquanoph/features/severity/domain/entities/pond_status_entity.dart';
import 'package:aquanoph/features/severity/domain/entities/severity_report_entity.dart';
import 'package:aquanoph/features/severity/domain/repositories/severity_repository.dart';

class SeverityRepositoryImpl implements SeverityRepository {
  final SeverityRemoteDatasource datasource;
  SeverityRepositoryImpl(this.datasource);

  @override
  Future<PondStatusEntity?> getPondStatus(String pondId) async {
    final m = await datasource.getPondStatus(pondId);
    return m?.toEntity();
  }

  @override
  Future<List<SeverityReportEntity>> getParameterReports(String pondId) async {
    final rows = await datasource.getLatestParameterReports(pondId);
    return rows.map((m) => m.toEntity()).toList();
  }
}
