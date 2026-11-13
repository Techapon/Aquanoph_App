import 'package:aquanoph/features/severity/domain/entities/severity_report_entity.dart';
import 'package:aquanoph/features/severity/domain/repositories/severity_repository.dart';

class GetParameterReportsUsecase {
  final SeverityRepository repo;
  GetParameterReportsUsecase(this.repo);

  Future<List<SeverityReportEntity>> call(String pondId) => repo.getParameterReports(pondId);
}
