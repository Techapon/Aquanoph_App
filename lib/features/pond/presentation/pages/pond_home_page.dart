import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:aquanoph/core/theme/app_colors.dart';
import 'package:aquanoph/core/theme/app_fonts.dart';
import 'package:aquanoph/core/utils/pond_time.dart';
import 'package:aquanoph/features/activity/domain/entities/activity_entity.dart';
import 'package:aquanoph/features/pond/domain/entities/pond_entity.dart';
import 'package:aquanoph/features/pond/presentation/controller/pond_home_provider.dart';
import 'package:aquanoph/features/pond/presentation/pages/pond_setting_page.dart';
import 'package:aquanoph/features/pond/presentation/widgets/parameters_dialog.dart';
import 'package:aquanoph/features/recommendation/domain/entities/recommendation_entity.dart';
import 'package:aquanoph/features/severity/domain/entities/pond_status_entity.dart';
import 'package:aquanoph/shared/widgets/buoy_art.dart';

/// Pond home per figma/pond1/ ("Ponds 1" PNG is the visual truth; CSS export
/// has some stale coordinates, e.g. Today's Task). 402×874 absolute design ->
/// native flex, content column 358 wide, gutter 21-22.
/// Step 3: severity status + open recs + today's activities come from Supabase
/// (PondHomeProvider); realtime refresh = step 4.
/// Menu/calendar have no defined destinations yet [U] -> inert; gear -> settings.
class PondHomePage extends StatelessWidget {
  final PondEntity pond;
  final String userId;
  const PondHomePage({super.key, required this.pond, required this.userId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PondHomeProvider()..load(pond),
      child: _PondHomeView(pond: pond, userId: userId),
    );
  }
}

class _PondHomeView extends StatelessWidget {
  final PondEntity pond;
  final String userId;
  const _PondHomeView({required this.pond, required this.userId});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<PondHomeProvider>();
    final feeding = p.of(ActivityType.feeding);
    final aeration = p.of(ActivityType.aeration);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => p.load(pond),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header: menu | "<pond name>" | calendar(red dot) + gear  (figma/pond1, design y65–109)
                Row(
                  children: [
                    const _HeaderButton(Icons.menu),
                    Expanded(
                      child: Center(
                        child: Text(
                          "Pond",
                          style: const TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.bold, fontSize: 24, height: 33 / 24, color: AppColors.textPrimary),
                        ),
                      ),
                    ),
                    const _HeaderButton(Icons.calendar_month_outlined, dot: true), // destination undefined [U] -> inert
                    const SizedBox(width: 8),
                    _HeaderButton(Icons.settings_outlined, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PondSettingPage(userId: userId, pond: pond)))),
                  ],
                ),
                if (p.error != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
                    child: Text(p.error!, style: const TextStyle(fontFamily: AppFonts.body, fontSize: 12, color: AppColors.danger)),
                  ),
                if (p.isLoading && p.status == null && p.recommendations.isEmpty)
                  const Padding(padding: EdgeInsets.fromLTRB(0, 12, 0, 0), child: LinearProgressIndicator(minHeight: 2)),
                const SizedBox(height: 22),
                // ── "Name : …" + "More detail" pill  (y131)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        'Name : ${pond.name}',
                        style: const TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.bold, fontSize: 18, height: 25 / 18, color: AppColors.textPrimary),
                      ),
                    ),
                    _MoreDetailPill(onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PondSettingPage(userId: userId, pond: pond)))),
                  ],
                ),
                const SizedBox(height: 28),
                // ── buoy illustration (centered; design also had "Today's Task" at y198 —
                // moved to the recommendations section per user's Figma selection)
                const SizedBox(
                  height: 65,
                  child: Align(child: BuoyWithWater()), // design centers the 117-wide group at x142/402
                ),
                const SizedBox(height: 28),
                // ── Water Quality Now (y277, h91) — tap opens all-parameters dialog (mock tiles for now)
                GestureDetector(
                  onTap: () => showParametersDialog(context, reports: p.parameters, timezone: pond.timezone),
                  child: _WaterQualityCard(status: p.status, timezone: pond.timezone),
                ),
                const SizedBox(height: 24), // was 65 (that gap led straight to All Recommendations before Today's Task moved here)
                const Text(
                  "Today’s Task", // curly apostrophe exactly as in the design
                  style: TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.bold, fontSize: 18, height: 25 / 18, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 11),
                const _SectionTitle('All Recommendations'),
                const SizedBox(height: 11),
                if (p.recommendations.isEmpty)
                  const SizedBox(
                    width: double.infinity,
                    child: Text('No open recommendations.', textAlign: TextAlign.center, style: TextStyle(fontFamily: AppFonts.body, fontSize: 12, color: AppColors.textMuted)),
                  )
                else
                  ..._recCards(p.recommendations),
                const SizedBox(height: 11),
                const _SectionTitle('All daily tasks'),
                const SizedBox(height: 11),
                // ── Feeding (y714, h92): point-in-time logs, check = done
                _TaskCard(
                  label: 'Feeding',
                  children: feeding.isEmpty
                      ? const [_NoTaskChip()]
                      : [for (final a in feeding) _TimeChip(formatClock(pondLocal(a.startTime, pond.timezone)), checked: a.status == ActivityStatus.done)],
                ),
                const SizedBox(height: 11),
                // ── Aeration (y817, h135): start–end ranges, trailing dot per design
                _TaskCard(
                  label: 'Aeration',
                  children: aeration.isEmpty
                      ? const [_NoTaskChip()]
                      : [
                          for (final a in aeration)
                            _TimeChip(
                              a.endTime == null
                                  ? '${formatClock(pondLocal(a.startTime, pond.timezone))}.'
                                  : '${formatClock(pondLocal(a.startTime, pond.timezone))} - ${formatClock(pondLocal(a.endTime!, pond.timezone))}.',
                              checked: a.status == ActivityStatus.done,
                            ),
                        ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 11px gap between cards, urgent flag from DB `urgency` (cards never lie about it).
  List<Widget> _recCards(List<RecommendationEntity> recs) {
    final out = <Widget>[];
    for (final r in recs) {
      out.add(_RecommendationCard(urgent: r.urgency == RecUrgency.urgent, title: r.title, body: r.body));
      out.add(const SizedBox(height: 11));
    }
    return out;
  }
}

/// CSS box-shadow "0px 2px 29.5px -2px rgba(0,0,0,0.1)" (buttons use a near-identical
/// 0.08/spread+2 variant — visually the same, one token kept).
const _cardShadow = BoxShadow(color: Color(0x1A000000), blurRadius: 29.5, spreadRadius: -2, offset: Offset(0, 2));

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final bool dot;
  final VoidCallback? onTap;
  const _HeaderButton(this.icon, {this.dot = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 44,
        height: 44,
        child: DecoratedBox(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: const [_cardShadow]),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Center(child: Icon(icon, size: 24, color: const Color(0xFF1E1E1E))),
              if (dot) const Positioned(left: 29, top: 8, child: SizedBox(width: 7, height: 7, child: DecoratedBox(decoration: BoxDecoration(color: Color(0xFFFF0000), shape: BoxShape.circle)))),
            ],
          ),
        ),
      ),
    );
  }
}

/// Section subtitle with the leading dot the design shows (· All Recommendations).
class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Row(
        children: [
          const SizedBox(width: 4, height: 4, child: DecoratedBox(decoration: BoxDecoration(color: AppColors.textSecondary, shape: BoxShape.circle))),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(fontFamily: AppFonts.body, fontWeight: FontWeight.bold, fontSize: 14, height: 17 / 14, color: AppColors.textSecondary)),
        ],
      );
}

class _MoreDetailPill extends StatelessWidget {
  final VoidCallback onTap;
  const _MoreDetailPill({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        // no `alignment` (stretches under loose constraints); Row(min) hugs content (≈ design 102 wide)
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: const [_cardShadow]),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ShaderMask(
              shaderCallback: (b) => const LinearGradient(colors: [AppColors.gradientStart, AppColors.gradientEnd]).createShader(b),
              blendMode: BlendMode.srcIn,
              child: const Text('More detail', style: TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class _WaterQualityCard extends StatelessWidget {
  final PondStatusEntity? status;
  final String timezone;
  const _WaterQualityCard({required this.status, required this.timezone});

  @override
  Widget build(BuildContext context) {
    final s = status;
    return Container(
      height: 91,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.neutralBorder, width: 1.5),
        boxShadow: const [_cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(19, 15, 11, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    s != null ? 'Water Quality : ${s.parameter}' : 'Water Quality', // worst-triggering parameter from v_pond_status
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                  ),
                ),
                if (s != null && s.severity != PondSeverity.unknown) _Badge(label: sevBadgeWord(s.severity), color: sevBadgeColor(s.severity)),
                if (s != null && s.showRecoveryBadge) ...[
                  const SizedBox(width: 4),
                  const _Badge(label: 'Recovery', gradient: true),
                ],
                if (s != null) ...[
                  const SizedBox(width: 10),
                  Text('${formatClock(pondLocal(s.updatedAt, timezone))}.', style: const TextStyle(fontFamily: AppFonts.heading, fontSize: 12, height: 16 / 12, color: AppColors.textMuted)),
                ],
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(31, 12, 15, 8),
              child: Text(
                s?.description ?? 'No analysis yet.',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontFamily: AppFonts.body, fontSize: 12, height: 14 / 12, color: AppColors.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Badge words/colors live in parameters_dialog.dart (shared with the dialog).
class _Badge extends StatelessWidget {
  final String label;
  final Color? color;
  final bool gradient;
  const _Badge({required this.label, this.color, this.gradient = false});

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.bold, fontSize: 14, height: 19 / 14, color: Colors.white);
    // hugs content (design's fixed 51/68 widths come out of the text + padding);
    // height 19 = design badge box (card_detail Rectangle 4) — 17 clipped the glyphs
    return Container(
      height: 19,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: gradient
          ? const BoxDecoration(gradient: LinearGradient(colors: [AppColors.gradientStart, AppColors.gradientEnd]), borderRadius: BorderRadius.all(Radius.circular(4)))
          : BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
      child: gradient
          ? ShaderMask(
              shaderCallback: (b) => const LinearGradient(colors: [AppColors.gradientStart, AppColors.gradientEnd]).createShader(b),
              blendMode: BlendMode.srcIn,
              child: Text(label, style: style),
            )
          : Text(label, style: style),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final bool urgent;
  final String title;
  final String body;
  const _RecommendationCard({required this.urgent, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // design: 358 full content column
      child: Container(
        padding: EdgeInsets.fromLTRB(urgent ? 18 : 16, urgent ? 15 : 14, urgent ? 18 : 16, urgent ? 19 : 14),
        decoration: BoxDecoration(
          color: urgent ? AppColors.urgentBg : AppColors.warningBg,
          border: Border.all(color: urgent ? AppColors.urgentBorder : AppColors.warningBorder, width: 1.5),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [_cardShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontFamily: urgent ? AppFonts.heading : AppFonts.body, fontWeight: FontWeight.bold, fontSize: 14, height: 19 / 14, color: urgent ? AppColors.textPrimary : Colors.black)),
            const SizedBox(height: 5),
            Padding(
              padding: EdgeInsets.only(left: urgent ? 10 : 12, right: urgent ? 16 : 4),
              child: Text(body, style: const TextStyle(fontFamily: AppFonts.body, fontSize: 12, height: 14 / 12, color: AppColors.textSecondary)),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final String label;
  final List<Widget> children;
  const _TaskCard({required this.label, required this.children});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // design cards span the full 358 content column — don't hug the chips
      width: double.infinity,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 9, 20, 19), // design: chips end 18-19 above card bottom
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.neutralBorder, width: 1.5),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [_cardShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary)),
            const SizedBox(height: 14),
            Wrap(spacing: 7, runSpacing: 10, children: children),
          ],
        ),
      ),
    );
  }
}

/// Empty-day placeholder inside a task card (no design variant [A]); centers across the card.
class _NoTaskChip extends StatelessWidget {
  const _NoTaskChip();

  @override
  Widget build(BuildContext context) => const SizedBox(
        width: double.infinity,
        child: Text('Nothing logged today', textAlign: TextAlign.center, style: TextStyle(fontFamily: AppFonts.body, fontSize: 12, color: AppColors.textMuted)),
      );
}

class _TimeChip extends StatelessWidget {
  final String text;
  final bool checked;
  const _TimeChip(this.text, {this.checked = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: EdgeInsets.symmetric(horizontal: checked ? 12 : (text.length > 10 ? 10 : 8)),
      decoration: BoxDecoration(border: Border.all(color: AppColors.neutralBorder, width: 2), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text, style: const TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary)),
          if (checked) ...[const SizedBox(width: 6), CustomPaint(size: const Size(11, 9), painter: _ChipCheck())],
        ],
      ),
    );
  }
}

/// Stroke-2 #0BE220 ✓ from the design (same shape as the success dialog's mini check).
class _ChipCheck extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = AppColors.optimal
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(Path()..moveTo(0, size.height * 0.5)..lineTo(size.width * 0.38, size.height)..lineTo(size.width, 0), p);
  }

  @override
  bool shouldRepaint(_ChipCheck old) => false;
}
