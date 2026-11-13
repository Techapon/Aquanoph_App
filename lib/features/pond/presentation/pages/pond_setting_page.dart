import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:aquanoph/core/theme/app_colors.dart';
import 'package:aquanoph/core/theme/app_fonts.dart';
import 'package:aquanoph/core/utils/country_timezones.dart';
import 'package:aquanoph/features/pond/domain/entities/pond_entity.dart';
import 'package:aquanoph/features/pond/presentation/controller/pond_provider.dart';

/// Pond settings — figma node 304:195 (figma/setting_page/; CSS+SVG+PNG all agree).
/// Layout truth (verified by pixel-sampling the PNG, 2026-11-13):
///  - header: nested blue ellipses + fish photo + "Settings" 24 bold, flanked by
///    two shadowed circles (back, green check = SAVE all edits)
///  - Editable: Pond name, Weight+kg split field, Amount (column grant allows
///    exactly name / avg_weight_g / stocking_count — matches these 3 inputs)
///  - Line 4 divider, then Read-only rows: Species, Pond volume (2-line card),
///    ID, Time zone (gray rows, 18/25 bold #232323)
///  - NO Pond Parameter pills card, NO 3 fact cards, NO Logout (earlier build
///    of those was a misread of this PNG — corrected 2026-11-13)
class PondSettingPage extends StatefulWidget {
  final String userId;
  final PondEntity pond;
  const PondSettingPage({super.key, required this.userId, required this.pond});

  @override
  State<PondSettingPage> createState() => _PondSettingPageState();
}

class _PondSettingPageState extends State<PondSettingPage> {
  late final _name = TextEditingController(text: widget.pond.name);
  late final _weight = TextEditingController(text: _kgText(widget.pond.avgWeightG));
  late final _amount = TextEditingController(text: widget.pond.stockingCount.toString());

  static String _kgText(double g) {
    if (g <= 0) return '';
    final s = (g / 1000).toStringAsFixed(2);
    return s.replaceFirst(RegExp(r'\.?0+$'), ''); // 0.400 -> 0.4
  }

  @override
  void dispose() {
    _name.dispose();
    _weight.dispose();
    _amount.dispose();
    super.dispose();
  }

  /// Green-check header button: commit the 3 grant-allowed columns at once.
  Future<void> _save() async {
    final name = _name.text.trim();
    final kg = double.tryParse(_weight.text.replaceAll(',', '.'));
    final count = int.tryParse(_amount.text.trim());
    if (name.isEmpty || kg == null || kg <= 0 || count == null || count <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name, weight and amount must be filled in')));
      return;
    }
    final ok = await context.read<PondProvider>().update(widget.userId, widget.pond.id, name: name, stockingCount: count, avgWeightG: kg * 1000);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Saved' : 'Save failed')));
  }

  @override
  Widget build(BuildContext context) {
    final pond = widget.pond;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 96, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LogoHeader(save: _save),
              const SizedBox(height: 30),
              const _Heading('Editable'),
              const SizedBox(height: 14),
              const _FieldLabel('Pond name'),
              const SizedBox(height: 7),
              _BorderedField(height: 51, child: _editText(_name)),
              const SizedBox(height: 14),
              const _FieldLabel('Aquatic animal'),
              const SizedBox(height: 7),
              // Weight | kg⌄ split boxes (152 + 81, 7 gap) — unit toggle is design-only [A]
              Row(
                children: [
                  SizedBox(
                    width: 152,
                    child: _BorderedField(
                      height: 51,
                      child: Row(
                        children: [
                          const Text('Weight', style: _roValue),
                          const SizedBox(width: 11),
                          const _VDivider(),
                          Expanded(child: _editText(_weight, digits: true)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 7),
                  SizedBox(
                    width: 81,
                    child: _BorderedField(
                      height: 51,
                      child: const Row(
                        children: [
                          Text('kg', style: _roValue),
                          Spacer(),
                          Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF1E1E1E)),
                          SizedBox(width: 12),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: 185,
                child: _BorderedField(
                  height: 51,
                  child: Row(
                    children: [
                      const Text('Amount', style: _roValue),
                      const SizedBox(width: 7),
                      const _VDivider(),
                      Expanded(child: _editText(_amount, digits: true)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 29),
              const SizedBox(width: double.infinity, height: 3, child: DecoratedBox(decoration: BoxDecoration(color: AppColors.dividerLight))), // Line 4
              const SizedBox(height: 25),
              const _Heading('Read-only'),
              const SizedBox(height: 14),
              const _FieldLabel('Aquatic animal'),
              const SizedBox(height: 7),
              _GrayRow(child: Text('Species : ${_speciesLabel(pond.species)}', style: _roValue)),
              const SizedBox(height: 14),
              const _FieldLabel('Pond volume'),
              const SizedBox(height: 7),
              // 86-tall card with two lines (design y-offsets 12 / 44)
              Container(
                height: 86,
                decoration: const BoxDecoration(color: AppColors.fillReadonly, borderRadius: BorderRadius.all(Radius.circular(8))),
                padding: const EdgeInsets.fromLTRB(17, 12, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Area : ${pond.areaM2.toStringAsFixed(1)} m²', style: _roValue),
                    const SizedBox(height: 7),
                    Text('Average depth : ${pond.avgDepthM.toStringAsFixed(0)} m', style: _roValue),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const _FieldLabel('Device'),
              const SizedBox(height: 7),
              _GrayRow(child: Text('ID : ${pond.deviceId}', style: _roValue)),
              const SizedBox(height: 14),
              const _FieldLabel('Time zone'),
              const SizedBox(height: 7),
              _GrayRow(child: Text(countryFor(pond.timezone), style: _roValue)), // display-only: column grant blocks timezone updates
            ],
          ),
        ),
      ),
    );
  }

  static String _speciesLabel(String species) => species == 'nile_tilapia' ? 'Nile tilapia' : species;

  static const _roValue = TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.w700, fontSize: 18, height: 25 / 18, color: AppColors.textPrimary);

  Widget _editText(TextEditingController c, {bool digits = false}) => TextField(
        controller: c,
        keyboardType: digits ? TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        inputFormatters: digits ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))] : null,
        style: const TextStyle(fontFamily: AppFonts.heading, fontSize: 18, height: 25 / 18, color: AppColors.textPrimary),
        decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
        textAlign: digits ? TextAlign.center : TextAlign.start,
      );
}

/// Nested blue ellipses + fish photo + "Settings", flanked by back & save circles.
class _LogoHeader extends StatelessWidget {
  final VoidCallback save;
  const _LogoHeader({required this.save});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // without this the Stack hugs the 61px fish and everything piles left
      height: 137,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // badge: exact ellipses from figma/decorate/pond.svg (210×44, cx105)
          const Positioned(top: 93, child: CustomPaint(size: Size(210, 44), painter: _BadgePainter())),
          // fish photo sits on the badge (design y0..61, badge 93..137)
          Image.asset('assets/images/fish.png', width: 61, height: 61),
          const Positioned(
            top: 41,
            child: Text('Settings', style: TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.w700, fontSize: 24, height: 33 / 24, color: AppColors.textPrimary)),
          ),
          const Positioned(top: 36, left: -2, child: _CircleButton(icon: Icons.chevron_left)),
          Positioned(top: 36, right: -4, child: _CircleButton(icon: Icons.check, iconColor: const Color(0xFF0BE220), onTap: save)),
        ],
      ),
    );
  }
}

/// Three nested ellipses, exact geometry from figma/decorate/pond.svg.
class _BadgePainter extends CustomPainter {
  const _BadgePainter();

  @override
  void paint(Canvas canvas, Size size) {
    // rx/ry pairs from the svg: (105,22,105,22) (105.7,20.5,82.86,17.5) (105,19.5,53.57,11.5)
    void e(double cx, double cy, double rx, double ry, Color c) => canvas.drawOval(Rect.fromLTWH(cx - rx, cy - ry, rx * 2, ry * 2), Paint()..color = c..isAntiAlias = true);
    e(105, 22, 105, 22, const Color(0xFF38D4FF));
    e(105.7, 20.5, 82.86, 17.5, const Color(0xFF32BDE3));
    e(105, 19.5, 53.57, 11.5, const Color(0xFF2FAFD3));
  }

  @override
  bool shouldRepaint(_BadgePainter oldDelegate) => false;
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;
  const _CircleButton({required this.icon, this.iconColor = const Color(0xFF2A2A2A), this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap ?? () => Navigator.of(context).maybePop(),
        child: Container(
          width: 44,
          height: 43,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xF8FDFDFD),
            shape: BoxShape.circle,
            boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 29.5, spreadRadius: -2, offset: Offset(0, 2))],
          ),
          child: Icon(icon, size: icon == Icons.check ? 24 : 28, color: iconColor),
        ),
      );
}

/// 354×h white bordered input box (border 1 #D9D9D9 r8, inner pad l17 r16).
class _BorderedField extends StatelessWidget {
  final double height;
  final Widget child;
  const _BorderedField({required this.height, required this.child});

  @override
  Widget build(BuildContext context) => Container(
        height: height,
        decoration: BoxDecoration(border: Border.all(color: AppColors.neutralBorder), borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.fromLTRB(17, 0, 16, 0),
        alignment: Alignment.centerLeft,
        child: child,
      );
}

class _VDivider extends StatelessWidget {
  const _VDivider();
  @override
  Widget build(BuildContext context) => const SizedBox(width: 1, height: 51, child: DecoratedBox(decoration: BoxDecoration(color: AppColors.neutralBorder)));
}

/// 354×51 gray read-only row, 18/25 bold text at left pad 17.
class _GrayRow extends StatelessWidget {
  final Widget child;
  const _GrayRow({required this.child});

  @override
  Widget build(BuildContext context) => Container(
        height: 51,
        decoration: const BoxDecoration(color: AppColors.fillReadonly, borderRadius: BorderRadius.all(Radius.circular(8))),
        padding: const EdgeInsets.fromLTRB(17, 0, 16, 0),
        alignment: Alignment.centerLeft,
        child: child,
      );
}

class _Heading extends StatelessWidget {
  final String text;
  const _Heading(this.text);
  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.w700, fontSize: 18, height: 25 / 18, color: AppColors.textPrimary));
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.w700, fontSize: 14, height: 19 / 14, color: AppColors.textSecondary));
}
