import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/app.dart';
import 'app/app_bootstrap.dart';
import 'app/app_environment.dart';
import 'services/app_state.dart';
import 'services/download_storage.dart';
import 'services/notification_service.dart';
import 'services/background_download_service.dart';
import 'package:just_audio_background/just_audio_background.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final env = AppEnvironment.fromBuildConfig();
  final scope = await AppBootstrap.initialize(env);

  // 1. Initial State Load
  final storage = DownloadStorage(scope.prefs);
  final userId = await storage.loadOrCreateUserId();

  final appState = AppState(
    storage,
    scope.apiClient,
    userId: userId,
  );

  // 2. Background initialization (non-blocking)
  _initPlatformServices();

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: scope),
        ChangeNotifierProvider.value(value: appState),
      ],
      child: KuramaApp(scope: scope),
    ),
  );
}

bool _platformServicesInitialized = false;

Future<void> _initPlatformServices() async {
  if (_platformServicesInitialized) return;
  _platformServicesInitialized = true;
  
  try {
    debugPrint('[Main] Initializing platform services...');
    // Small delay to let the UI breathe first
    await Future.delayed(const Duration(milliseconds: 500));
    
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.kuramabot.audio',
      androidNotificationChannelName: 'Kurama audio playback',
      androidNotificationOngoing: true,
    );
    
    await NotificationService.initialize();
    await BackgroundDownloadService.initialize();
    debugPrint('[Main] Platform services ready.');
  } catch (e) {
    debugPrint('[Main] Platform service init error: $e');
  }
}
