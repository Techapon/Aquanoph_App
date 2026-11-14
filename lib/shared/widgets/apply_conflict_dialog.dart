import 'package:flutter/material.dart';

import 'package:aquanoph/core/theme/app_colors.dart';
import 'package:aquanoph/core/theme/app_fonts.dart';

/// Warning popup when target day(s) already have a schedule.
/// Blind upsert would hit the DB exclusion constraint
/// (e.g. activities_aeration_no_overlap) and fail the whole batch,
/// so we warn first and apply only to the free days.
/// Returns true = apply to free days (skip conflicted), false/null = cancel.
Future<bool?> showApplyConflictDialog(
  BuildContext context, {
  required String pondName,
  required List<String> conflictDays,
  required int freeDays,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 75,
              height: 75,
              decoration: const BoxDecoration(
                color: AppColors.warningBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                size: 40,
                color: AppColors.warnTitle,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Schedule already exists',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppFonts.heading,
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '•  $pondName already has a schedule:',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            ...conflictDays
                .take(5)
                .map(
                  (d) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      '•  $d',
                      style: const TextStyle(
                        fontFamily: AppFonts.heading,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
            if (conflictDays.length > 5)
              Text(
                '+${conflictDays.length - 5} more day(s)',
                style: const TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            const SizedBox(height: 20),
            if (freeDays > 0)
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontFamily: AppFonts.heading,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gradientStart,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Apply others',
                        style: TextStyle(
                          fontFamily: AppFonts.heading,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else
              SizedBox(
                width: 100,
                height: 40,
                child: TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF2C2C2C),
                    foregroundColor: const Color(0xFFF5F5F5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'close',
                    style: TextStyle(
                      fontFamily: AppFonts.heading,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
