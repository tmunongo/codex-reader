import 'dart:io';

import 'package:flutter/material.dart';

import '../models/file_tree_node.dart';
import '../services/file_service.dart';
import '../widgets/markdown_viewer.dart';

/// Screen for viewing a directory as a project with file tree navigation
class ProjectViewerScreen extends StatefulWidget {
  final Directory directory;

  const ProjectViewerScreen({super.key, required this.directory});

  @override
  State<ProjectViewerScreen> createState() => _ProjectViewerScreenState();
}

class _ProjectViewerScreenState extends State<ProjectViewerScreen> {
  final FileService _fileService = FileService();

  FileTreeNode? _rootNode;
  FileTreeNode? _selectedNode;
  String? _markdownContent;

  bool _isLoadingTree = true;
  bool _isLoadingFile = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFileTree();
  }

  /// Load the file tree from the directory
  Future<void> _loadFileTree() async {
    setState(() {
      _isLoadingTree = true;
      _errorMessage = null;
    });

    try {
      // Validate directory
      final isValid = await _fileService.validateDirectory(widget.directory);
      if (!isValid) {
        throw FileServiceException(
          'Cannot access directory: ${widget.directory.path}',
        );
      }

      // Build file tree
      final rootNode = await _fileService.buildFileTree(widget.directory);

      if (rootNode.markdownFileCount == 0) {
        throw FileServiceException('No markdown files found in this directory');
      }

      setState(() {
        _rootNode = rootNode;
        _isLoadingTree = false;
      });

      // Auto-select first markdown file
      final firstFile = rootNode.allMarkdownFiles.firstOrNull;
      if (firstFile != null) {
        _selectNode(firstFile);
      }
    } on FileServiceException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isLoadingTree = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Unexpected error: $e';
        _isLoadingTree = false;
      });
    }
  }

  /// Select a node and load its content
  Future<void> _selectNode(FileTreeNode node) async {
    if (node.isDirectory) return; // Only files can be selected

    setState(() {
      _isLoadingFile = true;
      _selectedNode?.isSelected = false;
      node.isSelected = true;
      _selectedNode = node;
    });

    try {
      final file = File(node.fullPath);
      final content = await _fileService.readFileContent(file);

      setState(() {
        _markdownContent = content;
        _isLoadingFile = false;
      });
    } catch (e) {
      setState(() {
        _markdownContent = null;
        _isLoadingFile = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load file: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  /// Toggle directory expansion
  void _toggleExpand(FileTreeNode node) {
    if (!node.isDirectory) return;

    setState(() {
      node.isExpanded = !node.isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final projectName = _fileService.getDirectoryName(widget.directory);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(projectName),
            if (_rootNode != null)
              Text(
                '${_rootNode!.markdownFileCount} markdown files',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: .6),
                ),
              ),
          ],
        ),
        actions: [
          // Refresh tree
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload project',
            onPressed: _isLoadingTree ? null : _loadFileTree,
          ),

          // Theme toggle (placeholder for M11)
          IconButton(
            icon: const Icon(Icons.brightness_6),
            tooltip: 'Toggle theme',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Theme switching coming in M11')),
              );
            },
          ),
        ],
      ),

      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Loading state
    if (_isLoadingTree) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Scanning directory...'),
          ],
        ),
      );
    }

    // Error state
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load project',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: .7),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _loadFileTree,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Go Back'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    // Success state - show file tree and content
    // For now, just show a simple tree list (we'll build proper UI in M5-M6)
    return Row(
      children: [
        // Temporary file tree list (M5 will replace this with proper tree UI)
        Container(
          width: 300,
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: .2),
              ),
            ),
          ),
          child: _buildSimpleTreeList(),
        ),

        // Content area
        Expanded(child: _buildContentArea()),
      ],
    );
  }

  /// Temporary simple tree list (M5 will replace with proper tree widget)
  Widget _buildSimpleTreeList() {
    if (_rootNode == null) return const SizedBox.shrink();

    final allFiles = _rootNode!.allMarkdownFiles;

    return ListView.builder(
      itemCount: allFiles.length,
      itemBuilder: (context, index) {
        final node = allFiles[index];

        return ListTile(
          dense: true,
          selected: node.isSelected,
          leading: const Icon(Icons.description, size: 18),
          title: Text(node.name, style: const TextStyle(fontSize: 13)),
          subtitle: Text(
            node.fullPath.replaceFirst(_rootNode!.fullPath, ''),
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: .5),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () => _selectNode(node),
        );
      },
    );
  }

  Widget _buildContentArea() {
    if (_isLoadingFile) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_markdownContent == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 64,
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: .3),
            ),
            const SizedBox(height: 16),
            Text(
              'Select a file to view',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: .6),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: MarkdownViewer(data: _markdownContent!),
    );
  }
}
