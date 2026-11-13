import 'package:flutter_test/flutter_test.dart';

import 'package:aquanoph/features/severity/domain/entities/pond_status_entity.dart';
import 'package:aquanoph/features/severity/data/models/severity_report_model.dart';

Map<String, dynamic> row(String param, String iso, String sev, {Object? value = 1}) => {
      'parameter': param,
      'measured_at': iso,
      'value': value,
      'severity': sev,
      'recovering': false,
      'description': 'd',
      'detail': null,
      'append_des': 'a',
      'guidance': 'g',
    };

void main() {
  group('SeverityReportModel.latestPerParameter (rows DESC)', () {
    test('keeps newest row per parameter, drops older dupes', () {
      final out = SeverityReportModel.latestPerParameter([
        row('DO', '2026-11-13T05:00:00Z', 'stress'),
        row('pH', '2026-11-13T05:00:00Z', 'optimal'),
        row('DO', '2026-11-13T04:30:00Z', 'critical'), // older DO — dropped
        row('NH3', '2026-11-13T04:30:00Z', 'elevated_risk', value: null),
      ]);
      expect(out.map((m) => '${m.parameter}@${m.severityLabel}'), ['DO@stress', 'pH@optimal', 'NH3@elevated_risk']);
      expect(out[0].measuredAt, DateTime.parse('2026-11-13T05:00:00Z'));
      expect(out[2].value, isNull);
    });

    test('drops rows with empty parameter; empty input -> empty', () {
      expect(SeverityReportModel.latestPerParameter([row('', '2026-01-01T00:00:00Z', 'optimal')]), isEmpty);
      expect(SeverityReportModel.latestPerParameter([]), isEmpty);
    });

    test('maps snake_case append_des and unknown severity label', () {
      final m = SeverityReportModel.fromMap(row('Salinity', '2026-11-13T00:00:00Z', 'hight risk', value: 2.5));
      expect(m.appendDes, 'a');
      final e = m.toEntity();
      expect(e.severity, PondSeverity.unknown); // never guess a real level
      expect(e.appendDes, 'a');
      expect(e.guidance, 'g');
    });
  });
}
