import 'package:aquanoph/features/auth/domain/entities/auth_user_entity.dart';
import 'package:aquanoph/features/auth/domain/repositories/auth_repository.dart';

class SignUpUsecase {
  final AuthRepository repo;
  SignUpUsecase(this.repo);

  Future<AuthUserEntity> call({required String email, required String username, required String password}) =>
      repo.signUp(email: email, username: username, password: password);
}
