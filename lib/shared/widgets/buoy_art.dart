import 'package:flutter/material.dart';

/// "Water Quality Monitoring Device" (+ optional water ellipses) redrawn from % insets in
/// figma/pond_page/Ponds.css (Group 87/5, node "Water Quality Monitoring Device") and
/// figma/add_pond_device/css.txt. ponytail: hand-drawn because the vector was never
/// exported as asset; swap for a PNG when one lands in figma/.

/// Device only. Home/list use 56x45, wizard step 3 uses 71x58 (slightly stretched in design).
class BuoyDeviceArt extends StatelessWidget {
  final double width;
  final double height;
  const BuoyDeviceArt({super.key, this.width = 56, this.height = 45});

  @override
  Widget build(BuildContext context) {
    double x(double pct) => width * pct;
    double y(double pct) => height * pct;
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(left: 0, top: y(0.7037), width: width, height: y(1 - 0.7037), child: const ColoredBox(color: Color(0xFFD9D9D9))), // deck
          Positioned(left: x(0.0588), top: y(0.8148), width: x(0.2353), height: y(1 - 0.8148 - 0.037), child: const ColoredBox(color: Color(0xFF6E6E6E))), // leg L
          Positioned(left: width - x(0.0588) - x(0.2353), top: y(0.8148), width: x(0.2353), height: y(1 - 0.8148 - 0.037), child: const ColoredBox(color: Color(0xFF6E6E6E))), // leg R
          Positioned(left: x(0.1176), top: y(0.2593), width: x(1 - 2 * 0.1176), height: y(1 - 0.2593 - 0.2963), child: const ColoredBox(color: Color(0xFF414141))), // body
          Positioned(left: x(0.8235), top: 0, width: x(1 - 0.8235 - 0.1471), height: y(0.2593), child: const ColoredBox(color: Color(0xFFA4A4A4))), // mast
        ],
      ),
    );
  }
}

/// 117x65 group: 3 concentric ellipses (#38D4FF/#32BDE3/#2FAFD3) + device at x32.
class BuoyWithWater extends StatelessWidget {
  const BuoyWithWater({super.key});

  static Widget _e(double w, double h, Color c) => Container(width: w, height: h, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(999)));

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 117,
      height: 65,
      child: const Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(left: 0, top: 19, child: _WaterEllipses()),
          Positioned(left: 32, top: 0, child: BuoyDeviceArt()),
        ],
      ),
    );
  }
}

class _WaterEllipses extends StatelessWidget {
  const _WaterEllipses();
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        BuoyWithWater._e(117, 46, const Color(0xFF38D4FF)),
        BuoyWithWater._e(92, 37, const Color(0xFF32BDE3)),
        BuoyWithWater._e(60, 24, const Color(0xFF2FAFD3)),
      ],
    );
  }
}
