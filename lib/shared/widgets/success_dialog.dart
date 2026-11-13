import 'package:flutter/material.dart';

import 'package:aquanoph/core/theme/app_colors.dart';
import 'package:aquanoph/core/theme/app_fonts.dart';

/// Figma 109:1176 success popup — absolute-positioned 1:1 from Dev Mode CSS
/// (stored at figma/design_css/109_1176_success.css, 2026-11-13). Card 358x383 r16.
/// Copy currently matches the mock; swap strings here when final app copy is decided
/// (DESIGN_TOKENS obs #2).
/// [U] button label: CSS text box is 40px @ Inter16 — too wide for "OK" (≈22px);
/// using "OK" until the design label is confirmed.
/// [V] user's Figma screenshot 2026-11-13: button label is "close" (lowercase),
/// status line = "• " bullet + bold name + regular suffix.
/// [V] skill rule §7 (2026-11-13): status line must fit the calling context —
/// defaults are the wizard copy; other flows pass their own label/suffix.
Future<void> showSuccessDialog(
  BuildContext context, {
  String title = 'Create success!',
  String subtitle = 'Analysis and Schedule complete.',
  String statusLabel = 'Analysis Pond',
  String statusSuffix = ' completed.',
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      // Design card is 358px on a 402pt artboard; narrower devices must SCALE the whole
      // card (fixed x-positions would otherwise overflow the white container on the right).
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          width: 358,
          height: 383,
          child: Stack(
            clipBehavior: Clip.none,
          children: [
            // Group 98 / Ellipse 5: 75px circle, left 142 (50%-37.5+0.5), top 52
            Positioned(
              left: 142,
              top: 52,
              child: const SizedBox(
                width: 75,
                height: 75,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: AppColors.successBg, shape: BoxShape.circle),
                  child: CustomPaint(painter: _TickPainter()),
                ),
              ),
            ),
            // Title 24/33 Bold #232323, top 145, centered
            Positioned(
              left: 0,
              right: 0,
              top: 145,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.bold, fontSize: 24, height: 33 / 24, color: AppColors.textPrimary),
              ),
            ),
            // Subtitle 16/22 Regular #707070, top 178, centered (Nunito, not InriaSans)
            Positioned(
              left: 0,
              right: 0,
              top: 178,
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.w400, fontSize: 16, height: 22 / 16, color: AppColors.textSecondary),
              ),
            ),
            // Status line (30,244) w213: "• " + Bold label + regular suffix (params, §7 rule)
            Positioned(
              left: 30,
              top: 244,
              width: 213,
              child: Text.rich(
                TextSpan(
                  style: const TextStyle(fontFamily: AppFonts.heading, fontSize: 16, height: 22 / 16, color: AppColors.textPrimary),
                  children: [
                    const TextSpan(text: '•  '),
                    TextSpan(text: statusLabel, style: const TextStyle(fontWeight: FontWeight.w700)),
                    TextSpan(text: statusSuffix, style: const TextStyle(fontWeight: FontWeight.w400)),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // small green check at (312,249) 16x12
            const Positioned(
              left: 312,
              top: 249,
              child: CustomPaint(size: Size(16, 12), painter: _MiniCheckPainter()),
            ),
            // Button 100x40 #2C2C2C r8, (238,324); label Inter16 #F5F5F5 -> app uses Nunito [A]
            Positioned(
              left: 238,
              top: 324,
              child: SizedBox(
                width: 100,
                height: 40,
                child: TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF2C2C2C), // svg/CSS exact, not AppColors.darkButton
                    foregroundColor: const Color(0xFFF5F5F5),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('close', style: TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.w400, fontSize: 16, height: 1)),
                ),
              ),
            ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Tick path (card coords 163,90.23 -> 175.38,100.46 -> 196,80) local to the
/// 75px circle at (142,52): (21,38.23) (33.38,48.46) (54,28). Stroke 6, round.
class _TickPainter extends CustomPainter {
  const _TickPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 75;
    final p = Path()
      ..moveTo(21 * s, 38.23 * s)
      ..lineTo(33.38 * s, 48.46 * s)
      ..lineTo(54 * s, 28 * s);
    canvas.drawPath(
      p,
      Paint()
        ..color = AppColors.success
        ..strokeWidth = 6 * s
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _TickPainter oldDelegate) => false;
}

/// "M312 255L318 261L328 249" in a 16x12 box: (0,6)-(6,12)-(16,0), stroke 2 #0BE220.
class _MiniCheckPainter extends CustomPainter {
  const _MiniCheckPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final p = Path()
      ..moveTo(0, size.height / 2)
      ..lineTo(size.width * 0.375, size.height)
      ..lineTo(size.width, 0);
    canvas.drawPath(
      p,
      Paint()
        ..color = const Color(0xFF0BE220)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _MiniCheckPainter oldDelegate) => false;
}
