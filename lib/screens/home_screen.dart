import 'dart:io';

import 'package:codex/models/recent_item.dart';
import 'package:codex/screens/file_viewer_screen.dart';
import 'package:codex/screens/project_viewer_screen.dart';
import 'package:codex/services/file_service.dart';
import 'package:codex/services/recents_service.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FileService _fileService = FileService();
  final RecentsService _recentsService = RecentsService();
  bool _isPickingFile = false;
  bool _isPickingFolder = false;
  List<RecentItem> _recents = [];

  @override
  void initState() {
    super.initState();
    _loadRecents();
  }

  /// Load recent items
  Future<void> _loadRecents() async {
    await _recentsService.init();
    await _recentsService.pruneInvalidRecents();

    setState(() {
      _recents = _recentsService.getRecents();
    });
  }

  /// Open a recent item
  Future<void> _openRecent(RecentItem item) async {
    final exists = await item.exists();

    if (!exists) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${item.isDirectory ? 'Folder' : 'File'} no longer exists: ${item.name}',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );

        // Remove from recents
        await _recentsService.removeRecent(item.path);
        await _loadRecents();
      }
      return;
    }

    if (mounted) {
      if (item.isDirectory) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ProjectViewerScreen(directory: Directory(item.path)),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FileViewerScreen(file: File(item.path)),
          ),
        );
      }
    }
  }

  Future<void> _clearRecents() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Recent Items'),
        content: const Text('Are you sure you want to clear all recent items?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _recentsService.clearRecents();
      await _loadRecents();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Recent items cleared')));
      }
    }
  }

  /// Open file picker and navigate to viewer
  Future<void> _openFile() async {
    if (_isPickingFile) return;

    setState(() {
      _isPickingFile = true;
    });

    try {
      final file = await _fileService.pickMarkdownFile();

      if (file != null && mounted) {
        // Add to recents
        await _recentsService.addRecentFile(file.path);

        if (mounted) {
          // Navigate to file viewer
          await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => FileViewerScreen(file: file)),
          );

          // Reload recents when returning
          await _loadRecents();
        }
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
        // Add to recents
        await _recentsService.addRecentDirectory(directory.path);

        if (mounted) {
          // Navigate to project viewer
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProjectViewerScreen(directory: directory),
            ),
          );

          // Reload recents when returning
          await _loadRecents();
        }
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
              } else if (value == 'clear_recents') {
                _clearRecents();
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
              if (_recents.isNotEmpty) ...[
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'clear_recents',
                  child: Text('Clear Recent Items'),
                ),
              ],
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'about', child: Text('About')),
            ],
          ),
        ],
      ),

      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: _recents.isEmpty ? _buildEmptyState() : _buildRecentsView(),
        ),
      ),
    );
  }

  /// Build empty state (no recents)
  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.description_outlined,
          size: 120,
          color: Theme.of(context).colorScheme.primary.withValues(alpha: .3),
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
          runSpacing: 16,
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
    );
  }

  Widget _buildRecentsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 48),

        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Text(
                'Recent',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),

              // Quick actions
              OutlinedButton.icon(
                onPressed: _isPickingFile ? null : _openFile,
                icon: const Icon(Icons.insert_drive_file_outlined, size: 18),
                label: const Text('Open File'),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: _isPickingFolder ? null : _openFolder,
                icon: const Icon(Icons.folder_outlined, size: 18),
                label: const Text('Open Folder'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Recent items list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: _recents.length,
            itemBuilder: (context, index) {
              final item = _recents[index];
              return _buildRecentItem(item);
            },
          ),
        ),
      ],
    );
  }

  /// Build a single recent item
  Widget _buildRecentItem(RecentItem item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () => _openRecent(item),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  item.isDirectory ? Icons.folder : Icons.description,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),

              const SizedBox(width: 16),

              // Name and path
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.parentPath,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: .6),
                        fontFamily: 'monospace',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Type badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  item.isDirectory ? 'Folder' : 'File',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Remove button
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () async {
                  await _recentsService.removeRecent(item.path);
                  await _loadRecents();
                },
                tooltip: 'Remove from recents',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
