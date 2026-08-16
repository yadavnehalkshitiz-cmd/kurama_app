import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  const PermissionService._();

  /// Logic for modern Android (13+) vs Legacy
  static Future<bool> checkAndRequestStorage(BuildContext context) async {
    if (Platform.isWindows) return true;

    if (Platform.isAndroid) {
      final sdkVersion = await _getAndroidSdkVersion();
      
      if (sdkVersion >= 33) {
        final video = await Permission.videos.status;
        final audio = await Permission.audio.status;
        
        if (video.isGranted && audio.isGranted) return true;
      } else {
        final storage = await Permission.storage.status;
        if (storage.isGranted) return true;
      }

      if (!context.mounted) return false;
      final status = await _showOnboardingSheet(context, 'media');
      return status.isGranted;
    } else {
      // iOS
      final status = await Permission.storage.status;
      if (status.isGranted) return true;
      if (!context.mounted) return false;
      final newStatus = await _showOnboardingSheet(context, 'storage');
      return newStatus.isGranted;
    }
  }

  static Future<bool> checkAndRequestLocalMedia(BuildContext context) async {
    return checkAndRequestStorage(context);
  }

  static Future<int> _getAndroidSdkVersion() async {
    if (Platform.isAndroid) {
      try {
        final sdkStr = Platform.operatingSystemVersion;
        // Search for "SDK 33" or similar
        final match = RegExp(r'SDK (\d+)').firstMatch(sdkStr);
        if (match != null) {
          return int.parse(match.group(1)!);
        }
        
        // Fallback: parse from Platform.version which is often "13" or "14"
        final versionParts = Platform.version.split(' ');
        if (versionParts.isNotEmpty) {
          final firstPart = versionParts.first;
          if (firstPart.contains('.')) {
            return int.tryParse(firstPart.split('.').first) ?? 0;
          }
          return int.tryParse(firstPart) ?? 0;
        }
      } catch (_) {}
    }
    return 0;
  }

  static Future<PermissionStatus> _showOnboardingSheet(BuildContext context, String type) async {
    final result = await showModalBottomSheet<PermissionStatus>(
      context: context,
      backgroundColor: const Color(0xFF1E1E2C),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 32),
              decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(2)),
            ),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFFF5722).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.folder_special_rounded, color: Color(0xFFFF5722), size: 40),
            ),
            const SizedBox(height: 24),
            const Text(
              'Permission Required',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'Allow Kurama to access your media to save downloads and scan your local library.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5722),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                onPressed: () async {
                  if (Platform.isAndroid) {
                    final sdk = await _getAndroidSdkVersion();
                    
                    if (sdk >= 33) {
                      final statuses = await [
                        Permission.videos,
                        Permission.audio,
                        Permission.photos,
                      ].request();
                      
                      final granted = statuses[Permission.videos]?.isGranted == true || 
                                     statuses[Permission.audio]?.isGranted == true ||
                                     statuses[Permission.photos]?.isGranted == true ||
                                     statuses[Permission.videos]?.isLimited == true; // Support partial access

                      if (!granted) {
                        // If permanently denied, take them to settings
                        if (statuses[Permission.videos]?.isPermanentlyDenied == true ||
                            statuses[Permission.audio]?.isPermanentlyDenied == true) {
                          await openAppSettings();
                        }
                      }
                      
                      if (context.mounted) Navigator.pop(context, granted ? PermissionStatus.granted : PermissionStatus.denied);
                    } else {
                      final status = await Permission.storage.request();
                      if (status.isPermanentlyDenied) await openAppSettings();
                      if (context.mounted) Navigator.pop(context, status);
                    }
                  } else {
                    final s = await Permission.storage.request();
                    if (s.isPermanentlyDenied) await openAppSettings();
                    if (context.mounted) Navigator.pop(context, s);
                  }
                },
                child: const Text('ALLOW ACCESS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.5)),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context, PermissionStatus.denied),
              child: Text('MAYBE LATER', style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            ),
          ],
        ),
      ),
    );
    return result ?? PermissionStatus.denied;
  }
}
