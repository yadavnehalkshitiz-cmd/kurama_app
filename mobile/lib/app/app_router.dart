import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/browser_screen.dart';
import '../screens/downloads_screen.dart';
import '../screens/vault_screen.dart';
import '../screens/profile_screen.dart';

/// Central route registry.
///
/// All `Navigator.pushNamed` calls must use constants from this class.
abstract final class AppRouter {
  static const home = '/';
  static const browser = '/browser';
  static const downloads = '/downloads';
  static const vault = '/vault';
  static const profile = '/profile';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case browser:
        return MaterialPageRoute(builder: (_) => const BrowserScreen());
      case downloads:
        return MaterialPageRoute(builder: (_) => const DownloadsScreen());
      case vault:
        return MaterialPageRoute(builder: (_) => const VaultScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text(
                'Route not found: ${settings.name}',
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          ),
        );
    }
  }
}
