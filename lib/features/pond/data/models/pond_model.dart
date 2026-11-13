import 'package:aquanoph/features/pond/domain/entities/pond_entity.dart';

class PondModel {
  final String id;
  final String name;
  final double areaM2;
  final double avgDepthM;
  final String species;
  final int stockingCount;
  final double avgWeightG;
  final String? stockingDate;
  final String deviceId;
  final String timezone;
  final String? createdAt;

  const PondModel({
    required this.id,
    required this.name,
    required this.areaM2,
    required this.avgDepthM,
    required this.species,
    required this.stockingCount,
    required this.avgWeightG,
    this.stockingDate,
    required this.deviceId,
    required this.timezone,
    this.createdAt,
  });

  factory PondModel.fromMap(Map<String, dynamic> map) => PondModel(
        id: map['id'] as String,
        name: (map['name'] ?? '') as String,
        areaM2: (map['area_m2'] as num?)?.toDouble() ?? 0,
        avgDepthM: (map['avg_depth_m'] as num?)?.toDouble() ?? 0,
        species: (map['species'] ?? 'nile_tilapia') as String,
        stockingCount: (map['stocking_count'] as num?)?.toInt() ?? 0,
        avgWeightG: (map['avg_weight_g'] as num?)?.toDouble() ?? 0,
        stockingDate: map['stocking_date']?.toString(),
        deviceId: (map['device_id'] ?? '') as String,
        timezone: (map['timezone'] ?? 'UTC') as String,
        createdAt: map['created_at']?.toString(),
      );

  PondEntity toEntity() => PondEntity(
        id: id,
        name: name,
        areaM2: areaM2,
        avgDepthM: avgDepthM,
        species: species,
        stockingCount: stockingCount,
        avgWeightG: avgWeightG,
        stockingDate: stockingDate == null ? null : DateTime.tryParse(stockingDate!),
        deviceId: deviceId,
        timezone: timezone,
        createdAt: createdAt == null ? null : DateTime.tryParse(createdAt!),
      );
}
