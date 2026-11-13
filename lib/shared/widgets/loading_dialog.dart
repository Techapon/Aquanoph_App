import 'package:flutter/material.dart';

/// Runs [work] behind a non-dismissible spinner dialog (CLAUDE.md §4.10):
/// every user-initiated async action must show this while the user waits,
/// then surface the result. Callers must ALSO guard against double-tap
/// (busy flag or disabled button) — the barrier blocks the screen, not the
/// callback.
Future<R> withLoading<R>(BuildContext context, Future<R> Function() work) async {
  showDialog(context: context, barrierDismissible: false, builder: (_) => const _Spinner());
  try {
    return await work();
  } finally {
    if (context.mounted) Navigator.of(context).pop();
  }
}

class _Spinner extends StatelessWidget {
  const _Spinner();

  @override
  Widget build(BuildContext context) => const PopScope(
        canPop: false,
        child: Center(
          child: SizedBox(
            width: 84,
            height: 84,
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(16)),
              elevation: 4,
              child: Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator(strokeWidth: 3.5))),
            ),
          ),
        ),
      );
}
