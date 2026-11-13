import 'package:aquanoph/features/recommendation/domain/entities/recommendation_entity.dart';

const _urgencyLabels = {
  'urgent': RecUrgency.urgent,
  'non_urgent': RecUrgency.nonUrgent,
};

class RecommendationModel {
  final String id;
  final String entryId;
  final String urgencyLabel;
  final String title;
  final String? reason;
  final DateTime? validUntil;
  final DateTime? createdAt;

  const RecommendationModel({
    required this.id,
    required this.entryId,
    required this.urgencyLabel,
    required this.title,
    this.reason,
    this.validUntil,
    this.createdAt,
  });

  factory RecommendationModel.fromMap(Map<String, dynamic> map) => RecommendationModel(
        id: map['id'] as String? ?? '',
        entryId: map['entry_id'] as String? ?? '',
        urgencyLabel: map['urgency'] as String? ?? '',
        title: map['title'] as String? ?? '',
        reason: map['reason'] as String?,
        validUntil: DateTime.tryParse(map['valid_until'] as String? ?? ''),
        createdAt: DateTime.tryParse(map['created_at'] as String? ?? ''),
      );

  RecommendationEntity toEntity() => RecommendationEntity(
        id: id,
        entryId: entryId,
        urgency: _urgencyLabels[urgencyLabel] ?? RecUrgency.unknown,
        title: title,
        reason: reason,
        validUntil: validUntil,
        createdAt: createdAt,
      );
}
