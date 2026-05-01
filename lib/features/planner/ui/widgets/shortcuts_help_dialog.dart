import 'package:flutter/material.dart';

import '../../../../core/theme/garden_theme.dart';

class ShortcutsHelpButton extends StatelessWidget {
  const ShortcutsHelpButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Keyboard shortcuts',
      icon: const Icon(Icons.keyboard_alt_outlined),
      color: GardenTheme.muted,
      onPressed: () {
        showDialog<void>(
          context: context,
          builder: (context) {
            return const ShortcutsHelpDialog();
          },
        );
      },
    );
  }
}

class ShortcutsHelpDialog extends StatelessWidget {
  const ShortcutsHelpDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: GardenTheme.panel,
      title: const Text('Keyboard Shortcuts'),
      content: const SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ShortcutRow(keys: 'Ctrl + S', action: 'Save project'),
            _ShortcutRow(keys: 'Ctrl + Z', action: 'Undo'),
            _ShortcutRow(keys: 'Ctrl + Y', action: 'Redo'),
            _ShortcutRow(keys: 'F', action: 'Fit map to screen'),
            _ShortcutRow(keys: '0', action: 'Reset zoom to 100%'),
            _ShortcutRow(keys: 'Esc', action: 'Close open panel later'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Close'),
        ),
      ],
    );
  }
}

class _ShortcutRow extends StatelessWidget {
  const _ShortcutRow({required this.keys, required this.action});

  final String keys;
  final String action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Container(
            width: 108,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: GardenTheme.paper,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: GardenTheme.border),
            ),
            child: Text(
              keys,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: GardenTheme.ink,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              action,
              style: const TextStyle(
                color: GardenTheme.muted,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
