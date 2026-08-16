import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../services/app_state.dart';
import '../services/media_library.dart';
import '../services/storage_manager.dart';
import '../services/permission_service.dart';
import '../services/media_scanner_service.dart';
import '../services/notification_service.dart';
import 'ak_player_library_screen.dart';
import 'video_info_screen.dart';
import 'player_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver, TickerProviderStateMixin {
  final _urlController = TextEditingController();
  bool _isLoading = false;
  StreamSubscription? _intentSubscription;
  StorageSummary? _storage;

  // Animations
  late AnimationController _fadeController;
  late List<Animation<double>> _staggeredAnimations;
  late AnimationController _buttonScaleController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initShareIntentListener();
    _loadStorage();
    _checkClipboardForLink();
    
    // Safely request permissions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestInitialPermissions();
    });

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _staggeredAnimations = List.generate(
      5,
      (index) => CurvedAnimation(
        parent: _fadeController,
        curve: Interval(
          0.1 * index,
          0.5 + (0.1 * index),
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    _buttonScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.96,
      upperBound: 1.0,
      value: 1.0,
    );

    _fadeController.forward();
  }

  Future<void> _requestInitialPermissions() async {
    debugPrint('[Home] Requesting initial permissions...');
    try {
      // 1. Notifications
      await NotificationService.requestPermission();
      
      // 2. Storage/Media check
      if (mounted) {
        final sdk = await _getSdkVersion();
        bool granted = false;
        if (Platform.isAndroid) {
          if (sdk >= 33) {
            granted = await Permission.videos.isGranted && await Permission.audio.isGranted;
          } else {
            granted = await Permission.storage.isGranted;
          }
        }
        
        debugPrint('[Home] Initial storage granted: $granted');
        
        if (!granted && mounted) {
          final result = await PermissionService.checkAndRequestStorage(context);
          debugPrint('[Home] Storage request result: $result');
        }
      }
    } catch (e) {
      debugPrint('[Home] Startup permission check failed: $e');
    }
  }

  Future<int> _getSdkVersion() async {
    if (!Platform.isAndroid) return 0;
    try {
      final sdkStr = Platform.operatingSystemVersion;
      final match = RegExp(r'SDK (\d+)').firstMatch(sdkStr);
      return match != null ? int.parse(match.group(1)!) : 0;
    } catch (_) {
      return 0;
    }
  }

  @override
  void dispose() {
    _intentSubscription?.cancel();
    _fadeController.dispose();
    _buttonScaleController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _urlController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkClipboardForLink();
      _loadStorage();
      if (mounted) context.read<AppState>().syncWithStorage();
    }
  }

  Future<void> _checkClipboardForLink() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final text = data?.text?.trim() ?? '';
      if (text.startsWith('http') && _urlController.text.isEmpty) {
        if (!mounted) return;
        setState(() => _urlController.text = text);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📋 Link auto-pasted from clipboard'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {}
  }

  Future<void> _loadStorage() async {
    try {
      final state = context.read<AppState>();
      final summary = await StorageManager.scan(state.downloads);
      if (mounted) setState(() => _storage = summary);
    } catch (_) {}
  }

  // ── Share Intent ─────────────────────────────────────────

  void _initShareIntentListener() {
    try {
      _intentSubscription = ReceiveSharingIntent.instance.getMediaStream().listen((value) {
        if (value.isNotEmpty) {
          _handleSharedItem(value.first.path);
        }
      });
      ReceiveSharingIntent.instance.getInitialMedia().then((value) {
        if (value.isNotEmpty) {
          _handleSharedItem(value.first.path);
        }
      });
    } catch (e) {
      debugPrint('Share intent error: $e');
    }
  }

  void _handleSharedItem(String path) {
    if (isMediaFile(path) && File(path).existsSync()) {
      _importAndPlay(path);
      return;
    }
    _handleUrl(path);
  }

  Future<void> _importAndPlay(String path) async {
    if (!mounted) return;
    final state = context.read<AppState>();
    final task = await importLocalFile(state, path);
    if (!mounted) return;
    if (task?.localPath == null) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerScreen(
      filePath: task!.localPath!,
      title: task.title,
      format: task.format,
    )));
  }

  void _handleUrl(String text) {
    final url = RegExp(r'https?://[^\s]+').firstMatch(text)?.group(0);
    if (url != null && mounted) {
      setState(() => _urlController.text = url);
      _fetchInfo();
    }
  }

  Future<void> _fetchInfo() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    // 🔒 Permission Check
    final granted = await PermissionService.checkAndRequestStorage(context);
    if (!mounted || !granted) return;

    setState(() => _isLoading = true);
    try {
      if (!mounted) return;
      final state = Provider.of<AppState>(context, listen: false);
      final api = state.client;
      final info = await api.fetchInfo(url);
      if (!mounted) return;
      Navigator.push(context, MaterialPageRoute(builder: (_) => VideoInfoScreen(info: info)));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── UI Components ────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const primary = Color(0xFFFF5722); // Fox Amber

    return Scaffold(
      backgroundColor: const Color(0xFF12121A),
      body: Stack(
        children: [
          // Background Gradient
          const Positioned.fill(child: _ObsidianGradient()),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _staggeredSlide(0, _buildFoxAura(primary)),
                    const SizedBox(height: 32),
                    _staggeredSlide(1, _buildUrlBento(theme, primary)),
                    const SizedBox(height: 20),
                    _staggeredSlide(2, _buildPulseGrid(theme, primary)),
                    const SizedBox(height: 32),
                    _staggeredSlide(3, _buildPlatformSection()),
                    const SizedBox(height: 40),
                  ]),
                ),
              ),
            ],
          ),
          
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.6),
                child: const Center(child: CircularProgressIndicator(color: primary)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _staggeredSlide(int index, Widget child) {
    return FadeTransition(
      opacity: _staggeredAnimations[index],
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(_staggeredAnimations[index]),
        child: child,
      ),
    );
  }

  Widget _buildSliverAppBar() {
    final state = context.watch<AppState>();
    final isDefaultUrl = state.client.baseUrl.contains('10.0.2.2');
    final isPhysical = !Platform.isWindows && (Platform.isAndroid || Platform.isIOS); // Simplified check
    
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: const Text('KURAMA', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 4, fontSize: 18, color: Colors.white)),
      actions: [
        if (isDefaultUrl && isPhysical)
          const Tooltip(
            message: 'Default local URL might not work on physical devices. Change it in Profile.',
            child: Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(Icons.wifi_off_rounded, color: Colors.orangeAccent, size: 20),
            ),
          ),
      ],
    );
  }

  Widget _buildFoxAura(Color primary) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Aura Glow
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primary.withValues(alpha: 0.2),
                  blurRadius: 60,
                  spreadRadius: 20,
                ),
              ],
            ),
          ),
          // Glass Card for Logo
          ClipRRect(
            borderRadius: BorderRadius.circular(36),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.08),
                      Colors.white.withValues(alpha: 0.02),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(36),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Center(
                  child: Image.asset('assets/images/logo.png', width: 64, height: 64, 
                    errorBuilder: (_, __, ___) => const Text('🦊', style: TextStyle(fontSize: 48))),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrlBento(ThemeData theme, Color primary) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bolt_rounded, color: primary, size: 20),
              const SizedBox(width: 10),
              const Text('INSTANT DOWNLOAD', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.w800, color: Colors.white60, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _urlController,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            decoration: InputDecoration(
              hintText: 'Paste media URL...',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2)),
              filled: true,
              fillColor: Colors.black.withValues(alpha: 0.4),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
            ),
            onSubmitted: (_) => _fetchInfo(),
          ),
          const SizedBox(height: 20),
          // 🚀 POLISHED BUTTON
          GestureDetector(
            onTapDown: (_) => _buttonScaleController.reverse(),
            onTapUp: (_) => _buttonScaleController.forward(),
            onTapCancel: () => _buttonScaleController.forward(),
            child: ScaleTransition(
              scale: _buttonScaleController,
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF5722), Color(0xFFFF4500)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF5722).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.download_rounded, color: Colors.white),
                    SizedBox(width: 12),
                    Text(
                      'Fetch & Download',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            onTap: () {
              HapticFeedback.lightImpact();
              _fetchInfo();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPulseGrid(ThemeData theme, Color primary) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Storage Bento
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E2C),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('STORAGE', style: TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.w800, color: Colors.white24, fontSize: 10)),
                  const SizedBox(height: 12),
                  Text(_storage?.usedBytes != null ? formatBytes(_storage!.usedBytes) : '...', 
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 4),
                  const Text('Local Files', style: TextStyle(color: Colors.white38, fontSize: 11)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () async {
                      HapticFeedback.mediumImpact();
                      final state = context.read<AppState>();
                      final count = await MediaScannerService.scanAndImport(state);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('🔍 Found and imported $count items'), behavior: SnackBarBehavior.floating),
                        );
                        _loadStorage();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                      child: Text('Scan Media', style: TextStyle(color: primary, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 20),
          // Recent Activity Bento
          Expanded(
            child: Consumer<AppState>(
              builder: (context, state, _) {
                final downloads = state.downloads;
                final lastTask = downloads.firstOrNull;
                return GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AkPlayerLibraryScreen())),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E2C),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: lastTask != null && lastTask.thumbnailUrl != null
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(lastTask.thumbnailUrl!, fit: BoxFit.cover),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.black26, Colors.black.withValues(alpha: 0.8)],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('RECENT', style: TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.w800, color: Colors.white60, fontSize: 10)),
                                  Text(lastTask.title, maxLines: 2, overflow: TextOverflow.ellipsis, 
                                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ],
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.history_rounded, color: Colors.white.withValues(alpha: 0.1), size: 32),
                              const SizedBox(height: 8),
                              const Text('No Activity', style: TextStyle(color: Colors.white24, fontSize: 12)),
                            ],
                          ),
                        ),
                  ),
                );
              }
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformSection() {
    const platforms = ['YouTube', 'Instagram', 'TikTok', 'Twitter', 'Facebook', 'Vimeo', 'Reddit', 'Twitch'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4),
          child: Text('SUPPORTED SERVICES', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.w800, color: Colors.white24, fontSize: 10)),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: platforms.map((p) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A24),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Text(p, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
          )).toList(),
        ),
      ],
    );
  }
}

class _ObsidianGradient extends StatelessWidget {
  const _ObsidianGradient();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0.7, -0.4),
          radius: 1.2,
          colors: [
            Color(0xFF1A1A2E),
            Color(0xFF0A0A0E),
          ],
          stops: [0.0, 0.8],
        ),
      ),
    );
  }
}
