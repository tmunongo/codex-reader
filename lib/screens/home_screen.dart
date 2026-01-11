import 'package:codex/screens/markdown_test_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Codex'),
        elevation: 0,
        actions: [
          // Placeholder for theme switcher (M11)
          IconButton(
            icon: const Icon(Icons.brightness_6),
            tooltip: 'Toggle theme',
            onPressed: () {
              // TODO: Theme switching in M11
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Theme switching coming soon')),
              );
            },
          ),

          // Placeholder for menu (M3+)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              // TODO: Implement menu actions
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'open_file',
                child: Text('Open File...'),
              ),
              const PopupMenuItem(
                value: 'open_folder',
                child: Text('Open Folder...'),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'about', child: Text('About')),
            ],
          ),
        ],
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 120,
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: .3),
            ),
            const SizedBox(height: 24),
            Text(
              'Codex',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Read the source.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: .6),
              ),
            ),
            const SizedBox(height: 48),

            // Empty state actions
            Wrap(
              spacing: 16,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to test screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MarkdownTestScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.science_outlined),
                  label: const Text('Test Renderer'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: M3 - Open file
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('File picker coming in M3')),
                    );
                  },
                  icon: const Icon(Icons.insert_drive_file_outlined),
                  label: const Text('Open File'),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    // TODO: M4 - Open folder
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Folder picker coming in M4'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.folder_outlined),
                  label: const Text('Open Folder'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
