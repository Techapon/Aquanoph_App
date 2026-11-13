/// Parameter display sugar [A] — single source for the pond-list DO card and
/// the parameters dialog. Keys are DB enum labels (raw PondParameters values).
library;

const paramOrder = ['DO', 'pH', 'Temperature', 'NH3', 'NO2_N', 'Salinity'];

String paramLabel(String p) => const {'DO': 'DO', 'Temperature': 'Temp', 'pH': 'pH', 'NH3': 'NH3', 'NO2_N': 'NO2', 'Salinity': 'Salinity'}[p] ?? p;
String paramSub(String p) => const {'DO': 'Oxygen in pond', 'Temperature': 'Water temperature', 'pH': 'pH balance', 'NH3': 'Ammonia level', 'NO2_N': 'Nitrite level', 'Salinity': 'Salt level'}[p] ?? 'In pond';
String paramUnit(String p) => const {'DO': 'mg/L', 'Temperature': '°C', 'NH3': 'mg/L', 'NO2_N': 'mg/L', 'Salinity': 'ppt', 'pH': ''}[p] ?? '';
String paramValueText(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
