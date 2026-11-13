/// Typed failure thrown across layers (Postgrest/Auth -> CoreFailure at datasource).
class CoreFailure implements Exception {
  final String kind;
  final String message;
  const CoreFailure(this.kind, this.message);

  factory CoreFailure.databaseError(String msg) => CoreFailure('database', msg);
  factory CoreFailure.authError(String msg) => CoreFailure('auth', msg);
  factory CoreFailure.unknown(String msg) => CoreFailure('unknown', msg);

  @override
  String toString() => '$kind: $message';
}
