import 'package:flutter/material.dart';

import 'package:aquanoph/core/theme/app_colors.dart';
import 'package:aquanoph/core/theme/app_fonts.dart';
import 'package:aquanoph/features/pond/domain/entities/pond_entity.dart';
import 'package:aquanoph/features/pond/presentation/pages/pond_setting_page.dart';

/// Pond home per figma/pond_page/Ponds.css ("Ponds 1", 402×874 absolute design ->
/// native flex with the exact measured offsets; content column 358 wide, gutter 21-22).
/// Step 2: static sample text from the design. Data wiring = step 3, realtime = step 4.
/// Menu/bell/plus have no defined destinations yet [U] -> inert for now.
class PondHomePage extends StatelessWidget {
  final PondEntity pond;
  final String userId;
  const PondHomePage({super.key, required this.pond, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header: menu | "<pond name>" | bell(red dot) + plus  (design y65–109)
              Row(
                children: [
                  const _HeaderButton(Icons.menu),
                  Expanded(
                    child: Center(
                      child: Text(
                        pond.name,
                        style: const TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.bold, fontSize: 24, height: 33 / 24, color: AppColors.textPrimary),
                      ),
                    ),
                  ),
                  const _HeaderButton(Icons.notifications_none, dot: true),
                  const SizedBox(width: 8),
                  const _HeaderButton(Icons.add),
                ],
              ),
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
              // ── "Today's Task" + buoy illustration (centered, y184–249)
              const SizedBox(
                height: 65,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(left: 0, top: 19, child: _Water()),
                    Positioned(left: 32, top: 0, child: _Device()),
                    Positioned(left: 0, top: 14, child: Text("Today’s Task", style: TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.bold, fontSize: 18, height: 25 / 18, color: AppColors.textPrimary))),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              // ── Water Quality Now (y277, h91)
              const _WaterQualityCard(),
              const SizedBox(height: 65),
              const _SectionTitle('All Recommendations'),
              const SizedBox(height: 11),
              const _RecommendationCard(
                urgent: true,
                title: 'Operate the aerator for 5 hours, starting at 11 PM.',
                body: 'Dissolved oxygen (DO) is expected to drop to 2.6 mg/L at 04:00 AM.',
              ),
              const SizedBox(height: 11),
              const _RecommendationCard(
                urgent: false,
                title: 'Apply dolomite to boost alkalinity this afternoon.',
                body: 'At 3:40 AM, pH measured at 6.9, which is below the optimal range (7.5–8.5). '
                    'The alkalinity may not be sufficient to buffer daily pH fluctuations.',
              ),
              const SizedBox(height: 11),
              const _SectionTitle('All daily tasks'),
              const SizedBox(height: 11),
              // ── Feeding (y714, h92)
              const _TaskCard(
                label: 'Feeding',
                children: [
                  _TimeChip('8:12 AM', fontSize: 12, checked: true),
                  _TimeChip('12:30 AM'),
                  _TimeChip('17:40 AM'),
                ],
              ),
              const SizedBox(height: 11),
              // ── Aeration (y817, h135; chips 156+153 then 153 -> wrap gives 2 runs)
              const _TaskCard(
                label: 'Aeration',
                children: [
                  _TimeChip('10:00 AM - 4:00 PM.'),
                  _TimeChip('4:00 PM - 10:00 PM.'),
                  _TimeChip('10:00 PM - 6:00 AM'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// CSS box-shadow "0px 2px 29.5px -2px rgba(0,0,0,0.1)" (buttons use a near-identical
/// 0.08/spread+2 variant — visually the same, one token kept).
const _cardShadow = BoxShadow(color: Color(0x1A000000), blurRadius: 29.5, spreadRadius: -2, offset: Offset(0, 2));

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final bool dot;
  const _HeaderButton(this.icon, {this.dot = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
    );
  }
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
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: const [_cardShadow]),
        child: ShaderMask(
          shaderCallback: (b) => const LinearGradient(colors: [AppColors.gradientStart, AppColors.gradientEnd]).createShader(b),
          blendMode: BlendMode.srcIn,
          child: const Text('More detail', style: TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(fontFamily: AppFonts.body, fontWeight: FontWeight.bold, fontSize: 14, height: 17 / 14, color: AppColors.textSecondary));
}

/// 3 concentric ellipses #38D4FF/#32BDE3/#2FAFD3 (Group 5, 117×46 at local y19).
/// ponytail: hand-drawn from CSS % because the design vector was never exported;
/// swap for a PNG asset when one lands in figma/pond_page/.
class _Water extends StatelessWidget {
  const _Water();

  static Widget _e(double w, double h, Color c) => Container(width: w, height: h, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(999)));

  @override
  Widget build(BuildContext context) => Stack(alignment: Alignment.center, children: [_e(117, 46, const Color(0xFF38D4FF)), _e(92, 37, const Color(0xFF32BDE3)), _e(60, 24, const Color(0xFF2FAFD3))]);
}

/// 56×45 device at local x32: mast/rects from "Water Quality Monitoring Device" %.
class _Device extends StatelessWidget {
  const _Device();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 45,
      child: Stack(
        clipBehavior: Clip.none,
        children: const [
          Positioned(left: 0, top: 31.7, width: 56, height: 13.3, child: ColoredBox(color: Color(0xFFD9D9D9))), // deck
          Positioned(left: 3.3, top: 36.7, width: 13.2, height: 6.9, child: ColoredBox(color: Color(0xFF6E6E6E))), // leg L
          Positioned(left: 39.5, top: 36.7, width: 13.2, height: 6.9, child: ColoredBox(color: Color(0xFF6E6E6E))), // leg R
          Positioned(left: 6.6, top: 11.7, width: 42.9, height: 20.0, child: ColoredBox(color: Color(0xFF414141))), // body
          Positioned(left: 46.1, top: 0, width: 1.6, height: 33.3, child: ColoredBox(color: Color(0xFFA4A4A4))), // mast
        ],
      ),
    );
  }
}

class _WaterQualityCard extends StatelessWidget {
  const _WaterQualityCard();

  @override
  Widget build(BuildContext context) {
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
                const Text('Water Quality Now', style: TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary)),
                const SizedBox(width: 10),
                const _Badge(label: 'Stress', color: AppColors.stress, width: 51),
                const SizedBox(width: 4),
                const _Badge(label: 'Recovery', gradient: true, width: 68),
                const Spacer(),
                const Text('9:30 AM.', style: TextStyle(fontFamily: AppFonts.heading, fontSize: 12, height: 16 / 12, color: AppColors.textMuted)),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(31, 12, 11, 0),
            child: Text(
              'Water quality at 11:00 AM is within the optimal range. DO, pH, and temperature levels are suitable for aquaculture.',
              style: TextStyle(fontFamily: AppFonts.body, fontSize: 12, height: 14 / 12, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color? color;
  final bool gradient;
  final double width;
  const _Badge({required this.label, this.color, this.gradient = false, required this.width});

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white);
    return Container(
      height: 17,
      width: width,
      alignment: Alignment.center,
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
    return Container(
      padding: EdgeInsets.fromLTRB(urgent ? 18 : 16, urgent ? 15 : 14, urgent ? 18 : 16, 0),
      decoration: BoxDecoration(
        color: urgent ? AppColors.urgentBg : AppColors.warningBg,
        border: Border.all(color: urgent ? AppColors.urgentBorder : AppColors.warningBorder, width: 1.5),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [_cardShadow],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
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
          if (!urgent) const Positioned(right: 10, top: 2, child: Icon(Icons.info_outline, size: 18, color: Color(0xFF1E1E1E))),
        ],
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
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 9, 20, 10),
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
    );
  }
}

class _TimeChip extends StatelessWidget {
  final String text;
  final double fontSize;
  final bool checked;
  const _TimeChip(this.text, {this.fontSize = 14, this.checked = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: EdgeInsets.symmetric(horizontal: checked ? 12 : (text.length > 10 ? 10 : 8)),
      decoration: BoxDecoration(border: Border.all(color: AppColors.neutralBorder, width: 2), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text, style: TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.bold, fontSize: fontSize, color: AppColors.textPrimary)),
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
