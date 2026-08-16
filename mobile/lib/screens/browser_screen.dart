import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';

import '../services/api_client.dart';
import '../services/app_state.dart';
import '../services/browser_address.dart';
import '../services/browser_detection_controller.dart';
import '../widgets/browser_detection_action.dart';
import 'video_info_screen.dart';

import 'browser_home_screen.dart';

class BrowserScreen extends StatefulWidget {
  const BrowserScreen({super.key});

  @override
  State<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends State<BrowserScreen> {
  final _urlController = TextEditingController();
  InAppWebViewController? _webViewController;
  late final BrowserDetectionController _detectionController;
  double _progress = 0;
  bool _showHome = true;

  static const _quickBookmarks = [
    QuickBookmark('YouTube', 'https://m.youtube.com', Icons.smart_display_rounded),
    QuickBookmark('Instagram', 'https://www.instagram.com', Icons.camera_alt_rounded),
    QuickBookmark('TikTok', 'https://www.tiktok.com', Icons.music_note_rounded),
    QuickBookmark('X', 'https://x.com', Icons.alternate_email_rounded),
    QuickBookmark('Facebook', 'https://m.facebook.com', Icons.public_rounded),
    QuickBookmark('Pinterest', 'https://www.pinterest.com', Icons.push_pin_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _detectionController = BrowserDetectionController(probe: (url) async {
      try {
        return await context.read<AppState>().client.fetchInfo(url);
      } on ApiException catch (error) {
        if (error.isUnsupportedMedia) {
          throw UnsupportedMediaException(error.message);
        }
        rethrow;
      }
    });
  }

  @override
  void dispose() {
    _detectionController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _loadInput(String input) {
    final value = input.trim();
    if (value.isEmpty) {
      setState(() => _showHome = true);
      return;
    }
    
    final uri = resolveBrowserInput(value);
    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid web address or search phrase'),
        ),
      );
      return;
    }

    final urlString = uri.toString();
    
    if (_showHome) {
      // Transitioning from home to web view
      setState(() {
        _urlController.text = urlString;
        _showHome = false;
      });
    } else {
      // Already in web view, just navigate
      _urlController.text = urlString;
      _webViewController?.loadUrl(
        urlRequest: URLRequest(url: WebUri(urlString)),
      );
    }
  }

  void _openDetectedMedia() {
    final info = _detectionController.state.info;
    if (info == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => VideoInfoScreen(info: info)),
    );
  }

  void _retryDetection() {
    final url = _detectionController.state.url ?? _urlController.text;
    if (url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri != null && isSafeBrowserUri(uri)) {
      _detectionController.beginNavigation();
      _detectionController.detect(uri.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          icon: _showHome ? const Icon(Icons.home_rounded, color: Color(0xFFFF5722)) : const Icon(Icons.arrow_back_rounded),
          onPressed: () async {
            if (_showHome) return;
            if (await _webViewController?.canGoBack() ?? false) {
              await _webViewController?.goBack();
            } else {
              setState(() => _showHome = true);
              _urlController.clear();
            }
          },
        ),
        title: SizedBox(
          height: 40,
          child: TextField(
            controller: _urlController,
            decoration: InputDecoration(
              hintText: 'Search or type web address',
              hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.3),
                fontSize: 13,
              ),
              prefixIcon: const Icon(Icons.language_rounded, size: 18),
              suffixIcon: _urlController.text.isNotEmpty 
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18),
                    onPressed: () {
                      _urlController.clear();
                      setState(() => _showHome = true);
                    },
                  )
                : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            style: const TextStyle(fontSize: 13),
            textInputAction: TextInputAction.go,
            keyboardType: TextInputType.url,
            autocorrect: false,
            onSubmitted: _loadInput,
          ),
        ),
        actions: [
          if (!_showHome)
            IconButton(
              tooltip: 'Refresh',
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () => _webViewController?.reload(),
            ),
        ],
      ),
      body: Stack(
        children: [
          if (_showHome)
            BrowserHomeScreen(
              onSearch: _loadInput,
              bookmarks: _quickBookmarks,
            )
          else
            Column(
              children: [
                if (_progress > 0 && _progress < 1)
                  LinearProgressIndicator(
                    value: _progress,
                    color: primary,
                    minHeight: 2,
                  ),
                Expanded(
                  child: InAppWebView(
                    initialUrlRequest: URLRequest(url: WebUri(_urlController.text)),
                    initialSettings: InAppWebViewSettings(
                      useShouldOverrideUrlLoading: true,
                      mediaPlaybackRequiresUserGesture: true,
                      allowsInlineMediaPlayback: true,
                    ),
                    onWebViewCreated: (controller) {
                      _webViewController = controller;
                      // JS Handler for video detection
                      controller.addJavaScriptHandler(
                        handlerName: 'videoDetected',
                        callback: (args) {
                          if (args.isNotEmpty && mounted) {
                            if (_detectionController.state.phase == BrowserDetectionPhase.unsupported ||
                                _detectionController.state.phase == BrowserDetectionPhase.idle) {
                               _detectionController.detect(_urlController.text);
                            }
                          }
                        },
                      );
                    },
                    onLoadStart: (_, url) {
                      _detectionController.beginNavigation();
                      if (url != null && mounted) {
                        setState(() {
                          _urlController.text = url.toString();
                          _showHome = false;
                        });
                      }
                    },
                    onLoadStop: (controller, url) {
                      if (url == null) return;

                      // Inject video sniffer script
                      controller.evaluateJavascript(source: """
                        (function() {
                          function check() {
                            var v = document.getElementsByTagName('video');
                            if (v.length > 0 && v[0].src) {
                              window.flutter_inappwebview.callHandler('videoDetected', { src: v[0].src });
                            }
                          }
                          var observer = new MutationObserver(check);
                          observer.observe(document.body, { childList: true, subtree: true });
                          check();
                        })();
                      """);

                      final uri = Uri.tryParse(url.toString());
                      if (uri != null && isSafeBrowserUri(uri)) {
                        if (mounted) {
                          setState(() => _urlController.text = uri.toString());
                        }
                        _detectionController.detect(uri.toString());
                      }
                    },
                    onProgressChanged: (_, progress) {
                      if (mounted) setState(() => _progress = progress / 100);
                    },
                    shouldOverrideUrlLoading: (_, action) async {
                      final raw = action.request.url?.toString();
                      final uri = raw == null ? null : Uri.tryParse(raw);
                      return uri != null && isSafeBrowserUri(uri)
                          ? NavigationActionPolicy.ALLOW
                          : NavigationActionPolicy.CANCEL;
                    },
                  ),
                ),
              ],
            ),
          if (!_showHome)
            Positioned(
              left: 16,
              right: 16,
              bottom: 20,
              child: AnimatedBuilder(
                animation: _detectionController,
                builder: (_, __) => BrowserDetectionAction(
                  state: _detectionController.state,
                  onDownload: _openDetectedMedia,
                  onRetry: _retryDetection,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
