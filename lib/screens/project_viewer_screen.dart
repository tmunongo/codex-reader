import 'dart:io';

import 'package:codex/services/preferences_service.dart';
import 'package:codex/widgets/split_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/file_tree_node.dart';
import '../services/file_service.dart';
import '../widgets/file_tree.dart';
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
  final PreferencesService _prefsService = PreferencesService();

  FileTreeNode? _rootNode;
  FileTreeNode? _selectedNode;
  String? _markdownContent;

  bool _isLoadingTree = true;
  bool _isLoadingFile = false;
  String? _errorMessage;

  double _sidebarWidth = 300;

  @override
  void initState() {
    super.initState();
    _initPreferences();
    _loadFileTree();
  }

  Future<void> _initPreferences() async {
    await _prefsService.init();
    setState(() {
      _sidebarWidth = _prefsService.getSidebarWidth(300);
    });
  }

  void _onSidebarResized(double width) {
    _prefsService.setSidebarWidth(width);
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

    // Deselect previous node
    if (_selectedNode != null && _selectedNode != node) {
      _rootNode?.deselectAll();
    }

    setState(() {
      _isLoadingFile = true;
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

  /// Expand all directories
  void _expandAll() {
    setState(() {
      _rootNode?.expandAll();
    });
  }

  /// Collapse all directories
  void _collapseAll() {
    setState(() {
      _rootNode?.collapseAll();
      // Re-expand root
      if (_rootNode != null) {
        _rootNode!.isExpanded = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final projectName = _fileService.getDirectoryName(widget.directory);

    return KeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          // Ctrl/Cmd + R: Reload
          if (event.logicalKey == LogicalKeyboardKey.keyR &&
              (HardwareKeyboard.instance.isControlPressed ||
                  HardwareKeyboard.instance.isMetaPressed)) {
            _loadFileTree();
          }
        }
      },
      child: Scaffold(
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
            // Collapse all
            IconButton(
              icon: const Icon(Icons.unfold_less),
              tooltip: 'Collapse all',
              onPressed: _rootNode == null ? null : _collapseAll,
            ),

            // Expand all
            IconButton(
              icon: const Icon(Icons.unfold_more),
              tooltip: 'Expand all',
              onPressed: _rootNode == null ? null : _expandAll,
            ),

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
                  const SnackBar(
                    content: Text('Theme switching coming in M11'),
                  ),
                );
              },
            ),
          ],
        ),

        body: _buildBody(),
      ),
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

    // Success state - show file tree and content in split view
    return SplitView(
      initialLeftWidth: _sidebarWidth,
      minLeftWidth: 200,
      maxLeftWidth: 600,
      onDividerDragged: _onSidebarResized,
      left: _buildSidebar(),
      right: _buildContentArea(),
    );
  }

  Widget _buildSidebar() {
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
      child: Column(
        children: [
          // Sidebar header
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: .2),
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.folder_outlined,
                  size: 18,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: .7),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Files',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tree view
          Expanded(
            child: _rootNode != null
                ? FileTree(
                    rootNode: _rootNode!,
                    onNodeSelected: _selectNode,
                    onNodeExpanded: _toggleExpand,
                  )
                : const Center(child: Text('No files')),
          ),
        ],
      ),
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
