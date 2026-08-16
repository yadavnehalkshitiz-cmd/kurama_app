import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gal/gal.dart';

import '../models/download_task.dart';
import '../models/playback_entry.dart';
import '../services/app_state.dart';
import '../services/storage_manager.dart';
import '../services/vault_service.dart';
import '../services/vault_cipher.dart';
import '../services/vault_key_store.dart';
import 'player_screen.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  String _query = '';
  String _formatFilter = 'all';
  bool _newestFirst = true;
  bool _searchOpen = false;
  StorageSummary? _storage;
  
  // Bulk Selection
  final Set<String> _selectedIds = {};
  bool _selectionMode = false;

  @override
  void initState() {
    super.initState();
    _loadStorage();
  }

  Future<void> _loadStorage() async {
    try {
      final state = context.read<AppState>();
      final summary = await StorageManager.scan(state.downloads);
      if (mounted) setState(() => _storage = summary);
    } catch (_) {}
  }

  List<DownloadTask> get _visibleDownloads {
    final all = context.watch<AppState>().downloads.where((task) => !task.isPrivate).toList();
    final q = _query.trim().toLowerCase();
    final filtered = all.where((task) {
      if (_formatFilter != 'all' && task.format != _formatFilter) return false;
      if (q.isEmpty) return true;
      return task.title.toLowerCase().contains(q) || task.platform.toLowerCase().contains(q);
    }).toList();
    filtered.sort((a, b) => _newestFirst ? b.createdAt.compareTo(a.createdAt) : a.createdAt.compareTo(b.createdAt));
    return filtered;
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

  Future<void> _bulkDelete() async {
    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
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
    final vault = VaultService(VaultCipher(), VaultKeyStore(FlutterSecureSecretStore()));
    
    try {
      for (final id in _selectedIds) {
        final task = state.downloads.firstWhere((t) => t.taskId == id);
        if (task.localPath != null) {
          final vaultPath = await vault.encryptAndMoveToVault(task, File(task.localPath!));
          await state.moveToVault(id, vaultPath);
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('🔒 ${_selectedIds.length} items moved to vault'), behavior: SnackBarBehavior.floating),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: $e'), behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      setState(() {
        _selectedIds.clear();
        _selectionMode = false;
      });
      _loadStorage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final downloads = _visibleDownloads;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0E),
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(),
              
              if (_searchOpen)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: TextField(
                      autofocus: true,
                      onChanged: (v) => setState(() => _query = v),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search your library...',
                        prefixIcon: const Icon(Icons.search_rounded, color: Colors.white38),
                        suffixIcon: IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => _searchOpen = false)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        filled: true,
                        fillColor: const Color(0xFF1E1E2C),
                      ),
                    ),
                  ),
                ),

              SliverToBoxAdapter(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _BentoFilterChip(label: 'All', selected: _formatFilter == 'all', onTap: () => setState(() => _formatFilter = 'all')),
                      _BentoFilterChip(label: 'Video', selected: _formatFilter == 'video', onTap: () => setState(() => _formatFilter = 'video')),
                      _BentoFilterChip(label: 'Audio', selected: _formatFilter == 'audio', onTap: () => setState(() => _formatFilter = 'audio')),
                    ],
                  ),
                ),
              ),

              if (_storage != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: _BentoStorageCard(summary: _storage!),
                  ),
                ),

              if (downloads.isEmpty)
                const SliverFillRemaining(child: _EmptyState())
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.85,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final task = downloads[index];
                        final isSelected = _selectedIds.contains(task.taskId);
                        return _BentoDownloadCard(
                          task: task,
                          isSelected: isSelected,
                          onTap: () => _selectionMode ? _toggleSelection(task.taskId) : _playTask(task, downloads),
                          onLongPress: () => _toggleSelection(task.taskId),
                        );
                      },
                      childCount: downloads.length,
                    ),
                  ),
                ),
            ],
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
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      centerTitle: true,
      title: Text(_selectionMode ? '${_selectedIds.length} Selected' : 'LIBRARY', 
        style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 14)),
      actions: [
        if (!_selectionMode) ...[
          IconButton(icon: const Icon(Icons.search_rounded), onPressed: () => setState(() => _searchOpen = !_searchOpen)),
          IconButton(icon: const Icon(Icons.sort_rounded), onPressed: () => setState(() => _newestFirst = !_newestFirst)),
        ] else
          IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => setState(() { _selectionMode = false; _selectedIds.clear(); })),
      ],
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
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
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

  void _playTask(DownloadTask task, List<DownloadTask> all) {
    if (task.status != DownloadStatus.completed || task.localPath == null || !File(task.localPath!).existsSync()) return;
    
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

  Future<void> _saveToGallery(DownloadTask task) async {
    if (task.localPath == null) return;
    final file = File(task.localPath!);
    if (!await file.exists()) {
      _show('❌ File no longer exists');
      return;
    }

    try {
      if (task.format == 'video') {
        await Gal.putVideo(task.localPath!);
        _show('✅ Video saved to gallery');
      } else {
        _show('🎵 Use "Share" to export audio files');
      }
    } catch (e) {
      _show('❌ Failed to save: $e');
    }
  }

  void _show(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
  }
}

class _BentoFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _BentoFilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFF5722) : const Color(0xFF14141E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? Colors.transparent : Colors.white.withValues(alpha: 0.05)),
        ),
        child: Text(label, style: TextStyle(color: selected ? Colors.white : Colors.white60, fontWeight: FontWeight.bold, fontSize: 12)),
      ),
    );
  }
}

class _BentoStorageCard extends StatelessWidget {
  final StorageSummary summary;
  const _BentoStorageCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF14141E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const Icon(Icons.sd_storage_rounded, color: Color(0xFFFF5722), size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('DEVICE STORAGE', style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                const SizedBox(height: 4),
                Text(formatBytes(summary.usedBytes), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${summary.downloadCount} Files', style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
              const Text('cached', style: TextStyle(color: Colors.white24, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}

class _BentoDownloadCard extends StatelessWidget {
  final DownloadTask task;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _BentoDownloadCard({required this.task, required this.isSelected, required this.onTap, required this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: const Color(0xFF14141E),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isSelected ? const Color(0xFFFF5722) : Colors.white.withValues(alpha: 0.05), width: isSelected ? 2 : 1),
          boxShadow: isSelected ? [BoxShadow(color: const Color(0xFFFF5722).withValues(alpha: 0.2), blurRadius: 12)] : null,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (task.thumbnailUrl != null)
              Image.network(task.thumbnailUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _placeholder())
            else
              _placeholder(),
            
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _platformBadge(task.platform),
                      if (isSelected) const Icon(Icons.check_circle_rounded, color: Color(0xFFFF5722), size: 20),
                      if (!isSelected && task.status == DownloadStatus.completed)
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.save_alt_rounded, color: Colors.white24, size: 18),
                          onPressed: () {
                            // Find state and call save
                            final state = context.findAncestorStateOfType<_DownloadsScreenState>();
                            state?._saveToGallery(task);
                          },
                          tooltip: 'Save to Gallery',
                        ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(task.title, maxLines: 2, overflow: TextOverflow.ellipsis, 
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      if (task.status == DownloadStatus.downloading)
                        _progressIndicator(task.progress)
                      else
                        Text(task.fileSizeStr ?? '', style: const TextStyle(color: Colors.white38, fontSize: 9)),
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

  Widget _placeholder() => Container(color: Colors.white.withValues(alpha: 0.02), child: const Center(child: Icon(Icons.movie_outlined, color: Colors.white10, size: 40)));

  Widget _platformBadge(String platform) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(6)),
      child: Text(platform, style: const TextStyle(color: Colors.white60, fontSize: 8, fontWeight: FontWeight.bold)),
    );
  }

  Widget _progressIndicator(int progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(value: progress / 100, minHeight: 2, backgroundColor: Colors.white10, color: const Color(0xFFFF5722)),
        ),
        const SizedBox(height: 2),
        Text('$progress%', style: const TextStyle(color: Color(0xFFFF5722), fontSize: 8, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.movie_filter_rounded, size: 64, color: Colors.white.withValues(alpha: 0.05)),
          const SizedBox(height: 16),
          const Text('Library is empty', style: TextStyle(color: Colors.white24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
