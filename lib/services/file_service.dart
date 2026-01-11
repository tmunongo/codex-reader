import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;

/// Service for handling file operations
class FileService {
  /// Supported markdown file extensions
  static const List<String> markdownExtensions = [
    'md',
    'markdown',
    'mdown',
    'mkd',
    'mdwn',
    'txt',
  ];

  /// Opens a file picker dialog and returns the selected markdown file
  /// Returns null if user cancels or no file is selected
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

  /// Reads the content of a file as a UTF-8 string
  /// Throws FileServiceException if file cannot be read
  Future<String> readFileContent(File file) async {
    try {
      // Check if file exists
      if (!await file.exists()) {
        throw FileServiceException('File does not exist: ${file.path}');
      }

      // Check if file is readable
      final stat = await file.stat();
      if (stat.type != FileSystemEntityType.file) {
        throw FileServiceException('Path is not a file: ${file.path}');
      }

      // Read file content as UTF-8
      final content = await file.readAsString();

      return content;
    } on FileSystemException catch (e) {
      throw FileServiceException('Cannot read file: ${e.message}');
    } catch (e) {
      throw FileServiceException('Failed to read file: $e');
    }
  }

  /// Validates if a file is a markdown file
  /// Checks extension and readability
  Future<bool> validateMarkdownFile(File file) async {
    try {
      // Check extension
      final ext = path.extension(file.path).toLowerCase().replaceFirst('.', '');
      if (!markdownExtensions.contains(ext)) {
        return false;
      }

      // Check if exists and readable
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

  /// Gets the file extension
  String getFileExtension(File file) {
    return path.extension(file.path).replaceFirst('.', '');
  }

  /// Gets the directory path of a file
  String getDirectoryPath(File file) {
    return path.dirname(file.path);
  }
}

/// Custom exception for file service errors
class FileServiceException implements Exception {
  final String message;

  FileServiceException(this.message);

  @override
  String toString() => message;
}
