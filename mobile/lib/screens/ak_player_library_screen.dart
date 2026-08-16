import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/download_task.dart';
import '../models/playback_entry.dart';
import '../services/app_state.dart';
import '../services/storage_manager.dart';
import '../services/permission_service.dart';
import '../services/media_scanner_service.dart';
import '../services/vault_service.dart';
import '../services/vault_cipher.dart';
import '../services/vault_key_store.dart';
import 'player_screen.dart';

class AkPlayerLibraryScreen extends StatefulWidget {
  const AkPlayerLibraryScreen({super.key});

  @override
  State<AkPlayerLibraryScreen> createState() => _AkPlayerLibraryScreenState();
}

class _AkPlayerLibraryScreenState extends State<AkPlayerLibraryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _query = '';
  bool _searchOpen = false;
  StorageSummary? _storage;
  bool _isScanning = false;
  
  final Set<String> _selectedIds = {};
  bool _selectionMode = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadStorage();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStorage() async {
    try {
      final state = context.read<AppState>();
      final summary = await StorageManager.scan(state.downloads);
      if (mounted) setState(() => _storage = summary);
    } catch (_) {}
  }

  Future<void> _scanLocalMedia() async {
    final granted = await PermissionService.checkAndRequestLocalMedia(context);
    if (!mounted || !granted) return;

    setState(() => _isScanning = true);
    try {
      final state = context.read<AppState>();
      final count = await MediaScannerService.scanAndImport(state);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🔍 Ak Player: Found and imported $count items'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFFFF5722),
          ),
        );
        _loadStorage();
      }
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  List<DownloadTask> _getMedia(String format) {
    final all = context.watch<AppState>().downloads.where((task) => !task.isPrivate).toList();
    final q = _query.trim().toLowerCase();
    
    return all.where((task) {
      if (task.format != format) return false;
      if (q.isEmpty) return true;
      return task.title.toLowerCase().contains(q) || task.platform.toLowerCase().contains(q);
    }).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0E),
      body: Stack(
        children: [
          NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: _buildHeader(),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: _tabController,
                    indicatorColor: const Color(0xFFFF5722),
                    indicatorWeight: 3,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white38,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
                    tabs: const [
                      Tab(text: 'VIDEOS'),
                      Tab(text: 'MUSIC'),
                    ],
                  ),
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                _MediaGrid(
                  items: _getMedia('video'),
                  selectionMode: _selectionMode,
                  selectedIds: _selectedIds,
                  onTap: _handleItemTap,
                  onLongPress: _toggleSelection,
                ),
                _MediaGrid(
                  items: _getMedia('audio'),
                  selectionMode: _selectionMode,
                  selectedIds: _selectedIds,
                  onTap: _handleItemTap,
                  onLongPress: _toggleSelection,
                ),
              ],
            ),
          ),

          if (_isScanning)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: const Center(child: CircularProgressIndicator(color: Color(0xFFFF5722))),
              ),
            ),

          if (_selectionMode)
            Positioned(
              bottom: 24,
              left: 20,
              right: 20,
              child: _buildSelectionBar(),
            ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      backgroundColor: const Color(0xFF0A0A0E),
      elevation: 0,
      pinned: true,
      centerTitle: true,
      title: const Text('AK PLAYER', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 4, fontSize: 16)),
      actions: [
        IconButton(
          icon: Icon(_searchOpen ? Icons.close_rounded : Icons.search_rounded),
          onPressed: () => setState(() {
            _searchOpen = !_searchOpen;
            if (!_searchOpen) _query = '';
          }),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (_searchOpen)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: TextField(
                autofocus: true,
                onChanged: (v) => setState(() => _query = v),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search library...',
                  prefixIcon: const Icon(Icons.search_rounded, color: Colors.white38),
                  filled: true,
                  fillColor: const Color(0xFF1E1E2C),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E2C),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons. library_music_rounded, color: Color(0xFFFF5722)),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_storage != null ? formatBytes(_storage!.usedBytes) : '0 B', 
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          const Text('Library Size', style: TextStyle(color: Colors.white38, fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _scanLocalMedia,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFFF5722), Color(0xFFFF4500)]),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: const Color(0xFFFF5722).withValues(alpha: 0.2), blurRadius: 10)],
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text('SCAN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFF5722).withValues(alpha: 0.9),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _selectionAction(Icons.share_rounded, 'Share', _bulkShare),
              _selectionAction(Icons.delete_rounded, 'Delete', _bulkDelete),
              _selectionAction(Icons.lock_rounded, 'Vault', _moveToVault),
            ],
          ),
        ),
      ),
    );
  }

  Widget _selectionAction(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _handleItemTap(DownloadTask task) {
    if (_selectionMode) {
      _toggleSelection(task.taskId);
    } else {
      _playTask(task);
    }
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty) _selectionMode = false;
      } else {
        _selectedIds.add(id);
        _selectionMode = true;
      }
    });
  }

  void _playTask(DownloadTask task) {
    if (task.localPath == null || !File(task.localPath!).existsSync()) return;
    
    final state = context.read<AppState>();
    final all = state.downloads.where((t) => t.format == task.format && !t.isPrivate).toList();
    final entries = all.where((t) => t.localPath != null && File(t.localPath!).existsSync())
      .map((t) => PlaybackEntry(
        path: t.localPath!,
        title: t.title,
        format: t.format,
        artist: t.platform,
        artworkUrl: t.thumbnailUrl,
      )).toList();
    
    final index = entries.indexWhere((e) => e.path == task.localPath);
    
    if (!mounted) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerScreen(
      filePath: task.localPath!,
      title: task.title,
      format: task.format,
      entries: entries,
      initialIndex: index >= 0 ? index : 0,
    )));
  }

  Future<void> _bulkDelete() async {
    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Delete selected?', style: TextStyle(color: Colors.white)),
        content: Text('Remove ${_selectedIds.length} items from your library?', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Delete'),
          ),
        ],
      ),
    ) ?? false;

    if (!confirmed) return;

    if (!mounted) return;
    final state = context.read<AppState>();
    for (final id in _selectedIds) {
      final task = state.downloads.firstWhere((t) => t.taskId == id);
      if (task.localPath != null) {
        final file = File(task.localPath!);
        if (await file.exists()) await file.delete();
      }
      state.removeDownload(id);
    }

    setState(() {
      _selectedIds.clear();
      _selectionMode = false;
    });
    _loadStorage();
  }

  Future<void> _bulkShare() async {
    final state = context.read<AppState>();
    final files = _selectedIds.map((id) => state.downloads.firstWhere((t) => t.taskId == id))
        .where((t) => t.localPath != null && File(t.localPath!).existsSync())
        .map((t) => XFile(t.localPath!))
        .toList();
    
    if (files.isEmpty) return;
    
    await Share.shareXFiles(files, text: 'Shared via Kurama App');
  }

  Future<void> _moveToVault() async {
    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Move to Vault?', style: TextStyle(color: Colors.white)),
        content: Text('Encrypt and hide ${_selectedIds.length} items?', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFF5722)),
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Move'),
          ),
        ],
      ),
    ) ?? false;

    if (!confirmed) return;
    
    if (!mounted) return;
    final state = context.read<AppState>();
    
    setState(() => _isScanning = true); // Use scanning state as generic busy
    
    try {
      final vault = VaultService(VaultCipher(), VaultKeyStore(FlutterSecureSecretStore()));
      for (final id in _selectedIds) {
        final task = state.downloads.firstWhere((t) => t.taskId == id);
        if (task.localPath != null) {
          final vaultPath = await vault.encryptAndMoveToVault(task, File(task.localPath!));
          await state.moveToVault(id, vaultPath);
        }
      }
      _show('🔒 ${_selectedIds.length} items moved to private vault');
    } catch (e) {
      _show('❌ Error moving to vault: $e');
    } finally {
      if (mounted) {
        setState(() {
          _selectedIds.clear();
          _selectionMode = false;
          _isScanning = false;
        });
      }
      _loadStorage();
    }
  }

  void _show(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating)
    );
  }
}

class _MediaGrid extends StatefulWidget {
  final List<DownloadTask> items;
  final bool selectionMode;
  final Set<String> selectedIds;
  final Function(DownloadTask) onTap;
  final Function(String) onLongPress;

  const _MediaGrid({
    required this.items,
    required this.selectionMode,
    required this.selectedIds,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  State<_MediaGrid> createState() => _MediaGridState();
}

class _MediaGridState extends State<_MediaGrid> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const Center(child: Text('No media found', style: TextStyle(color: Colors.white24, fontWeight: FontWeight.bold)));
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        final item = widget.items[index];
        final isSelected = widget.selectedIds.contains(item.taskId);
        
        final animation = CurvedAnimation(
          parent: _controller,
          curve: Interval(
            (0.1 * index).clamp(0.0, 1.0),
            1.0,
            curve: Curves.easeOutBack,
          ),
        );

        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: animation,
            child: _BentoMediaCard(
              item: item,
              isSelected: isSelected,
              onTap: () => widget.onTap(item),
              onLongPress: () => widget.onLongPress(item.taskId),
            ),
          ),
        );
      },
    );
  }
}

class _BentoMediaCard extends StatelessWidget {
  final DownloadTask item;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _BentoMediaCard({required this.item, required this.isSelected, required this.onTap, required this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2C),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isSelected ? const Color(0xFFFF5722) : Colors.white.withValues(alpha: 0.05), width: isSelected ? 2 : 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (item.thumbnailUrl != null)
              Image.network(item.thumbnailUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _placeholder())
            else
              _placeholder(),
            
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(6)),
                        child: Text(item.platform, style: const TextStyle(color: Colors.white60, fontSize: 8, fontWeight: FontWeight.bold)),
                      ),
                      if (isSelected) const Icon(Icons.check_circle_rounded, color: Color(0xFFFF5722), size: 20),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis, 
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(item.fileSizeStr ?? '', style: const TextStyle(color: Colors.white38, fontSize: 9)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
    color: Colors.white.withValues(alpha: 0.02), 
    child: Center(child: Icon(item.format == 'audio' ? Icons.music_note_rounded : Icons.play_arrow_rounded, color: Colors.white10, size: 40))
  );
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: const Color(0xFF0A0A0E),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}
