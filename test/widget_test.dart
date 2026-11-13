// Pure-Dart checks for the auth chain pieces that don't touch Supabase.
import 'package:flutter_test/flutter_test.dart';

import 'package:aquanoph/core/exception/core_error_failure.dart';
import 'package:aquanoph/core/utils/country_timezones.dart';
import 'package:aquanoph/features/auth/data/models/auth_user_model.dart';
import 'package:aquanoph/features/pond/data/models/pond_model.dart';
import 'package:aquanoph/features/pond/domain/entities/pond_entity.dart';
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
      }).toEntity();
      expect(e.pondId, 'p1');
      expect(e.parameter, 'DO');
      expect(e.severity, PondSeverity.stress);
      expect(e.description, 'DO is below optimal.');
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
}
