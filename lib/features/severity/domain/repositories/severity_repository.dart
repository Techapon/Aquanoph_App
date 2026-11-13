import 'package:aquanoph/features/severity/domain/entities/pond_status_entity.dart';
import 'package:aquanoph/features/severity/domain/entities/severity_report_entity.dart';

abstract class SeverityRepository {
  /// null = no severity data yet (fresh pond before first analysis).
  Future<PondStatusEntity?> getPondStatus(String pondId);

  /// Latest severity_reports row per parameter (empty list before first analysis).
  Future<List<SeverityReportEntity>> getParameterReports(String pondId);
}
