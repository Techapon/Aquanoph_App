import 'package:aquanoph/features/auth/domain/entities/auth_user_entity.dart';
import 'package:aquanoph/features/auth/domain/repositories/auth_repository.dart';

class GetCurrentUserUsecase {
  final AuthRepository repo;
  GetCurrentUserUsecase(this.repo);

  Future<AuthUserEntity?> call() => repo.getCurrentUser();
}
