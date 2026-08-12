import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

// ── Table definitions ─────────────────────────────────────────────────────────

class DownloadRecords extends Table {
  TextColumn get taskId => text()();
  TextColumn get url => text()();
  TextColumn get platform => text().withDefault(const Constant('Unknown'))();
  TextColumn get title => text().withDefault(const Constant('Unknown'))();
  TextColumn get format => text().withDefault(const Constant('video'))();
  TextColumn get quality => text().withDefault(const Constant('best'))();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  IntColumn get progress => integer().withDefault(const Constant(0))();
  IntColumn get fileSize => integer().nullable()();
  TextColumn get fileSizeStr => text().nullable()();
  TextColumn get error => text().nullable()();
  TextColumn get localPath => text().nullable()();
  TextColumn get filename => text().nullable()();
  TextColumn get thumbnailUrl => text().nullable()();
  BoolColumn get isPrivate =>
      boolean().withDefault(const Constant(false))();
  TextColumn get vaultPath => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {taskId};
}

class PlaybackPositions extends Table {
  TextColumn get mediaId => text()();
  IntColumn get positionMs => integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {mediaId};
}

class SchemaMetadata extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

class MigrationRecords extends Table {
  TextColumn get id => text()();
  TextColumn get status =>
      text().withDefault(const Constant('pending'))();
  DateTimeColumn get startedAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get detail => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ── Database ──────────────────────────────────────────────────────────────────

@DriftDatabase(
  tables: [
    DownloadRecords,
    PlaybackPositions,
    SchemaMetadata,
    MigrationRecords,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? _openConnection());

  /// Schema version — bump when adding new tables or columns.
  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          // Record the initial schema version
          await into(schemaMetadata).insert(
            SchemaMetadataCompanion.insert(
              key: 'schema_version',
              value: '1',
            ),
          );
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'kurama_app.db'));
    return NativeDatabase.createInBackground(file);
  });
}
