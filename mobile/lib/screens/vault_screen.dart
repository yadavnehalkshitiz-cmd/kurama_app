import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';

import '../models/download_task.dart';
import '../services/app_state.dart';
import '../services/vault_cipher.dart';
import '../services/vault_key_store.dart';
import '../services/vault_service.dart';
import 'player_screen.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> with WidgetsBindingObserver {
  final _auth = LocalAuthentication();
  late final VaultKeyStore _keys;
  late final VaultService _vault;
  bool _unlocked = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _keys = VaultKeyStore(FlutterSecureSecretStore());
    _vault = VaultService(VaultCipher(), _keys);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      if (mounted) setState(() => _unlocked = false);
    }
  }

  Future<void> _unlock() async {
    setState(() => _busy = true);
    var authenticated = false;
    try {
      if (await _auth.isDeviceSupported()) {
        authenticated = await _auth.authenticate(
          localizedReason: 'Unlock your Kurama private vault',
          options: const AuthenticationOptions(
            biometricOnly: false,
            stickyAuth: true,
          ),
        );
      }
    } on PlatformException {
      authenticated = false;
    }
    if (!authenticated && mounted) {
      authenticated = await _verifyPin();
    }
    if (mounted) {
      setState(() {
        _unlocked = authenticated;
        _busy = false;
      });
      if (authenticated) HapticFeedback.mediumImpact();
    }
  }

  Future<bool> _verifyPin() async {
    final hasPin = await _keys.hasPin();
    if (!mounted) return false;
    final first = await _askForPin(hasPin ? 'Enter vault PIN' : 'Create vault PIN');
    if (first == null) return false;
    if (hasPin) return _keys.verifyPin(first);
    final confirmation = await _askForPin('Confirm vault PIN');
    if (confirmation != first) {
      _message('PINs did not match');
      return false;
    }
    try {
      await _keys.setPin(first);
      return true;
    } on ArgumentError {
      _message('Use exactly six digits');
      return false;
    }
  }

  Future<String?> _askForPin(String title) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          autofocus: true,
          obscureText: true,
          keyboardType: TextInputType.number,
          maxLength: 6,
          style: const TextStyle(color: Colors.white, fontSize: 28, letterSpacing: 8, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: '••••••',
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.1)),
            counterText: '',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
            filled: true,
            fillColor: Colors.black26,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.white38))),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFF5722)),
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }

  Future<void> _play(DownloadTask task) async {
    File? temporaryFile;
    try {
      setState(() => _busy = true);
      temporaryFile = await _vault.openForPlayback(task);
      if (!mounted) return;
      setState(() => _busy = false);
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PlayerScreen(
            filePath: temporaryFile!.path,
            title: task.title,
            format: task.format,
            artist: task.format == 'audio' ? task.platform : null,
            artworkUrl: task.thumbnailUrl,
          ),
        ),
      );
    } catch (error) {
      _message('Could not open private media: $error');
    } finally {
      if (temporaryFile != null) await _vault.removePlaybackCopy(temporaryFile);
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restore(DownloadTask task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('Restore from Vault?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text('This will decrypt the file and make it visible in your main library again.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: Colors.white38))),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFF5722)),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Restore'),
          ),
        ],
      ),
    ) ?? false;

    if (!confirmed) return;

    try {
      setState(() => _busy = true);
      final restoredFile = await _vault.restoreFromVault(task);
      if (mounted) {
        await context.read<AppState>().restoreFromVault(task.taskId, restoredFile.path);
        _message('✅ Restored: ${task.title}');
      }
    } catch (e) {
      _message('❌ Restore failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete(DownloadTask task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('Permanently Delete?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text('This item will be removed from your vault and device forever.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: Colors.white38))),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    ) ?? false;

    if (!confirmed) return;

    try {
      setState(() => _busy = true);
      if (task.vaultPath != null) {
        final file = File(task.vaultPath!);
        if (await file.exists()) await file.delete();
      }
      if (mounted) {
        context.read<AppState>().removeDownload(task.taskId);
        _message('🗑️ Deleted from Vault');
      }
    } catch (e) {
      _message('❌ Delete failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _message(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    final items = context.watch<AppState>().downloads.where((task) => task.isPrivate).toList();
    const primary = Color(0xFFFF5722);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0E),
      body: Stack(
        children: [
          // Background "Deep" layer
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.0,
                  colors: [Color(0xFF1A1A2E), Color(0xFF0A0A0E)],
                ),
              ),
              child: Center(
                child: Opacity(
                  opacity: 0.02,
                  child: Image.asset('assets/images/logo.png', width: 400),
                ),
              ),
            ),
          ),

          if (!_unlocked)
            _lockedOverlay(primary)
          else
            _unlockedView(items, primary),

          if (_busy)
            const Positioned(top: 0, left: 0, right: 0, child: LinearProgressIndicator(color: primary, minHeight: 2)),
        ],
      ),
    );
  }

  Widget _lockedOverlay(Color primary) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
      child: Container(
        color: Colors.black.withValues(alpha: 0.4),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: primary.withValues(alpha: 0.2)),
                    boxShadow: [BoxShadow(color: primary.withValues(alpha: 0.1), blurRadius: 60, spreadRadius: 10)],
                  ),
                  child: Icon(Icons.lock_person_rounded, size: 80, color: primary),
                ),
                const SizedBox(height: 40),
                const Text('PRIVATE VAULT', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 8)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text('AES-256 MILITARY GRADE ENCRYPTION', style: TextStyle(color: primary.withValues(alpha: 0.8), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                ),
                const SizedBox(height: 64),
                GestureDetector(
                  onTap: _busy ? null : _unlock,
                  child: Container(
                    width: 220,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [primary, primary.withRed(200)]),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [BoxShadow(color: primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.fingerprint_rounded, color: Colors.white),
                        SizedBox(width: 12),
                        Text('UNLOCK VAULT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.2)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _unlockedView(List<DownloadTask> items, Color primary) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          backgroundColor: const Color(0xFF0A0A0E),
          elevation: 0,
          pinned: true,
          centerTitle: true,
          title: const Text('PRIVATE VAULT', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 4, fontSize: 16)),
          actions: [
            IconButton(icon: const Icon(Icons.lock_rounded, color: Colors.white38), onPressed: () => setState(() => _unlocked = false)),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E2C),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.security_rounded, color: Colors.greenAccent),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Vault is Unlocked', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        Text('Media is decrypted on-the-fly', style: TextStyle(color: Colors.white24, fontSize: 11)),
                      ],
                    ),
                  ),
                  Text('${items.length} ITEMS', style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
        if (items.isEmpty)
          const SliverFillRemaining(
            child: Center(child: Text('No private items yet', style: TextStyle(color: Colors.white10, fontWeight: FontWeight.bold))),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final task = items[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF14141E),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(16)),
                        child: Icon(task.format == 'audio' ? Icons.audiotrack_rounded : Icons.lock_outline_rounded, color: primary, size: 24),
                      ),
                      title: Text(task.title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text('Encrypted ${task.format.toUpperCase()}', style: const TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.unarchive_rounded, color: Colors.white38, size: 20),
                            onPressed: _busy ? null : () => _restore(task),
                            tooltip: 'Restore to Library',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.white38, size: 20),
                            onPressed: _busy ? null : () => _delete(task),
                            tooltip: 'Delete Permanently',
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.play_circle_fill_rounded, color: Colors.white70, size: 32),
                            onPressed: _busy ? null : () => _play(task),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: items.length,
              ),
            ),
          ),
      ],
    );
  }
}
