# Kurama Phase 0 Stabilization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Introduce stable client and backend boundaries, transactional local persistence, versioned API contracts, and cross-platform build gates without changing Kurama's current user-visible download, browser, player, or vault behavior.

**Architecture:** The Flutter client gains an explicit composition root, semantic Lacquer & Gold tokens, feature-scoped controllers, repository interfaces, and a SQLite source of truth with one-release legacy mirroring. The FastAPI backend gains an application factory, typed errors, task repositories, download services, versioned `/v1` routes, and compatibility `/api` routes while retaining the current worker implementation. Phase 0 deliberately stops before automatic media scanning, the unified catalog UI, managed user authentication, and production worker-queue migration.

**Tech Stack:** Flutter/Dart, Provider, Drift/SQLite, SharedPreferences compatibility mirror, FastAPI, Pydantic, Python 3.11, unittest/httpx TestClient, GitHub Actions, Android/iOS/Windows runners.

## Global Constraints

- Local and completed media playback must never require the backend.
- Guest mode remains the complete local/offline product; account creation is not introduced in Phase 0.
- Android, iOS, and Windows are the Phase 0 build/test targets.
- The existing Android application ID and Dart package identity must remain unchanged.
- The approved visual direction is Lacquer & Gold; gold denotes playback progress, focus, confirmed selection, or the primary action.
- Interactive targets remain at least 44 pt on iOS and 48 dp on Android.
- No production shared secret may be compiled into a release client.
- Legacy `/api/*` routes remain available through a compatibility adapter for one migration release.
- SQLite migration must be transactional and reversible for one release by mirroring writes to the legacy SharedPreferences format.
- Billing, credits, subscriptions, payment receipts, automatic media scanning, account sync, PostgreSQL, durable queues, and object storage are outside this Phase 0 plan.
- Protected streams, DRM, paywalls, and access-control bypass remain out of scope.

---

## File structure and responsibilities

### Flutter files created

```text
mobile/lib/app/app.dart                       MaterialApp and application shell
mobile/lib/app/app_bootstrap.dart             startup ordering and dependency construction
mobile/lib/app/app_environment.dart           release endpoint and debug-only overrides
mobile/lib/app/app_router.dart                named routes and notification deep-link routing
mobile/lib/app/app_scope.dart                 typed dependency container and providers
mobile/lib/app/theme/kurama_colors.dart        semantic Lacquer & Gold color tokens
mobile/lib/app/theme/kurama_theme.dart         accessible Material 3 theme
mobile/lib/core/errors/app_failure.dart        stable client failure codes and recovery metadata
mobile/lib/domain/downloads/download_repository.dart
mobile/lib/domain/playback/playback_position_repository.dart
mobile/lib/features/downloads/download_controller.dart
mobile/lib/infrastructure/database/app_database.dart
mobile/lib/infrastructure/database/app_database.g.dart
mobile/lib/infrastructure/downloads/sqlite_download_repository.dart
mobile/lib/infrastructure/playback/sqlite_playback_position_repository.dart
mobile/lib/infrastructure/migration/legacy_state_reader.dart
mobile/lib/infrastructure/migration/legacy_state_migrator.dart
mobile/lib/infrastructure/migration/legacy_state_mirror.dart
mobile/test/app/app_environment_test.dart
mobile/test/app/kurama_theme_test.dart
mobile/test/domain/downloads/download_repository_contract.dart
mobile/test/features/downloads/download_controller_test.dart
mobile/test/infrastructure/database/app_database_test.dart
mobile/test/infrastructure/migration/legacy_state_migrator_test.dart
```

### Flutter files modified

```text
mobile/pubspec.yaml                            add Drift/code-generation dependencies
mobile/lib/main.dart                           delegate startup to app_bootstrap.dart
mobile/lib/services/app_state.dart             one-release compatibility facade
mobile/lib/services/download_storage.dart      expose legacy snapshot/mirror operations
mobile/lib/services/playback_position_store.dart one-release repository adapter
mobile/lib/services/api_client.dart            accept typed endpoint config and error envelopes
mobile/lib/screens/home_screen.dart             remove production API-key repair path
mobile/lib/screens/profile_screen.dart          hide server/key editing outside debug builds
mobile/lib/screens/*.dart                       consume DownloadController through facade/provider
mobile/lib/widgets/*.dart                       consume semantic theme tokens where touched
```

### Backend files created

```text
backend/kurama_api/__init__.py
backend/kurama_api/app.py                      FastAPI application factory
backend/kurama_api/config.py                   typed runtime settings
backend/kurama_api/auth.py                     legacy auth dependency boundary
backend/kurama_api/errors.py                   stable error envelope and handlers
backend/kurama_api/models.py                   task record and state definitions
backend/kurama_api/repositories.py              TaskRepository protocol and JSON implementation
backend/kurama_api/services/downloads.py        task orchestration and idempotency
backend/kurama_api/routers/health.py
backend/kurama_api/routers/v1_downloads.py
backend/kurama_api/routers/legacy.py
tests/test_backend_app_factory.py
tests/test_backend_task_repository.py
tests/test_backend_download_service.py
tests/test_backend_v1_contract.py
```

### Backend files modified

```text
backend/api_server.py                          compatibility import and legacy worker functions
backend/config.py                              delegate new settings while preserving imports
backend/requirements.txt                       retain runtime dependencies and add no database yet
deployment/Dockerfile                          launch kurama_api.app:create_app factory
tests/test_mobile_api.py                       target compatibility app with injected repositories
tests/test_ci_workflow.py                      assert platform and container gates
```

### Delivery files created or modified

```text
mobile/windows/**                              committed Windows runner generated once
.github/workflows/flutter_build.yml            Android, iOS, and Windows verification matrix
.github/workflows/backend_ci.yml               new package import and contract checks
docs/PHASE_0_MIGRATION.md                       rollout, rollback, and legacy-mirror removal gate
README.md                                       accurate supported-platform and backend boundaries
```

---

### Task 1: Pin Phase 0 repository boundaries with failing contract tests

**Files:**
- Create: `tests/test_phase0_architecture.py`
- Modify: `tests/test_repository_contract.py`
- Test: `tests/test_phase0_architecture.py`

**Interfaces:**
- Consumes: the approved design at `docs/superpowers/specs/2026-08-12-unified-media-hub-design.md`.
- Produces: executable repository rules used by every later task in this plan.

- [ ] **Step 1: Write the failing architecture contract test**

```python
from pathlib import Path
import unittest


ROOT = Path(__file__).parents[1]


class Phase0ArchitectureTests(unittest.TestCase):
    def test_flutter_composition_files_exist(self):
        for relative in (
            "mobile/lib/app/app.dart",
            "mobile/lib/app/app_bootstrap.dart",
            "mobile/lib/app/app_environment.dart",
            "mobile/lib/app/app_scope.dart",
            "mobile/lib/infrastructure/database/app_database.dart",
        ):
            with self.subTest(relative=relative):
                self.assertTrue((ROOT / relative).is_file(), relative)

    def test_backend_package_boundaries_exist(self):
        for relative in (
            "backend/kurama_api/app.py",
            "backend/kurama_api/errors.py",
            "backend/kurama_api/repositories.py",
            "backend/kurama_api/services/downloads.py",
            "backend/kurama_api/routers/v1_downloads.py",
            "backend/kurama_api/routers/legacy.py",
        ):
            with self.subTest(relative=relative):
                self.assertTrue((ROOT / relative).is_file(), relative)

    def test_phase0_does_not_add_server_database_or_queue_dependencies(self):
        requirements = (ROOT / "backend/requirements.txt").read_text(
            encoding="utf-8"
        ).lower()
        for forbidden in ("sqlalchemy", "psycopg", "redis", "celery", "rq"):
            with self.subTest(forbidden=forbidden):
                self.assertNotIn(forbidden, requirements)


if __name__ == "__main__":
    unittest.main()
```

- [ ] **Step 2: Add the release-secret rule to the repository contract**

Add this method to `RepositoryContractTests`:

```python
def test_release_client_has_no_api_key_setting_or_default(self):
    dart = "\n".join(
        path.read_text(encoding="utf-8")
        for path in (ROOT / "mobile/lib").rglob("*.dart")
    )
    self.assertNotRegex(dart, r"KURAMA_API_KEY\s*=\s*['\"][^'\"]+")
    self.assertNotIn("Fix Key", dart)
```

- [ ] **Step 3: Run the tests and confirm the expected boundary failures**

Run:

```powershell
python -m unittest tests.test_phase0_architecture tests.test_repository_contract -v
```

Expected: `test_flutter_composition_files_exist` and `test_backend_package_boundaries_exist` fail because the new boundaries do not exist. Existing repository-contract tests remain green.

- [ ] **Step 4: Commit the executable Phase 0 boundary**

```powershell
git add tests/test_phase0_architecture.py tests/test_repository_contract.py
git commit -m "test: define phase zero architecture boundaries"
```

### Task 2: Add typed application environment and Lacquer & Gold theme

**Files:**
- Create: `mobile/lib/app/app_environment.dart`
- Create: `mobile/lib/app/theme/kurama_colors.dart`
- Create: `mobile/lib/app/theme/kurama_theme.dart`
- Create: `mobile/test/app/app_environment_test.dart`
- Create: `mobile/test/app/kurama_theme_test.dart`
- Modify: `mobile/lib/main.dart`

**Interfaces:**
- Consumes: Flutter `kDebugMode`, `TargetPlatform`, and `ColorScheme`.
- Produces: `AppEnvironment.fromBuildConfig()`, `AppEnvironment.debug()`, `KuramaColors`, and `buildKuramaTheme()` for Task 5.

- [ ] **Step 1: Write the failing environment tests**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:kurama_mobile/app/app_environment.dart';

void main() {
  test('release configuration supplies the endpoint without an embedded key', () {
    const env = AppEnvironment.fromValues(
      apiBaseUrl: 'https://api.kurama.app',
    );
    expect(env.apiBaseUrl, 'https://api.kurama.app');
    expect(env.legacyApiKey, isNull);
    expect(env.allowEndpointEditing, isFalse);
  });

  test('debug override is explicit and never changes production defaults', () {
    const env = AppEnvironment.debug(
      apiBaseUrl: 'http://localhost:8000',
      legacyApiKey: 'local-only',
    );
    expect(env.apiBaseUrl, 'http://localhost:8000');
    expect(env.legacyApiKey, 'local-only');
    expect(env.allowEndpointEditing, isTrue);
  });
}
```

- [ ] **Step 2: Run the environment test and verify it fails**

Run:

```powershell
& 'C:\tmp\flutter-sdk\bin\flutter.bat' test test/app/app_environment_test.dart
```

Expected: FAIL because `AppEnvironment` does not exist.

- [ ] **Step 3: Implement the typed environment**

```dart
class AppEnvironment {
  final String apiBaseUrl;
  final String? legacyApiKey;
  final bool allowEndpointEditing;

  const AppEnvironment.fromValues({
    required this.apiBaseUrl,
    this.legacyApiKey,
    this.allowEndpointEditing = false,
  });

  factory AppEnvironment.fromBuildConfig() {
    const url = String.fromEnvironment('KURAMA_API_BASE_URL');
    const legacyKey = String.fromEnvironment('KURAMA_LEGACY_API_KEY');
    if (url.isEmpty) {
      throw StateError('KURAMA_API_BASE_URL is required for release builds.');
    }
    return AppEnvironment.fromValues(
      apiBaseUrl: url,
      legacyApiKey: legacyKey.isEmpty ? null : legacyKey,
    );
  }

  const AppEnvironment.debug({
    required this.apiBaseUrl,
    this.legacyApiKey,
  }) : allowEndpointEditing = true;
}
```

`KURAMA_LEGACY_API_KEY` is a migration-only build input for internal Phase 0 validation. Public rollout stays disabled until Phase 2 replaces it with managed sessions. No key value is stored in the repository or exposed in production settings.

- [ ] **Step 4: Write the failing semantic-theme test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kurama_mobile/app/theme/kurama_colors.dart';
import 'package:kurama_mobile/app/theme/kurama_theme.dart';

void main() {
  test('Lacquer and Gold tokens drive the dark color scheme', () {
    final theme = buildKuramaTheme();
    expect(theme.brightness, Brightness.dark);
    expect(theme.scaffoldBackgroundColor, KuramaColors.ink);
    expect(theme.colorScheme.primary, KuramaColors.gold);
    expect(theme.colorScheme.surface, KuramaColors.panel);
  });

  test('buttons keep Android minimum target height', () {
    final theme = buildKuramaTheme();
    expect(
      theme.filledButtonTheme.style?.minimumSize?.resolve({})?.height,
      greaterThanOrEqualTo(48),
    );
  });
}
```

- [ ] **Step 5: Implement semantic colors and the theme**

Define these exact tokens in `kurama_colors.dart`:

```dart
abstract final class KuramaColors {
  static const ink = Color(0xFF0B0809);
  static const panel = Color(0xFF181113);
  static const panelRaised = Color(0xFF211619);
  static const lacquer = Color(0xFF743533);
  static const gold = Color(0xFFD8B46A);
  static const goldHigh = Color(0xFFF1D79C);
  static const ivory = Color(0xFFF4E8D0);
  static const ash = Color(0xFFB9AA9C);
  static const success = Color(0xFF78B990);
  static const warning = Color(0xFFE0A75D);
  static const danger = Color(0xFFDC7871);
}
```

In `kurama_theme.dart`, create `buildKuramaTheme()` with Material 3, the semantic colors above, 48 dp minimum filled/outlined button sizes, visible focus/pressed overlays, and no per-screen raw accent color.

- [ ] **Step 6: Point `KuramaApp` at `buildKuramaTheme()` without changing routes**

Replace the private `_buildTheme()` implementation in `main.dart` with the imported `buildKuramaTheme()` for `theme` and `darkTheme`. Do not move bootstrap or navigation yet.

- [ ] **Step 7: Run focused and full Flutter tests**

Run:

```powershell
& 'C:\tmp\flutter-sdk\bin\flutter.bat' test test/app
& 'C:\tmp\flutter-sdk\bin\flutter.bat' test
```

Expected: both commands PASS and existing navigation behavior is unchanged.

- [ ] **Step 8: Commit the environment and theme boundary**

```powershell
git add mobile/lib/app mobile/lib/main.dart mobile/test/app
git commit -m "refactor: add typed app environment and theme"
```

### Task 3: Define download and playback repository contracts

**Files:**
- Create: `mobile/lib/core/errors/app_failure.dart`
- Create: `mobile/lib/domain/downloads/download_repository.dart`
- Create: `mobile/lib/domain/playback/playback_position_repository.dart`
- Create: `mobile/test/domain/downloads/download_repository_contract.dart`
- Modify: `mobile/lib/models/download_task.dart`

**Interfaces:**
- Consumes: existing `DownloadTask` JSON compatibility.
- Produces: `DownloadRepository`, `PlaybackPositionRepository`, `AppFailure`, and the expanded `DownloadStatus` used by Tasks 4-5.

- [ ] **Step 1: Expand the status test before changing the enum**

Add to `mobile/test/models/download_status_test.dart`:

```dart
test('durable download states survive JSON persistence', () {
  for (final status in DownloadStatus.values) {
    final task = DownloadTask(
      taskId: 'job-${status.name}',
      url: 'https://example.com/${status.name}',
      platform: 'Example',
      title: status.name,
      status: status,
    );
    expect(DownloadTask.fromJson(task.toJson()).status, status);
  }
});
```

- [ ] **Step 2: Run the status test and verify the new states are absent**

Run:

```powershell
& 'C:\tmp\flutter-sdk\bin\flutter.bat' test test/models/download_status_test.dart
```

Expected: the test compiles, but it covers only the existing four values; the next implementation adds the required durable state set.

- [ ] **Step 3: Add the exact Phase 0 status set and backward parser**

Replace the enum with:

```dart
enum DownloadStatus {
  pending,
  resolving,
  downloading,
  paused,
  waitingForNetwork,
  waitingForWifi,
  waitingForStorage,
  sourceRefreshRequired,
  verifying,
  completed,
  failed,
  cancelled,
}
```

Update `_parseStatus` to return the matching enum by `name` and map unknown legacy values to `pending`. Update `statusLabel` with explicit readable labels for all states.

- [ ] **Step 4: Define failures and repository signatures**

Use these public contracts:

```dart
enum RecoveryAction {
  retry,
  resume,
  refreshSource,
  waitForWifi,
  reviewStorage,
  changeDestination,
  chooseAnotherFormat,
  openInSourceApp,
  reportIssue,
}

class AppFailure implements Exception {
  final String code;
  final String message;
  final bool retryable;
  final RecoveryAction? recoveryAction;
  const AppFailure({
    required this.code,
    required this.message,
    this.retryable = false,
    this.recoveryAction,
  });
}
```

```dart
abstract interface class DownloadRepository {
  Future<List<DownloadTask>> list();
  Stream<List<DownloadTask>> watch();
  Future<DownloadTask?> find(String taskId);
  Future<void> upsert(DownloadTask task);
  Future<void> remove(String taskId);
}
```

```dart
abstract interface class PlaybackPositionRepository {
  Future<Duration> load(String mediaLocationKey);
  Future<void> save(String mediaLocationKey, Duration position);
  Future<void> clear(String mediaLocationKey);
}
```

- [ ] **Step 5: Write a reusable repository contract test**

`download_repository_contract.dart` exports:

```dart
void downloadRepositoryContract(
  String name,
  Future<DownloadRepository> Function() createRepository,
) {
  group(name, () {
    test('upsert, watch, find, and remove use taskId identity', () async {
      final repository = await createRepository();
      final task = DownloadTask(
        taskId: 'task-1',
        url: 'https://example.com/1',
        platform: 'Example',
        title: 'One',
      );
      await repository.upsert(task);
      expect((await repository.find('task-1'))?.title, 'One');
      expect(await repository.watch().first, hasLength(1));
      await repository.remove('task-1');
      expect(await repository.find('task-1'), isNull);
    });
  });
}
```

- [ ] **Step 6: Run model and analyzer checks**

Run:

```powershell
& 'C:\tmp\flutter-sdk\bin\flutter.bat' test test/models/download_status_test.dart
& 'C:\tmp\flutter-sdk\bin\flutter.bat' analyze --no-fatal-infos
```

Expected: PASS; switch statements in existing screens are updated exhaustively without changing their existing completed/downloading/failed visuals.

- [ ] **Step 7: Commit the domain contracts**

```powershell
git add mobile/lib/core mobile/lib/domain mobile/lib/models/download_task.dart mobile/test/domain mobile/test/models/download_status_test.dart
git commit -m "refactor: define durable media repository contracts"
```

### Task 4: Introduce SQLite and transactional legacy migration

**Files:**
- Modify: `mobile/pubspec.yaml`
- Create: `mobile/lib/infrastructure/database/app_database.dart`
- Generate: `mobile/lib/infrastructure/database/app_database.g.dart`
- Create: `mobile/lib/infrastructure/downloads/sqlite_download_repository.dart`
- Create: `mobile/lib/infrastructure/playback/sqlite_playback_position_repository.dart`
- Create: `mobile/lib/infrastructure/migration/legacy_state_reader.dart`
- Create: `mobile/lib/infrastructure/migration/legacy_state_migrator.dart`
- Create: `mobile/lib/infrastructure/migration/legacy_state_mirror.dart`
- Modify: `mobile/lib/services/download_storage.dart`
- Test: `mobile/test/infrastructure/database/app_database_test.dart`
- Test: `mobile/test/infrastructure/migration/legacy_state_migrator_test.dart`

**Interfaces:**
- Consumes: Task 3 repository interfaces and the existing `download_history` and `playback_positions` SharedPreferences values.
- Produces: `AppDatabase`, `SqliteDownloadRepository`, `SqlitePlaybackPositionRepository`, and `LegacyStateMigrator.migrateOnce()` for Task 5.

- [ ] **Step 1: Add database dependencies through Flutter package resolution**

Run from `mobile/`:

```powershell
& 'C:\tmp\flutter-sdk\bin\flutter.bat' pub add drift sqlite3_flutter_libs uuid
& 'C:\tmp\flutter-sdk\bin\flutter.bat' pub add --dev drift_dev build_runner
```

Expected: `pubspec.yaml` and `pubspec.lock` resolve compatible versions without changing the Flutter SDK constraint.

- [ ] **Step 2: Write the failing database test**

```dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kurama_mobile/infrastructure/database/app_database.dart';

void main() {
  test('database starts at schema version one with required tables', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    expect(db.schemaVersion, 1);
    final tables = await db.customSelect(
      "SELECT name FROM sqlite_master WHERE type = 'table'",
    ).get();
    final names = tables.map((row) => row.read<String>('name')).toSet();
    expect(names, containsAll({
      'download_records',
      'playback_positions',
      'schema_metadata',
      'migration_records',
    }));
    await db.close();
  });
}
```

- [ ] **Step 3: Define the Phase 0 schema**

`app_database.dart` must define:

```dart
class DownloadRecords extends Table {
  TextColumn get taskId => text()();
  TextColumn get payloadJson => text()();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column<Object>> get primaryKey => {taskId};
}

class PlaybackPositions extends Table {
  TextColumn get mediaLocationKey => text()();
  IntColumn get positionSeconds => integer()();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column<Object>> get primaryKey => {mediaLocationKey};
}

class SchemaMetadata extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  @override
  Set<Column<Object>> get primaryKey => {key};
}

class MigrationRecords extends Table {
  TextColumn get migrationId => text()();
  DateTimeColumn get completedAt => dateTime()();
  IntColumn get importedDownloads => integer()();
  IntColumn get importedPositions => integer()();
  @override
  Set<Column<Object>> get primaryKey => {migrationId};
}
```

Use `schemaVersion => 1`, a file-backed production constructor, and `AppDatabase.forTesting(QueryExecutor executor)`.

- [ ] **Step 4: Generate Drift code and run the database test**

Run:

```powershell
& 'C:\tmp\flutter-sdk\bin\cache\dart-sdk\bin\dart.exe' run build_runner build --delete-conflicting-outputs
& 'C:\tmp\flutter-sdk\bin\flutter.bat' test test/infrastructure/database/app_database_test.dart
```

Expected: PASS.

- [ ] **Step 5: Implement SQLite repositories and run the shared contract**

`SqliteDownloadRepository` serializes `DownloadTask.toJson()` into `payloadJson`, orders `list()` by `updatedAt DESC`, and publishes changes with a Drift watch query. Its constructor is `SqliteDownloadRepository(AppDatabase db, {LegacyStateMirror mirror = const NoopLegacyStateMirror()})`. `SqlitePlaybackPositionRepository` uses the equivalent optional mirror and stores positive whole seconds while removing zero/cleared positions.

Instantiate the shared contract in `app_database_test.dart`:

```dart
downloadRepositoryContract('SQLite download repository', () async {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  addTearDown(db.close);
  return SqliteDownloadRepository(db);
});
```

- [ ] **Step 6: Write the failing transactional migration test**

```dart
test('legacy migration imports once and retains legacy values', () async {
  SharedPreferences.setMockInitialValues({
    'download_history': jsonEncode([
      DownloadTask(
        taskId: 'legacy-1',
        url: 'https://example.com/1',
        platform: 'Example',
        title: 'Legacy item',
      ).toJson(),
    ]),
    'playback_positions': jsonEncode({'/media/one.mp4': 37}),
  });
  final prefs = await SharedPreferences.getInstance();
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  final migrator = LegacyStateMigrator(db, LegacyStateReader(prefs));

  final first = await migrator.migrateOnce();
  final second = await migrator.migrateOnce();

  expect(first.importedDownloads, 1);
  expect(first.importedPositions, 1);
  expect(second.alreadyCompleted, isTrue);
  expect(prefs.getString('download_history'), isNotNull);
  expect(prefs.getString('playback_positions'), isNotNull);
  await db.close();
});
```

- [ ] **Step 7: Implement `LegacyStateMigrator.migrateOnce()` as one transaction**

Use migration ID `phase0_shared_preferences_to_sqlite_v1`. Parse corrupt individual entries defensively, but let database failures abort the transaction and leave the migration record absent. Do not remove legacy keys.

- [ ] **Step 8: Implement the one-release mirror**

`LegacyStateMirror` exposes:

```dart
abstract interface class LegacyStateMirror {
  Future<void> replaceDownloads(List<DownloadTask> downloads);
  Future<void> savePlaybackPosition(String key, Duration position);
  Future<void> clearPlaybackPosition(String key);
}
```

The SharedPreferences implementation writes the existing JSON shapes. SQLite repositories call the mirror after a successful database transaction. A mirror failure is logged but does not roll back SQLite; this keeps the new database authoritative while maximizing rollback compatibility.

- [ ] **Step 9: Run migration and repository tests**

Run:

```powershell
& 'C:\tmp\flutter-sdk\bin\flutter.bat' test test/infrastructure
```

Expected: PASS, including corrupt-legacy-entry, second-run idempotency, and legacy-key-retention tests.

- [ ] **Step 10: Commit SQLite and migration infrastructure**

```powershell
git add mobile/pubspec.yaml mobile/pubspec.lock mobile/lib/infrastructure mobile/lib/services/download_storage.dart mobile/test/infrastructure
git commit -m "feat: migrate durable client state to sqlite"
```

### Task 5: Add the composition root and compatibility facade

**Files:**
- Create: `mobile/lib/app/app.dart`
- Create: `mobile/lib/app/app_bootstrap.dart`
- Create: `mobile/lib/app/app_router.dart`
- Create: `mobile/lib/app/app_scope.dart`
- Create: `mobile/lib/features/downloads/download_controller.dart`
- Create: `mobile/test/features/downloads/download_controller_test.dart`
- Modify: `mobile/lib/main.dart`
- Modify: `mobile/lib/services/app_state.dart`
- Modify: `mobile/lib/services/background_download_service.dart`
- Modify: `mobile/lib/services/playback_position_store.dart`
- Modify: `mobile/lib/screens/home_screen.dart`
- Modify: `mobile/lib/screens/profile_screen.dart`

**Interfaces:**
- Consumes: `AppEnvironment`, `AppDatabase`, repositories, migrator, existing `ApiClient`, notification service, and background service.
- Produces: `AppBootstrap.initialize() -> Future<AppDependencies>`, `KuramaApp`, `AppScope`, and a repository-backed compatibility `AppState`.

- [ ] **Step 1: Write the failing controller test**

```dart
class MemoryDownloadRepository implements DownloadRepository {
  final _items = <String, DownloadTask>{};
  final _changes = StreamController<List<DownloadTask>>.broadcast();
  @override Future<List<DownloadTask>> list() async => _items.values.toList();
  @override Stream<List<DownloadTask>> watch() => _changes.stream;
  @override Future<DownloadTask?> find(String id) async => _items[id];
  @override Future<void> upsert(DownloadTask task) async {
    _items[task.taskId] = task;
    _changes.add(await list());
  }
  @override Future<void> remove(String id) async {
    _items.remove(id);
    _changes.add(await list());
  }
}

test('controller exposes repository changes and persists mutations', () async {
  final repository = MemoryDownloadRepository();
  final controller = DownloadController(repository);
  await controller.initialize();
  await controller.upsert(DownloadTask(
    taskId: 'one',
    url: 'https://example.com/one',
    platform: 'Example',
    title: 'One',
  ));
  expect(controller.downloads.single.taskId, 'one');
  await controller.disposeAsync();
});
```

- [ ] **Step 2: Implement `DownloadController`**

The controller owns a repository subscription, immutable `List<DownloadTask>`, `initialize`, `upsert`, `remove`, `moveToVault`, `restoreFromVault`, and `disposeAsync`. It does not own `ApiClient` or a numeric user ID.

- [ ] **Step 3: Define `AppDependencies` and startup order**

`AppBootstrap.initialize()` performs this exact sequence:

```text
Widgets binding -> background audio -> notifications -> background worker
-> SharedPreferences -> AppDatabase -> legacy migration
-> repositories -> DownloadController.initialize
-> environment/API client -> AppDependencies
```

If database open or migration fails, startup shows a recoverable local-data error route; it must not silently fall back to empty state.

- [ ] **Step 4: Move MaterialApp, shell, and routes out of `main.dart`**

`main.dart` becomes:

```dart
Future<void> main() async {
  final dependencies = await AppBootstrap.initialize();
  runApp(AppScope(
    dependencies: dependencies,
    child: const KuramaApp(),
  ));
}
```

`app.dart` owns `MaterialApp`, `buildKuramaTheme()`, and `AppShell`. `app_router.dart` owns player route construction for notification launches.

- [ ] **Step 5: Make `AppState` a one-release facade**

Keep the public methods used by existing screens, but delegate download reads and mutations to `DownloadController`. Keep `ApiClient client` and the legacy numeric `userId` in the facade until Phase 2 replaces authentication. Mark the class documentation as a compatibility facade scheduled for removal after all screens use feature controllers.

- [ ] **Step 6: Route background and playback writes through repositories**

Inject `DownloadRepository` into background-download reconciliation. Add `PlaybackPositionStore.configure(PlaybackPositionRepository repository)` and delegate its existing static methods to that configured repository; call `configure` during bootstrap before `runApp`. This retains the static API only as a temporary adapter used by existing player widgets.

- [ ] **Step 7: Remove user-facing production API-key repair**

Home and Profile must distinguish `connected`, `offline`, and `serviceUnavailable`, but must not ask a release user to paste an API key. Endpoint/key editing is rendered only when `AppEnvironment.allowEndpointEditing` is true. Production displays `Try again` and a diagnostic code.

- [ ] **Step 8: Run controller, widget, and full Flutter verification**

Run:

```powershell
& 'C:\tmp\flutter-sdk\bin\flutter.bat' test test/features/downloads/download_controller_test.dart
& 'C:\tmp\flutter-sdk\bin\flutter.bat' test
& 'C:\tmp\flutter-sdk\bin\flutter.bat' analyze --no-fatal-infos
```

Expected: PASS. Existing browser, download, player, and vault flows retain their current behavior through adapters.

- [ ] **Step 9: Commit the client composition root**

```powershell
git add mobile/lib/app mobile/lib/features mobile/lib/main.dart mobile/lib/services mobile/lib/screens/home_screen.dart mobile/lib/screens/profile_screen.dart mobile/test/features
git commit -m "refactor: compose client through repositories"
```

### Task 6: Create the FastAPI application factory and stable error envelope

**Files:**
- Create: `backend/kurama_api/__init__.py`
- Create: `backend/kurama_api/config.py`
- Create: `backend/kurama_api/auth.py`
- Create: `backend/kurama_api/errors.py`
- Create: `backend/kurama_api/app.py`
- Create: `backend/kurama_api/routers/__init__.py`
- Create: `backend/kurama_api/routers/health.py`
- Create: `tests/test_backend_app_factory.py`
- Modify: `backend/api_server.py`

**Interfaces:**
- Consumes: existing `backend/config.py` values and legacy Bearer authentication.
- Produces: `create_app(settings: Settings | None = None) -> FastAPI`, `ApiError`, and `/v1/health` for Tasks 7-8.

- [ ] **Step 1: Write the failing app-factory tests**

```python
import os
import sys
import unittest
from fastapi.testclient import TestClient

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "backend"))

from kurama_api.app import create_app
from kurama_api.config import Settings


class AppFactoryTests(unittest.TestCase):
    def setUp(self):
        self.client = TestClient(create_app(Settings.for_testing()))

    def test_v1_health_has_versioned_contract(self):
        response = self.client.get("/v1/health")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json()["service"], "kurama-api")
        self.assertEqual(response.json()["status"], "ok")

    def test_api_error_uses_stable_envelope_and_request_id(self):
        response = self.client.get("/v1/test/not-found")
        self.assertEqual(response.status_code, 404)
        body = response.json()["error"]
        self.assertEqual(body["code"], "route_not_found")
        self.assertFalse(body["retryable"])
        self.assertIn("request_id", body)
```

- [ ] **Step 2: Run the tests and verify imports fail**

Run:

```powershell
$env:PYTHONPATH='backend'; python -m unittest tests.test_backend_app_factory -v
```

Expected: FAIL with `ModuleNotFoundError: kurama_api`.

- [ ] **Step 3: Implement typed settings and error types**

Use:

```python
@dataclass(frozen=True)
class Settings:
    api_auth_key: str | None
    api_admin_key: str | None
    allowed_origins: tuple[str, ...]
    temp_folder: str
    task_ttl_seconds: int
    max_concurrent_downloads: int

    @classmethod
    def from_environment(cls) -> "Settings":
        origins = tuple(
            item.strip()
            for item in os.getenv("CORS_ALLOWED_ORIGINS", "").split(",")
            if item.strip()
        ) or ("http://localhost:3000", "http://127.0.0.1:3000")
        return cls(
            api_auth_key=os.getenv("KURAMA_API_KEY") or None,
            api_admin_key=os.getenv("KURAMA_ADMIN_KEY") or None,
            allowed_origins=origins,
            temp_folder=os.getenv("KURAMA_TEMP_FOLDER", str(Path(__file__).parents[1] / "temp_mobile")),
            task_ttl_seconds=int(os.getenv("TASK_TTL", "3600")),
            max_concurrent_downloads=int(os.getenv("MAX_CONCURRENT_DOWNLOADS", "5")),
        )

    @classmethod
    def for_testing(cls, temp_folder: str | None = None) -> "Settings":
        return cls(
            api_auth_key="test-key",
            api_admin_key="test-admin-key",
            allowed_origins=("http://testserver",),
            temp_folder=temp_folder or tempfile.mkdtemp(prefix="kurama-api-test-"),
            task_ttl_seconds=3600,
            max_concurrent_downloads=5,
        )
```

Import `os`, `tempfile`, `Path`, and `dataclass` in this module.

`ApiError` has `status_code`, `code`, `message`, `retryable`, and `recovery_action`. Exception handlers add or propagate `X-Request-ID` and return:

```json
{
  "error": {
    "code": "route_not_found",
    "message": "The requested API route does not exist.",
    "retryable": false,
    "recovery_action": null,
    "request_id": "generated-uuid"
  }
}
```

- [ ] **Step 4: Implement the factory and health router**

`create_app(settings: Settings | None = None)` resolves `Settings.from_environment()` only when no settings are supplied, then adds middleware, exception handlers, and `/v1/health`. It must not load task state at import time.

- [ ] **Step 5: Keep `api_server.app` compatible**

At the bottom of the migration step, `backend/api_server.py` must export `app = create_app(Settings.from_environment())` while retaining current legacy routes until Task 8 moves them. Existing imports of `api_server.app` must still work.

- [ ] **Step 6: Run factory and existing API tests**

Run:

```powershell
$env:PYTHONPATH='backend'; $env:KURAMA_API_KEY='test-key'; python -m unittest tests.test_backend_app_factory tests.test_mobile_api -v
```

Expected: PASS.

- [ ] **Step 7: Commit the application factory**

```powershell
git add backend/kurama_api backend/api_server.py tests/test_backend_app_factory.py
git commit -m "refactor: add backend application factory"
```

### Task 7: Extract task persistence and download orchestration

**Files:**
- Create: `backend/kurama_api/models.py`
- Create: `backend/kurama_api/repositories.py`
- Create: `backend/kurama_api/services/__init__.py`
- Create: `backend/kurama_api/services/downloads.py`
- Create: `tests/test_backend_task_repository.py`
- Create: `tests/test_backend_download_service.py`
- Modify: `backend/api_server.py`

**Interfaces:**
- Consumes: existing worker callables `background_download` and `background_playlist_download`, plus legacy credit callbacks isolated behind a compatibility policy.
- Produces: `TaskRecord`, `TaskRepository`, `JsonTaskRepository`, `DownloadService`, and `CreateDownloadCommand` for Task 8.

- [ ] **Step 1: Write the failing JSON repository recovery test**

```python
class JsonTaskRepositoryTests(unittest.TestCase):
    def test_interrupted_task_is_recovered_without_deleting_progress(self):
        path = Path(self.temp.name) / "tasks.json"
        path.write_text(json.dumps({
            "job-1": {
                "task_id": "job-1",
                "status": "downloading",
                "progress": 68,
                "downloaded_bytes": 680,
                "total_bytes": 1000,
                "created_at": 1.0,
                "updated_at": 2.0,
            }
        }), encoding="utf-8")
        repository = JsonTaskRepository(path)
        task = repository.get("job-1")
        self.assertEqual(task.status, TaskStatus.waiting_for_worker)
        self.assertEqual(task.progress, 68)
        self.assertEqual(task.downloaded_bytes, 680)
```

- [ ] **Step 2: Define task state and repository protocol**

```python
class TaskStatus(StrEnum):
    pending = "pending"
    waiting_for_worker = "waiting_for_worker"
    downloading = "downloading"
    verifying = "verifying"
    completed = "completed"
    failed = "failed"
    cancelled = "cancelled"

@dataclass
class TaskRecord:
    task_id: str
    owner_id: str
    client_request_id: str
    url: str
    format: str
    status: TaskStatus
    progress: int
    downloaded_bytes: int
    total_bytes: int | None
    created_at: float
    updated_at: float
    error_code: str | None = None
    error_message: str | None = None
```

```python
class TaskRepository(Protocol):
    def create(self, task: TaskRecord) -> TaskRecord:
        raise NotImplementedError
    def get(self, task_id: str) -> TaskRecord | None:
        raise NotImplementedError
    def find_by_request(self, owner_id: str, client_request_id: str) -> TaskRecord | None:
        raise NotImplementedError
    def update(self, task: TaskRecord) -> TaskRecord:
        raise NotImplementedError
    def list(self) -> list[TaskRecord]:
        raise NotImplementedError
    def delete(self, task_id: str) -> bool:
        raise NotImplementedError
```

- [ ] **Step 3: Implement atomic JSON persistence behind the protocol**

Use lock + temporary file + `os.replace`, preserve unknown legacy fields in `TaskRecord.extra`, and map recovered `pending`/`downloading` tasks to `waiting_for_worker` without resetting byte/progress fields. The repository must not call credit or billing code.

- [ ] **Step 4: Write the failing idempotent service test**

```python
def test_create_returns_existing_task_for_same_owner_and_request_id(self):
    repository = InMemoryTaskRepository()
    spawned = []
    service = DownloadService(repository, spawn=lambda task: spawned.append(task.task_id))
    command = CreateDownloadCommand(
        owner_id="legacy-user-7",
        client_request_id="request-abc",
        url="https://example.com/video",
        format="video",
    )
    first = service.create(command)
    second = service.create(command)
    self.assertEqual(first.task_id, second.task_id)
    self.assertEqual(spawned, [first.task_id])
```

- [ ] **Step 5: Implement `DownloadService`**

`create` validates concurrency through an injected policy, checks `find_by_request`, persists before spawning, and returns the existing record for duplicates. `retry` accepts only failed or waiting-for-worker states, preserves the task ID, increments attempt count, and delegates legacy charging/refund to an injected `LegacyEntitlementPolicy` so billing is not embedded in repositories or routes.

Extend the factory signature here to `create_app(settings: Settings | None = None, task_repository: TaskRepository | None = None, download_service: DownloadService | None = None)`. When dependencies are omitted, build `JsonTaskRepository` and `DownloadService` from the resolved settings. This exact optional signature is used by Task 8 tests and by the Uvicorn `--factory` command in Task 9.

- [ ] **Step 6: Adapt legacy worker hooks to repository updates**

Replace direct `download_tasks[task_id]` writes in progress and completion hooks with `repository.get` + `repository.update`. Keep a temporary `download_tasks` mapping adapter only for old tests and administrative compatibility; mark it for removal after the compatibility release.

- [ ] **Step 7: Run repository, service, and existing backend tests**

Run:

```powershell
$env:PYTHONPATH='backend'; $env:KURAMA_API_KEY='test-key'; python -m unittest tests.test_backend_task_repository tests.test_backend_download_service tests.test_mobile_api -v
```

Expected: PASS. Restart recovery preserves progress and legacy credit behavior still passes through the compatibility policy.

- [ ] **Step 8: Commit backend repositories and services**

```powershell
git add backend/kurama_api backend/api_server.py tests/test_backend_task_repository.py tests/test_backend_download_service.py tests/test_mobile_api.py
git commit -m "refactor: isolate backend task orchestration"
```

### Task 8: Add `/v1` idempotency and preserve `/api` compatibility

**Files:**
- Create: `backend/kurama_api/routers/v1_downloads.py`
- Create: `backend/kurama_api/routers/legacy.py`
- Create: `tests/test_backend_v1_contract.py`
- Modify: `backend/kurama_api/app.py`
- Modify: `backend/api_server.py`
- Modify: `mobile/lib/services/api_client.dart`
- Modify: `mobile/test/services/api_exception_test.dart`

**Interfaces:**
- Consumes: `DownloadService`, legacy auth, TaskRepository, and current `/api` response shapes.
- Produces: `POST /v1/downloads`, `GET /v1/downloads/{id}`, stable errors, client request IDs, and unchanged `/api/*` routes.

- [ ] **Step 1: Write the failing `/v1` idempotency contract test**

```python
def test_same_idempotency_key_returns_same_job(self):
    headers = {
        "Authorization": "Bearer test-key",
        "Idempotency-Key": "6b66e36a-708a-4ea0-9456-bbe28fcb28e8",
    }
    payload = {"url": "https://example.com/video", "format": "video"}
    first = self.client.post("/v1/downloads", headers=headers, json=payload)
    second = self.client.post("/v1/downloads", headers=headers, json=payload)
    self.assertEqual(first.status_code, 202)
    self.assertEqual(second.status_code, 200)
    self.assertEqual(first.json()["download_id"], second.json()["download_id"])
    self.assertTrue(second.json()["idempotent_replay"])
```

- [ ] **Step 2: Write stable error-shape tests**

Cover missing idempotency key (`400`, `idempotency_key_required`), unsupported URL (`400`, `unsupported_source`), unavailable capacity (`429`, `worker_capacity_reached`, retryable), missing job (`404`, `download_not_found`), and bad legacy key (`401`, `invalid_legacy_credential`).

- [ ] **Step 3: Implement the versioned router**

Required request/response:

```python
class CreateDownloadBody(BaseModel):
    url: HttpUrl
    format: Literal["video", "audio"] = "video"
    video_quality: str = "best"
    audio_quality: str = "best"
    thumbnail: HttpUrl | None = None
    playlist: bool = False

class DownloadEnvelope(BaseModel):
    download_id: str
    status: str
    idempotent_replay: bool
```

The temporary legacy identity maps the authenticated key plus numeric user ID, when present, to `legacy-user-{user_id}`. Managed session identity replaces this mapping in Phase 2.

- [ ] **Step 4: Move old routes into the compatibility router**

`routers/legacy.py` retains the exact existing `/api/health`, `/api/platforms`, `/api/fetch-info`, `/api/download`, status, retry, stream, file, profile, payment, and admin route shapes. The download routes call `DownloadService`; profile/payment routes continue to call `user_config` only inside this router.

- [ ] **Step 5: Make `backend/api_server.py` a compatibility module**

It exports `app`, `run_api_server`, worker callables, and aliases required by current tests, but no longer declares FastAPI route functions. Add an architecture test asserting no `@app.` decorators remain in `api_server.py`.

- [ ] **Step 6: Teach the Flutter client to send a request ID and parse error envelopes**

Add optional `clientRequestId` to `ApiClient.startDownload`; default it to a generated UUID and send it as `Idempotency-Key` for `/v1`. During the compatibility release, a feature flag selects `/v1` or `/api`. Extend `ApiException` with `code`, `retryable`, and `RecoveryAction? recoveryAction`; fall back to legacy `detail` parsing when the envelope is absent.

- [ ] **Step 7: Run contract and compatibility suites**

Run:

```powershell
$env:PYTHONPATH='backend'; $env:KURAMA_API_KEY='test-key'; python -m unittest tests.test_backend_v1_contract tests.test_mobile_api -v
& 'C:\tmp\flutter-sdk\bin\flutter.bat' test test/services/api_exception_test.dart
```

Expected: `/v1` contract tests PASS and every legacy mobile API test remains green.

- [ ] **Step 8: Commit versioned contracts and compatibility routes**

```powershell
git add backend/kurama_api backend/api_server.py mobile/lib/services/api_client.dart mobile/test/services/api_exception_test.dart tests/test_backend_v1_contract.py tests/test_mobile_api.py
git commit -m "feat: add versioned idempotent download api"
```

### Task 9: Commit platform runners and enforce the build matrix

**Files:**
- Create: `mobile/windows/**`
- Modify: `.github/workflows/flutter_build.yml`
- Modify: `.github/workflows/backend_ci.yml`
- Modify: `tests/test_ci_workflow.py`
- Modify: `deployment/Dockerfile`

**Interfaces:**
- Consumes: the refactored Flutter application and `kurama_api.app:create_app`.
- Produces: reproducible Android, iOS, Windows, backend-test, and container gates.

- [ ] **Step 1: Add failing CI contract assertions**

Add to `FlutterWorkflowTests`:

```python
def test_windows_runner_is_committed_and_not_generated_in_ci(self):
    workflow = self.workflow_text()
    self.assertTrue((self.root / "mobile/windows/runner/main.cpp").is_file())
    self.assertNotIn("flutter create --platforms=windows", workflow)

def test_ios_unsigned_build_is_a_pull_request_gate(self):
    workflow = self.workflow_text()
    self.assertIn("build_ios", workflow)
    self.assertIn("runs-on: macos-15", workflow)
    self.assertIn("flutter build ios --release --no-codesign", workflow)

def test_all_client_jobs_run_tests_or_depend_on_a_test_job(self):
    workflow = self.workflow_text()
    self.assertIn("test_flutter", workflow)
    self.assertIn("needs: test_flutter", workflow)

def test_container_uses_application_factory(self):
    dockerfile = (self.root / "deployment/Dockerfile").read_text(encoding="utf-8")
    self.assertIn("kurama_api.app:create_app", dockerfile)
    self.assertIn("--factory", dockerfile)
```

- [ ] **Step 2: Run the CI contract and verify failures**

Run:

```powershell
python -m unittest tests.test_ci_workflow -v
```

Expected: the four new tests FAIL.

- [ ] **Step 3: Generate and commit the Windows runner once**

Run from `mobile/`:

```powershell
& 'C:\tmp\flutter-sdk\bin\flutter.bat' create --platforms=windows .
```

Review generated changes. Keep the existing package identity and Kurama App display name. Do not regenerate Android or iOS.

- [ ] **Step 4: Refactor Flutter CI into test and platform jobs**

Add `test_flutter` on Ubuntu to run `flutter test` and `flutter analyze --no-fatal-infos`. Make Android, iOS, and Windows jobs depend on it. Remove Windows runner generation. Add `build_ios` on `macos-15` running `flutter build ios --release --no-codesign`. Keep signed release publication limited to the already configured release artifacts until iOS distribution receives its own signing plan.

- [ ] **Step 5: Launch the backend through the factory**

Change the Docker command to:

```dockerfile
CMD ["uvicorn", "kurama_api.app:create_app", "--factory", "--host", "0.0.0.0", "--port", "8000"]
```

Update backend CI to run the complete unit suite before the container build.

- [ ] **Step 6: Run CI contract, builds available locally, and container build**

Run:

```powershell
python -m unittest tests.test_ci_workflow -v
& 'C:\tmp\flutter-sdk\bin\flutter.bat' build apk --debug
& 'C:\tmp\flutter-sdk\bin\flutter.bat' build windows --debug
docker build -f deployment/Dockerfile -t kurama-phase0 .
```

Expected: all commands PASS. The iOS build is verified by GitHub Actions on macOS.

- [ ] **Step 7: Commit reproducible platform gates**

```powershell
git add mobile/windows .github/workflows deployment/Dockerfile tests/test_ci_workflow.py
git commit -m "ci: gate android ios windows and backend builds"
```

### Task 10: Document migration, execute the Phase 0 exit gate, and tag rollback conditions

**Files:**
- Create: `docs/PHASE_0_MIGRATION.md`
- Modify: `README.md`
- Modify: `tests/test_migration_manifest.py`
- Modify: `tests/test_mobile_configuration.py`

**Interfaces:**
- Consumes: every Phase 0 task and the acceptance criteria in the approved design.
- Produces: operator-readable rollout/rollback procedure and a verified Phase 0 completion commit.

- [ ] **Step 1: Add failing documentation-contract tests**

```python
def test_phase0_runbook_defines_rollout_and_rollback(self):
    text = (ROOT / "docs/PHASE_0_MIGRATION.md").read_text(encoding="utf-8")
    for required in (
        "phase0_shared_preferences_to_sqlite_v1",
        "Legacy mirror retention",
        "Rollback procedure",
        "Mirror removal gate",
        "Database backup",
        "API compatibility window",
    ):
        self.assertIn(required, text)
```

Add to `MobileConfigurationTests`:

```python
def test_production_endpoint_is_official_and_not_legacy_telegram(self):
    environment = (ROOT / "mobile/lib/app/app_environment.dart").read_text(
        encoding="utf-8"
    )
    self.assertIn("KURAMA_API_BASE_URL", environment)
    self.assertNotIn("kurama-telebot.onrender.com", environment)
```

- [ ] **Step 2: Write the migration runbook with exact rollback decisions**

`docs/PHASE_0_MIGRATION.md` must state:

```text
Rollout cohort: internal -> 5% -> 25% -> 100%
Pause threshold: migration failure > 0.5% or crash-free sessions < 99.5%
Rollback: ship previous client while the legacy mirror is retained
Legacy mirror retention: one full stable release after Phase 0 reaches 100%
Mirror removal gate: 30 days at 100%, migration failure < 0.1%, no rollback
Database backup: copy SQLite file before any future destructive schema migration
API compatibility window: /api routes remain through the same stable-release window
```

Document how to inspect migration records, verify record counts, preserve the database during app upgrades, and restore the previous release without deleting user files.

- [ ] **Step 3: Update README promises**

Describe Android, iOS, and Windows as verified build targets; describe macOS/Linux as planned adapter targets; describe web as a later limited client. Replace downloader-only wording with the Phase 0 foundation for the unified media hub while making clear that later features are not yet shipped.

- [ ] **Step 4: Run the complete repository verification**

Run:

```powershell
$env:PYTHONPATH='backend'; $env:KURAMA_API_KEY='test-key'; python -m unittest discover -s tests -v
& 'C:\tmp\flutter-sdk\bin\flutter.bat' test
& 'C:\tmp\flutter-sdk\bin\flutter.bat' analyze --no-fatal-infos
& 'C:\tmp\flutter-sdk\bin\flutter.bat' build apk --debug
& 'C:\tmp\flutter-sdk\bin\flutter.bat' build windows --debug
git diff --check
```

Expected: every command PASS. There are no unstaged generated database files, release secrets, temporary databases, task JSON files, or signing artifacts.

- [ ] **Step 5: Perform manual Phase 0 smoke checks**

On an Android device/emulator and Windows build, verify:

```text
1. Upgrade from a fixture containing legacy downloads and playback positions.
2. Confirm record counts and resume positions after migration.
3. Add/update/remove a download and confirm the legacy mirror changes.
4. Open local downloaded audio/video with the backend blocked.
5. Exercise browser detection, current download, notification-open, and vault round trip.
6. Confirm production UI has no API-key entry or “Fix Key” action.
7. Restart during a transfer and confirm reconciliation preserves recorded progress.
```

- [ ] **Step 6: Commit Phase 0 documentation and final verification changes**

```powershell
git add README.md docs/PHASE_0_MIGRATION.md tests/test_migration_manifest.py tests/test_mobile_configuration.py
git commit -m "docs: define phase zero rollout and rollback"
```

- [ ] **Step 7: Record the Phase 0 exit evidence in the pull request**

Include the exact test/build command outputs, migration fixture counts, Android/Windows smoke results, GitHub iOS job URL, and confirmation that `.agents/`, `.superpowers/`, local databases, secrets, and generated build outputs are not included in the change set.

---

## Phase 0 completion gate

Phase 0 is complete only when all ten tasks are committed, the full Python and Flutter suites pass, Android and Windows debug builds succeed locally, the iOS unsigned build succeeds in CI, legacy data migrates once without deletion, compatibility writes remain current, `/v1` idempotency works, every `/api` contract test remains green, production UI contains no API-key repair path, and rollback instructions have been exercised against a fixture.

After this gate, write the focused Phase 1 specification and plan for the automatic local-media index, unified catalog, Home/Library redesign, and approved players. Do not begin Phase 1 inside a Phase 0 pull request.
