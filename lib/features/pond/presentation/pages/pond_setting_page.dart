import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:aquanoph/core/theme/app_colors.dart';
import 'package:aquanoph/core/theme/app_fonts.dart';
import 'package:aquanoph/core/utils/country_timezones.dart';
import 'package:aquanoph/features/pond/domain/entities/pond_entity.dart';
import 'package:aquanoph/features/pond/presentation/controller/pond_provider.dart';
import 'package:aquanoph/features/pond/presentation/pages/ponds_page.dart' show speciesLabel;
import 'package:aquanoph/shared/widgets/app_text_field.dart';
import 'package:aquanoph/shared/widgets/gradient_button.dart';

/// Figma 304:195 — editable: name / count / weight [V: column grant], rest read-only.
class PondSettingPage extends StatefulWidget {
  final String userId;
  final PondEntity pond;
  const PondSettingPage({super.key, required this.userId, required this.pond});

  @override
  State<PondSettingPage> createState() => _PondSettingPageState();
}

class _PondSettingPageState extends State<PondSettingPage> {
  late final _name = TextEditingController(text: widget.pond.name);
  late final _count = TextEditingController(text: widget.pond.stockingCount.toString());
  late final _weight = TextEditingController(text: (widget.pond.avgWeightG / 1000).toStringAsFixed(3)); // design shows kg; DB stores g

  @override
  void dispose() {
    _name.dispose();
    _count.dispose();
    _weight.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final count = int.tryParse(_count.text.trim());
    final weightKg = double.tryParse(_weight.text.trim().replaceAll(',', '.'));
    if (_name.text.trim().isEmpty || count == null || count <= 0 || weightKg == null || weightKg <= 0) return;
    final ok = await context.read<PondProvider>().update(
          widget.userId,
          widget.pond.id,
          name: _name.text.trim(),
          stockingCount: count,
          avgWeightG: weightKg * 1000,
        );
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<PondProvider>().isLoading;
    final pond = widget.pond;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: const Text('Settings', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: AppFonts.heading, color: AppColors.textPrimary)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _SectionHeader('Editable'),
              const SizedBox(height: 16),
              AppTextField(label: 'Pond name', controller: _name),
              const SizedBox(height: 16),
              AppTextField(label: 'Aquatic animals count', keyboardType: TextInputType.number, controller: _count),
              const SizedBox(height: 16),
              AppTextField(label: 'Average weight', unit: 'kg', keyboardType: TextInputType.number, controller: _weight),
              const SizedBox(height: 24),
              const Divider(thickness: 1.5, color: AppColors.neutralBorder),
              const SizedBox(height: 16),
              const _SectionHeader('Read-only'),
              const SizedBox(height: 16),
              _roRow('Species', speciesLabel(pond.species)),
              _roRow('Area', '${pond.areaM2.toStringAsFixed(1)}  m²'),
              _roRow('Average depth', '${pond.avgDepthM.toStringAsFixed(2)}  m'),
              _roRow('Volume', '${pond.volumeM3.toStringAsFixed(1)}  m³'),
              _roRow('Device', pond.deviceId.isEmpty ? '—' : pond.deviceId),
              _roRow('Time zone', countryFor(pond.timezone)),
              const SizedBox(height: 24),
              GradientButton(label: 'Save', loading: loading, onPressed: _save),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // design: rgba(244,244,244,0.85) row, bold label + regular value inline, r8 h51
  Widget _roRow(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          height: 51,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: AppColors.fillReadonly),
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: '$label :', style: const TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
                TextSpan(text: '  $value', style: const TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.w400, fontSize: 16, color: AppColors.textPrimary)),
              ],
            ),
          ),
        ),
      );
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: AppFonts.heading, color: AppColors.textPrimary),
      );
}
