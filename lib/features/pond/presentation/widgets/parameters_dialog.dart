import 'package:flutter/material.dart';

import 'package:aquanoph/core/theme/app_colors.dart';
import 'package:aquanoph/core/theme/app_fonts.dart';

/// All-parameters dialog + per-parameter detail, per figma/ponds_parameter/.
/// UI-only stage: the tile list below is the design's own mock copy — replace
/// with v_pond_status / severity_reports rows when wiring (later task).
/// Design mock has 9 params (Turbidity/EC/TAN/NO3/Alkalinity beyond our v1 six);
/// kept as-is until wiring decides which the DB can fill.

/// One parameter tile (grid card + its detail dialog).
class ParameterTile {
  final String name;
  final String description;
  final String value;
  final String unit;
  final String badge; // good / watch / high / Stress (design words)
  final Color badgeColor;
  const ParameterTile({
    required this.name,
    required this.description,
    required this.value,
    required this.unit,
    required this.badge,
    required this.badgeColor,
  });

  /// Detail dialog: "good" gets the short one-paragraph layout, the rest the
  /// Reason/Symptoms + Diagnostic + Guidance layout (Optimal vs Not Optimal case).
  bool get isGood => badge == 'good';
}

/// Badge colors verified against figma/ponds_parameter CSS.
const _badgeGood = AppColors.optimal; // #0BE220
const _badgeWatch = AppColors.watch; // #FF9232
const _badgeHigh = AppColors.critical; // #FF3232
const _badgeStress = AppColors.stress; // #FFCC00

const mockParameters = <ParameterTile>[
  ParameterTile(
    name: 'DO',
    description: 'Oxygen in pond',
    value: '5.02',
    unit: 'mg/L',
    badge: 'Stress',
    badgeColor: _badgeStress,
  ),
  ParameterTile(
    name: 'pH',
    description: 'The acidity or alkalinity of water.',
    value: '7.50',
    unit: '',
    badge: 'good',
    badgeColor: _badgeGood,
  ),
  ParameterTile(
    name: 'Temperature',
    description: 'Water temperature',
    value: '36',
    unit: '°C',
    badge: 'high',
    badgeColor: _badgeHigh,
  ),
  ParameterTile(
    name: 'Turbidity',
    description: 'Water turbidity',
    value: '25.00',
    unit: 'NTU',
    badge: 'watch',
    badgeColor: _badgeWatch,
  ),
  ParameterTile(
    name: 'EC',
    description: 'Electrical conductivity',
    value: '22.5',
    unit: 'mS/cm',
    badge: 'good',
    badgeColor: _badgeGood,
  ),
  ParameterTile(
    name: 'TAN',
    description: 'Total ammonia in water.',
    value: '0.90',
    unit: 'mg/L',
    badge: 'high',
    badgeColor: _badgeHigh,
  ),
  ParameterTile(
    name: 'NO2',
    description: 'Nitrite in water',
    value: '0.18',
    unit: 'mg/L',
    badge: 'watch',
    badgeColor: _badgeWatch,
  ),
  ParameterTile(
    name: 'NO3',
    description: 'Nitrates in water',
    value: '22.00',
    unit: 'mg/L',
    badge: 'good',
    badgeColor: _badgeGood,
  ),
  ParameterTile(
    name: 'Alkalinity',
    description: 'Alkalinity of water',
    value: '55.00',
    unit: 'mg/L',
    badge: 'watch',
    badgeColor: _badgeWatch,
  ),
];

// Design mock strings (card_detail frames) — placeholder copy until real
// analysis text is wired in.
const _mockClock = '9:30 AM.';
const _mockDate = '20 Aug. 2026';
const _mockZone = 'Thailand (UTC+7)';
const _optimalBody =
    'Water quality at 11:00 AM is within the optimal range. DO, pH, and temperature levels are suitable for aquaculture.';
const _notOptimalReason =
    'Reason (Temporal cause): Lorem Ipsum is simply dummy text of the printing and typesetting industry.';
const _notOptimalSymptoms =
    'Symptoms in aquatic animals. : Lorem Ipsum is simply dummy text of the printing and typesetting industry.';
const _diagnosticBody =
    'Water temperature usually peaks in the afternoon (11:00–16:00).';
const _guidanceBody =
    'Take immediate action — monitor DO and NH₃ levels.'; // [A] design export glues "actionmonitor"

/// Opened by tapping the Water Quality Now card: floating 2-col grid on a dim
/// barrier (the design has no dialog panel behind the cards).
Future<void> showParametersDialog(BuildContext context) => showDialog<void>(
  context: context,
  barrierColor: const Color(0x99000000),
  builder: (_) => Dialog(
    insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
    backgroundColor: Colors.transparent,
    constraints: const BoxConstraints(
      maxWidth: 347,
    ), // keep transparent Material from stretching to full width
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
            const _ClockCard(),
            for (final t in mockParameters)
              _ParameterCard(
                tile: t,
                onTap: () => showParameterDetailDialog(context, t),
              ),
          ],
        ),
      ),
    ),
  ),
);

/// Detail card for one parameter (card_detail Optimal / Not Optimal case).
Future<void> showParameterDetailDialog(
  BuildContext context,
  ParameterTile tile,
) => showDialog<void>(
  context: context,
  barrierColor: const Color(0x99000000),
  builder: (_) => Dialog(
    insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
    backgroundColor: Colors.transparent,
    constraints: const BoxConstraints(
      maxWidth: 334,
    ), // design card width; keeps transparent Material tight
    elevation: 0,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 560),
      child: ListView(
        shrinkWrap:
            true, // height hugs content (scrolls when taller) — no transparent dead zone that would eat barrier taps
        children: [
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.fromLTRB(27, 21, 27, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          tile.name,
                          style: const TextStyle(
                            fontFamily: AppFonts.heading,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            height: 33 / 24,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            tile.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: AppFonts.body,
                              fontSize: 16,
                              height: 19 / 16,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 11),
                    const Text(
                      '$_mockClock $_mockDate $_mockZone',
                      style: TextStyle(
                        fontFamily: AppFonts.body,
                        fontSize: 12,
                        height: 14 / 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          tile.value,
                          style: const TextStyle(
                            fontFamily: AppFonts.heading,
                            fontWeight: FontWeight.bold,
                            fontSize: 36,
                            height: 49 / 36,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (tile.unit.isNotEmpty) ...[
                          const SizedBox(width: 3),
                          Text(
                            tile.unit,
                            style: const TextStyle(
                              fontFamily: AppFonts.heading,
                              fontSize: 12,
                              height: 16 / 12,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 5),
                    Center(
                      child: _DetailBadge(
                        label: tile.badge,
                        color: tile.badgeColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const SizedBox(
                      width: 280,
                      height: 3,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.dividerLight,
                        ),
                      ),
                    ),
                    if (tile.isGood) ...[
                      const _DetailLabel('Description'),
                      const SizedBox(height: 10),
                      const Padding(
                        padding: EdgeInsets.only(left: 15),
                        child: Text(
                          _optimalBody,
                          style: TextStyle(
                            fontFamily: AppFonts.body,
                            fontSize: 12,
                            height: 14 / 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ] else ...[
                      const _DetailLabel('Description'),
                      const SizedBox(height: 6),
                      const Padding(
                        padding: EdgeInsets.only(left: 13),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _notOptimalReason,
                              style: TextStyle(
                                fontFamily: AppFonts.body,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                height: 14 / 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              _notOptimalSymptoms,
                              style: TextStyle(
                                fontFamily: AppFonts.body,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                height: 14 / 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const _DetailLabel('Diagnostic'),
                      const SizedBox(height: 6),
                      const Padding(
                        padding: EdgeInsets.only(left: 15),
                        child: Text(
                          _diagnosticBody,
                          style: TextStyle(
                            fontFamily: AppFonts.body,
                            fontSize: 12,
                            height: 14 / 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const _DetailLabel('Guidance'),
                      const SizedBox(height: 6),
                      const Padding(
                        padding: EdgeInsets.only(left: 15),
                        child: Text(
                          _guidanceBody,
                          style: TextStyle(
                            fontFamily: AppFonts.body,
                            fontSize: 12,
                            height: 14 / 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Positioned(
                top: 14,
                right: 14,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(
                    Icons.close,
                    size: 22,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  ),
);

/// "Description / Diagnostic / Guidance" section label (Inria bold 14, x23).
class _DetailLabel extends StatelessWidget {
  final String text;
  const _DetailLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 23, top: 18),
    child: Text(
      text,
      style: const TextStyle(
        fontFamily: AppFonts.body,
        fontWeight: FontWeight.bold,
        fontSize: 14,
        height: 17 / 14,
        color: AppColors.textPrimary,
      ),
    ),
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
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      label,
      style: const TextStyle(
        fontFamily: AppFonts.heading,
        fontWeight: FontWeight.bold,
        fontSize: 14,
        height: 19 / 14,
        color: Colors.white,
      ),
    ),
  );
}

/// Grid tile 168.5×121.15 — reading timestamp (first card of the design grid).
class _ClockCard extends StatelessWidget {
  const _ClockCard();

  @override
  Widget build(BuildContext context) => _CardShell(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(12, 9, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              Text(
                '9:30',
                style: TextStyle(
                  fontFamily: AppFonts.heading,
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                  height: 44 / 32,
                  color: AppColors.textPrimary,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text(
                  'AM.',
                  style: TextStyle(
                    fontFamily: AppFonts.heading,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    height: 16 / 12,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          const Text(
            '20 Aug. 2026',
            style: TextStyle(
              fontFamily: AppFonts.heading,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              height: 22 / 16,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Thailand (UTC+7)',
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 12,
              height: 14 / 12,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    ),
  );
}

/// Grid tile for one parameter: name, description, value+unit bottom-left, badge bottom-right.
class _ParameterCard extends StatelessWidget {
  final ParameterTile tile;
  final VoidCallback onTap;
  const _ParameterCard({required this.tile, required this.onTap});

  @override
  Widget build(BuildContext context) => _CardShell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(12, 9, 10, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // layout per user screenshot: name / description / badge left, value bottom
          Text(
            tile.name,
            style: const TextStyle(
              fontFamily: AppFonts.heading,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              height: 22 / 16,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            tile.description,
            maxLines: 1, // badge moved below the desc inside the fixed 121px card — 2 lines no longer fit
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 12,
              height: 14 / 12,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 12),
          _DetailBadge(label: tile.badge, color: tile.badgeColor),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                tile.value,
                style: const TextStyle(
                  fontFamily: AppFonts.heading,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  height: 33 / 24,
                  color: AppColors.textPrimary,
                ),
              ),
              if (tile.unit.isNotEmpty) ...[
                const SizedBox(width: 3),
                Text(
                  tile.unit,
                  style: const TextStyle(
                    fontFamily: AppFonts.heading,
                    fontSize: 12,
                    height: 16 / 12,
                    color: AppColors.textPrimary,
                  ),
                ),
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
