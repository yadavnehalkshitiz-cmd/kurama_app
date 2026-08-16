import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/download_task.dart';
import 'vault_cipher.dart';
import 'vault_key_store.dart';

class VaultService {
  final VaultCipher _cipher;
  final VaultKeyStore _keys;

  VaultService(this._cipher, this._keys);

  /// Standard vault location
  Future<Directory> get _vaultDir async {
    final support = await getApplicationSupportDirectory();
    final dir = Directory('${support.path}/private_vault');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Encrypts a local file and moves it into the private vault.
  Future<String> encryptAndMoveToVault(DownloadTask task, File source) async {
    if (!await source.exists()) throw StateError('Source file missing');
    
    final dir = await _vaultDir;
    final destination = File('${dir.path}/${task.taskId}.kurama');
    
    // Encrypt to a temporary file first
    final staging = File('${destination.path}.tmp');
    if (await staging.exists()) await staging.delete();
    
    await _cipher.encryptFile(source, staging, await _keys.getOrCreateKey());
    
    // Move to final destination
    if (await destination.exists()) await destination.delete();
    await staging.rename(destination.path);
    
    // Remove original
    await source.delete();
    
    return destination.path;
  }

  /// Decrypts a file from the vault and moves it back to the public downloads folder.
  Future<File> restoreFromVault(DownloadTask task) async {
    if (task.vaultPath == null) throw StateError('Vault path missing');
    final source = File(task.vaultPath!);
    if (!await source.exists()) throw StateError('Encrypted file missing');

    final docs = await getApplicationDocumentsDirectory();
    final kuramaDir = Directory('${docs.path}/KuramaBot');
    if (!await kuramaDir.exists()) await kuramaDir.create(recursive: true);
    
    final extension = task.format == 'audio' ? 'mp3' : 'mp4';
    final destination = File('${kuramaDir.path}/${task.taskId}_restored.$extension');
    
    await _cipher.decryptFile(source, destination, await _keys.getOrCreateKey());
    
    // Remove encrypted version
    await source.delete();
    
    return destination;
  }

  /// Decrypts to a temporary location for immediate playback.
  Future<File> openForPlayback(DownloadTask task) async {
    if (task.vaultPath == null) throw StateError('Vault path missing');
    final source = File(task.vaultPath!);
    if (!await source.exists()) throw StateError('Encrypted file missing');

    final temp = await getTemporaryDirectory();
    final extension = task.format == 'audio' ? 'mp3' : 'mp4';
    final destination = File('${temp.path}/play_${task.taskId}.$extension');
    
    if (await destination.exists()) await destination.delete();
    await _cipher.decryptFile(source, destination, await _keys.getOrCreateKey());
    
    return destination;
  }

  Future<void> removePlaybackCopy(File file) async {
    if (await file.exists()) await file.delete();
  }

  /// Legacy method kept for compatibility
  Future<String> protect(DownloadTask task) async {
    if (task.localPath == null) throw StateError('Local path missing');
    return encryptAndMoveToVault(task, File(task.localPath!));
  }
}
