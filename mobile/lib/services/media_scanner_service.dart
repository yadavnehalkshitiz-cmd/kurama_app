import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'app_state.dart';
import 'media_library.dart';

class MediaScannerService {
  const MediaScannerService._();

  /// Scans common device folders for media files and imports them into the library.
  static Future<int> scanAndImport(AppState state) async {
    // 🔒 Ensure we have permission to list directories
    // Note: On Android 11+, this will still return empty for public folders 
    // unless MANAGE_EXTERNAL_STORAGE is granted, but we try anyway.
    
    final List<String> pathsToScan = [];

    if (Platform.isAndroid) {
      // Modern Android root
      const root = '/storage/emulated/0';
      pathsToScan.addAll([
        '$root/Movies',
        '$root/Music',
        '$root/Download',
        '$root/DCIM/Camera',
        '$root/Pictures/Instagram',
        '$root/Pictures/Twitter',
        '$root/Movies/TikTok',
      ]);
    } else if (Platform.isWindows) {
      final docs = await getApplicationDocumentsDirectory();
      // Navigate up from Documents to get the user profile folder
      final userProfile = docs.parent.parent.path; 
      pathsToScan.addAll([
        '$userProfile\\Videos',
        '$userProfile\\Music',
        '$userProfile\\Downloads',
        '$userProfile\\Desktop',
      ]);
    }

    // Add app-specific document directory (internal storage)
    final appDocs = await getApplicationDocumentsDirectory();
    pathsToScan.add(appDocs.path);

    int importedCount = 0;
    final processedPaths = <String>{};

    for (final path in pathsToScan) {
      final dir = Directory(path);
      if (await dir.exists()) {
        try {
          // Recursive scan with error handling
          await for (final entity in dir.list(recursive: true, followLinks: false)) {
            if (entity is File && isMediaFile(entity.path)) {
              if (processedPaths.contains(entity.path)) continue;
              
              // Skip very small files (usually ads or system sounds)
              final stat = await entity.stat();
              if (stat.size < 1024 * 50) continue; // Skip < 50KB

              final task = await importLocalFile(state, entity.path);
              if (task != null) {
                importedCount++;
                processedPaths.add(entity.path);
              }
            }
          }
        } catch (e) {
          debugPrint('[Scanner] Could not list directory $path: $e');
        }
      }
    }
    
    return importedCount;
  }
}
