import 'package:flutter/material.dart';

import '../models/file_tree_node.dart';

/// Callback when a file node is selected
typedef OnNodeSelected = void Function(FileTreeNode node);

/// Callback when a directory node is expanded/collapsed
typedef OnNodeExpanded = void Function(FileTreeNode node);

/// A collapsible file tree widget
class FileTree extends StatelessWidget {
  final FileTreeNode rootNode;
  final OnNodeSelected? onNodeSelected;
  final OnNodeExpanded? onNodeExpanded;

  const FileTree({
    super.key,
    required this.rootNode,
    this.onNodeSelected,
    this.onNodeExpanded,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: _buildTreeNodes(rootNode, context),
    );
  }

  /// Recursively build tree nodes
  List<Widget> _buildTreeNodes(FileTreeNode node, BuildContext context) {
    final widgets = <Widget>[];

    // Add current node
    widgets.add(
      FileTreeNodeWidget(
        node: node,
        onTap: () {
          if (node.isDirectory) {
            onNodeExpanded?.call(node);
          } else {
            onNodeSelected?.call(node);
          }
        },
      ),
    );

    // Add children if directory is expanded
    if (node.isDirectory && node.isExpanded) {
      for (final child in node.children) {
        widgets.addAll(_buildTreeNodes(child, context));
      }
    }

    return widgets;
  }
}

/// Widget for a single tree node
class FileTreeNodeWidget extends StatefulWidget {
  final FileTreeNode node;
  final VoidCallback onTap;

  const FileTreeNodeWidget({
    super.key,
    required this.node,
    required this.onTap,
  });

  @override
  State<FileTreeNodeWidget> createState() => _FileTreeNodeWidgetState();
}

class _FileTreeNodeWidgetState extends State<FileTreeNodeWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final node = widget.node;
    final indent = node.depth * 16.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Material(
        color: _getBackgroundColor(theme),
        child: InkWell(
          onTap: widget.onTap,
          child: Container(
            height: 32,
            padding: EdgeInsets.only(left: indent + 8, right: 8),
            child: Row(
              children: [
                // Expansion chevron (for directories)
                if (node.isDirectory) ...[
                  AnimatedRotation(
                    turns: node.isExpanded ? 0.25 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(width: 4),
                ] else
                  const SizedBox(width: 22), // Align with files
                // Icon
                Icon(_getIcon(), size: 18, color: _getIconColor(theme)),
                const SizedBox(width: 8),

                // Name
                Expanded(
                  child: Text(
                    node.name,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: node.isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                      fontWeight: node.isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      fontFamily: 'monospace',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // File count badge (for directories)
                if (node.isDirectory && node.markdownFileCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${node.markdownFileCount}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Get background color based on state
  Color _getBackgroundColor(ThemeData theme) {
    if (widget.node.isSelected) {
      return theme.colorScheme.primary.withOpacity(0.15);
    }
    if (_isHovered) {
      return theme.colorScheme.onSurface.withOpacity(0.05);
    }
    return Colors.transparent;
  }

  IconData _getIcon() {
    if (widget.node.isDirectory) {
      return widget.node.isExpanded ? Icons.folder_open : Icons.folder;
    }
    return Icons.description;
  }

  /// Get icon color
  Color _getIconColor(ThemeData theme) {
    if (widget.node.isDirectory) {
      return const Color(0xFF6C3FDB); // Codex purple
    }
    if (widget.node.isSelected) {
      return theme.colorScheme.primary;
    }
    return theme.colorScheme.onSurface.withValues(alpha: .6);
  }
}
