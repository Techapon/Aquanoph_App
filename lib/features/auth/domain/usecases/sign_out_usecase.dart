import 'package:aquanoph/features/auth/domain/repositories/auth_repository.dart';

class SignOutUsecase {
  final AuthRepository repo;
  SignOutUsecase(this.repo);

  Future<void> call() => repo.signOut();
}
