import 'dart:io';

import 'package:flutter/material.dart';

import '../services/file_service.dart';
import '../widgets/markdown_viewer.dart';

/// Screen for viewing a single markdown file
class FileViewerScreen extends StatefulWidget {
  final File file;

  const FileViewerScreen({super.key, required this.file});

  @override
  State<FileViewerScreen> createState() => _FileViewerScreenState();
}

class _FileViewerScreenState extends State<FileViewerScreen> {
  final FileService _fileService = FileService();

  String? _content;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFile();
  }

  /// Load and read the file content
  Future<void> _loadFile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Validate file
      final isValid = await _fileService.validateMarkdownFile(widget.file);
      if (!isValid) {
        throw FileServiceException(
          'Invalid markdown file. Supported extensions: ${FileService.markdownExtensions.join(", ")}',
        );
      }

      // Read content
      final content = await _fileService.readFileContent(widget.file);

      setState(() {
        _content = content;
        _isLoading = false;
      });
    } on FileServiceException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Unexpected error: $e';
        _isLoading = false;
      });
    }
  }

  /// Reload the file (useful if file changes externally)
  Future<void> _reloadFile() async {
    await _loadFile();
    if (mounted && _errorMessage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('File reloaded'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final fileName = _fileService.getFileName(widget.file);
    final filePath = widget.file.path;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(fileName),
            Text(
              filePath,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: .6),
              ),
            ),
          ],
        ),
        actions: [
          // Reload button
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload file',
            onPressed: _isLoading ? null : _reloadFile,
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
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading file...'),
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
                'Failed to load file',
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
                    onPressed: _reloadFile,
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

    // Success state - show markdown content
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: MarkdownViewer(data: _content ?? ''),
    );
  }
}
