import 'package:shared_preferences/shared_preferences.dart';

import 'app_environment.dart';
import '../domain/downloads/download_repository.dart';
import '../domain/playback/playback_position_repository.dart';
import '../infrastructure/database/app_database.dart';
import '../services/api_client.dart';

/// Typed dependency container for the application.
///
/// Passed through the widget tree via [Provider] or [InheritedWidget].
/// All fields are immutable after construction.
class AppScope {
  final AppEnvironment env;
  final AppDatabase db;
  final DownloadRepository downloadRepository;
  final PlaybackPositionRepository playbackPositionRepository;
  final SharedPreferences prefs;
  final ApiClient apiClient;

  const AppScope({
    required this.env,
    required this.db,
    required this.downloadRepository,
    required this.playbackPositionRepository,
    required this.prefs,
    required this.apiClient,
  });
}
