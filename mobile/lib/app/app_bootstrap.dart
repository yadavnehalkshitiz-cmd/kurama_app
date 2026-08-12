import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_environment.dart';
import 'app_scope.dart';
import '../infrastructure/database/app_database.dart';
import '../infrastructure/migration/legacy_state_migrator.dart';
import '../infrastructure/downloads/sqlite_download_repository.dart';
import '../infrastructure/playback/sqlite_playback_position_repository.dart';
import '../services/api_client.dart';

/// Bootstraps all platform dependencies in the correct order.
///
/// Call [AppBootstrap.initialize] once inside [main] before [runApp].
class AppBootstrap {
  const AppBootstrap._();

  /// Initialise platform services and return a configured [AppScope].
  static Future<AppScope> initialize(AppEnvironment env) async {
    // 1. Flutter binding must be ready before any plugin calls.
    WidgetsFlutterBinding.ensureInitialized();

    // 2. Open the Drift database (creates file on first launch).
    final db = AppDatabase();

    // 3. Run the one-shot legacy migration (idempotent).
    try {
      final migrated = await LegacyStateMigrator(db).run();
      debugPrint('[Bootstrap] Migration: $migrated tasks moved to SQLite');
    } catch (e) {
      // Non-fatal: app works without migration; old data stays in prefs.
      debugPrint('[Bootstrap] Migration skipped: $e');
    }

    // 4. Recover any interrupted downloads.
    final downloadRepo = SqliteDownloadRepository(db);
    await downloadRepo.recoverInterruptedTasks();

    // 5. Build remaining dependencies.
    final playbackRepo = SqlitePlaybackPositionRepository(db);
    final prefs = await SharedPreferences.getInstance();
    final apiClient = ApiClient(
      baseUrl: env.apiBaseUrl,
      apiKey: '',
    );

    return AppScope(
      env: env,
      db: db,
      downloadRepository: downloadRepo,
      playbackPositionRepository: playbackRepo,
      prefs: prefs,
      apiClient: apiClient,
    );
  }
}
