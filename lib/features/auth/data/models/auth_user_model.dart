import 'package:aquanoph/features/auth/domain/entities/auth_user_entity.dart';

class AuthUserModel {
  final String id;
  final String email;
  final String? username;
  final bool pendingEmailConfirmation;

  const AuthUserModel({
    required this.id,
    required this.email,
    this.username,
    this.pendingEmailConfirmation = false,
  });

  /// profiles row (user_id, username) + email from the auth session.
  factory AuthUserModel.fromProfileAndEmail(Map<String, dynamic> profile, String email) => AuthUserModel(
        id: profile['user_id'] as String,
        email: email,
        username: profile['username'] as String?,
      );

  AuthUserEntity toEntity() => AuthUserEntity(
        id: id,
        email: email,
        username: username,
        pendingEmailConfirmation: pendingEmailConfirmation,
      );
}
