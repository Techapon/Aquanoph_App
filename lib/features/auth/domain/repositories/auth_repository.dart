import 'package:aquanoph/features/auth/domain/entities/auth_user_entity.dart';

abstract class AuthRepository {
  Future<AuthUserEntity> signIn({required String email, required String password});
  Future<AuthUserEntity> signUp({required String email, required String username, required String password});
  Future<AuthUserEntity?> getCurrentUser();
  Future<void> signOut();
}
