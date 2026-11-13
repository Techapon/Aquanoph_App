import 'package:aquanoph/features/auth/domain/entities/auth_user_entity.dart';
import 'package:aquanoph/features/auth/domain/repositories/auth_repository.dart';

class SignInUsecase {
  final AuthRepository repo;
  SignInUsecase(this.repo);

  Future<AuthUserEntity> call({required String email, required String password}) =>
      repo.signIn(email: email, password: password);
}
