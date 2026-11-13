import 'package:aquanoph/core/utils/db_num.dart';
import 'package:aquanoph/features/activity/domain/entities/activity_entity.dart';

const _typeLabels = {
  'feeding': ActivityType.feeding,
  'aeration': ActivityType.aeration,
  'water_change': ActivityType.waterChange,
  'alkalinity': ActivityType.alkalinity,
  'lime': ActivityType.lime,
  'probiotic': ActivityType.probiotic,
  'other': ActivityType.other,
};

const _statusLabels = {
  'pending': ActivityStatus.pending,
  'done': ActivityStatus.done,
  'skipped': ActivityStatus.skipped,
};

class ActivityModel {
  final String id;
  final String typeLabel;
  final String statusLabel;
  final DateTime startTime;
  final DateTime? endTime;
  final double? fraction;
  final double? quantityKg;
  final bool missed;

  const ActivityModel({
    required this.id,
    required this.typeLabel,
    required this.statusLabel,
    required this.startTime,
    this.endTime,
    this.fraction,
    this.quantityKg,
    this.missed = false,
  });

  factory ActivityModel.fromMap(Map<String, dynamic> map) => ActivityModel(
        id: map['id'] as String? ?? '',
        typeLabel: map['type'] as String? ?? '',
        statusLabel: map['status'] as String? ?? '',
        startTime: DateTime.tryParse(map['start_time'] as String? ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
        endTime: DateTime.tryParse(map['end_time'] as String? ?? ''),
        fraction: asDouble(map['fraction']),
        quantityKg: asDouble(map['quantity_kg']),
        missed: map['missed'] as bool? ?? false,
      );

  ActivityEntity toEntity() => ActivityEntity(
        id: id,
        type: _typeLabels[typeLabel] ?? ActivityType.unknown,
        status: _statusLabels[statusLabel] ?? ActivityStatus.pending,
        startTime: startTime,
        endTime: endTime,
        fraction: fraction,
        quantityKg: quantityKg,
        missed: missed,
      );
}
