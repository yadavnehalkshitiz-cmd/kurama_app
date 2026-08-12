import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Reads the legacy SharedPreferences task snapshot written by the old
/// [DownloadStorageService] and converts it to plain Dart maps.
///
/// This class is read-only and never mutates SharedPreferences data.
class LegacyStateReader {
  static const _tasksKey = 'download_tasks';
  static const _playbackKey = 'playback_positions';

  /// Returns the raw list of task maps stored by the legacy service.
  /// Returns an empty list if no data exists or the format is invalid.
  static Future<List<Map<String, dynamic>>> readTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_tasksKey);
      if (raw == null) return [];
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.whereType<Map<String, dynamic>>().toList();
      }
      if (decoded is Map<String, dynamic>) {
        // Legacy format: {taskId: {...}} map
        return decoded.values.whereType<Map<String, dynamic>>().toList();
      }
    } catch (_) {
      // Any decode failure → skip migration rather than crash
    }
    return [];
  }

  /// Returns {mediaId: positionMs} from SharedPreferences.
  static Future<Map<String, int>> readPlaybackPositions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_playbackKey);
      if (raw == null) return {};
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return {
          for (final entry in decoded.entries)
            if (entry.key is String && entry.value is int)
              entry.key as String: entry.value as int,
        };
      }
    } catch (_) {}
    return {};
  }
}
