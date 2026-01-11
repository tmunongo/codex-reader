import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;

import '../models/file_tree_node.dart';

class FileService {
  static const List<String> markdownExtensions = [
    'md',
    'markdown',
    'mdown',
    'mkd',
    'mdwn',
    'txt',
  ];

  Future<Directory?> pickDirectory() async {
    try {
      final result = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Open Folder as Project',
      );

      if (result != null) {
        return Directory(result);
      }

      return null;
    } catch (e) {
      throw FileServiceException('Failed to pick directory: $e');
    }
  }

  Future<FileTreeNode> buildFileTree(
    Directory directory, {
    int maxDepth = -1,
    int currentDepth = 0,
  }) async {
    try {
      final rootNode = FileTreeNode.fromDirectory(directory);
      final children = <FileTreeNode>[];

      if (maxDepth != -1 && currentDepth >= maxDepth) {
        return rootNode;
      }

      final entities = await directory.list().toList();

      for (final entity in entities) {
        final basename = path.basename(entity.path);
        if (basename.startsWith('.')) continue;

        if (entity is File) {
          final node = FileTreeNode.fromFile(entity);
          if (node.isMarkdownFile) {
            node.parent = rootNode;
            children.add(node);
          }
        } else if (entity is Directory) {
          final subdirNode = await buildFileTree(
            entity,
            maxDepth: maxDepth,
            currentDepth: currentDepth + 1,
          );

          if (subdirNode.markdownFileCount > 0) {
            subdirNode.parent = rootNode;
            children.add(subdirNode);
          }
        }
      }

      final nodeWithChildren = FileTreeNode(
        name: rootNode.name,
        fullPath: rootNode.fullPath,
        isDirectory: true,
        children: children,
        parent: rootNode.parent,
        isExpanded: currentDepth == 0,
      );

      nodeWithChildren.sortChildren();

      return nodeWithChildren;
    } on FileSystemException catch (e) {
      throw FileServiceException('Cannot access directory: ${e.message}');
    } catch (e) {
      throw FileServiceException('Failed to build file tree: $e');
    }
  }

  Future<bool> validateDirectory(Directory directory) async {
    try {
      if (!await directory.exists()) {
        return false;
      }

      final stat = await directory.stat();
      if (stat.type != FileSystemEntityType.directory) {
        return false;
      }

      await directory.list().first;

      return true;
    } catch (e) {
      return false;
    }
  }

  String getDirectoryName(Directory directory) {
    return path.basename(directory.path);
  }

  Future<File?> pickMarkdownFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: markdownExtensions,
        dialogTitle: 'Open Markdown File',
      );

      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      }

      return null;
    } catch (e) {
      throw FileServiceException('Failed to pick file: $e');
    }
  }

  Future<String> readFileContent(File file) async {
    try {
      if (!await file.exists()) {
        throw FileServiceException('File does not exist: ${file.path}');
      }

      final stat = await file.stat();
      if (stat.type != FileSystemEntityType.file) {
        throw FileServiceException('Path is not a file: ${file.path}');
      }

      final content = await file.readAsString();

      return content;
    } on FileSystemException catch (e) {
      throw FileServiceException('Cannot read file: ${e.message}');
    } catch (e) {
      throw FileServiceException('Failed to read file: $e');
    }
  }

  Future<bool> validateMarkdownFile(File file) async {
    try {
      // Check extension
      final ext = path.extension(file.path).toLowerCase().replaceFirst('.', '');
      if (!markdownExtensions.contains(ext)) {
        return false;
      }

      if (!await file.exists()) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Gets the filename without path
  String getFileName(File file) {
    return path.basename(file.path);
  }

  String getFileExtension(File file) {
    return path.extension(file.path).replaceFirst('.', '');
  }

  String getDirectoryPath(File file) {
    return path.dirname(file.path);
  }
}

class FileServiceException implements Exception {
  final String message;

  FileServiceException(this.message);

  @override
  String toString() => message;
}
