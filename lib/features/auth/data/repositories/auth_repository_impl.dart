import 'package:aquanoph/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:aquanoph/features/auth/domain/entities/auth_user_entity.dart';
import 'package:aquanoph/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource datasource;
  AuthRepositoryImpl(this.datasource);

  @override
  Future<AuthUserEntity> signIn({required String email, required String password}) =>
      datasource.signIn(email: email, password: password).then((m) => m.toEntity());

  @override
  Future<AuthUserEntity> signUp({required String email, required String username, required String password}) =>
      datasource.signUp(email: email, username: username, password: password).then((m) => m.toEntity());

  @override
  Future<AuthUserEntity?> getCurrentUser() =>
      datasource.getCurrentUser().then((m) => m?.toEntity());

  @override
  Future<void> signOut() => datasource.signOut();
}
