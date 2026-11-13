/// Active recommendation for display (facts from v_recommendations).
enum RecUrgency { urgent, nonUrgent, unknown }

class RecommendationEntity {
  final String id;
  final String entryId; // 'AERATE' | 'WATER_CHANGE' | 'ADD_ALKALINITY'
  final RecUrgency urgency;
  final String title;
  final String? reason; // card body when present
  final DateTime? validUntil; // deadline (apply window end)
  final DateTime? createdAt; // "Detected HH:MM" (app_spec §12 #9)

  const RecommendationEntity({
    required this.id,
    required this.entryId,
    required this.urgency,
    required this.title,
    this.reason,
    this.validUntil,
    this.createdAt,
  });

  String get body => reason ?? title;
}
