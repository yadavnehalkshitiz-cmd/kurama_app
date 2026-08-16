import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/browser_detection_controller.dart';

class BrowserDetectionAction extends StatelessWidget {
  final BrowserDetectionState state;
  final VoidCallback onDownload;
  final VoidCallback onRetry;

  const BrowserDetectionAction({
    super.key,
    required this.state,
    required this.onDownload,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) => SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
        child: child,
      ),
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    switch (state.phase) {
      case BrowserDetectionPhase.idle:
        return const SizedBox.shrink();
      case BrowserDetectionPhase.checking:
        return const _FloatingBento(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFF5722))),
              SizedBox(width: 12),
              Text('Scanning page...', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
        );
      case BrowserDetectionPhase.unsupported:
        return const SizedBox.shrink(); 
      case BrowserDetectionPhase.error:
        return _FloatingBento(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.white38, size: 18),
              const SizedBox(width: 12),
              const Text('Detection failed', style: TextStyle(color: Colors.white60, fontSize: 13)),
              const SizedBox(width: 8),
              TextButton(onPressed: onRetry, child: const Text('Retry', style: TextStyle(color: Color(0xFFFF5722)))),
            ],
          ),
        );
      case BrowserDetectionPhase.detected:
        return _FloatingBento(
          accentColor: const Color(0xFFFF5722),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFFF5722).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.bolt_rounded, color: Color(0xFFFF5722), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('READY TO DOWNLOAD', style: TextStyle(color: Color(0xFFFF5722), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.2)),
                    const SizedBox(height: 2),
                    Text(state.info?.title ?? 'Untitled Media', maxLines: 1, overflow: TextOverflow.ellipsis, 
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  onDownload();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF5722),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: const Color(0xFFFF5722).withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: const Text('Download', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
            ],
          ),
        );
    }
  }
}

class _FloatingBento extends StatelessWidget {
  final Widget child;
  final Color? accentColor;

  const _FloatingBento({required this.child, this.accentColor});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2C).withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: accentColor?.withValues(alpha: 0.3) ?? Colors.white.withValues(alpha: 0.05)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 30, offset: const Offset(0, 15))],
          ),
          child: child,
        ),
      ),
    );
  }
}
