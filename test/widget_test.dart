// Pure-Dart checks for the pieces that don't touch Supabase.
import 'package:flutter_test/flutter_test.dart';

import 'package:aquanoph/core/exception/core_error_failure.dart';
import 'package:aquanoph/core/utils/country_timezones.dart';
import 'package:aquanoph/core/utils/db_num.dart';
import 'package:aquanoph/core/utils/pond_time.dart';
import 'package:aquanoph/core/utils/thousands.dart';
import 'package:aquanoph/features/activity/data/models/activity_model.dart';
import 'package:aquanoph/features/activity/domain/entities/activity_entity.dart';
import 'package:aquanoph/features/auth/data/models/auth_user_model.dart';
import 'package:aquanoph/features/pond/data/models/pond_model.dart';
import 'package:aquanoph/features/pond/domain/entities/pond_entity.dart';
import 'package:aquanoph/features/recommendation/data/models/recommendation_model.dart';
import 'package:aquanoph/features/recommendation/domain/entities/recommendation_entity.dart';
import 'package:aquanoph/features/severity/data/models/pond_status_model.dart';
import 'package:aquanoph/features/severity/domain/entities/pond_status_entity.dart';

void main() {
  group('AuthUserModel', () {
    test('fromProfileAndEmail maps profiles columns', () {
      final m = AuthUserModel.fromProfileAndEmail({'user_id': 'u1', 'username': 'Farm A'}, 'a@b.co');
      expect(m.id, 'u1');
      expect(m.email, 'a@b.co');
      expect(m.username, 'Farm A');
    });

    test('missing username column stays null', () {
      final m = AuthUserModel.fromProfileAndEmail({'user_id': 'u2'}, 'x@y.z');
      expect(m.username, isNull);
    });

    test('toEntity carries all fields', () {
      const m = AuthUserModel(id: 'u3', email: 'e@f.g', username: 'n', pendingEmailConfirmation: true);
      final e = m.toEntity();
      expect(e.id, 'u3');
      expect(e.pendingEmailConfirmation, isTrue);
    });
  });

  group('CoreFailure', () {
    test('factories set kind and toString', () {
      expect(CoreFailure.databaseError('dup').kind, 'database');
      expect(CoreFailure.authError('bad pw').toString(), 'auth: bad pw');
      expect(CoreFailure.unknown('?').kind, 'unknown');
    });
  });

  group('country_timezones', () {
    test('country maps to IANA id', () {
      expect(timezoneFor('Thailand'), 'Asia/Bangkok');
    });

    test('round-trip for every picker entry', () {
      for (final country in countryToTimezone.keys) {
        expect(countryFor(timezoneFor(country)), country);
      }
    });

    test('unknown IANA id shows as-is, unknown country falls back to UTC', () {
      expect(countryFor('Asia/Novosibirsk'), 'Asia/Novosibirsk');
      expect(timezoneFor('Narnia'), 'UTC');
    });
  });

  group('PondModel / PondEntity', () {
    test('fromMap maps snake_case columns with defaults', () {
      final m = PondModel.fromMap({
        'id': 'p1',
        'name': 'Pond A',
        'area_m2': 49.0,
        'avg_depth_m': 3,
        'species': 'nile_tilapia',
        'stocking_count': 1000,
        'avg_weight_g': 200.5,
        'stocking_date': '2026-05-01',
        'device_id': '102X4',
        'timezone': 'Asia/Bangkok',
      });
      final e = m.toEntity();
      expect(e.id, 'p1');
      expect(e.areaM2, 49.0);
      expect(e.avgDepthM, 3.0);
      expect(e.stockingCount, 1000);
      expect(e.stockingDate, DateTime.parse('2026-05-01'));
      expect(e.timezone, 'Asia/Bangkok');
    });

    test('missing columns fall back safely', () {
      final e = PondModel.fromMap({'id': 'p2'}).toEntity();
      expect(e.species, 'nile_tilapia');
      expect(e.timezone, 'UTC');
      expect(e.name, '');
      expect(e.stockingDate, isNull);
    });

    test('volume and biomass are computed from facts', () {
      final e = PondEntity(
        id: 'p3', name: 'x', areaM2: 50, avgDepthM: 2, species: 'nile_tilapia',
        stockingCount: 1000, avgWeightG: 250, deviceId: 'd', timezone: 'UTC',
      );
      expect(e.volumeM3, 100.0);
      expect(e.biomassKg, 250.0); // 1000 * 250g / 1000
    });
  });

  group('PondStatusModel', () {
    Map<String, dynamic> statusRow({String severity = 'stress'}) => {
          'pond_id': 'p1',
          'parameter': 'DO',
          'severity': severity,
          'updated_at': '2026-11-13T06:00:00Z',
        };

    test('status + report maps all fields', () {
      final e = PondStatusModel.fromMaps(statusRow(), {
        'description': 'DO is below optimal.',
        'recovering': false,
        'value': 4.2,
      }).toEntity();
      expect(e.pondId, 'p1');
      expect(e.parameter, 'DO');
      expect(e.severity, PondSeverity.stress);
      expect(e.description, 'DO is below optimal.');
      expect(e.value, 4.2);
      expect(e.updatedAt, DateTime.parse('2026-11-13T06:00:00Z'));
    });

    test('enum labels incl. elevated_risk; unexpected label -> unknown', () {
      expect(PondStatusModel.fromMaps(statusRow(severity: 'elevated_risk'), null).severity, PondSeverity.elevatedRisk);
      expect(PondStatusModel.fromMaps(statusRow(severity: 'hight risk'), null).severity, PondSeverity.unknown);
    });

    test('missing report row degrades to no text, not recovering', () {
      final e = PondStatusModel.fromMaps(statusRow(severity: 'optimal'), null).toEntity();
      expect(e.description, isNull);
      expect(e.recovering, isFalse);
    });

    test('showRecoveryBadge only for recovering stress', () {
      final recovering = PondStatusModel.fromMaps(statusRow(), {'description': 'x', 'recovering': true}).toEntity();
      expect(recovering.showRecoveryBadge, isTrue);
      final optimal = PondStatusModel.fromMaps(statusRow(severity: 'optimal'), {'description': 'x', 'recovering': true}).toEntity();
      expect(optimal.showRecoveryBadge, isFalse);
    });
  });

  group('asDouble', () {
    test('accepts num, numeric string, null; rejects garbage', () {
      expect(asDouble(2.5), 2.5);
      expect(asDouble(3), 3.0);
      expect(asDouble('2.5'), 2.5);
      expect(asDouble(null), isNull);
      expect(asDouble('abc'), isNull);
    });
  });

  group('pond_time', () {
    test('pondLocal applies fixed offsets (incl. half-hour zones)', () {
      final utc = DateTime.utc(2026, 11, 13, 6);
      expect(pondLocal(utc, 'Asia/Bangkok'), DateTime.utc(2026, 11, 13, 13));
      expect(pondLocal(utc, 'Asia/Yangon'), DateTime.utc(2026, 11, 13, 12, 30));
      expect(pondLocal(utc, 'UTC'), DateTime.utc(2026, 11, 13, 6));
    });

    test('formatClock: 12-hour with AM/PM, midnight -> 12 AM', () {
      expect(formatClock(DateTime(2026, 11, 13, 9, 30)), '9:30 AM');
      expect(formatClock(DateTime(2026, 11, 13, 17, 5)), '5:05 PM');
      expect(formatClock(DateTime(2026, 11, 13, 0, 0)), '12:00 AM');
      expect(formatClock(DateTime(2026, 11, 13, 12, 0)), '12:00 PM');
    });

    test('pondDayUtc bounds the pond-local calendar day', () {
      // 06:00Z = 13:00 Bangkok -> Bangkok day 2026-11-13 spans 2026-11-12T17:00Z .. 2026-11-13T17:00Z
      final day = pondDayUtc(DateTime.utc(2026, 11, 13, 6), 'Asia/Bangkok');
      expect(day.from, DateTime.utc(2026, 11, 12, 17));
      expect(day.to.difference(day.from), const Duration(days: 1));
    });

    test('utcOffsetLabel: whole + half-hour offsets, unknown id -> empty', () {
      expect(utcOffsetLabel('Asia/Bangkok'), 'UTC+7');
      expect(utcOffsetLabel('Asia/Yangon'), 'UTC+6:30');
      expect(utcOffsetLabel('UTC'), 'UTC+0');
      expect(utcOffsetLabel('Mars/Olympus'), '');
    });
  });

  group('formatThousands', () {
    test('groups every 3 digits, leaves small and negative intact', () {
      expect(formatThousands(3000), '3,000');
      expect(formatThousands(1234567), '1,234,567');
      expect(formatThousands(999), '999');
      expect(formatThousands(0), '0');
      expect(formatThousands(-1500), '-1,500');
    });
  });

  group('RecommendationModel', () {
    test('maps urgency enum and dates; unknown label -> unknown', () {
      final e = RecommendationModel.fromMap({
        'id': 'r1', 'entry_id': 'AERATE', 'urgency': 'urgent', 'title': 'Run aerator',
        'reason': 'DO will drop', 'valid_until': '2026-11-13T20:00:00Z', 'created_at': '2026-11-13T06:00:00Z',
      }).toEntity();
      expect(e.urgency, RecUrgency.urgent);
      expect(e.body, 'DO will drop');
      expect(e.validUntil, DateTime.parse('2026-11-13T20:00:00Z'));
      final odd = RecommendationModel.fromMap({'urgency': 'critical'}).toEntity();
      expect(odd.urgency, RecUrgency.unknown);
    });

    test('body falls back to title when reason missing', () {
      final e = RecommendationModel.fromMap({'id': 'r2', 'entry_id': 'WATER_CHANGE', 'urgency': 'non_urgent', 'title': 'Change water'}).toEntity();
      expect(e.body, 'Change water');
      expect(e.urgency, RecUrgency.nonUrgent);
    });
  });

  group('ActivityModel', () {
    test('maps type/status enums + aeration range + missed flag', () {
      final e = ActivityModel.fromMap({
        'id': 'a1', 'type': 'aeration', 'status': 'done',
        'start_time': '2026-11-12T17:00:00Z', 'end_time': '2026-11-12T23:00:00Z', 'missed': true,
      }).toEntity();
      expect(e.type, ActivityType.aeration);
      expect(e.status, ActivityStatus.done);
      expect(e.endTime, DateTime.parse('2026-11-12T23:00:00Z'));
      expect(e.missed, isTrue);
    });

    test('unknown type stays unknown; missing status defaults pending', () {
      final e = ActivityModel.fromMap({'id': 'a2', 'type': 'snorkeling', 'start_time': '2026-11-13T02:00:00Z', 'quantity_kg': '2.5'}).toEntity();
      expect(e.type, ActivityType.unknown);
      expect(e.status, ActivityStatus.pending);
      expect(e.quantityKg, 2.5);
      expect(e.startTime.isUtc, isTrue);
    });
  });
}
