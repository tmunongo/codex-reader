import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/recent_item.dart';

/// Service for managing recently opened files and directories
class RecentsService {
  static const String _recentsKey = 'recent_items';
  static const int _maxRecents = 10;

  SharedPreferences? _prefs;

  /// Initialize the service (must be called before use)
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Ensure preferences are initialized
  void _ensureInitialized() {
    if (_prefs == null) {
      throw Exception('RecentsService not initialized. Call init() first.');
    }
  }

  /// Get all recent items, sorted by most recent first
  List<RecentItem> getRecents() {
    _ensureInitialized();

    final String? recentsJson = _prefs!.getString(_recentsKey);
    if (recentsJson == null) return [];

    try {
      final List<dynamic> decoded = jsonDecode(recentsJson);
      final items = decoded
          .map((json) => RecentItem.fromJson(json as Map<String, dynamic>))
          .toList();

      // Sort by most recent first
      items.sort((a, b) => b.lastOpened.compareTo(a.lastOpened));

      return items;
    } catch (e) {
      // If parsing fails, return empty list
      return [];
    }
  }

  /// Add a recent item (or update if already exists)
  Future<void> addRecent(RecentItem item) async {
    if (_prefs == null) await init();

    final recents = getRecents();

    // Remove if already exists (will be re-added with new timestamp)
    recents.removeWhere((r) => r.path == item.path);

    // Add to front
    recents.insert(0, item);

    // Keep only max items
    if (recents.length > _maxRecents) {
      recents.removeRange(_maxRecents, recents.length);
    }

    await _saveRecents(recents);
  }

  /// Add a file to recents
  Future<void> addRecentFile(String filePath) async {
    final item = RecentItem(
      path: filePath,
      isDirectory: false,
      lastOpened: DateTime.now(),
    );
    await addRecent(item);
  }

  /// Add a directory to recents
  Future<void> addRecentDirectory(String dirPath) async {
    final item = RecentItem(
      path: dirPath,
      isDirectory: true,
      lastOpened: DateTime.now(),
    );
    await addRecent(item);
  }

  /// Remove a specific recent item
  Future<void> removeRecent(String path) async {
    if (_prefs == null) await init();

    final recents = getRecents();
    recents.removeWhere((r) => r.path == path);
    await _saveRecents(recents);
  }

  /// Clear all recents
  Future<void> clearRecents() async {
    if (_prefs == null) await init();
    await _prefs!.remove(_recentsKey);
  }

  /// Remove items that no longer exist on the filesystem
  Future<void> pruneInvalidRecents() async {
    if (_prefs == null) await init();

    final recents = getRecents();
    final validRecents = <RecentItem>[];

    for (final item in recents) {
      if (await item.exists()) {
        validRecents.add(item);
      }
    }

    if (validRecents.length != recents.length) {
      await _saveRecents(validRecents);
    }
  }

  /// Save recents list to storage
  Future<void> _saveRecents(List<RecentItem> recents) async {
    final encoded = jsonEncode(recents.map((r) => r.toJson()).toList());
    await _prefs!.setString(_recentsKey, encoded);
  }
}
