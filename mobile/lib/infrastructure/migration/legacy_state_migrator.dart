import 'package:drift/drift.dart';
import '../../models/download_task.dart';
import '../database/app_database.dart';
import 'legacy_state_reader.dart';

/// One-shot transactional migration from SharedPreferences → SQLite.
///
/// Properties:
/// - **Idempotent**: tracks completion in [MigrationRecords]; if the record
///   exists and status is `completed`, it is a no-op.
/// - **Transactional**: all inserts happen in a single Drift transaction.
///   If anything fails, the DB is rolled back to its pre-migration state.
/// - **Reversible**: the migration never deletes SharedPreferences data.
///   The legacy mirror (see [LegacyStateMirror]) keeps it in sync for one
///   release so rollback to the previous APK works without data loss.
class LegacyStateMigrator {
  static const _migrationId = 'phase0_sharedprefs_to_sqlite_v1';

  final AppDatabase _db;

  LegacyStateMigrator(this._db);

  /// Run the migration. Returns the number of tasks migrated.
  /// Returns 0 if already completed or if there is nothing to migrate.
  Future<int> run() async {
    // Idempotency check
    final existing = await (_db.select(_db.migrationRecords)
          ..where((r) => r.id.equals(_migrationId)))
        .getSingleOrNull();
    if (existing?.status == 'completed') return 0;

    // Mark started
    await _db.into(_db.migrationRecords).insertOnConflictUpdate(
          MigrationRecordsCompanion.insert(
            id: _migrationId,
            status: const Value('running'),
            startedAt: Value(DateTime.now()),
          ),
        );

    try {
      final tasks = await LegacyStateReader.readTasks();
      final positions = await LegacyStateReader.readPlaybackPositions();

      int count = 0;

      await _db.transaction(() async {
        for (final raw in tasks) {
          final task = _taskFromRaw(raw);
          if (task == null) continue;
          await _db.into(_db.downloadRecords).insertOnConflictUpdate(
                DownloadRecordsCompanion.insert(
                  taskId: task.taskId,
                  url: task.url,
                  platform: Value(task.platform),
                  title: Value(task.title),
                  format: Value(task.format),
                  quality: Value(task.quality),
                  status: Value(task.status.name),
                  progress: Value(task.progress),
                  fileSize: Value(task.fileSize),
                  fileSizeStr: Value(task.fileSizeStr),
                  error: Value(task.error),
                  localPath: Value(task.localPath),
                  filename: Value(task.filename),
                  thumbnailUrl: Value(task.thumbnailUrl),
                  isPrivate: Value(task.isPrivate),
                  vaultPath: Value(task.vaultPath),
                  createdAt: Value(task.createdAt),
                  updatedAt: Value(DateTime.now()),
                ),
              );
          count++;
        }

        for (final entry in positions.entries) {
          await _db.into(_db.playbackPositions).insertOnConflictUpdate(
                PlaybackPositionsCompanion.insert(
                  mediaId: entry.key,
                  positionMs: Value(entry.value),
                  updatedAt: Value(DateTime.now()),
                ),
              );
        }
      });

      // Mark completed
      await (_db.update(_db.migrationRecords)
            ..where((r) => r.id.equals(_migrationId)))
          .write(MigrationRecordsCompanion(
        status: const Value('completed'),
        completedAt: Value(DateTime.now()),
        detail: Value('Migrated $count tasks, ${positions.length} positions'),
      ));

      return count;
    } catch (e) {
      await (_db.update(_db.migrationRecords)
            ..where((r) => r.id.equals(_migrationId)))
          .write(MigrationRecordsCompanion(
        status: const Value('failed'),
        detail: Value(e.toString().substring(0, 500)),
      ));
      rethrow;
    }
  }

  DownloadTask? _taskFromRaw(Map<String, dynamic> raw) {
    final id = raw['task_id'] as String?;
    final url = raw['url'] as String?;
    if (id == null || id.isEmpty || url == null || url.isEmpty) return null;
    return DownloadTask.fromJson(raw, taskId: id, url: url);
  }
}
