import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:aquanoph/core/theme/app_colors.dart';
import 'package:aquanoph/core/theme/app_fonts.dart';
import 'package:aquanoph/core/utils/country_timezones.dart';
import 'package:aquanoph/core/utils/pond_time.dart';
import 'package:aquanoph/core/utils/thousands.dart';
import 'package:aquanoph/features/auth/presentation/controller/auth_provider.dart';
import 'package:aquanoph/features/pond/domain/entities/pond_entity.dart';
import 'package:aquanoph/features/pond/presentation/controller/pond_provider.dart';

/// Pond settings per figma/setting_page/ — PNG is layout truth (user pick 2026-11-13):
/// chevron + "Setting", Editable (pond name + Edit), Pond Parameter pills card,
/// divider, Read-only 3 cards (Water/Fish/Area), Time zone row, Logout.
/// The CSS variant's extras (green-check save, Weight/kg/Amount fields, Species/ID
/// rows) are not in the PNG -> skipped. Content column 355, gutter 22.
class PondSettingPage extends StatefulWidget {
  final String userId;
  final PondEntity pond;
  const PondSettingPage({super.key, required this.userId, required this.pond});

  @override
  State<PondSettingPage> createState() => _PondSettingPageState();
}

class _PondSettingPageState extends State<PondSettingPage> {
  late final _name = TextEditingController(text: widget.pond.name);
  final _nameFocus = FocusNode();
  bool _editingName = false;

  @override
  void dispose() {
    _name.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  Future<void> _saveName() async {
    final text = _name.text.trim();
    if (text.isEmpty) {
      setState(() => _editingName = false);
      _name.text = widget.pond.name;
      return;
    }
    final ok = await context.read<PondProvider>().update(widget.userId, widget.pond.id, name: text);
    if (!mounted) return;
    setState(() => _editingName = false);
    if (!ok) _name.text = widget.pond.name;
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().doSignOut();
    if (!mounted) return;
    Navigator.of(context).popUntil((r) => r.isFirst); // _AuthGate swaps to SignIn underneath
  }

  @override
  Widget build(BuildContext context) {
    final pond = widget.pond;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── header: plain chevron + "Setting" (PNG; CSS circle-buttons not in visual truth)
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: const Icon(Icons.chevron_left, size: 32, color: AppColors.textPrimary),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Setting', // design copy (singular)
                    style: TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.w800, fontSize: 32, height: 39 / 32, color: AppColors.textPrimary),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              const _SectionHeader('Editable'),
              const SizedBox(height: 14),
              const _FieldLabel('Pond name'),
              const SizedBox(height: 7),
              Container(
                height: 51,
                decoration: BoxDecoration(border: Border.all(color: AppColors.neutralBorder), borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _name,
                        focusNode: _nameFocus,
                        readOnly: !_editingName, // Edit pill flips it; Save commits via PondProvider
                        style: const TextStyle(fontFamily: AppFonts.heading, fontSize: 18, color: AppColors.textPrimary),
                        decoration: const InputDecoration(border: InputBorder.none),
                        onSubmitted: (_) => _saveName(),
                      ),
                    ),
                    _Pill(
                      label: _editingName ? 'Save' : 'Edit', // [A] design shows only "Edit"; Save state is our commit path
                      onTap: () {
                        if (_editingName) {
                          setState(() => _editingName = false);
                          _saveName();
                        } else {
                          setState(() => _editingName = true);
                          _nameFocus.requestFocus();
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // ── Pond Parameter pills (design mock values; wire to v_pond_status rows later)
              Container(
                decoration: BoxDecoration(border: Border.all(color: AppColors.neutralBorder), borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Pond Parameter', style: TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.bold, fontSize: 18, height: 25 / 18, color: AppColors.textPrimary)),
                    const SizedBox(height: 10),
                    const Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _ParamPill('DO', '5.5'),
                        _ParamPill('NH3', '0.02'),
                        _ParamPill('NO2', '0.9'),
                        _ParamPill('pH', '7.4'),
                        _ParamPill('Temperature', '35'),
                        _ParamPill('Salinity', '16.5'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const SizedBox(height: 3, child: DecoratedBox(decoration: BoxDecoration(color: AppColors.dividerLight))), // Line 4
              const SizedBox(height: 25),
              const _SectionHeader('Read-only'),
              const SizedBox(height: 14),
              // ── 3 fact cards: volume / stock / area+depth (computed from facts, not stored)
              Row(
                children: [
                  Expanded(child: _FactCard(label: 'Water', value: '${pond.volumeM3.toStringAsFixed(0)}\nm³')),
                  const SizedBox(width: 8),
                  Expanded(child: _FactCard(label: 'Fish', value: '${formatThousands(pond.stockingCount)}\npcs')),
                  const SizedBox(width: 8),
                  Expanded(child: _FactCard(label: 'Area', value: '${pond.areaM2.toStringAsFixed(0)} m²\n${pond.avgDepthM.toStringAsFixed(0)} m')),
                ],
              ),
              const SizedBox(height: 20),
              const _FieldLabel('Time zone'),
              const SizedBox(height: 7),
              // column grant blocks timezone updates (APP_SPEC_ALIGNMENT §2.3) — display-only row,
              // chevron is the design's; editing needs an RPC (not built) [U]
              Container(
                height: 51,
                decoration: BoxDecoration(color: AppColors.fillReadonly, borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.fromLTRB(16, 0, 12, 0),
                child: Row(
                  children: [
                    Text(countryFor(pond.timezone), style: const TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimary)),
                    const Spacer(),
                    Text(utcOffsetLabel(pond.timezone), style: const TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimary)),
                    const SizedBox(width: 8),
                    const Icon(Icons.expand_more, size: 22, color: AppColors.textPrimary),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              // ── Logout (pink pill; signOut flips _AuthGate to SignIn)
              GestureDetector(
                onTap: _logout,
                child: Container(
                  height: 51,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: const Color(0xFFFFEAEA), borderRadius: BorderRadius.circular(8)), // [A] PNG tint, no exported token
                  child: const Text('Logout', style: TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.warnTitle)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.bold, fontSize: 18, height: 25 / 18, color: AppColors.textPrimary));
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.bold, fontSize: 14, height: 19 / 14, color: AppColors.textSecondary));
}

/// White shadowed pill inside a field row (the design's "Edit").
class _Pill extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _Pill({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 29.5, spreadRadius: 2, offset: Offset(0, 2))],
          ),
          child: Text(label, style: const TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
        ),
      );
}

/// Bordered parameter chip: name left, mock value right (figma PNG pills).
class _ParamPill extends StatelessWidget {
  final String name;
  final String value;
  const _ParamPill(this.name, this.value);

  @override
  Widget build(BuildContext context) => Container(
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(border: Border.all(color: AppColors.neutralBorder), borderRadius: BorderRadius.circular(6)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(name, style: const TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
            const SizedBox(width: 6),
            Text(value, style: const TextStyle(fontFamily: AppFonts.heading, fontSize: 13, color: AppColors.textPrimary)),
          ],
        ),
      );
}

/// Read-only fact card (Water / Fish / Area).
class _FactCard extends StatelessWidget {
  final String label;
  final String value;
  const _FactCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Container(
        height: 88,
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(color: AppColors.fillReadonly, borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary)),
            const Spacer(),
            Center(
              child: Text(value, textAlign: TextAlign.center, style: const TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.bold, fontSize: 18, height: 22 / 18, color: AppColors.textPrimary)),
            ),
          ],
        ),
      );
}
