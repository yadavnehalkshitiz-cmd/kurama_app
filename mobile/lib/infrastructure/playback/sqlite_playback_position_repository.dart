import 'package:drift/drift.dart';
import '../../domain/playback/playback_position_repository.dart';
import '../database/app_database.dart';

/// Production [PlaybackPositionRepository] backed by Drift/SQLite.
class SqlitePlaybackPositionRepository implements PlaybackPositionRepository {
  final AppDatabase _db;

  SqlitePlaybackPositionRepository(this._db);

  @override
  Future<void> savePosition(String mediaId, int positionMs) async {
    await _db.into(_db.playbackPositions).insertOnConflictUpdate(
          PlaybackPositionsCompanion.insert(
            mediaId: mediaId,
            positionMs: Value(positionMs),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  @override
  Future<int> getPosition(String mediaId) async {
    final row = await (_db.select(_db.playbackPositions)
          ..where((r) => r.mediaId.equals(mediaId)))
        .getSingleOrNull();
    return row?.positionMs ?? 0;
  }

  @override
  Stream<int> watchPosition(String mediaId) {
    return (_db.select(_db.playbackPositions)
          ..where((r) => r.mediaId.equals(mediaId)))
        .watchSingleOrNull()
        .map((row) => row?.positionMs ?? 0);
  }

  @override
  Future<void> clearPosition(String mediaId) async {
    await (_db.delete(_db.playbackPositions)
          ..where((r) => r.mediaId.equals(mediaId)))
        .go();
  }

  @override
  Future<void> clearAll() async {
    await _db.delete(_db.playbackPositions).go();
  }
}
