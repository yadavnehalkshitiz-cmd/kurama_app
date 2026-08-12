/// Download task lifecycle states.
///
/// The 4 original states (pending, downloading, completed, failed) are
/// preserved for backward-compat with existing JSON / SQLite data.
/// New states are added without breaking the `_parseStatus` fallback.
enum DownloadStatus {
  // ── Original (legacy-compatible) ────────────────────────────
  pending,
  downloading,
  completed,
  failed,
  // ── Phase 0 additions ────────────────────────────────────────
  /// Task is queued but waiting for a worker slot.
  waitingForWorker,
  /// A post-download integrity check is running.
  verifying,
  /// User or system cancelled the task.
  cancelled,
  /// Download succeeded but file is being moved/saved locally.
  saving,
  /// File saved to the local vault (private storage).
  savedToVault,
  /// All retries exhausted — no further attempts will be made.
  permanentlyFailed,
  /// Task was recovered from a crashed session.
  recovered,
  /// Task is paused (reserved for future streaming resumption).
  paused,
}

extension DownloadStatusDisplay on DownloadStatus {
  String get displayLabel {
    switch (this) {
      case DownloadStatus.pending:
        return 'QUEUED';
      case DownloadStatus.waitingForWorker:
        return 'WAITING';
      case DownloadStatus.downloading:
        return 'DOWNLOADING';
      case DownloadStatus.verifying:
        return 'VERIFYING';
      case DownloadStatus.saving:
        return 'SAVING';
      case DownloadStatus.completed:
        return 'COMPLETED';
      case DownloadStatus.savedToVault:
        return 'IN VAULT';
      case DownloadStatus.failed:
        return 'FAILED';
      case DownloadStatus.permanentlyFailed:
        return 'FAILED';
      case DownloadStatus.cancelled:
        return 'CANCELLED';
      case DownloadStatus.recovered:
        return 'RECOVERED';
      case DownloadStatus.paused:
        return 'PAUSED';
    }
  }

  bool get isTerminal =>
      this == DownloadStatus.completed ||
      this == DownloadStatus.savedToVault ||
      this == DownloadStatus.permanentlyFailed ||
      this == DownloadStatus.cancelled;

  bool get isActive =>
      this == DownloadStatus.pending ||
      this == DownloadStatus.waitingForWorker ||
      this == DownloadStatus.downloading ||
      this == DownloadStatus.verifying ||
      this == DownloadStatus.saving ||
      this == DownloadStatus.recovered;
}

class DownloadTask {
  final String taskId;
  final String url;
  final String platform;
  final String? icon;
  final String title;
  final String format;
  final String quality;
  DownloadStatus status;
  int progress;
  int? fileSize;
  String? fileSizeStr;
  String? error;
  int? speedBytesPerSecond;
  String? speedLabel;
  int? etaSeconds;
  final DateTime createdAt;
  bool isSavedLocally;
  String? localPath;
  String? filename;

  /// Artwork URL captured at download time, shown in the media player.
  String? thumbnailUrl;
  bool isPrivate;
  String? vaultPath;

  DownloadTask({
    required this.taskId,
    required this.url,
    required this.platform,
    this.icon,
    required this.title,
    this.format = 'video',
    this.quality = 'best',
    this.status = DownloadStatus.pending,
    this.progress = 0,
    this.fileSize,
    this.fileSizeStr,
    this.error,
    this.speedBytesPerSecond,
    this.speedLabel,
    this.etaSeconds,
    DateTime? createdAt,
    this.isSavedLocally = false,
    this.localPath,
    this.filename,
    this.thumbnailUrl,
    this.isPrivate = false,
    this.vaultPath,
  }) : createdAt = createdAt ?? DateTime.now();

  String get statusLabel {
    switch (status) {
      case DownloadStatus.pending:
        return 'Queued';
      case DownloadStatus.waitingForWorker:
        return 'Waiting';
      case DownloadStatus.downloading:
        return 'Downloading $progress%';
      case DownloadStatus.verifying:
        return 'Verifying';
      case DownloadStatus.saving:
        return 'Saving';
      case DownloadStatus.completed:
        return 'Completed';
      case DownloadStatus.savedToVault:
        return 'In Vault';
      case DownloadStatus.failed:
      case DownloadStatus.permanentlyFailed:
        return 'Failed';
      case DownloadStatus.cancelled:
        return 'Cancelled';
      case DownloadStatus.recovered:
        return 'Recovered';
      case DownloadStatus.paused:
        return 'Paused';
    }
  }

  factory DownloadTask.fromJson(Map<String, dynamic> json,
      {String? taskId, String? url}) {
    DateTime? parsedDate;
    final raw = json['created_at'] as String?;
    if (raw != null) {
      parsedDate = DateTime.tryParse(raw);
    }

    return DownloadTask(
      taskId: taskId ?? json['task_id'] as String? ?? '',
      url: url ?? json['url'] as String? ?? '',
      platform: json['platform'] as String? ?? 'Unknown',
      icon: json['icon'] as String?,
      title: json['title'] as String? ?? 'Unknown',
      format: json['format'] as String? ?? 'video',
      quality: json['quality'] as String? ?? 'best',
      status: _parseStatus(json['status'] as String?),
      progress: json['progress'] as int? ?? 0,
      fileSize: json['file_size'] as int?,
      fileSizeStr: json['file_size_str'] as String?,
      error: json['error'] as String?,
      speedBytesPerSecond:
          (json['speed_bytes_per_second'] as num?)?.toInt(),
      speedLabel: json['speed_label'] as String?,
      etaSeconds: (json['eta_seconds'] as num?)?.toInt(),
      createdAt: parsedDate,
      isSavedLocally: json['is_saved_locally'] as bool? ?? false,
      localPath: json['local_path'] as String?,
      filename: json['filename'] as String?,
      thumbnailUrl: json['thumbnail'] as String?,
      isPrivate: json['is_private'] as bool? ?? false,
      vaultPath: json['vault_path'] as String?,
    );
  }

  static DownloadStatus _parseStatus(String? s) {
    switch (s) {
      case 'pending':
        return DownloadStatus.pending;
      case 'waiting_for_worker':
        return DownloadStatus.waitingForWorker;
      case 'downloading':
        return DownloadStatus.downloading;
      case 'verifying':
        return DownloadStatus.verifying;
      case 'saving':
        return DownloadStatus.saving;
      case 'completed':
        return DownloadStatus.completed;
      case 'saved_to_vault':
        return DownloadStatus.savedToVault;
      case 'failed':
        return DownloadStatus.failed;
      case 'permanently_failed':
        return DownloadStatus.permanentlyFailed;
      case 'cancelled':
        return DownloadStatus.cancelled;
      case 'recovered':
        return DownloadStatus.recovered;
      case 'paused':
        return DownloadStatus.paused;
      default:
        return DownloadStatus.pending;
    }
  }

  Map<String, dynamic> toJson() => {
        'task_id': taskId,
        'url': url,
        'platform': platform,
        'icon': icon,
        'title': title,
        'format': format,
        'quality': quality,
        'status': status.name,
        'progress': progress,
        'file_size': fileSize,
        'file_size_str': fileSizeStr,
        'error': error,
        'speed_bytes_per_second': speedBytesPerSecond,
        'speed_label': speedLabel,
        'eta_seconds': etaSeconds,
        'created_at': createdAt.toIso8601String(),
        'is_saved_locally': isSavedLocally,
        'local_path': localPath,
        'filename': filename,
        'thumbnail': thumbnailUrl,
        'is_private': isPrivate,
        'vault_path': vaultPath,
      };
}
