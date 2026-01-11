import 'dart:io';

import 'package:path/path.dart' as p;

class RecentItem {
  final String path;

  final bool isDirectory;

  final DateTime lastOpened;

  RecentItem({
    required this.path,
    required this.isDirectory,
    required this.lastOpened,
  });

  String get name => p.basename(path);

  String get parentPath => p.dirname(path);

  Future<bool> exists() async {
    try {
      if (isDirectory) {
        return await Directory(path).exists();
      } else {
        return await File(path).exists();
      }
    } catch (e) {
      return false;
    }
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'isDirectory': isDirectory,
      'lastOpened': lastOpened.toIso8601String(),
    };
  }

  /// Create from JSON
  factory RecentItem.fromJson(Map<String, dynamic> json) {
    return RecentItem(
      path: json['path'] as String,
      isDirectory: json['isDirectory'] as bool,
      lastOpened: DateTime.parse(json['lastOpened'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecentItem && other.path == path;
  }

  @override
  int get hashCode => path.hashCode;

  @override
  String toString() {
    return 'RecentItem(path: $path, isDirectory: $isDirectory, lastOpened: $lastOpened)';
  }
}
