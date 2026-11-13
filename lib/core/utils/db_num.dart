/// PostgREST can hand back `numeric` columns as either a JSON number or a
/// quoted string depending on version/config — accept both, never crash a screen.
double? asDouble(Object? v) => v == null ? null : (v is num ? v.toDouble() : double.tryParse(v.toString()));
