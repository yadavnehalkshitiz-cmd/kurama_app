import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/user_profile.dart';
import '../services/app_state.dart';
import '../services/permission_service.dart';
import '../services/notification_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _transactionController = TextEditingController();
  UserProfile? _profile;
  String _method = 'esewa';
  String? _receiptPath;
  bool _loading = true;
  bool _submitting = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loading && _profile == null) _load();
  }

  @override
  void dispose() {
    _transactionController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final state = context.read<AppState>();
      final profile = await state.client.getUserProfile(state.userId);
      if (mounted) setState(() => _profile = profile);
    } catch (error) {
      _show('Could not load profile: $error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _claim() async {
    try {
      final state = context.read<AppState>();
      final result = await state.client.claimDailyReward(state.userId);
      _show('🎁 Reward claimed: +${result['reward']} credits');
      await _load();
    } catch (error) {
      _show(error.toString());
    }
  }

  Future<void> _pickReceipt() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'pdf'],
    );
    if (result != null && mounted) {
      setState(() => _receiptPath = result.files.single.path);
    }
  }

  Future<void> _submit() async {
    final transaction = _transactionController.text.trim();
    if (transaction.isEmpty) {
      _show('Enter your transaction or reference ID');
      return;
    }
    setState(() => _submitting = true);
    try {
      final state = context.read<AppState>();
      final result = await state.client.submitPayment(
        userId: state.userId,
        txId: transaction,
        method: _method,
        receiptPath: _receiptPath,
      );
      _transactionController.clear();
      setState(() => _receiptPath = null);
      _show(result['message']?.toString() ?? 'Submitted for review');
    } catch (error) {
      _show('Submission failed: $error');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _show(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating)
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profile;
    const primary = Color(0xFFFF5722);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0E),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(profile),
          SliverToBoxAdapter(
            child: _loading && profile == null
                ? const SizedBox(height: 300, child: Center(child: CircularProgressIndicator(color: primary)))
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        _buildIdentityBento(profile),
                        const SizedBox(height: 16),
                        _buildDailyBento(profile),
                        const SizedBox(height: 32),
                        const _SectionHeader(title: 'PERMISSIONS & ACCESS'),
                        const SizedBox(height: 16),
                        _buildPermissionsBento(),
                        const SizedBox(height: 32),
                        const _SectionHeader(title: 'PREMIUM MEMBERSHIP'),
                        const SizedBox(height: 16),
                        if (profile != null) _buildPaymentBento(profile),
                        const SizedBox(height: 32),
                        const _SectionHeader(title: 'ADVANCED SETTINGS'),
                        const SizedBox(height: 16),
                        _buildServerBento(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildServerBento() {
    final state = context.watch<AppState>();
    final controller = TextEditingController(text: state.client.baseUrl);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Backend URL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              if (state.isDiscovering)
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFF5722)),
                )
              else
                GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    state.discoverServer();
                  },
                  child: const Text('AUTO-DETECT', 
                    style: TextStyle(color: Color(0xFFFF5722), fontSize: 10, fontWeight: FontWeight.w900)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.black26,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              suffixIcon: IconButton(
                icon: const Icon(Icons.save_rounded, color: Color(0xFFFF5722), size: 20),
                onPressed: () {
                  final newUrl = controller.text.trim();
                  if (newUrl.isNotEmpty) {
                    state.updateClient(state.client.copyWith(baseUrl: newUrl));
                    _show('✅ Server URL updated');
                    FocusScope.of(context).unfocus();
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text('The app automatically searches for your PC on the local network.', 
            style: TextStyle(color: Colors.white24, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(UserProfile? profile) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: const Color(0xFF0A0A0E),
      flexibleSpace: const FlexibleSpaceBar(
        centerTitle: true,
        title: Text('PROFILE', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 4, fontSize: 16)),
      ),
      actions: [
        IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded, color: Colors.white70)),
      ],
    );
  }

  Widget _buildIdentityBento(UserProfile? profile) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFFFF5722).withValues(alpha: 0.15), const Color(0xFF1E1E2C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFFF5722).withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFF5722), width: 2),
            ),
            child: const CircleAvatar(
              radius: 32,
              backgroundColor: Colors.black26,
              child: Icon(Icons.person_rounded, size: 40, color: Colors.white),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('MEMBER', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                    if (profile?.isPro ?? false) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: const Color(0xFFFF5722), borderRadius: BorderRadius.circular(8)),
                        child: const Text('PRO', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
                Text('ID: ${profile?.userId ?? 'OFFLINE'}', style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Column(
            children: [
              Text('${profile?.credits ?? '—'}', style: const TextStyle(color: Color(0xFFFF5722), fontSize: 32, fontWeight: FontWeight.w900)),
              const Text('CREDITS', style: TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDailyBento(UserProfile? profile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.redeem_rounded, color: Color(0xFFFF5722)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Daily Drop', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text('Claim your free credits', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
              ],
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFF5722).withValues(alpha: 0.1),
              foregroundColor: const Color(0xFFFF5722),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: profile == null ? null : _claim, 
            child: const Text('CLAIM', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionsBento() {
    return Column(
      children: [
        _PermissionTile(
          icon: Icons.folder_rounded,
          title: 'Storage & Media',
          description: 'Access to save and play local files',
          onRequest: () => PermissionService.checkAndRequestStorage(context),
          checkStatus: () async {
            if (Platform.isWindows) return true;
            if (Platform.isAndroid) {
              final sdk = int.parse(Platform.version.split(' ').first.split('.').first);
              if (sdk >= 33) {
                return await Permission.videos.isGranted && await Permission.audio.isGranted;
              }
            }
            return await Permission.storage.isGranted;
          },
        ),
        const SizedBox(height: 12),
        _PermissionTile(
          icon: Icons.notifications_active_rounded,
          title: 'Notifications',
          description: 'Status of your active downloads',
          onRequest: () async {
            await NotificationService.requestPermission();
            return await Permission.notification.isGranted;
          },
          checkStatus: () => Permission.notification.isGranted,
        ),
      ],
    );
  }

  Widget _buildPaymentBento(UserProfile profile) {
    final payload = profile.paymentMethods[_method] ?? '';
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Subscription: NPR ${profile.monthlyPriceNpr} / month', 
            style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['esewa', 'khalti', 'bank'].map((m) => GestureDetector(
              onTap: () => setState(() => _method = m),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: _method == m ? const Color(0xFFFF5722) : Colors.black26,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(m.toUpperCase(), style: TextStyle(color: _method == m ? Colors.white : Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            )).toList(),
          ),
          const SizedBox(height: 24),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: QrImageView(data: payload, size: 160),
              ),
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _transactionController,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Transaction or Reference ID',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2)),
              prefixIcon: const Icon(Icons.receipt_long_rounded, color: Colors.white24),
              filled: true,
              fillColor: Colors.black26,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _pickReceipt,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.attach_file_rounded, color: Colors.white38, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(_receiptPath == null ? 'Attach receipt (optional)' : _receiptPath!.split(RegExp(r'[/\\]')).last,
                      style: TextStyle(color: _receiptPath == null ? Colors.white24 : Colors.white70, fontSize: 13),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 56,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFF5722),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _submitting ? null : _submit,
              child: _submitting 
                ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                : const Text('SUBMIT FOR REVIEW', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: const TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2));
  }
}

class _PermissionTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final Future<bool> Function() onRequest;
  final Future<bool> Function() checkStatus;

  const _PermissionTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.onRequest,
    required this.checkStatus,
  });

  @override
  State<_PermissionTile> createState() => _PermissionTileState();
}

class _PermissionTileState extends State<_PermissionTile> {
  bool _granted = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final ok = await widget.checkStatus();
    if (mounted) setState(() => _granted = ok);
  }

  Future<void> _request() async {
    final ok = await widget.onRequest();
    if (mounted) setState(() => _granted = ok);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(12)),
            child: Icon(widget.icon, color: _granted ? Colors.greenAccent : Colors.white38, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                Text(widget.description, style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 10)),
              ],
            ),
          ),
          if (!_granted)
            TextButton(
              onPressed: _request,
              child: const Text('ALLOW', style: TextStyle(color: Color(0xFFFF5722), fontWeight: FontWeight.w900, fontSize: 11)),
            )
          else
            const Icon(Icons.check_circle_outline_rounded, color: Colors.greenAccent, size: 20),
        ],
      ),
    );
  }
}
