import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:aquanoph/core/theme/app_colors.dart';
import 'package:aquanoph/core/theme/app_fonts.dart';
import 'package:aquanoph/core/utils/country_timezones.dart';
import 'package:aquanoph/core/utils/pond_time.dart';
import 'package:aquanoph/features/auth/presentation/controller/auth_provider.dart';
import 'package:aquanoph/features/pond/domain/entities/pond_entity.dart';
import 'package:aquanoph/features/pond/presentation/controller/pond_provider.dart';
import 'package:aquanoph/features/pond/presentation/pages/add_pond_page.dart';
import 'package:aquanoph/features/pond/presentation/pages/pond_home_page.dart';
import 'package:aquanoph/features/recommendation/domain/entities/recommendation_entity.dart';
import 'package:aquanoph/features/severity/domain/entities/pond_status_entity.dart';
import 'package:aquanoph/shared/widgets/buoy_art.dart';

/// Ponds LIST screen per figma/pond_page/Ponds.css (frame "Ponds" — Dev Mode CSS,
/// pixel-exact offsets; detail frame CSS moved to css_detail.txt).
/// DO card = representative severity row, Warning card = top open recommendation (step 3).
/// Province (mock "Sakon Nakhon") has no DB field -> country from timezone only.
/// Menu = sign out. carbon:fish glyph has no Material match [A] -> placeholder icon.
class PondsPage extends StatefulWidget {
  final String userId;
  const PondsPage({super.key, required this.userId});

  @override
  State<PondsPage> createState() => _PondsPageState();
}

class _PondsPageState extends State<PondsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<PondProvider>().load(widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    final ponds = context.watch<PondProvider>();
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: Padding(
        // design FAB: 75x75 circle at right30/bottom36; Scaffold margin is 16 -> add 14/20
        padding: const EdgeInsets.only(right: 14, bottom: 20),
        child: GestureDetector(
          onTap: () => _add(context),
          child: SizedBox(
            width: 75,
            height: 75,
            child: DecoratedBox(
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [_pillShadow]),
              child: ShaderMask(
                // plus glyph: linear-gradient(180deg, #0496FF, #7ED348)
                shaderCallback: (b) => const LinearGradient(colors: [AppColors.gradientStart, AppColors.gradientEnd], begin: Alignment.topCenter, end: Alignment.bottomCenter).createShader(b),
                blendMode: BlendMode.srcIn,
                child: const Icon(Icons.add, size: 28, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header: menu | "Ponds" (list frame has no right-side button)
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 11, 22, 0),
              child: Row(
                children: [
                  PopupMenuButton<String>(
                    color: Colors.white,
                    onSelected: (v) {
                      if (v == 'signout') context.read<AuthProvider>().doSignOut();
                    },
                    itemBuilder: (_) => const [PopupMenuItem(value: 'signout', child: Text('Sign out'))],
                    child: const _HeaderChrome(Icons.menu),
                  ),
                  const Expanded(child: Center(child: Text('Ponds', style: TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.bold, fontSize: 24, height: 33 / 24, color: AppColors.textPrimary)))),
                  const SizedBox(width: 44),
                ],
              ),
            ),
            Expanded(
              child: Builder(
                builder: (context) {
                  if (ponds.isLoading && ponds.ponds.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (ponds.error != null && ponds.ponds.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(ponds.error!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: AppColors.danger, fontFamily: AppFonts.body)),
                            const SizedBox(height: 12),
                            TextButton(onPressed: () => ponds.load(widget.userId), child: const Text('Retry')),
                          ],
                        ),
                      ),
                    );
                  }
                  if (ponds.ponds.isEmpty) return _EmptyState(onAdd: () => _add(context));
                  return RefreshIndicator(
                    onRefresh: () => ponds.load(widget.userId),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(0, 28, 0, 100),
                      itemCount: ponds.ponds.length,
                      // Line 4: 322 wide, 3px #F4F4F4, centered (x40..362)
                      separatorBuilder: (_, _) => const Padding(padding: EdgeInsets.fromLTRB(40, 24, 40, 24), child: DecoratedBox(decoration: BoxDecoration(color: AppColors.dividerLight), child: SizedBox(height: 3))),
                      itemBuilder: (_, i) {
                        final pond = ponds.ponds[i];
                        return _PondBlock(
                          index: i,
                          pond: pond,
                          userId: widget.userId,
                          status: ponds.statuses[pond.id],
                          warning: ponds.warnings[pond.id],
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _add(BuildContext context) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddPondPage(userId: widget.userId)));
}

const _headerShadow = BoxShadow(color: Color(0x1A000000), blurRadius: 29.5, spreadRadius: -2, offset: Offset(0, 2));
const _pillShadow = BoxShadow(color: Color(0x1F000000), blurRadius: 7.6, spreadRadius: 1, offset: Offset(0, 1));

/// 44x44 white rounded-8 button with shadow ("Rectangle 30" chrome).
class _HeaderChrome extends StatelessWidget {
  final IconData icon;
  const _HeaderChrome(this.icon);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: DecoratedBox(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(8)), boxShadow: [_headerShadow]),
        child: Center(child: Icon(icon, size: 22, color: const Color(0xFF1E1E1E))),
      ),
    );
  }
}

class _PondBlock extends StatelessWidget {
  final int index;
  final PondEntity pond;
  final String userId;
  final PondStatusEntity? status;
  final RecommendationEntity? warning;
  const _PondBlock({required this.index, required this.pond, required this.userId, this.status, this.warning});

  @override
  Widget build(BuildContext context) {
    // design pitch: title@137, buoy@189, meta 174/206/235, cards@277 (99h), pill@399
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Text(
            'Ponds ${index + 1} : ${pond.name}',
            style: const TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.w400, fontSize: 18, height: 25 / 18, color: AppColors.textPrimary),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Row(
            children: [
              const Padding(padding: EdgeInsets.only(left: 11), child: BuoyWithWater()), // buoy group at x33 vs gutter 22
              const SizedBox(width: 19),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _metaRow(Icons.location_on_outlined, 15, countryFor(pond.timezone), AppColors.textPrimary),
                    const SizedBox(height: 10),
                    _metaRow(Icons.surfing, 17, speciesLabel(pond.species), AppColors.gradientStart), // carbon:fish placeholder [A]
                    const SizedBox(height: 7),
                    _metaRow(Icons.view_in_ar_outlined, 15, '${_volumeText()} cubic meter', AppColors.gradientEnd),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 23),
        // cards 177/178 wide, 12 gap, 18 gutter (18+177+12+178=385);
        // height 99 -> 121: badge moved onto its own row under the description
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: SizedBox(
            height: 121,
            child: Row(
              children: [
                Expanded(child: _DoCard(status: status, timezone: pond.timezone)),
                const SizedBox(width: 12),
                Expanded(child: _WarningCard(rec: warning)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 23),
        // pill sizes to its content (min width = text + 16*2 ≈ design's 142.61), centered
        Center(child: _ViewDetailsPill(onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PondHomePage(userId: userId, pond: pond))))),
      ],
    );
  }

  String _volumeText() {
    final v = pond.volumeM3;
    return v % 1 == 0 ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
  }

  static Widget _metaRow(IconData icon, double iconSize, String text, Color textColor) => Row(
        children: [
          Icon(icon, size: iconSize, color: const Color(0xFF232323)),
          const SizedBox(width: 6),
          Flexible(child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.bold, fontSize: 16, height: 22 / 16, color: textColor))),
        ],
      );
}

/// Representative-parameter card — design's green "DO / Oxygen in pond / 4.2 mg/L [good]"
/// (Rectangle 3). Non-optimal variants have no Figma frame [A]: same layout,
/// severity-tinted colors + badge word from the severity enum.
class _DoCard extends StatelessWidget {
  final PondStatusEntity? status;
  final String timezone;
  const _DoCard({required this.status, required this.timezone});

  @override
  Widget build(BuildContext context) {
    final s = status;
    if (s == null || s.severity == PondSeverity.unknown) {
      return Container(
        padding: const EdgeInsets.fromLTRB(12, 7, 12, 8),
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.neutralBorder, width: 1.5), borderRadius: BorderRadius.circular(8)),
        child: const Center(
          child: Text('No data yet', style: TextStyle(fontFamily: AppFonts.body, fontSize: 12, color: AppColors.textMuted)),
        ),
      );
    }
    final style = _sevStyle(s.severity);
    final time = s.severity == PondSeverity.unknown ? '' : '${formatClock(pondLocal(s.updatedAt, timezone))}.';
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 7, 12, 8),
      decoration: BoxDecoration(color: style.bg, border: Border.all(color: style.border, width: 1.5), borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(_paramLabel(s.parameter), style: const TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.bold, fontSize: 16, height: 22 / 16, color: AppColors.textPrimary)),
              const SizedBox(width: 3),
              Flexible(child: Text(time, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: AppFonts.heading, fontSize: 12, height: 16 / 12, color: AppColors.textMuted))),
            ],
          ),
          Padding(padding: const EdgeInsets.only(top: 2), child: Text(_paramSub(s.parameter), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: AppFonts.body, fontSize: 12, height: 14 / 12, color: AppColors.textMuted))),
          const SizedBox(height: 8),
          _SevBadge(label: style.badge, color: style.badgeColor), // badge under the subtitle (user layout: never shares a row with the name)
          const SizedBox(height: 4),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(s.value == null ? '—' : _valueText(s.value!), style: const TextStyle(fontFamily: AppFonts.heading, fontSize: 32, height: 44 / 32, color: AppColors.textPrimary)), // design weight 400
                if (_paramUnit(s.parameter).isNotEmpty) Padding(padding: const EdgeInsets.only(left: 4, bottom: 7), child: Text(_paramUnit(s.parameter), style: const TextStyle(fontFamily: AppFonts.heading, fontSize: 12, color: AppColors.textPrimary))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Badge hugs content; 'good' lands on the design's exact 51px (33 text + 9*2).
class _SevBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _SevBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
      child: Text(label, style: const TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
    );
  }
}

typedef _CardStyle = ({Color bg, Color border, String badge, Color badgeColor});

_CardStyle _sevStyle(PondSeverity s) => switch (s) {
      PondSeverity.optimal => (bg: AppColors.listOptimalBg, border: AppColors.listOptimalBorder, badge: 'good', badgeColor: AppColors.optimal),
      PondSeverity.stress => (bg: AppColors.listStressBg, border: AppColors.stress, badge: 'stress', badgeColor: AppColors.stress),
      PondSeverity.elevatedRisk => (bg: AppColors.urgentBg, border: AppColors.urgentBorder, badge: 'risk', badgeColor: AppColors.watch), // badge FF9232
      PondSeverity.critical => (bg: AppColors.urgentBg, border: AppColors.critical, badge: 'critical', badgeColor: AppColors.critical),
      PondSeverity.unknown => (bg: Colors.white, border: AppColors.neutralBorder, badge: '', badgeColor: Colors.transparent),
    };

/// Parameter display sugar [A] — only the DO strings come from the design.
String _paramLabel(String p) => const {'DO': 'DO', 'Temperature': 'Temp', 'pH': 'pH', 'NH3': 'NH3', 'NO2_N': 'NO2', 'Salinity': 'Salinity'}[p] ?? p;
String _paramSub(String p) => const {'DO': 'Oxygen in pond', 'Temperature': 'Water temperature', 'pH': 'pH balance', 'NH3': 'Ammonia level', 'NO2_N': 'Nitrite level', 'Salinity': 'Salt level'}[p] ?? 'In pond';
String _paramUnit(String p) => const {'DO': 'mg/L', 'Temperature': '°C', 'NH3': 'mg/L', 'NO2_N': 'mg/L', 'Salinity': 'ppt', 'pH': ''}[p] ?? '';
String _valueText(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

/// ⚠ Warning card (Rectangle 5) = top open recommendation for the pond.
/// urgent -> design's red "Warning"; non-urgent -> softer "Notice" [A]
/// (reuses warningBg tokens; no Figma variant for either state).
/// None -> neutral card so the two-card row never collapses.
class _WarningCard extends StatelessWidget {
  final RecommendationEntity? rec;
  const _WarningCard({required this.rec});

  @override
  Widget build(BuildContext context) {
    final r = rec;
    if (r == null) {
      return Container(
        padding: const EdgeInsets.fromLTRB(13, 9, 13, 0),
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.neutralBorder, width: 1.5), borderRadius: BorderRadius.circular(8)),
        child: const Center(
          child: Text('No open warnings', style: TextStyle(fontFamily: AppFonts.body, fontSize: 12, color: AppColors.textMuted)),
        ),
      );
    }
    final urgent = r.urgency == RecUrgency.urgent;
    return Container(
      padding: const EdgeInsets.fromLTRB(13, 9, 13, 0),
      decoration: BoxDecoration(
        color: urgent ? AppColors.urgentBg : AppColors.warningBg,
        border: Border.all(color: urgent ? AppColors.urgentBorder : AppColors.warningBorder, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(urgent ? Icons.warning_amber_rounded : Icons.info_outline, size: 20, color: urgent ? AppColors.warnIcon : AppColors.warningBorder),
              const SizedBox(width: 6),
              Text(urgent ? 'Warning' : 'Notice', style: TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.bold, fontSize: 16, height: 22 / 16, color: urgent ? AppColors.warnTitle : AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            r.body,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.start,
            style: const TextStyle(fontFamily: AppFonts.body, fontSize: 12, height: 14 / 12, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

/// "View full details": 142.61x31 white r8 shadow 0/1/7.6/1@0.12, gradient text 14.
class _ViewDetailsPill extends StatelessWidget {
  final VoidCallback onTap;
  const _ViewDetailsPill({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 31,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        // NOTE: no Container `alignment` here — it would stretch to fill loose
        // constraints; Row(min) hugs content (≈ design 142.61 wide).
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(8)), boxShadow: [_pillShadow]),
        child: Row(mainAxisSize: MainAxisSize.min, children: [_gradientText('View full details', 14)]),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // design 107:690: 'Let’s add a new pond' Nunito Bold 24 #707070
          const Text(
            'Let’s add a new pond',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: AppFonts.heading, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          // design 107:692: white pill, shadow, gradient-clipped text 14 bold
          GestureDetector(
            onTap: onAdd,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [BoxShadow(color: Color(0x1F000000), blurRadius: 7.6, offset: Offset(0, 1))],
              ),
              child: _gradientText('Add new Pond', 14),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _gradientText(String text, double size) => ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(colors: [AppColors.gradientStart, AppColors.gradientEnd]).createShader(bounds),
      blendMode: BlendMode.srcIn,
      child: Text(text, style: TextStyle(fontSize: size, fontWeight: FontWeight.bold, fontFamily: AppFonts.heading, color: Colors.white)),
    );

String speciesLabel(String species) {
  const labels = {'nile_tilapia': 'Nile tilapia'};
  final l = labels[species] ?? species.replaceAll('_', ' ');
  return l.isEmpty ? l : l[0].toUpperCase() + l.substring(1);
}
