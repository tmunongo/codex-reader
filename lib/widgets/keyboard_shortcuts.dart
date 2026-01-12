import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KeyboardShortcuts extends StatelessWidget {
  final Widget child;
  final VoidCallback? onOpenFile;
  final VoidCallback? onOpenFolder;
  final VoidCallback? onToggleTheme;
  final VoidCallback? onRefresh;
  final VoidCallback? onShowShortcuts;

  const KeyboardShortcuts({
    super.key,
    required this.child,
    this.onOpenFile,
    this.onOpenFolder,
    this.onToggleTheme,
    this.onRefresh,
    this.onShowShortcuts,
  });

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        // Ctrl/Cmd + O: Open file
        const SingleActivator(LogicalKeyboardKey.keyO, control: true): () {
          onOpenFile?.call();
        },

        // Ctrl/Cmd + Shift + O: Open folder
        const SingleActivator(
          LogicalKeyboardKey.keyO,
          control: true,
          shift: true,
        ): () {
          onOpenFolder?.call();
        },

        // Ctrl/Cmd + T: Toggle theme
        const SingleActivator(LogicalKeyboardKey.keyT, control: true): () {
          onToggleTheme?.call();
        },

        // Ctrl/Cmd + R: Refresh
        const SingleActivator(LogicalKeyboardKey.keyR, control: true): () {
          onRefresh?.call();
        },

        // F1: Show shortcuts
        const SingleActivator(LogicalKeyboardKey.f1): () {
          onShowShortcuts?.call();
        },
      },
      child: Focus(autofocus: true, child: child),
    );
  }
}

class ShortcutsDialog extends StatelessWidget {
  const ShortcutsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.keyboard),
          SizedBox(width: 12),
          Text('Keyboard Shortcuts'),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _ShortcutSection(
                title: 'File Operations',
                shortcuts: [
                  _ShortcutItem(keys: 'Ctrl + O', description: 'Open file'),
                  _ShortcutItem(
                    keys: 'Ctrl + Shift + O',
                    description: 'Open folder',
                  ),
                  _ShortcutItem(
                    keys: 'Ctrl + R',
                    description: 'Reload current file',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _ShortcutSection(
                title: 'Appearance',
                shortcuts: [
                  _ShortcutItem(
                    keys: 'Ctrl + T',
                    description: 'Toggle light/dark theme',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _ShortcutSection(
                title: 'Help',
                shortcuts: [
                  _ShortcutItem(
                    keys: 'F1',
                    description: 'Show this help dialog',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Note: Use Cmd instead of Ctrl on macOS',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: .6),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _ShortcutSection extends StatelessWidget {
  final String title;
  final List<_ShortcutItem> shortcuts;

  const _ShortcutSection({required this.title, required this.shortcuts});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...shortcuts,
      ],
    );
  }
}

class _ShortcutItem extends StatelessWidget {
  final String keys;
  final String description;

  const _ShortcutItem({required this.keys, required this.description});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: .3),
              ),
            ),
            child: Text(
              keys,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(description, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
