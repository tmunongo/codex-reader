import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// About dialog for Codex
class CodexAboutDialog extends StatelessWidget {
  const CodexAboutDialog({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: SizedBox(
        width: 450,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with gradient
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.description,
                    size: 64,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'CODEX',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimary,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Read the source.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(
                        context,
                      ).colorScheme.onPrimary.withValues(alpha: .9),
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Version 1.0.0',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'A calm, customizable Markdown reader for researchers and writers who need a quiet space to explore their work.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: .7),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Features
                  _InfoRow(
                    icon: Icons.folder_outlined,
                    text: 'Open files or entire directories',
                  ),
                  _InfoRow(
                    icon: Icons.palette_outlined,
                    text: 'Custom theme support',
                  ),
                  _InfoRow(
                    icon: Icons.code,
                    text: 'Syntax highlighting for code',
                  ),
                  _InfoRow(
                    icon: Icons.offline_bolt,
                    text: 'Fully offline, no tracking',
                  ),

                  const SizedBox(height: 24),

                  // Links
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () => _launchUrl(
                          'https://github.com/tmunongo/codex-reader',
                        ),
                        icon: const Icon(Icons.code, size: 18),
                        label: const Text('GitHub'),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () => _launchUrl(
                          'https://github.com/tmunongo/codex-reader/issues',
                        ),
                        icon: const Icon(Icons.bug_report, size: 18),
                        label: const Text('Report Issue'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Footer
                  Text(
                    '© 2026 Codex. MIT License.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: .5),
                    ),
                  ),
                  Text(
                    'Built with Flutter',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: .5),
                    ),
                  ),
                ],
              ),
            ),
          ],
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}
