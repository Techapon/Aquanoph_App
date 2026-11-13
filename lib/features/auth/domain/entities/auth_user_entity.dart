class AuthUserEntity {
  final String id;
  final String email;
  final String? username;
  final bool pendingEmailConfirmation;

  const AuthUserEntity({
    required this.id,
    required this.email,
    this.username,
    this.pendingEmailConfirmation = false,
  });
}
