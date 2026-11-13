import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:aquanoph/core/theme/app_colors.dart';
import 'package:aquanoph/core/theme/app_fonts.dart';
import 'package:aquanoph/core/utils/country_timezones.dart';
import 'package:aquanoph/features/auth/presentation/controller/auth_provider.dart';
import 'package:aquanoph/features/pond/domain/entities/pond_entity.dart';
import 'package:aquanoph/features/pond/presentation/controller/pond_provider.dart';
import 'package:aquanoph/features/pond/presentation/pages/add_pond_page.dart';
import 'package:aquanoph/features/pond/presentation/pages/pond_home_page.dart';
import 'package:aquanoph/shared/widgets/buoy_art.dart';

/// Ponds LIST screen per figma/pond_page/Ponds.css (frame "Ponds" — Dev Mode CSS,
/// pixel-exact offsets; detail frame CSS moved to css_detail.txt).
/// DO value/time + Warning text are the design's static strings [A] — data wiring = step 3.
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
                      itemBuilder: (_, i) => _PondBlock(index: i, pond: ponds.ponds[i], userId: widget.userId),
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
  const _PondBlock({required this.index, required this.pond, required this.userId});

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
        // cards 177/178 x 99, 12 gap, 18 gutter (18+177+12+178=385)
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 18),
          child: SizedBox(
            height: 99,
            child: Row(children: [Expanded(child: _DoCard()), SizedBox(width: 12), Expanded(child: _WarningCard())]),
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

/// "DO 9:30 AM. / Oxygen in pond / 4.2 mg/L [good]" — Optimal-zone card (Rectangle 3).
/// All values static for now [A]; step 3 pulls severity_reports + latest reading.
class _DoCard extends StatelessWidget {
  const _DoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 7, 12, 8),
      decoration: BoxDecoration(color: AppColors.listOptimalBg, border: Border.all(color: AppColors.listOptimalBorder, width: 1.5), borderRadius: BorderRadius.circular(8)),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('DO', style: TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.bold, fontSize: 16, height: 22 / 16, color: AppColors.textPrimary)),
              SizedBox(width: 3),
              Text('9:30 AM.', style: TextStyle(fontFamily: AppFonts.heading, fontSize: 12, height: 16 / 12, color: AppColors.textMuted)),
            ],
          ),
          Padding(padding: EdgeInsets.only(top: 2), child: Text('Oxygen in pond', style: TextStyle(fontFamily: AppFonts.body, fontSize: 12, height: 14 / 12, color: AppColors.textMuted))),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('4.2', style: TextStyle(fontFamily: AppFonts.heading, fontSize: 32, height: 44 / 32, color: AppColors.textPrimary)), // design weight 400
                Padding(padding: EdgeInsets.only(left: 4, bottom: 7), child: Text('mg/L', style: TextStyle(fontFamily: AppFonts.heading, fontSize: 12, color: AppColors.textPrimary))),
                Spacer(),
                _GoodBadge(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "good" badge: 51x20 #0BE220 r4, Nunito 14 bold white.
class _GoodBadge extends StatelessWidget {
  const _GoodBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 51,
      height: 20,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: AppColors.optimal, borderRadius: BorderRadius.circular(4)),
      child: const Text('good', style: TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
    );
  }
}

/// ⚠ Warning card (Rectangle 5) — static prediction string; step 3: top pending rec.
class _WarningCard extends StatelessWidget {
  const _WarningCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(13, 9, 13, 0),
      decoration: BoxDecoration(color: AppColors.urgentBg, border: Border.all(color: AppColors.urgentBorder, width: 1.5), borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded, size: 20, color: AppColors.warnIcon),
              SizedBox(width: 6),
              Text('Warning', style: TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.bold, fontSize: 16, height: 22 / 16, color: AppColors.warnTitle)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Center(
              child: Text(
                'DO is expected to drop to 2.6 mg/L at 04:00 AM.',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: AppFonts.body, fontSize: 12, height: 14 / 12, color: AppColors.textPrimary),
              ),
            ),
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
