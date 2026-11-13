// Pure-Dart checks for the auth chain pieces that don't touch Supabase.
import 'package:flutter_test/flutter_test.dart';

import 'package:aquanoph/core/exception/core_error_failure.dart';
import 'package:aquanoph/features/auth/data/models/auth_user_model.dart';

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
}
