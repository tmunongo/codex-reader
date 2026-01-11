import 'dart:io';

import 'package:path/path.dart' as path;

/// Represents a node in the file tree (directory or file)
class FileTreeNode {
  /// Display name (filename or directory name)
  final String name;

  /// Full path on filesystem
  final String fullPath;

  /// Whether this node is a directory
  final bool isDirectory;

  /// Child nodes (empty for files)
  final List<FileTreeNode> children;

  /// Parent node (null for root)
  FileTreeNode? parent;

  /// Whether this node is expanded in the UI (directories only)
  bool isExpanded;

  /// Whether this node is currently selected
  bool isSelected;

  FileTreeNode({
    required this.name,
    required this.fullPath,
    required this.isDirectory,
    this.children = const [],
    this.parent,
    this.isExpanded = false,
    this.isSelected = false,
  });

  /// Factory constructor to create a node from a File
  factory FileTreeNode.fromFile(File file) {
    return FileTreeNode(
      name: path.basename(file.path),
      fullPath: file.path,
      isDirectory: false,
    );
  }

  /// Factory constructor to create a node from a Directory
  factory FileTreeNode.fromDirectory(Directory directory) {
    return FileTreeNode(
      name: path.basename(directory.path),
      fullPath: directory.path,
      isDirectory: true,
    );
  }

  /// Get file extension (empty string for directories)
  String get extension {
    if (isDirectory) return '';
    return path.extension(fullPath).replaceFirst('.', '').toLowerCase();
  }

  /// Check if this is a markdown file
  bool get isMarkdownFile {
    if (isDirectory) return false;
    const markdownExtensions = [
      'md',
      'markdown',
      'mdown',
      'mkd',
      'mdwn',
      'txt',
    ];
    return markdownExtensions.contains(extension);
  }

  /// Get the depth level in the tree (0 for root)
  int get depth {
    int level = 0;
    FileTreeNode? current = parent;
    while (current != null) {
      level++;
      current = current.parent;
    }
    return level;
  }

  /// Get all descendant nodes (recursive)
  List<FileTreeNode> get descendants {
    final result = <FileTreeNode>[];
    for (final child in children) {
      result.add(child);
      result.addAll(child.descendants);
    }
    return result;
  }

  /// Get all markdown files in this subtree
  List<FileTreeNode> get allMarkdownFiles {
    final result = <FileTreeNode>[];
    if (!isDirectory && isMarkdownFile) {
      result.add(this);
    }
    for (final child in children) {
      result.addAll(child.allMarkdownFiles);
    }
    return result;
  }

  /// Count total markdown files in this subtree
  int get markdownFileCount {
    return allMarkdownFiles.length;
  }

  /// Sort children (directories first, then alphabetically)
  void sortChildren() {
    children.sort((a, b) {
      // Directories before files
      if (a.isDirectory && !b.isDirectory) return -1;
      if (!a.isDirectory && b.isDirectory) return 1;

      // Then alphabetically (case-insensitive)
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    // Recursively sort children's children
    for (final child in children) {
      if (child.isDirectory) {
        child.sortChildren();
      }
    }
  }

  /// Find a node by path
  FileTreeNode? findByPath(String searchPath) {
    if (fullPath == searchPath) return this;

    for (final child in children) {
      final found = child.findByPath(searchPath);
      if (found != null) return found;
    }

    return null;
  }

  /// Collapse all nodes in this subtree
  void collapseAll() {
    isExpanded = false;
    for (final child in children) {
      child.collapseAll();
    }
  }

  /// Expand all nodes in this subtree
  void expandAll() {
    if (isDirectory) {
      isExpanded = true;
      for (final child in children) {
        child.expandAll();
      }
    }
  }

  /// Deselect all nodes in this subtree
  void deselectAll() {
    isSelected = false;
    for (final child in children) {
      child.deselectAll();
    }
  }

  @override
  String toString() {
    return 'FileTreeNode(name: $name, isDirectory: $isDirectory, children: ${children.length})';
  }
}
