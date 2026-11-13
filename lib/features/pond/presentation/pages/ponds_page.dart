import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:aquanoph/core/theme/app_colors.dart';
import 'package:aquanoph/core/theme/app_fonts.dart';
import 'package:aquanoph/features/auth/presentation/controller/auth_provider.dart';
import 'package:aquanoph/features/pond/domain/entities/pond_entity.dart';
import 'package:aquanoph/features/pond/presentation/controller/pond_provider.dart';
import 'package:aquanoph/features/pond/presentation/pages/add_pond_page.dart';
import 'package:aquanoph/features/pond/presentation/pages/pond_home_page.dart';

/// Figma 30:496 (empty) + 77:605 header chrome. Design has no "pond card" mock ->
/// simple card with name + summary line [A decided 2026-11-13].
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: const Text('Ponds', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: AppFonts.heading, color: AppColors.textPrimary)),
        actions: [
          PopupMenuButton<String>(
            color: Colors.white,
            onSelected: (v) {
              if (v == 'signout') context.read<AuthProvider>().doSignOut();
            },
            itemBuilder: (_) => const [PopupMenuItem(value: 'signout', child: Text('Sign out'))],
          ),
        ],
      ),
      body: Builder(
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
          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => ponds.load(widget.userId),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                    itemCount: ponds.ponds.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _PondCard(pond: ponds.ponds[i], userId: widget.userId),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 8, 22, 22),
                child: ElevatedButton(
                  onPressed: () => _add(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.textPrimary,
                    elevation: 2,
                    shadowColor: const Color(0x1F000000),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _gradientText('Add new Pond', 16),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _add(BuildContext context) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddPondPage(userId: widget.userId)));
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

class _PondCard extends StatelessWidget {
  final PondEntity pond;
  final String userId;
  const _PondCard({required this.pond, required this.userId});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PondHomePage(userId: userId, pond: pond))),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.neutralBorder, width: 1.5),
          boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 20, offset: Offset(0, 2))],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(pond.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: AppFonts.heading, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(
                    '${speciesLabel(pond.species)} · ${pond.volumeM3.toStringAsFixed(1)} m³ · ${pond.stockingCount} fish',
                    style: const TextStyle(fontSize: 14, fontFamily: AppFonts.body, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

String speciesLabel(String species) {
  const labels = {'nile_tilapia': 'Nile tilapia'};
  final l = labels[species] ?? species.replaceAll('_', ' ');
  return l.isEmpty ? l : l[0].toUpperCase() + l.substring(1);
}
