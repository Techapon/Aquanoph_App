import 'package:flutter_test/flutter_test.dart';

import 'package:aquanoph/features/diagnostic/data/models/diagnostic_report_model.dart';

void main() {
  group('DiagnosticReportModel.fromMap', () {
    test('parses text jsonb cache into title/causes/footer', () {
      final m = DiagnosticReportModel.fromMap({
        'parameter': 'DO',
        'onset_at': '2026-08-20T14:00:00Z',
        'end_at': null,
        'status': 'open',
        'no_clear_cause': false,
        'text': {
          'title': 'DO dropped overnight.',
          'causes': ['Algae die-off', 'High biomass'],
          'footer': 'Peak: Critical',
        },
      });
      expect(m.title, 'DO dropped overnight.');
      expect(m.causes, ['Algae die-off', 'High biomass']);
      expect(m.footer, 'Peak: Critical');
      expect(m.toEntity().open, isTrue);
    });

    test('missing or wrong-shaped text never throws', () {
      final m = DiagnosticReportModel.fromMap({
        'parameter': 'pH',
        'onset_at': 'bogus',
        'text': 'oops',
      });
      expect(m.causes, isEmpty);
      expect(m.title, isNull);
      expect(m.onsetAt, DateTime.fromMillisecondsSinceEpoch(0));
    });

    test('latestPerParameter keeps first row per parameter (onset DESC)', () {
      final rows = [
        {
          'parameter': 'DO',
          'onset_at': '2026-08-21T00:00:00Z',
          'status': 'closed',
          'text': {'title': 'new'},
        },
        {
          'parameter': 'DO',
          'onset_at': '2026-08-20T00:00:00Z',
          'status': 'open',
          'text': {'title': 'old'},
        },
        {
          'parameter': 'NH3',
          'onset_at': '2026-08-19T00:00:00Z',
          'status': 'open',
        },
        {'parameter': '', 'onset_at': '2026-08-19T00:00:00Z'},
      ];
      final out = DiagnosticReportModel.latestPerParameter(rows);
      expect(out.map((m) => m.parameter), ['DO', 'NH3']);
      expect(out.first.title, 'new');
      expect(out.first.toEntity().open, isFalse);
    });
  });
}
