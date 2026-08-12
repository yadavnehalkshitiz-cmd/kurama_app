import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/download_task.dart';

/// Mirrors every SQLite write back to SharedPreferences for one release cycle.
///
/// Purpose: if a user rolls back from the Phase 0 APK to the previous version,
/// their downloads are still visible because SharedPreferences is intact.
///
/// **Removal gate** (document in PHASE_0_MIGRATION.md):
/// Remove this class and all calls to it when ≥ 99 % of active users are on
/// the Phase 0 build (tracked via analytics `migration_completed` event).
class LegacyStateMirror {
  static const _tasksKey = 'download_tasks';

  final SharedPreferences _prefs;

  LegacyStateMirror(this._prefs);

  factory LegacyStateMirror.fromPrefs(SharedPreferences prefs) =>
      LegacyStateMirror(prefs);

  /// Upsert a task into the SharedPreferences task map.
  Future<void> upsertTask(DownloadTask task) async {
    final raw = _prefs.getString(_tasksKey);
    final Map<String, dynamic> tasks = raw == null
        ? {}
        : Map<String, dynamic>.from(jsonDecode(raw) as Map? ?? {});
    tasks[task.taskId] = task.toJson();
    await _prefs.setString(_tasksKey, jsonEncode(tasks));
  }

  /// Remove a task from the SharedPreferences mirror.
  Future<void> removeTask(String taskId) async {
    final raw = _prefs.getString(_tasksKey);
    if (raw == null) return;
    final Map<String, dynamic> tasks =
        Map<String, dynamic>.from(jsonDecode(raw) as Map? ?? {});
    tasks.remove(taskId);
    await _prefs.setString(_tasksKey, jsonEncode(tasks));
  }

  /// Replace the entire task map (used after bulk migrations).
  Future<void> replaceAll(List<DownloadTask> tasks) async {
    final Map<String, dynamic> map = {
      for (final t in tasks) t.taskId: t.toJson(),
    };
    await _prefs.setString(_tasksKey, jsonEncode(map));
  }
}
