import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PlannerShortcuts extends StatelessWidget {
  const PlannerShortcuts({
    super.key,
    required this.child,
    required this.onSave,
    required this.onUndo,
    required this.onRedo,
    required this.onFitMap,
    required this.onResetZoom,
  });

  final Widget child;
  final VoidCallback onSave;
  final VoidCallback? onUndo;
  final VoidCallback? onRedo;
  final VoidCallback onFitMap;
  final VoidCallback onResetZoom;

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        const SingleActivator(LogicalKeyboardKey.keyS, control: true):
            const _SaveIntent(),
        const SingleActivator(LogicalKeyboardKey.keyZ, control: true):
            const _UndoIntent(),
        const SingleActivator(LogicalKeyboardKey.keyY, control: true):
            const _RedoIntent(),
        const SingleActivator(LogicalKeyboardKey.keyF): const _FitMapIntent(),
        const SingleActivator(LogicalKeyboardKey.digit0):
            const _ResetZoomIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _SaveIntent: CallbackAction<_SaveIntent>(
            onInvoke: (_) {
              onSave();
              return null;
            },
          ),
          _UndoIntent: CallbackAction<_UndoIntent>(
            onInvoke: (_) {
              onUndo?.call();
              return null;
            },
          ),
          _RedoIntent: CallbackAction<_RedoIntent>(
            onInvoke: (_) {
              onRedo?.call();
              return null;
            },
          ),
          _FitMapIntent: CallbackAction<_FitMapIntent>(
            onInvoke: (_) {
              onFitMap();
              return null;
            },
          ),
          _ResetZoomIntent: CallbackAction<_ResetZoomIntent>(
            onInvoke: (_) {
              onResetZoom();
              return null;
            },
          ),
        },
        child: Focus(autofocus: true, child: child),
      ),
    );
  }
}

class _SaveIntent extends Intent {
  const _SaveIntent();
}

class _UndoIntent extends Intent {
  const _UndoIntent();
}

class _RedoIntent extends Intent {
  const _RedoIntent();
}

class _FitMapIntent extends Intent {
  const _FitMapIntent();
}

class _ResetZoomIntent extends Intent {
  const _ResetZoomIntent();
}
