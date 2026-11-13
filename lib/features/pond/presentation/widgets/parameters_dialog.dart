import 'package:flutter/material.dart';

import 'package:aquanoph/core/theme/app_colors.dart';
import 'package:aquanoph/core/theme/app_fonts.dart';
import 'package:aquanoph/core/utils/country_timezones.dart';
import 'package:aquanoph/core/utils/param_display.dart';
import 'package:aquanoph/core/utils/pond_time.dart';
import 'package:aquanoph/features/severity/domain/entities/pond_status_entity.dart' show PondSeverity;
import 'package:aquanoph/features/severity/domain/entities/severity_report_entity.dart';

/// All-parameters dialog + per-parameter detail, per figma/ponds_parameter/.
/// Data = latest severity_reports row per parameter (v1 six; the design mock
/// showed 9 params — Turbidity/EC/TAN/NO3/Alkalinity are not in v1).
/// The Diagnostic section is intentionally absent until diagnostic_reports
/// wiring (later phase).

/// Severity badge words/colors — Optimal/Stress design-verified (css_detail.txt);
/// Elevated risk/Critical have no Figma variant yet [A]. Shared with pond home.
String sevBadgeWord(PondSeverity s) => switch (s) {
  PondSeverity.optimal => 'Optimal',
  PondSeverity.stress => 'Stress',
  PondSeverity.elevatedRisk => 'Elevated risk',
  PondSeverity.critical => 'Critical',
  PondSeverity.unknown => '',
};

Color sevBadgeColor(PondSeverity s) => switch (s) {
  PondSeverity.optimal => AppColors.optimal, // 0BE220
  PondSeverity.stress => AppColors.stress, // FFCC00
  PondSeverity.elevatedRisk => AppColors.watch, // FF9232
  _ => AppColors.critical, // FF3232
};

SeverityReportEntity? _reportFor(List<SeverityReportEntity> reports, String parameter) {
  for (final r in reports) {
    if (r.parameter == parameter) return r;
  }
  return null;
}

/// Pond-local zone label, design style "Thailand (UTC+7)".
String _zoneLabel(String iana) {
  final off = ianaUtcOffset[iana];
  if (off == null) return countryFor(iana);
  final h = off.inMinutes / 60;
  return '${countryFor(iana)} (UTC+${h == h.roundToDouble() ? h.toInt() : h})';
}

/// Opened by tapping the Water Quality Now card: floating 2-col grid on a dim
/// barrier (the design has no dialog panel behind the cards).
Future<void> showParametersDialog(BuildContext context, {required List<SeverityReportEntity> reports, required String timezone}) => showDialog<void>(
  context: context,
  barrierColor: const Color(0x99000000),
  builder: (_) => Dialog(
    insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
    backgroundColor: Colors.transparent,
    constraints: const BoxConstraints(maxWidth: 347), // keep transparent Material from stretching to full width
    elevation: 0,
    // no Center here: Dialog centers itself, and a stretched transparent
    // Material swallows barrier taps (outside-tap could not dismiss)
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 646), // design frame height
      child: SingleChildScrollView(
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _ClockCard(reports: reports, timezone: timezone),
            for (final p in paramOrder)
              _ParameterCard(parameter: p, report: _reportFor(reports, p), onTap: () => showParameterDetailDialog(context, parameter: p, report: _reportFor(reports, p), timezone: timezone)),
          ],
        ),
      ),
    ),
  ),
);

/// Detail card for one parameter (card_detail frame, real severity text).
Future<void> showParameterDetailDialog(BuildContext context, {required String parameter, required SeverityReportEntity? report, required String timezone}) => showDialog<void>(
  context: context,
  barrierColor: const Color(0x99000000),
  builder: (_) => Dialog(
    insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
    backgroundColor: Colors.transparent,
    constraints: const BoxConstraints(maxWidth: 334), // design card width; keeps transparent Material tight
    elevation: 0,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 560),
      child: ListView(
        shrinkWrap: true, // height hugs content (scrolls when taller) — no transparent dead zone that would eat barrier taps
        children: [
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.fromLTRB(27, 21, 27, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(paramLabel(parameter), style: const TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.bold, fontSize: 24, height: 33 / 24, color: AppColors.textPrimary)),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(paramSub(parameter), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: AppFonts.body, fontSize: 16, height: 19 / 16, color: AppColors.textPrimary)),
                        ),
                      ],
                    ),
                    if (report == null) ...[
                      const SizedBox(height: 24),
                      const Text('No analysis yet.', style: TextStyle(fontFamily: AppFonts.body, fontSize: 12, height: 14 / 12, color: AppColors.textMuted)),
                    ] else ...[
                      const SizedBox(height: 11),
                      Text('${formatClock(pondLocal(report.measuredAt, timezone))} ${formatDayDate(pondLocal(report.measuredAt, timezone))} ${_zoneLabel(timezone)}', style: const TextStyle(fontFamily: AppFonts.body, fontSize: 12, height: 14 / 12, color: AppColors.textMuted)),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(report.value == null ? '—' : paramValueText(report.value!), style: const TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.bold, fontSize: 36, height: 49 / 36, color: AppColors.textPrimary)),
                          if (paramUnit(parameter).isNotEmpty) ...[const SizedBox(width: 3), Text(paramUnit(parameter), style: const TextStyle(fontFamily: AppFonts.heading, fontSize: 12, height: 16 / 12, color: AppColors.textPrimary))],
                        ],
                      ),
                      const SizedBox(height: 5),
                      Center(child: _DetailBadge(label: sevBadgeWord(report.severity), color: sevBadgeColor(report.severity))),
                      const SizedBox(height: 24),
                      const SizedBox(width: 280, height: 3, child: DecoratedBox(decoration: BoxDecoration(color: AppColors.dividerLight))),
                      const _DetailLabel('Description'),
                      const SizedBox(height: 6),
                      for (final para in [report.description, report.detail, report.appendDes])
                        if (para != null && para.isNotEmpty)
                          Padding(padding: const EdgeInsets.only(left: 15), child: Text(para, style: const TextStyle(fontFamily: AppFonts.body, fontSize: 12, height: 14 / 12, color: AppColors.textSecondary))),
                      if (report.guidance != null && report.guidance!.isNotEmpty) ...[
                        const _DetailLabel('Guidance'),
                        const SizedBox(height: 6),
                        Padding(padding: const EdgeInsets.only(left: 15), child: Text(report.guidance!, style: const TextStyle(fontFamily: AppFonts.body, fontSize: 12, height: 14 / 12, color: AppColors.textSecondary))),
                      ],
                    ],
                  ],
                ),
              ),
              Positioned(
                top: 14,
                right: 14,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.close, size: 22, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  ),
);

/// "Description / Guidance" section label (Inria bold 14, x23).
class _DetailLabel extends StatelessWidget {
  final String text;
  const _DetailLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 23, top: 18),
    child: Text(text, style: const TextStyle(fontFamily: AppFonts.body, fontWeight: FontWeight.bold, fontSize: 14, height: 17 / 14, color: AppColors.textPrimary)),
  );
}

/// 71×19 r4 verdict pill, centered in the detail card.
class _DetailBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _DetailBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    height: 19,
    padding: const EdgeInsets.symmetric(horizontal: 8),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
    child: Text(label, style: const TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.bold, fontSize: 14, height: 19 / 14, color: Colors.white)),
  );
}

/// Grid tile 168.5×121.15 — reading timestamp of the latest report (first card
/// of the design grid); "No data yet" before the first analysis.
class _ClockCard extends StatelessWidget {
  final List<SeverityReportEntity> reports;
  final String timezone;
  const _ClockCard({required this.reports, required this.timezone});

  @override
  Widget build(BuildContext context) {
    DateTime? latest;
    for (final r in reports) {
      if (latest == null || r.measuredAt.isAfter(latest)) latest = r.measuredAt;
    }
    if (latest == null) {
      return const _CardShell(
        child: Center(child: Text('No data yet', style: TextStyle(fontFamily: AppFonts.body, fontSize: 12, color: AppColors.textMuted))),
      );
    }
    final t = pondLocal(latest, timezone);
    final parts = formatClock(t).split(' '); // design splits "9:30" big + "AM." small
    return _CardShell(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 9, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(parts.first, style: const TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.bold, fontSize: 32, height: 44 / 32, color: AppColors.textPrimary)),
                Padding(padding: const EdgeInsets.only(bottom: 4), child: Text('${parts.last}.', style: const TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.bold, fontSize: 12, height: 16 / 12, color: AppColors.textPrimary))),
              ],
            ),
            const Spacer(),
            Text(formatDayDate(t), style: const TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.bold, fontSize: 16, height: 22 / 16, color: AppColors.textPrimary)),
            const SizedBox(height: 2),
            Text(_zoneLabel(timezone), style: const TextStyle(fontFamily: AppFonts.body, fontSize: 12, height: 14 / 12, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}

/// Grid tile for one parameter (layout per user screenshot): name / description
/// / badge left, value+unit on the floor.
class _ParameterCard extends StatelessWidget {
  final String parameter;
  final SeverityReportEntity? report;
  final VoidCallback onTap;
  const _ParameterCard({required this.parameter, required this.report, required this.onTap});

  bool get _hasBadge => report != null && report!.severity != PondSeverity.unknown;

  @override
  Widget build(BuildContext context) => _CardShell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(12, 9, 10, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(paramLabel(parameter), style: const TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.bold, fontSize: 16, height: 22 / 16, color: AppColors.textPrimary)),
          const SizedBox(height: 1),
          Text(paramSub(parameter), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: AppFonts.body, fontSize: 12, height: 14 / 12, color: AppColors.textMuted)),
          if (_hasBadge) ...[
            const SizedBox(height: 4),
            _DetailBadge(label: sevBadgeWord(report!.severity), color: sevBadgeColor(report!.severity)),
          ],
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(report?.value == null ? '—' : paramValueText(report!.value!), style: const TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.bold, fontSize: 24, height: 33 / 24, color: AppColors.textPrimary)),
              if (paramUnit(parameter).isNotEmpty) ...[
                const SizedBox(width: 3),
                Text(paramUnit(parameter), style: const TextStyle(fontFamily: AppFonts.heading, fontSize: 12, height: 16 / 12, color: AppColors.textPrimary)),
              ],
            ],
          ),
        ],
      ),
    ),
  );
}

/// 168.5×121.15 white card, border 1.5 #D9D9D9, radius 8 (grid shell).
class _CardShell extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  const _CardShell({required this.child, this.onTap});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 168.5,
    height: 121.15,
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.neutralBorder, width: 1.5),
        ),
        child: child,
      ),
    ),
  );
}
