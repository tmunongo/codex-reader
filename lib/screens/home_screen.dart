import 'package:codex/screens/file_viewer_screen.dart';
import 'package:codex/screens/project_viewer_screen.dart';
import 'package:codex/services/file_service.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FileService _fileService = FileService();
  bool _isPickingFile = false;
  bool _isPickingFolder = false;

  /// Open file picker and navigate to viewer
  Future<void> _openFile() async {
    if (_isPickingFile) return;

    setState(() {
      _isPickingFile = true;
    });

    try {
      final file = await _fileService.pickMarkdownFile();

      if (file != null && mounted) {
        // Navigate to file viewer
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FileViewerScreen(file: file)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening file: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPickingFile = false;
        });
      }
    }
  }

  Future<void> _openFolder() async {
    if (_isPickingFolder) return;

    setState(() {
      _isPickingFolder = true;
    });

    try {
      final directory = await _fileService.pickDirectory();

      if (directory != null && mounted) {
        // Navigate to project viewer
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProjectViewerScreen(directory: directory),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening folder: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPickingFolder = false;
        });
      }
    }
  }

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
              if (value == 'open_file') {
                _openFile();
              } else if (value == 'open_folder') {
                _openFolder();
              }
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
                  onPressed: _isPickingFile ? null : _openFile,
                  icon: _isPickingFile
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.insert_drive_file_outlined),
                  label: Text(_isPickingFile ? 'Opening...' : 'Open File'),
                ),
                OutlinedButton.icon(
                  onPressed: _isPickingFolder ? null : _openFolder,
                  icon: _isPickingFolder
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.folder_outlined),
                  label: Text(_isPickingFolder ? 'Opening...' : 'Open Folder'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
