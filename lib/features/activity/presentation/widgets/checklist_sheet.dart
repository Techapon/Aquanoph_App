import 'package:flutter/material.dart';

import 'package:aquanoph/core/theme/app_colors.dart';
import 'package:aquanoph/core/theme/app_fonts.dart';
import 'package:aquanoph/core/utils/pond_time.dart';
import 'package:aquanoph/features/activity/domain/entities/activity_entity.dart';
import 'package:aquanoph/features/activity/presentation/controller/activity_provider.dart';
import 'package:aquanoph/features/pond/domain/entities/pond_entity.dart';
import 'package:aquanoph/shared/widgets/success_dialog.dart';

/// Entry point: opens the feeding/aeration checklist as a bottom sheet.
Future<void> showChecklistSheet(
  BuildContext context, {
  required PondEntity pond,
  required ActivityType type,
  required String timezone,
  required VoidCallback onSaved,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ChecklistSheet(
      pond: pond,
      type: type,
      timezone: timezone,
      onSaved: onSaved,
    ),
  );
}

class _ChecklistSheet extends StatefulWidget {
  final PondEntity pond;
  final ActivityType type;
  final String timezone;
  final VoidCallback onSaved;
  const _ChecklistSheet({
    required this.pond,
    required this.type,
    required this.timezone,
    required this.onSaved,
  });

  @override
  State<_ChecklistSheet> createState() => _ChecklistSheetState();
}

class _ChecklistSheetState extends State<_ChecklistSheet> {
  late final ActivityProvider _provider;
  bool _loaded = false;
  // working status per activity id
  final Map<String, ActivityStatus> _work = {};
  final Set<String> _changed = {};

  @override
  void initState() {
    super.initState();
    _provider = ActivityProvider();
    _provider.load(widget.pond.id, widget.timezone).then((_) {
      if (!mounted) return;
      setState(() {
        _loaded = true;
        for (final a in _ofType(_provider.activities)) {
          _work[a.id] = a.status;
        }
      });
    });
  }

  List<ActivityEntity> _ofType(List<ActivityEntity> list) =>
      list.where((a) => a.type == widget.type).toList();

  bool get _isFeeding => widget.type == ActivityType.feeding;

  String get _title => _isFeeding
      ? "Today's Feeding Schedule"
      : "Today's Aeration Schedule";

  @override
  Widget build(BuildContext context) {
    final items = _loaded ? _ofType(_provider.activities) : <ActivityEntity>[];
    return PopScope(
      canPop: _changed.isEmpty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final discard = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Discard changes?'),
            content: const Text('You have unsaved changes.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Keep editing')),
              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Discard')),
            ],
          ),
        );
        if (discard == true && mounted) {
          setState(() => _changed.clear());
          Navigator.pop(context);
        }
      },
      child: Container(
        height: 373,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // drag handle
            const SizedBox(height: 20),
            Center(
              child: Container(
                width: 111,
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            // header row: title + more btn
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _title,
                      style: const TextStyle(
                        fontFamily: AppFonts.heading,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        height: 25 / 18,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _openMore,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [
                          BoxShadow(color: Color(0x1A000000), blurRadius: 29.5, spreadRadius: -2, offset: Offset(0, 2)),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.more_horiz, size: 24, color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(22, 6, 22, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Check the box after you finish the task.',
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontSize: 14,
                    height: 17 / 14,
                    color: Color(0xFF707070),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _loaded
                  ? (items.isEmpty
                      ? const Center(child: Text('Nothing logged today', style: TextStyle(fontFamily: AppFonts.body, fontSize: 12, color: AppColors.textMuted)))
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          itemCount: items.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (_, i) => _row(items[i]),
                        ))
                  : const Center(child: CircularProgressIndicator()),
            ),
            // Save button
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 16),
              child: SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: (_changed.isEmpty || _provider.busy) ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gradientStart,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _provider.busy
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text('Save${_changed.isEmpty ? '' : ' (${_changed.length})'}',
                          style: const TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(ActivityEntity a) {
    final checked = _work[a.id] == ActivityStatus.done;
    final timeText = _isFeeding
        ? formatClock(pondLocal(a.startTime, widget.timezone))
        : '${formatClock(pondLocal(a.startTime, widget.timezone))} - ${a.endTime == null ? '' : formatClock(pondLocal(a.endTime!, widget.timezone))}.';
    return Container(
      height: 51,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.neutralBorder, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // time
          SizedBox(
            width: 110,
            child: Text(
              timeText,
              style: const TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(width: 1.5, height: 31, color: const Color(0xFFD3D3D3)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _isFeeding
                  ? 'Feed the shrimp ${_fmtNum(a.quantityKg)} kg.'
                  : 'Intensity: ${_intensity(a)}%',
              style: const TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                final cur = _work[a.id] ?? ActivityStatus.pending;
                final next = cur == ActivityStatus.done ? ActivityStatus.pending : ActivityStatus.done;
                _work[a.id] = next;
                if (next == a.status) {
                  _changed.remove(a.id);
                } else {
                  _changed.add(a.id);
                }
              });
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFC7C7C7), width: 1.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: checked
                  ? CustomPaint(painter: _GreenCheckPainter())
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  String _fmtNum(double? v) {
    if (v == null) return '0';
    if (v == v.roundToDouble()) return v.toStringAsFixed(0);
    return v.toString();
  }

  String _intensity(ActivityEntity a) => '30'; // [A] no intensity field in schema; placeholder

  Future<void> _save() async {
    final changes = _changed.map((id) => {
          'op': 'update',
          'activity': {'id': id, 'status': _work[id]!.name},
        }).toList();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Save changes?'),
        content: Text('Update ${changes.length} item(s)?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
        ],
      ),
    );
    if (ok != true) return;
    final success = await _provider.saveChecklist(changes);
    if (!mounted) return;
    if (success) {
      await showSuccessDialog(context, title: 'Save success!', subtitle: 'Activities updated.', statusLabel: widget.pond.name, statusSuffix: ' saved.');
      widget.onSaved();
      if (mounted) Navigator.pop(context);
    } else {
      await showSuccessDialog(context, title: 'Save failed', subtitle: _provider.error ?? 'Could not save.', statusLabel: widget.pond.name, statusSuffix: ' not saved.', failed: true);
    }
  }

  Future<void> _openMore() async {
    final action = await showDialog<String>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 20),
        child: _MoreMenuSheet(onPick: (v) => Navigator.pop(ctx, v)),
      ),
    );
    if (action == null || !mounted) return;
    switch (action) {
      case 'edit':
        await _openEdit();
        break;
      case 'add':
        await _openAdd();
        break;
      case 'apply':
        await _openApply();
        break;
      case 'delete':
        await _deleteAll();
        break;
    }
  }

  Future<void> _openEdit() async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: _EditScheduleSheet(
          pond: widget.pond,
          type: widget.type,
          timezone: widget.timezone,
          provider: _provider,
          onSaved: () {
            _provider.load(widget.pond.id, widget.timezone).then((_) {
              if (!mounted) return;
              setState(() {
                for (final a in _ofType(_provider.activities)) {
                  _work[a.id] = a.status;
                }
                _changed.clear();
              });
            });
            widget.onSaved();
            Navigator.pop(ctx);
          },
        ),
      ),
    );
  }

  Future<void> _openAdd() async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: _AddActivitySheet(
          pond: widget.pond,
          type: widget.type,
          timezone: widget.timezone,
          provider: _provider,
          onCreated: () {
            _provider.load(widget.pond.id, widget.timezone).then((_) {
              if (!mounted) return;
              setState(() {
                for (final a in _ofType(_provider.activities)) {
                  _work[a.id] = a.status;
                }
                _changed.clear();
              });
            });
            widget.onSaved();
            Navigator.pop(ctx);
          },
        ),
      ),
    );
  }

  Future<void> _openApply() async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: _ApplyToOtherDaySheet(
          pond: widget.pond,
          type: widget.type,
          timezone: widget.timezone,
          provider: _provider,
          onDone: () {
            _provider.load(widget.pond.id, widget.timezone).then((_) {
              if (!mounted) return;
              setState(() {
                for (final a in _ofType(_provider.activities)) {
                  _work[a.id] = a.status;
                }
                _changed.clear();
              });
            });
            widget.onSaved();
            Navigator.pop(ctx);
          },
        ),
      ),
    );
  }

  Future<void> _deleteAll() async {
    final items = _ofType(_provider.activities);
    if (items.isEmpty) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete all activities?'),
        content: Text('Delete ${items.length} ${_isFeeding ? 'feeding' : 'aeration'} item(s)?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: AppColors.danger))),
        ],
      ),
    );
    if (ok != true) return;
    for (final a in items) {
      await _provider.delete(a.id);
    }
    if (!mounted) return;
    setState(() {
      _work.clear();
      _changed.clear();
    });
    widget.onSaved();
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }
}

class _MoreMenuSheet extends StatelessWidget {
  final ValueChanged<String> onPick;
  const _MoreMenuSheet({required this.onPick});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      height: 295,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          _item(Icons.edit_outlined, 'Edit Schedule', 'edit', onPick),
          _divider(),
          _item(Icons.add, 'Add Activities', 'add', onPick),
          _divider(),
          _item(Icons.calendar_month_outlined, 'Apply schedule to other day', 'apply', onPick),
          _divider(),
          _item(Icons.delete_outline, 'Delete Activities', 'delete', onPick, red: true),
        ],
      ),
    );
  }

  Widget _divider() => Container(height: 2, color: const Color(0xFFD9D9D9));

  Widget _item(IconData icon, String label, String value, ValueChanged<String> onPick, {bool red = false}) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onPick(value),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Icon(icon, size: 24, color: red ? AppColors.danger : Colors.black),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppFonts.heading,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: red ? AppColors.danger : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GreenCheckPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFF0BE220)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(size.width * 0.28, size.height * 0.5)
      ..lineTo(size.width * 0.47, size.height * 0.7)
      ..lineTo(size.width * 0.8, size.height * 0.3);
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

String _dbType(ActivityType t) => switch (t) {
      ActivityType.feeding => 'feeding',
      ActivityType.aeration => 'aeration',
      ActivityType.waterChange => 'water_change',
      ActivityType.alkalinity => 'alkalinity',
      ActivityType.lime => 'lime',
      ActivityType.probiotic => 'probiotic',
      ActivityType.other => 'other',
      ActivityType.unknown => 'other',
    };

String _fmtTod(TimeOfDay t) {
  final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
  final m = t.minute.toString().padLeft(2, '0');
  return '$h:$m ${t.period == DayPeriod.am ? 'AM' : 'PM'}';
}

TimeOfDay _todFromDateTime(DateTime utc, String tz) {
  final local = pondLocal(utc, tz);
  return TimeOfDay(hour: local.hour, minute: local.minute);
}

DateTime _localToUtc(DateTime localWall, String tz) {
  final off = ianaUtcOffset[tz] ?? Duration.zero;
  final base = DateTime.utc(localWall.year, localWall.month, localWall.day, localWall.hour, localWall.minute);
  return base.subtract(off);
}

// ---------- Add Activity sheet ----------
class _AddActivitySheet extends StatefulWidget {
  final PondEntity pond;
  final ActivityType type;
  final String timezone;
  final ActivityProvider provider;
  final VoidCallback onCreated;
  const _AddActivitySheet({
    required this.pond,
    required this.type,
    required this.timezone,
    required this.provider,
    required this.onCreated,
  });

  @override
  State<_AddActivitySheet> createState() => _AddActivitySheetState();
}

class _AddActivitySheetState extends State<_AddActivitySheet> {
  late ActivityType _type;
  final _kgCtrl = TextEditingController();
  TimeOfDay _time = TimeOfDay.now();
  TimeOfDay _start = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay _end = const TimeOfDay(hour: 16, minute: 0);
  String _fraction = '0.25';
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _type = widget.type;
    final now = DateTime.now();
    final local = pondLocal(now.toUtc(), widget.timezone);
    _time = TimeOfDay(hour: local.hour, minute: local.minute);
    _start = TimeOfDay(hour: local.hour, minute: local.minute);
    _end = TimeOfDay(hour: (local.hour + 2) % 24, minute: local.minute);
  }

  @override
  void dispose() {
    _kgCtrl.dispose();
    super.dispose();
  }

  bool get _isFeeding => _type == ActivityType.feeding;
  bool get _isAeration => _type == ActivityType.aeration;
  bool get _isWaterChange => _type == ActivityType.waterChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 349,
      height: _isAeration ? 312 : 380,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(21, 21, 21, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Add activity', style: TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimary)),
                const SizedBox(height: 12),
                // type selector
                _label('Activity'),
                const SizedBox(height: 8),
                _selectType(),
                const SizedBox(height: 12),
                if (_isFeeding || _type == ActivityType.alkalinity || _type == ActivityType.lime || _type == ActivityType.probiotic || _type == ActivityType.other) ...[
                  _label('Active time'),
                  const SizedBox(height: 8),
                  _timeInput(_time, (t) => setState(() => _time = t)),
                  const SizedBox(height: 12),
                  if (_isFeeding || _type == ActivityType.alkalinity || _type == ActivityType.lime || _type == ActivityType.probiotic) ...[
                    _label('Quantity'),
                    const SizedBox(height: 8),
                    _kgInput(),
                    const SizedBox(height: 12),
                  ],
                ],
                if (_isAeration) ...[
                  _label('Active time'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _timeInput(_start, (t) => setState(() => _start = t), hint: 'Start with')),
                      const SizedBox(width: 8),
                      Expanded(child: _timeInput(_end, (t) => setState(() => _end = t), hint: 'End with')),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                if (_isWaterChange) ...[
                  _label('Active time'),
                  const SizedBox(height: 8),
                  _timeInput(_time, (t) => setState(() => _time = t)),
                  const SizedBox(height: 12),
                  _label('Fraction'),
                  const SizedBox(height: 8),
                  _fractionSelect(),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
          Positioned(
            left: (349 - 304) / 2,
            bottom: 21,
            child: SizedBox(
              width: 304,
              height: 40,
              child: ElevatedButton(
                onPressed: _busy ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gradientStart,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _busy
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Add Activity', style: TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String t) => Text(t, style: const TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textSecondary));

  Widget _selectType() {
    final opts = ['feeding', 'aeration', 'water_change', 'alkalinity', 'lime', 'probiotic', 'other'];
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.neutralBorder, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _dbType(_type),
          isExpanded: true,
          items: opts.map((o) => DropdownMenuItem(value: o, child: Text(o, style: const TextStyle(fontFamily: AppFonts.heading, fontSize: 16, color: AppColors.textPrimary)))).toList(),
          onChanged: (v) {
            if (v == null) return;
            setState(() {
              _type = _typeFromDb(v);
            });
          },
        ),
      ),
    );
  }

  ActivityType _typeFromDb(String v) => switch (v) {
        'feeding' => ActivityType.feeding,
        'aeration' => ActivityType.aeration,
        'water_change' => ActivityType.waterChange,
        'alkalinity' => ActivityType.alkalinity,
        'lime' => ActivityType.lime,
        'probiotic' => ActivityType.probiotic,
        _ => ActivityType.other,
      };

  Widget _timeInput(TimeOfDay value, ValueChanged<TimeOfDay> onChanged, {String? hint}) {
    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(context: context, initialTime: value);
        if (picked != null) onChanged(picked);
      },
      child: Container(
        height: 43,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.neutralBorder, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(child: Text(_fmtTod(value), style: const TextStyle(fontFamily: AppFonts.heading, fontSize: 16, color: AppColors.textPrimary))),
            const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _kgInput() {
    return Container(
      width: 140,
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.neutralBorder, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _kgCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(border: InputBorder.none, hintText: '0.0', hintStyle: TextStyle(fontFamily: AppFonts.body, fontSize: 16, color: AppColors.textHint)),
              style: const TextStyle(fontFamily: AppFonts.heading, fontSize: 16, color: AppColors.textPrimary),
            ),
          ),
          const Text('kg', style: TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _fractionSelect() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.neutralBorder, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _fraction,
          isExpanded: true,
          items: const [
            DropdownMenuItem(value: '0.25', child: Text('1/4')),
            DropdownMenuItem(value: '0.5', child: Text('1/2')),
            DropdownMenuItem(value: '0.75', child: Text('3/4')),
          ],
          onChanged: (v) => setState(() => _fraction = v ?? '0.25'),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _busy = true);
    try {
      final now = DateTime.now();
      final wall = DateTime(now.year, now.month, now.day, _time.hour, _time.minute);
      final utc = _localToUtc(wall, widget.timezone);
      final activity = <String, dynamic>{
        'type': _dbType(_type),
        'status': 'pending',
        'startTime': utc.toIso8601String(),
        'source': 'user',
      };
      if (_isFeeding || _type == ActivityType.alkalinity || _type == ActivityType.lime || _type == ActivityType.probiotic) {
        final kg = double.tryParse(_kgCtrl.text.replaceAll(',', '.'));
        activity['quantityKg'] = kg;
      }
      if (_isAeration) {
        final startWall = DateTime(now.year, now.month, now.day, _start.hour, _start.minute);
        final endWall = DateTime(now.year, now.month, now.day, _end.hour, _end.minute);
        activity['startTime'] = _localToUtc(startWall, widget.timezone).toIso8601String();
        activity['endTime'] = _localToUtc(endWall, widget.timezone).toIso8601String();
      }
      if (_isWaterChange) {
        activity['fraction'] = double.tryParse(_fraction);
      }
      final id = await widget.provider.upsert(activity);
      if (id != null && mounted) {
        await showSuccessDialog(context, title: 'Save success!', subtitle: 'Activity added.', statusLabel: widget.pond.name, statusSuffix: ' saved.');
        widget.onCreated();
        if (mounted) Navigator.pop(context);
      } else if (mounted) {
        await showSuccessDialog(context, title: 'Save failed', subtitle: widget.provider.error ?? 'Could not add.', statusLabel: widget.pond.name, statusSuffix: ' not saved.', failed: true);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

// ---------- Edit Schedule sheet ----------
class _EditScheduleSheet extends StatefulWidget {
  final PondEntity pond;
  final ActivityType type;
  final String timezone;
  final ActivityProvider provider;
  final VoidCallback onSaved;
  const _EditScheduleSheet({
    required this.pond,
    required this.type,
    required this.timezone,
    required this.provider,
    required this.onSaved,
  });

  @override
  State<_EditScheduleSheet> createState() => _EditScheduleSheetState();
}

class _EditScheduleSheetState extends State<_EditScheduleSheet> {
  late List<ActivityEntity> _items;
  late Map<String, TimeOfDay> _times;
  late Map<String, TimeOfDay> _starts;
  late Map<String, TimeOfDay> _ends;
  late Map<String, TextEditingController> _kgCtrls;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _items = widget.provider.activities.where((a) => a.type == widget.type).toList();
    _times = {for (final a in _items) a.id: _todFromDateTime(a.startTime, widget.timezone)};
    _starts = {for (final a in _items) a.id: _todFromDateTime(a.startTime, widget.timezone)};
    _ends = {for (final a in _items) a.id: a.endTime == null ? const TimeOfDay(hour: 16, minute: 0) : _todFromDateTime(a.endTime!, widget.timezone)};
    _kgCtrls = {for (final a in _items) a.id: TextEditingController(text: a.quantityKg == null ? '' : _fmtNum(a.quantityKg))};
  }

  @override
  void dispose() {
    for (final c in _kgCtrls.values) c.dispose();
    super.dispose();
  }

  bool get _isFeeding => widget.type == ActivityType.feeding;
  bool get _isAeration => widget.type == ActivityType.aeration;

  String _fmtNum(double? v) {
    if (v == null) return '';
    if (v == v.roundToDouble()) return v.toStringAsFixed(0);
    return v.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 373,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Center(child: Container(width: 111, height: 6, decoration: BoxDecoration(color: const Color(0xFFD9D9D9), borderRadius: BorderRadius.circular(8)))),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(_isFeeding ? "Today's Feeding Schedule" : "Today's Aeration Schedule", style: const TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimary)),
                ),
                SizedBox(
                  width: 63,
                  height: 28,
                  child: TextButton(
                    onPressed: _busy ? null : _save,
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), backgroundColor: Colors.white, shadowColor: Colors.black26, elevation: 2),
                    child: ShaderMask(
                      shaderCallback: (b) => const LinearGradient(colors: [AppColors.gradientStart, AppColors.gradientEnd]).createShader(b),
                      child: const Text('save', style: TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              itemCount: _items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _row(_items[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(ActivityEntity a) {
    return Container(
      height: 51,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.neutralBorder, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // time picker box
          GestureDetector(
            onTap: () async {
              final picked = await showTimePicker(context: context, initialTime: _isFeeding ? _times[a.id]! : _starts[a.id]!);
              if (picked == null) return;
              setState(() {
                if (_isFeeding) _times[a.id] = picked;
                else _starts[a.id] = picked;
              });
            },
            child: Container(
              width: 71,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.neutralBorder, width: 1.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _fmtTod(_isFeeding ? _times[a.id]! : _starts[a.id]!),
                style: const TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textPrimary),
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (_isAeration) ...[
            GestureDetector(
              onTap: () async {
                final picked = await showTimePicker(context: context, initialTime: _ends[a.id]!);
                if (picked == null) return;
                setState(() => _ends[a.id] = picked);
              },
              child: Container(
                width: 71,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.neutralBorder, width: 1.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_fmtTod(_ends[a.id]!), style: const TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textPrimary)),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              _isFeeding ? 'Feed the shrimp' : 'Intensity',
              style: const TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
            ),
          ),
          if (_isFeeding)
            SizedBox(
              width: 35,
              height: 32,
              child: TextField(
                controller: _kgCtrls[a.id],
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.center,
                decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.zero),
                style: const TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
              ),
            ),
          Text('kg.', style: const TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _busy = true);
    try {
      final changes = <Map<String, dynamic>>[];
      for (final a in _items) {
        final wall = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, (_isFeeding ? _times[a.id]! : _starts[a.id]!).hour, (_isFeeding ? _times[a.id]! : _starts[a.id]!).minute);
        final utc = _localToUtc(wall, widget.timezone);
        final act = <String, dynamic>{'id': a.id, 'startTime': utc.toIso8601String()};
        if (_isAeration) {
          final endWall = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, _ends[a.id]!.hour, _ends[a.id]!.minute);
          act['endTime'] = _localToUtc(endWall, widget.timezone).toIso8601String();
        }
        if (_isFeeding) {
          final kg = double.tryParse(_kgCtrls[a.id]!.text.replaceAll(',', '.'));
          act['quantityKg'] = kg;
        }
        changes.add({'op': 'update', 'activity': act});
      }
      final ok = await widget.provider.saveChecklist(changes);
      if (!mounted) return;
      if (ok) {
        await showSuccessDialog(context, title: 'Save success!', subtitle: 'Schedule updated.', statusLabel: widget.pond.name, statusSuffix: ' saved.');
        widget.onSaved();
        if (mounted) Navigator.pop(context);
      } else {
        await showSuccessDialog(context, title: 'Save failed', subtitle: widget.provider.error ?? 'Could not save.', statusLabel: widget.pond.name, statusSuffix: ' not saved.', failed: true);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

// ---------- Apply to other day sheet ----------
class _ApplyToOtherDaySheet extends StatelessWidget {
  final PondEntity pond;
  final ActivityType type;
  final String timezone;
  final ActivityProvider provider;
  final VoidCallback onDone;
  const _ApplyToOtherDaySheet({
    required this.pond,
    required this.type,
    required this.timezone,
    required this.provider,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 349,
      height: 190,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _opt(context, 'Apply for Tomorrow', 1),
          Container(height: 2, color: const Color(0xFFD9D9D9)),
          _opt(context, 'Apply for 7 days', 7),
          Container(height: 2, color: const Color(0xFFD9D9D9)),
          _opt(context, 'Apply for 30 days', 30),
        ],
      ),
    );
  }

  Widget _opt(BuildContext context, String label, int days) {
    return Expanded(
      child: GestureDetector(
        onTap: () async {
          Navigator.pop(context);
          // duplicate current day's activities for the next [days] days
          final items = provider.activities.where((a) => a.type == type).toList();
          for (var d = 1; d <= days; d++) {
            for (final a in items) {
              final newStart = a.startTime.add(Duration(days: d));
              final newEnd = a.endTime?.add(Duration(days: d));
              await provider.upsert({
                'type': _dbType(a.type),
                'status': 'pending',
                'startTime': newStart.toIso8601String(),
                if (newEnd != null) 'endTime': newEnd.toIso8601String(),
                if (a.quantityKg != null) 'quantityKg': a.quantityKg,
                if (a.fraction != null) 'fraction': a.fraction,
                'source': 'user',
              });
            }
          }
          onDone();
        },
        child: Center(
          child: Text(label, style: const TextStyle(fontFamily: AppFonts.heading, fontSize: 18, color: AppColors.textPrimary)),
        ),
      ),
    );
  }
}