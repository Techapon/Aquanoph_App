import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:aquanoph/core/theme/app_colors.dart';
import 'package:aquanoph/core/theme/app_fonts.dart';
import 'package:aquanoph/core/utils/country_timezones.dart';
import 'package:aquanoph/features/pond/domain/entities/pond_draft.dart';
import 'package:aquanoph/features/pond/presentation/controller/pond_provider.dart';
import 'package:aquanoph/shared/widgets/app_select_field.dart';
import 'package:aquanoph/shared/widgets/app_text_field.dart';
import 'package:aquanoph/shared/widgets/success_dialog.dart';

/// Figma 61:536 (step 1) + 154:139 (step 2). Step 3 + success screen could not be read
/// (Figma MCP rate limit) -> derived: [A] step 3 = device id + timezone, no success page (pop back to list).
/// Species is a Select with the single v1 option "Nile tilapia" [V: CLAUDE.md §1];
/// not sent to the RPC (DB default nile_tilapia). Stocking date IS required by create_pond [V signature].
class AddPondPage extends StatefulWidget {
  final String userId;
  const AddPondPage({super.key, required this.userId});

  @override
  State<AddPondPage> createState() => _AddPondPageState();
}

class _AddPondPageState extends State<AddPondPage> {
  int _step = 0;
  final _name = TextEditingController();
  final _area = TextEditingController();
  final _depth = TextEditingController();
  final _count = TextEditingController();
  final _weight = TextEditingController();
  // ponytail: curated ASEAN + UTC zones; backend accepts any IANA id — add a search picker if users need more.
  String _species = 'Nile tilapia';
  String _timezone = 'Thailand'; // picker holds the country name; timezoneFor() converts to IANA on save
  final _stockingDate = TextEditingController(text: DateTime.now().toIso8601String().substring(0, 10));
  final _device = TextEditingController();

  String? _stepError;

  @override
  void dispose() {
    for (final c in [_name, _area, _depth, _count, _weight, _stockingDate, _device]) {
      c.dispose();
    }
    super.dispose();
  }

  double? _num(TextEditingController c) => double.tryParse(c.text.trim().replaceAll(',', '.'));

  bool _validateStep() {
    _stepError = null;
    if (_step == 0) {
      if (_name.text.trim().isEmpty) return _fail('Pond name is required');
      if ((_num(_area) ?? 0) <= 0 || (_num(_depth) ?? 0) <= 0) return _fail('Area and depth must be greater than 0');
    } else if (_step == 1) {
      if ((_num(_count) ?? 0) <= 0 || (_num(_weight) ?? 0) <= 0) return _fail('Count and average weight must be greater than 0');
      if (_stockingDate.text.isEmpty) return _fail('Stocking date is required');
    } else {
      if (_device.text.trim().isEmpty) return _fail('Device ID is required');
    }
    return true;
  }

  bool _fail(String msg) {
    setState(() => _stepError = msg);
    return false;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
    );
    if (picked != null) _stockingDate.text = picked.toIso8601String().substring(0, 10);
  }

  Future<void> _create() async {
    if (!_validateStep()) return;
    final draft = PondDraft(
      name: _name.text.trim(),
      areaM2: _num(_area)!,
      avgDepthM: _num(_depth)!,
      stockingCount: (_num(_count) ?? 0).round(),
      avgWeightG: _num(_weight)! * 1000, // UI is kg, DB/RPC is grams
      stockingDate: DateTime.parse(_stockingDate.text),
      deviceId: _device.text.trim(),
      timezone: timezoneFor(_timezone),
    );
    final ok = await context.read<PondProvider>().create(widget.userId, draft);
    if (!ok || !mounted) return;
    // Figma 109:1176 success popup (design copy is the default now), then back to the list.
    await showSuccessDialog(context);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final ponds = context.watch<PondProvider>();
    final isLast = _step == 2;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => _step == 0 ? Navigator.of(context).pop() : setState(() => _step--),
        ),
        title: Text(
          _step == 0 ? 'Create new pond' : 'Create new pond · ${_step + 1}/3',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: AppFonts.heading, color: AppColors.textPrimary),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(_subtitle(), style: const TextStyle(fontSize: 16, fontFamily: AppFonts.heading, color: AppColors.textSecondary)),
              const SizedBox(height: 32),
              ..._fields(),
              if (_stepError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(_stepError!, style: const TextStyle(fontSize: 14, fontFamily: AppFonts.body, color: AppColors.danger)),
                ),
              if (ponds.error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(ponds.error!, style: const TextStyle(fontSize: 14, fontFamily: AppFonts.body, color: AppColors.danger)),
                ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: _darkButton(
                  isLast ? 'Create' : 'Next',
                  ponds.isLoading
                      ? null
                      : () {
                          if (isLast) {
                            _create();
                          } else if (_validateStep()) {
                            setState(() => _step++);
                          }
                        },
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  String _subtitle() => switch (_step) {
        0 => 'Enter details for your new pond.',
        1 => 'Tell us about your stock.',
        _ => 'Connect your buoy device.',
      };

  List<Widget> _fields() {
    switch (_step) {
      case 0:
        return [
          AppTextField(label: 'Pond name', hint: 'My Pond', controller: _name),
          const SizedBox(height: 16),
          AppTextField(label: 'Pond size · area', hint: 'Area', unit: 'm²', keyboardType: TextInputType.number, controller: _area),
          const SizedBox(height: 16),
          AppTextField(label: 'Pond size · average depth', hint: 'Average depth', unit: 'm', keyboardType: TextInputType.number, controller: _depth),
        ];
      case 1:
        return [
          AppSelectField(
            label: 'Aquatic species',
            value: _species,
            options: const ['Nile tilapia'],
            onChanged: (v) => setState(() => _species = v),
          ),
          const SizedBox(height: 16),
          AppTextField(label: 'Aquatic animals count', hint: '0', keyboardType: TextInputType.number, controller: _count),
          const SizedBox(height: 16),
          AppTextField(label: 'Average weight', hint: '0.0', unit: 'kg', keyboardType: TextInputType.number, controller: _weight),
          const SizedBox(height: 16),
          AppTextField(label: 'Stocking date', hint: 'YYYY-MM-DD', readOnly: true, onTap: _pickDate, controller: _stockingDate),
        ];
      default:
        return [
          AppTextField(label: 'Device', hint: 'Buoy device ID (must exist in devices)', controller: _device),
          const SizedBox(height: 16),
          AppSelectField(
            label: 'Time zone',
            value: _timezone,
            options: countryToTimezone.keys.toList(),
            onChanged: (v) => setState(() => _timezone = v),
          ),
        ];
    }
  }

  // design 154:159: solid #2A2A2A, r8, 88x40, white Nunito 16 + arrow
  Widget _darkButton(String label, VoidCallback? onPressed) => ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkButton,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          minimumSize: const Size(88, 40),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: const TextStyle(fontSize: 16, fontFamily: AppFonts.heading)),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward, size: 14, color: Colors.white),
          ],
        ),
      );
}
