/// Activity facts for display (from v_activities = activities + `missed`).
enum ActivityType { feeding, aeration, waterChange, alkalinity, lime, probiotic, other, unknown }

enum ActivityStatus { pending, done, skipped }

class ActivityEntity {
  final String id;
  final ActivityType type;
  final ActivityStatus status;
  final DateTime startTime; // UTC
  final DateTime? endTime; // aeration ranges
  final double? fraction; // water_change 1/4,1/2,3/4
  final double? quantityKg;
  final bool missed; // v_activities computed column [V: 010]

  const ActivityEntity({
    required this.id,
    required this.type,
    required this.status,
    required this.startTime,
    this.endTime,
    this.fraction,
    this.quantityKg,
    this.missed = false,
  });
}
