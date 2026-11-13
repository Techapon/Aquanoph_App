import 'package:flutter/foundation.dart';

import 'package:aquanoph/core/exception/core_error_failure.dart';
import 'package:aquanoph/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:aquanoph/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:aquanoph/features/auth/domain/entities/auth_user_entity.dart';
import 'package:aquanoph/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:aquanoph/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:aquanoph/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:aquanoph/features/auth/domain/usecases/sign_up_usecase.dart';

class AuthProvider extends ChangeNotifier {
  // ponytail: wiring here per project style (no get_it); move to main.dart constructor injection when features > ~10.
  final _repo = AuthRepositoryImpl(AuthRemoteDatasource());
  late final signIn = SignInUsecase(_repo);
  late final signUp = SignUpUsecase(_repo);
  late final getCurrentUser = GetCurrentUserUsecase(_repo);
  late final signOut = SignOutUsecase(_repo);

  bool isLoading = false;
  bool bootstrapped = false;
  String? error;
  String? info;
  AuthUserEntity? user;

  Future<void> loadSession() async {
    try {
      user = await getCurrentUser();
    } on CoreFailure catch (f) {
      error = f.message;
    }
    bootstrapped = true;
    notifyListeners();
  }

  Future<void> doSignIn({required String email, required String password}) =>
      _run(() => signIn(email: email, password: password));

  Future<void> doSignUp({required String email, required String username, required String password}) =>
      _run(() async {
        final created = await signUp(email: email, username: username, password: password);
        if (created.pendingEmailConfirmation) {
          // not logged in yet; stay on sign-in with a hint
          info = 'Account created. Confirm your email, then sign in.';
          return null;
        }
        return created;
      });

  Future<void> doSignOut() async {
    await signOut();
    user = null;
    notifyListeners();
  }

  Future<void> _run(Future<AuthUserEntity?> Function() op) async {
    error = null;
    info = null;
    isLoading = true;
    notifyListeners();
    try {
      user = await op();
    } on CoreFailure catch (f) {
      error = f.message;
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }
}
