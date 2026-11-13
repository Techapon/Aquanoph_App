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

/// Ponds LIST screen per figma/pond_page/Ponds.png (frame "Ponds", 402×874 — the second
/// frame on that Figma page; Ponds.css/SVG is the "Pond 1" detail page).
/// No Dev Mode CSS exists for this frame yet, so geometry is measured off the PNG (±2px).
/// DO value/time + Warning text are the design's static strings [A] — data wiring = step 3.
/// Province (PNG mock "Sakon Nakhon") has no DB field -> country from timezone only.
/// Menu = sign out (moved from the old AppBar action). Calendar button destination [U] -> inert.
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
      floatingActionButton: FloatingActionButton(
        // design: white circle bottom-right, gradient "+"
        onPressed: () => _add(context),
        backgroundColor: Colors.white,
        elevation: 2,
        child: ShaderMask(
          shaderCallback: (b) => const LinearGradient(colors: [AppColors.gradientStart, AppColors.gradientEnd]).createShader(b),
          blendMode: BlendMode.srcIn,
          child: const Icon(Icons.add, size: 24, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header: menu | "Ponds" | calendar(red dot)  (design y65–109)
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 8),
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
                  const _HeaderChrome(Icons.calendar_today_outlined, dot: true),
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
                      padding: const EdgeInsets.fromLTRB(22, 8, 22, 88),
                      itemCount: ponds.ponds.length,
                      separatorBuilder: (_, _) => const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Divider(height: 1, thickness: 1, color: Color(0xFFEFEFEF))),
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

const _shadow = BoxShadow(color: Color(0x1A000000), blurRadius: 29.5, spreadRadius: -2, offset: Offset(0, 2));

/// 44×44 white button with shadow (menu / calendar), same chrome as PondHomePage header.
class _HeaderChrome extends StatelessWidget {
  final IconData icon;
  final bool dot;
  const _HeaderChrome(this.icon, {this.dot = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: DecoratedBox(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(8)), boxShadow: [_shadow]),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(child: Icon(icon, size: 22, color: const Color(0xFF1E1E1E))),
            if (dot) const Positioned(left: 30, top: 7, child: SizedBox(width: 7, height: 7, child: DecoratedBox(decoration: BoxDecoration(color: Color(0xFFFF0000), shape: BoxShape.circle)))),
          ],
        ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // "Ponds 1 : <name>" — prefix regular 400, name bold 700 (design 18 Nunito)
        Text.rich(
          TextSpan(
            style: const TextStyle(fontFamily: AppFonts.heading, fontSize: 18, height: 25 / 18, color: AppColors.textPrimary),
            children: [
              TextSpan(text: 'Ponds ${index + 1} : '),
              TextSpan(text: pond.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const BuoyWithWater(),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _metaRow(Icons.location_on_outlined, countryFor(pond.timezone), AppColors.textSecondary),
                  const SizedBox(height: 6),
                  _metaRow(Icons.surfing, speciesLabel(pond.species), AppColors.gradientStart), // [U] no fish glyph in Material; swap when icon asset lands
                  const SizedBox(height: 6),
                  _metaRow(Icons.square_foot, '${pond.volumeM3.toStringAsFixed(1)} cubic meter', AppColors.success),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const SizedBox(height: 98, child: Row(children: [Expanded(child: _DoCard()), SizedBox(width: 10), Expanded(child: _WarningCard())])),
        const SizedBox(height: 10),
        Center(child: _ViewDetailsPill(onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PondHomePage(userId: userId, pond: pond))))),
      ],
    );
  }

  static Widget _metaRow(IconData icon, String text, Color color) => Row(
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Flexible(child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: AppFonts.body, fontSize: 12, height: 16 / 12, color: color))),
        ],
      );
}

/// "DO  9:30 AM. / Oxygen in pond / 4.2 mg/L [good]" — green Optimal-zone styling from
/// the PNG. All values static for now [A]; step 3 pulls severity_reports + latest reading.
class _DoCard extends StatelessWidget {
  const _DoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(color: AppColors.zoneOptimal, border: Border.all(color: AppColors.optimal, width: 1.5), borderRadius: BorderRadius.circular(8)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('DO', style: TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
              Spacer(),
              Text('9:30 AM.', style: TextStyle(fontFamily: AppFonts.heading, fontSize: 12, color: AppColors.textMuted)),
            ],
          ),
          const Text('Oxygen in pond', style: TextStyle(fontFamily: AppFonts.body, fontSize: 12, color: AppColors.textSecondary)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              Text('4.2', style: TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.bold, fontSize: 30, height: 1, color: AppColors.textPrimary)),
              Padding(padding: EdgeInsets.only(bottom: 3, left: 4), child: Text('mg/L', style: TextStyle(fontFamily: AppFonts.body, fontSize: 12, color: AppColors.textSecondary))),
              Spacer(),
              _GoodBadge(),
            ],
          ),
        ],
      ),
    );
  }
}

class _GoodBadge extends StatelessWidget {
  const _GoodBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: AppColors.optimal, borderRadius: BorderRadius.circular(6)),
      child: const Text('good', style: TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.bold, fontSize: 10, color: Colors.white)),
    );
  }
}

/// ⚠ Warning card — static prediction string from the PNG (step 3: top pending rec).
class _WarningCard extends StatelessWidget {
  const _WarningCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(color: AppColors.urgentBg, border: Border.all(color: AppColors.urgentBorder, width: 1.5), borderRadius: BorderRadius.circular(8)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, size: 18, color: const Color(0xFFFF3232)),
              const SizedBox(width: 4),
              const Text('Warning', style: TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFFF3232))),
            ],
          ),
          const Text(
            'DO is expected to drop to 2.6 mg/L at 04:00 AM.',
            style: TextStyle(fontFamily: AppFonts.body, fontSize: 12, height: 14 / 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ViewDetailsPill extends StatelessWidget {
  final VoidCallback onTap;
  const _ViewDetailsPill({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 28,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(8)), boxShadow: [_shadow]),
        child: ShaderMask(
          shaderCallback: (b) => const LinearGradient(colors: [AppColors.gradientStart, AppColors.gradientEnd]).createShader(b),
          blendMode: BlendMode.srcIn,
          child: const Text('View full details', style: TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
        ),
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
