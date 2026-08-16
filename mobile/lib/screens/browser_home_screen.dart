import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BrowserHomeScreen extends StatelessWidget {
  final Function(String) onSearch;
  final List<QuickBookmark> bookmarks;

  const BrowserHomeScreen({
    super.key,
    required this.onSearch,
    required this.bookmarks,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();

    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.2),
          radius: 1.5,
          colors: [Color(0xFF1E1E2C), Color(0xFF0A0A0E)],
        ),
      ),
      child: Column(
        children: [
          const Spacer(flex: 2),
          // Kurama Branding
          Column(
            children: [
              Container(
                width: 100,
                height: 100,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFF5722).withValues(alpha: 0.1),
                  border: Border.all(color: const Color(0xFFFF5722).withValues(alpha: 0.2)),
                ),
                child: Image.asset('assets/images/logo.png', 
                  errorBuilder: (_, __, ___) => const Icon(Icons.auto_awesome_rounded, size: 50, color: Color(0xFFFF5722))),
              ),
              const SizedBox(height: 16),
              const Text(
                'KURAMA BROWSER',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 8,
                ),
              ),
              Text(
                'Private • Fast • Secure',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Google Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A24),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: TextField(
                controller: controller,
                onSubmitted: (val) {
                  if (val.trim().isNotEmpty) onSearch(val.trim());
                },
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search with Google or enter URL',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2)),
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFFF5722)),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white38),
                    onPressed: () {
                      if (controller.text.trim().isNotEmpty) onSearch(controller.text.trim());
                    },
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          // Quick Bookmarks Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Wrap(
              spacing: 24,
              runSpacing: 24,
              alignment: WrapAlignment.center,
              children: bookmarks.map((b) => _BookmarkItem(bookmark: b, onTap: onSearch)).toList(),
            ),
          ),
          const Spacer(flex: 3),
        ],
      ),
    );
  }
}

class _BookmarkItem extends StatelessWidget {
  final QuickBookmark bookmark;
  final Function(String) onTap;

  const _BookmarkItem({required this.bookmark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap(bookmark.url);
      },
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2C),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Icon(bookmark.icon, color: Colors.white70, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            bookmark.name,
            style: const TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class QuickBookmark {
  final String name;
  final String url;
  final IconData icon;

  const QuickBookmark(this.name, this.url, this.icon);
}
