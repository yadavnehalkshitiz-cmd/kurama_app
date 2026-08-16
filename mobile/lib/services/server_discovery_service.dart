import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';

class ServerDiscoveryService {
  static const int defaultPort = 8000;
  
  /// Attempts to find the server automatically.
  /// Returns the working base URL or null if none found.
  static Future<String?> discover(String currentUrl) async {
    // 1. Try current first
    if (await _probe(currentUrl)) return currentUrl;

    final List<String> candidates = [];

    if (Platform.isAndroid) {
      candidates.add('http://10.0.2.2:$defaultPort');
    }
    
    candidates.addAll([
      'http://localhost:$defaultPort',
      'http://127.0.0.1:$defaultPort',
      'http://kurama.local:$defaultPort',
    ]);

    // 2. Try common local IP candidates if on WiFi
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.wifi)) {
      final wifiCandidates = await _getWifiCandidates();
      candidates.addAll(wifiCandidates);
    }

    // Deduplicate and remove empty
    final uniqueCandidates = candidates.where((c) => c != currentUrl).toSet().toList();

    debugPrint('[Discovery] Probing ${uniqueCandidates.length} candidates...');

    // Run probes in parallel with a short timeout
    final results = await Future.wait(
      uniqueCandidates.map((url) => _probe(url).then((ok) => ok ? url : null))
    );

    final found = results.firstWhere((r) => r != null, orElse: () => null);
    if (found != null) {
      debugPrint('[Discovery] Found server at: $found');
    }
    
    return found;
  }

  static Future<bool> _probe(String baseUrl) async {
    if (baseUrl.isEmpty) return false;
    try {
      final uri = Uri.parse('$baseUrl/api/health').replace(path: '/api/health');
      final response = await http.get(uri).timeout(const Duration(seconds: 2));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<List<String>> _getWifiCandidates() async {
    final List<String> list = [];
    try {
      // Get the device's local IP and try the .1 and .100-110 range (common host IPs)
      for (var interface in await NetworkInterface.list()) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
            final parts = addr.address.split('.');
            if (parts.length == 4) {
              final prefix = '${parts[0]}.${parts[1]}.${parts[2]}';
              list.add('http://$prefix.1:$defaultPort');   // Gateway
              list.add('http://$prefix.100:$defaultPort'); // Common DHCP start
              list.add('http://$prefix.2:$defaultPort');   // Alternative gateway
            }
          }
        }
      }
    } catch (_) {}
    return list;
  }
}
