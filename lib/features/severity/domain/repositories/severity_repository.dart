import 'package:aquanoph/features/severity/domain/entities/pond_status_entity.dart';

abstract class SeverityRepository {
  /// null = no severity data yet (fresh pond before first analysis).
  Future<PondStatusEntity?> getPondStatus(String pondId);
}
