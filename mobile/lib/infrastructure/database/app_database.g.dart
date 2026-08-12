// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $DownloadRecordsTable extends DownloadRecords
    with TableInfo<$DownloadRecordsTable, DownloadRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
      'task_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
      'url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _platformMeta =
      const VerificationMeta('platform');
  @override
  late final GeneratedColumn<String> platform = GeneratedColumn<String>(
      'platform', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Unknown'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Unknown'));
  static const VerificationMeta _formatMeta = const VerificationMeta('format');
  @override
  late final GeneratedColumn<String> format = GeneratedColumn<String>(
      'format', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('video'));
  static const VerificationMeta _qualityMeta =
      const VerificationMeta('quality');
  @override
  late final GeneratedColumn<String> quality = GeneratedColumn<String>(
      'quality', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('best'));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _progressMeta =
      const VerificationMeta('progress');
  @override
  late final GeneratedColumn<int> progress = GeneratedColumn<int>(
      'progress', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _fileSizeMeta =
      const VerificationMeta('fileSize');
  @override
  late final GeneratedColumn<int> fileSize = GeneratedColumn<int>(
      'file_size', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _fileSizeStrMeta =
      const VerificationMeta('fileSizeStr');
  @override
  late final GeneratedColumn<String> fileSizeStr = GeneratedColumn<String>(
      'file_size_str', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _errorMeta = const VerificationMeta('error');
  @override
  late final GeneratedColumn<String> error = GeneratedColumn<String>(
      'error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _localPathMeta =
      const VerificationMeta('localPath');
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
      'local_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _filenameMeta =
      const VerificationMeta('filename');
  @override
  late final GeneratedColumn<String> filename = GeneratedColumn<String>(
      'filename', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _thumbnailUrlMeta =
      const VerificationMeta('thumbnailUrl');
  @override
  late final GeneratedColumn<String> thumbnailUrl = GeneratedColumn<String>(
      'thumbnail_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isPrivateMeta =
      const VerificationMeta('isPrivate');
  @override
  late final GeneratedColumn<bool> isPrivate = GeneratedColumn<bool>(
      'is_private', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_private" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _vaultPathMeta =
      const VerificationMeta('vaultPath');
  @override
  late final GeneratedColumn<String> vaultPath = GeneratedColumn<String>(
      'vault_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        taskId,
        url,
        platform,
        title,
        format,
        quality,
        status,
        progress,
        fileSize,
        fileSizeStr,
        error,
        localPath,
        filename,
        thumbnailUrl,
        isPrivate,
        vaultPath,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'download_records';
  @override
  VerificationContext validateIntegrity(Insertable<DownloadRecord> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('task_id')) {
      context.handle(_taskIdMeta,
          taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta));
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
          _urlMeta, url.isAcceptableOrUnknown(data['url']!, _urlMeta));
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('platform')) {
      context.handle(_platformMeta,
          platform.isAcceptableOrUnknown(data['platform']!, _platformMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    }
    if (data.containsKey('format')) {
      context.handle(_formatMeta,
          format.isAcceptableOrUnknown(data['format']!, _formatMeta));
    }
    if (data.containsKey('quality')) {
      context.handle(_qualityMeta,
          quality.isAcceptableOrUnknown(data['quality']!, _qualityMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('progress')) {
      context.handle(_progressMeta,
          progress.isAcceptableOrUnknown(data['progress']!, _progressMeta));
    }
    if (data.containsKey('file_size')) {
      context.handle(_fileSizeMeta,
          fileSize.isAcceptableOrUnknown(data['file_size']!, _fileSizeMeta));
    }
    if (data.containsKey('file_size_str')) {
      context.handle(
          _fileSizeStrMeta,
          fileSizeStr.isAcceptableOrUnknown(
              data['file_size_str']!, _fileSizeStrMeta));
    }
    if (data.containsKey('error')) {
      context.handle(
          _errorMeta, error.isAcceptableOrUnknown(data['error']!, _errorMeta));
    }
    if (data.containsKey('local_path')) {
      context.handle(_localPathMeta,
          localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta));
    }
    if (data.containsKey('filename')) {
      context.handle(_filenameMeta,
          filename.isAcceptableOrUnknown(data['filename']!, _filenameMeta));
    }
    if (data.containsKey('thumbnail_url')) {
      context.handle(
          _thumbnailUrlMeta,
          thumbnailUrl.isAcceptableOrUnknown(
              data['thumbnail_url']!, _thumbnailUrlMeta));
    }
    if (data.containsKey('is_private')) {
      context.handle(_isPrivateMeta,
          isPrivate.isAcceptableOrUnknown(data['is_private']!, _isPrivateMeta));
    }
    if (data.containsKey('vault_path')) {
      context.handle(_vaultPathMeta,
          vaultPath.isAcceptableOrUnknown(data['vault_path']!, _vaultPathMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {taskId};
  @override
  DownloadRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DownloadRecord(
      taskId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}task_id'])!,
      url: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}url'])!,
      platform: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}platform'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      format: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}format'])!,
      quality: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}quality'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      progress: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}progress'])!,
      fileSize: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}file_size']),
      fileSizeStr: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_size_str']),
      error: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}error']),
      localPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}local_path']),
      filename: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}filename']),
      thumbnailUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}thumbnail_url']),
      isPrivate: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_private'])!,
      vaultPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}vault_path']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $DownloadRecordsTable createAlias(String alias) {
    return $DownloadRecordsTable(attachedDatabase, alias);
  }
}

class DownloadRecord extends DataClass implements Insertable<DownloadRecord> {
  final String taskId;
  final String url;
  final String platform;
  final String title;
  final String format;
  final String quality;
  final String status;
  final int progress;
  final int? fileSize;
  final String? fileSizeStr;
  final String? error;
  final String? localPath;
  final String? filename;
  final String? thumbnailUrl;
  final bool isPrivate;
  final String? vaultPath;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DownloadRecord(
      {required this.taskId,
      required this.url,
      required this.platform,
      required this.title,
      required this.format,
      required this.quality,
      required this.status,
      required this.progress,
      this.fileSize,
      this.fileSizeStr,
      this.error,
      this.localPath,
      this.filename,
      this.thumbnailUrl,
      required this.isPrivate,
      this.vaultPath,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['task_id'] = Variable<String>(taskId);
    map['url'] = Variable<String>(url);
    map['platform'] = Variable<String>(platform);
    map['title'] = Variable<String>(title);
    map['format'] = Variable<String>(format);
    map['quality'] = Variable<String>(quality);
    map['status'] = Variable<String>(status);
    map['progress'] = Variable<int>(progress);
    if (!nullToAbsent || fileSize != null) {
      map['file_size'] = Variable<int>(fileSize);
    }
    if (!nullToAbsent || fileSizeStr != null) {
      map['file_size_str'] = Variable<String>(fileSizeStr);
    }
    if (!nullToAbsent || error != null) {
      map['error'] = Variable<String>(error);
    }
    if (!nullToAbsent || localPath != null) {
      map['local_path'] = Variable<String>(localPath);
    }
    if (!nullToAbsent || filename != null) {
      map['filename'] = Variable<String>(filename);
    }
    if (!nullToAbsent || thumbnailUrl != null) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl);
    }
    map['is_private'] = Variable<bool>(isPrivate);
    if (!nullToAbsent || vaultPath != null) {
      map['vault_path'] = Variable<String>(vaultPath);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DownloadRecordsCompanion toCompanion(bool nullToAbsent) {
    return DownloadRecordsCompanion(
      taskId: Value(taskId),
      url: Value(url),
      platform: Value(platform),
      title: Value(title),
      format: Value(format),
      quality: Value(quality),
      status: Value(status),
      progress: Value(progress),
      fileSize: fileSize == null && nullToAbsent
          ? const Value.absent()
          : Value(fileSize),
      fileSizeStr: fileSizeStr == null && nullToAbsent
          ? const Value.absent()
          : Value(fileSizeStr),
      error:
          error == null && nullToAbsent ? const Value.absent() : Value(error),
      localPath: localPath == null && nullToAbsent
          ? const Value.absent()
          : Value(localPath),
      filename: filename == null && nullToAbsent
          ? const Value.absent()
          : Value(filename),
      thumbnailUrl: thumbnailUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailUrl),
      isPrivate: Value(isPrivate),
      vaultPath: vaultPath == null && nullToAbsent
          ? const Value.absent()
          : Value(vaultPath),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DownloadRecord.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DownloadRecord(
      taskId: serializer.fromJson<String>(json['taskId']),
      url: serializer.fromJson<String>(json['url']),
      platform: serializer.fromJson<String>(json['platform']),
      title: serializer.fromJson<String>(json['title']),
      format: serializer.fromJson<String>(json['format']),
      quality: serializer.fromJson<String>(json['quality']),
      status: serializer.fromJson<String>(json['status']),
      progress: serializer.fromJson<int>(json['progress']),
      fileSize: serializer.fromJson<int?>(json['fileSize']),
      fileSizeStr: serializer.fromJson<String?>(json['fileSizeStr']),
      error: serializer.fromJson<String?>(json['error']),
      localPath: serializer.fromJson<String?>(json['localPath']),
      filename: serializer.fromJson<String?>(json['filename']),
      thumbnailUrl: serializer.fromJson<String?>(json['thumbnailUrl']),
      isPrivate: serializer.fromJson<bool>(json['isPrivate']),
      vaultPath: serializer.fromJson<String?>(json['vaultPath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'taskId': serializer.toJson<String>(taskId),
      'url': serializer.toJson<String>(url),
      'platform': serializer.toJson<String>(platform),
      'title': serializer.toJson<String>(title),
      'format': serializer.toJson<String>(format),
      'quality': serializer.toJson<String>(quality),
      'status': serializer.toJson<String>(status),
      'progress': serializer.toJson<int>(progress),
      'fileSize': serializer.toJson<int?>(fileSize),
      'fileSizeStr': serializer.toJson<String?>(fileSizeStr),
      'error': serializer.toJson<String?>(error),
      'localPath': serializer.toJson<String?>(localPath),
      'filename': serializer.toJson<String?>(filename),
      'thumbnailUrl': serializer.toJson<String?>(thumbnailUrl),
      'isPrivate': serializer.toJson<bool>(isPrivate),
      'vaultPath': serializer.toJson<String?>(vaultPath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DownloadRecord copyWith(
          {String? taskId,
          String? url,
          String? platform,
          String? title,
          String? format,
          String? quality,
          String? status,
          int? progress,
          Value<int?> fileSize = const Value.absent(),
          Value<String?> fileSizeStr = const Value.absent(),
          Value<String?> error = const Value.absent(),
          Value<String?> localPath = const Value.absent(),
          Value<String?> filename = const Value.absent(),
          Value<String?> thumbnailUrl = const Value.absent(),
          bool? isPrivate,
          Value<String?> vaultPath = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      DownloadRecord(
        taskId: taskId ?? this.taskId,
        url: url ?? this.url,
        platform: platform ?? this.platform,
        title: title ?? this.title,
        format: format ?? this.format,
        quality: quality ?? this.quality,
        status: status ?? this.status,
        progress: progress ?? this.progress,
        fileSize: fileSize.present ? fileSize.value : this.fileSize,
        fileSizeStr: fileSizeStr.present ? fileSizeStr.value : this.fileSizeStr,
        error: error.present ? error.value : this.error,
        localPath: localPath.present ? localPath.value : this.localPath,
        filename: filename.present ? filename.value : this.filename,
        thumbnailUrl:
            thumbnailUrl.present ? thumbnailUrl.value : this.thumbnailUrl,
        isPrivate: isPrivate ?? this.isPrivate,
        vaultPath: vaultPath.present ? vaultPath.value : this.vaultPath,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  DownloadRecord copyWithCompanion(DownloadRecordsCompanion data) {
    return DownloadRecord(
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      url: data.url.present ? data.url.value : this.url,
      platform: data.platform.present ? data.platform.value : this.platform,
      title: data.title.present ? data.title.value : this.title,
      format: data.format.present ? data.format.value : this.format,
      quality: data.quality.present ? data.quality.value : this.quality,
      status: data.status.present ? data.status.value : this.status,
      progress: data.progress.present ? data.progress.value : this.progress,
      fileSize: data.fileSize.present ? data.fileSize.value : this.fileSize,
      fileSizeStr:
          data.fileSizeStr.present ? data.fileSizeStr.value : this.fileSizeStr,
      error: data.error.present ? data.error.value : this.error,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      filename: data.filename.present ? data.filename.value : this.filename,
      thumbnailUrl: data.thumbnailUrl.present
          ? data.thumbnailUrl.value
          : this.thumbnailUrl,
      isPrivate: data.isPrivate.present ? data.isPrivate.value : this.isPrivate,
      vaultPath: data.vaultPath.present ? data.vaultPath.value : this.vaultPath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DownloadRecord(')
          ..write('taskId: $taskId, ')
          ..write('url: $url, ')
          ..write('platform: $platform, ')
          ..write('title: $title, ')
          ..write('format: $format, ')
          ..write('quality: $quality, ')
          ..write('status: $status, ')
          ..write('progress: $progress, ')
          ..write('fileSize: $fileSize, ')
          ..write('fileSizeStr: $fileSizeStr, ')
          ..write('error: $error, ')
          ..write('localPath: $localPath, ')
          ..write('filename: $filename, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('isPrivate: $isPrivate, ')
          ..write('vaultPath: $vaultPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      taskId,
      url,
      platform,
      title,
      format,
      quality,
      status,
      progress,
      fileSize,
      fileSizeStr,
      error,
      localPath,
      filename,
      thumbnailUrl,
      isPrivate,
      vaultPath,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DownloadRecord &&
          other.taskId == this.taskId &&
          other.url == this.url &&
          other.platform == this.platform &&
          other.title == this.title &&
          other.format == this.format &&
          other.quality == this.quality &&
          other.status == this.status &&
          other.progress == this.progress &&
          other.fileSize == this.fileSize &&
          other.fileSizeStr == this.fileSizeStr &&
          other.error == this.error &&
          other.localPath == this.localPath &&
          other.filename == this.filename &&
          other.thumbnailUrl == this.thumbnailUrl &&
          other.isPrivate == this.isPrivate &&
          other.vaultPath == this.vaultPath &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DownloadRecordsCompanion extends UpdateCompanion<DownloadRecord> {
  final Value<String> taskId;
  final Value<String> url;
  final Value<String> platform;
  final Value<String> title;
  final Value<String> format;
  final Value<String> quality;
  final Value<String> status;
  final Value<int> progress;
  final Value<int?> fileSize;
  final Value<String?> fileSizeStr;
  final Value<String?> error;
  final Value<String?> localPath;
  final Value<String?> filename;
  final Value<String?> thumbnailUrl;
  final Value<bool> isPrivate;
  final Value<String?> vaultPath;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const DownloadRecordsCompanion({
    this.taskId = const Value.absent(),
    this.url = const Value.absent(),
    this.platform = const Value.absent(),
    this.title = const Value.absent(),
    this.format = const Value.absent(),
    this.quality = const Value.absent(),
    this.status = const Value.absent(),
    this.progress = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.fileSizeStr = const Value.absent(),
    this.error = const Value.absent(),
    this.localPath = const Value.absent(),
    this.filename = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    this.isPrivate = const Value.absent(),
    this.vaultPath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DownloadRecordsCompanion.insert({
    required String taskId,
    required String url,
    this.platform = const Value.absent(),
    this.title = const Value.absent(),
    this.format = const Value.absent(),
    this.quality = const Value.absent(),
    this.status = const Value.absent(),
    this.progress = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.fileSizeStr = const Value.absent(),
    this.error = const Value.absent(),
    this.localPath = const Value.absent(),
    this.filename = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    this.isPrivate = const Value.absent(),
    this.vaultPath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : taskId = Value(taskId),
        url = Value(url);
  static Insertable<DownloadRecord> custom({
    Expression<String>? taskId,
    Expression<String>? url,
    Expression<String>? platform,
    Expression<String>? title,
    Expression<String>? format,
    Expression<String>? quality,
    Expression<String>? status,
    Expression<int>? progress,
    Expression<int>? fileSize,
    Expression<String>? fileSizeStr,
    Expression<String>? error,
    Expression<String>? localPath,
    Expression<String>? filename,
    Expression<String>? thumbnailUrl,
    Expression<bool>? isPrivate,
    Expression<String>? vaultPath,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (taskId != null) 'task_id': taskId,
      if (url != null) 'url': url,
      if (platform != null) 'platform': platform,
      if (title != null) 'title': title,
      if (format != null) 'format': format,
      if (quality != null) 'quality': quality,
      if (status != null) 'status': status,
      if (progress != null) 'progress': progress,
      if (fileSize != null) 'file_size': fileSize,
      if (fileSizeStr != null) 'file_size_str': fileSizeStr,
      if (error != null) 'error': error,
      if (localPath != null) 'local_path': localPath,
      if (filename != null) 'filename': filename,
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
      if (isPrivate != null) 'is_private': isPrivate,
      if (vaultPath != null) 'vault_path': vaultPath,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DownloadRecordsCompanion copyWith(
      {Value<String>? taskId,
      Value<String>? url,
      Value<String>? platform,
      Value<String>? title,
      Value<String>? format,
      Value<String>? quality,
      Value<String>? status,
      Value<int>? progress,
      Value<int?>? fileSize,
      Value<String?>? fileSizeStr,
      Value<String?>? error,
      Value<String?>? localPath,
      Value<String?>? filename,
      Value<String?>? thumbnailUrl,
      Value<bool>? isPrivate,
      Value<String?>? vaultPath,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return DownloadRecordsCompanion(
      taskId: taskId ?? this.taskId,
      url: url ?? this.url,
      platform: platform ?? this.platform,
      title: title ?? this.title,
      format: format ?? this.format,
      quality: quality ?? this.quality,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      fileSize: fileSize ?? this.fileSize,
      fileSizeStr: fileSizeStr ?? this.fileSizeStr,
      error: error ?? this.error,
      localPath: localPath ?? this.localPath,
      filename: filename ?? this.filename,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      isPrivate: isPrivate ?? this.isPrivate,
      vaultPath: vaultPath ?? this.vaultPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (platform.present) {
      map['platform'] = Variable<String>(platform.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (format.present) {
      map['format'] = Variable<String>(format.value);
    }
    if (quality.present) {
      map['quality'] = Variable<String>(quality.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (progress.present) {
      map['progress'] = Variable<int>(progress.value);
    }
    if (fileSize.present) {
      map['file_size'] = Variable<int>(fileSize.value);
    }
    if (fileSizeStr.present) {
      map['file_size_str'] = Variable<String>(fileSizeStr.value);
    }
    if (error.present) {
      map['error'] = Variable<String>(error.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (filename.present) {
      map['filename'] = Variable<String>(filename.value);
    }
    if (thumbnailUrl.present) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl.value);
    }
    if (isPrivate.present) {
      map['is_private'] = Variable<bool>(isPrivate.value);
    }
    if (vaultPath.present) {
      map['vault_path'] = Variable<String>(vaultPath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadRecordsCompanion(')
          ..write('taskId: $taskId, ')
          ..write('url: $url, ')
          ..write('platform: $platform, ')
          ..write('title: $title, ')
          ..write('format: $format, ')
          ..write('quality: $quality, ')
          ..write('status: $status, ')
          ..write('progress: $progress, ')
          ..write('fileSize: $fileSize, ')
          ..write('fileSizeStr: $fileSizeStr, ')
          ..write('error: $error, ')
          ..write('localPath: $localPath, ')
          ..write('filename: $filename, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('isPrivate: $isPrivate, ')
          ..write('vaultPath: $vaultPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlaybackPositionsTable extends PlaybackPositions
    with TableInfo<$PlaybackPositionsTable, PlaybackPosition> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaybackPositionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _mediaIdMeta =
      const VerificationMeta('mediaId');
  @override
  late final GeneratedColumn<String> mediaId = GeneratedColumn<String>(
      'media_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _positionMsMeta =
      const VerificationMeta('positionMs');
  @override
  late final GeneratedColumn<int> positionMs = GeneratedColumn<int>(
      'position_ms', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [mediaId, positionMs, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playback_positions';
  @override
  VerificationContext validateIntegrity(Insertable<PlaybackPosition> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('media_id')) {
      context.handle(_mediaIdMeta,
          mediaId.isAcceptableOrUnknown(data['media_id']!, _mediaIdMeta));
    } else if (isInserting) {
      context.missing(_mediaIdMeta);
    }
    if (data.containsKey('position_ms')) {
      context.handle(
          _positionMsMeta,
          positionMs.isAcceptableOrUnknown(
              data['position_ms']!, _positionMsMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {mediaId};
  @override
  PlaybackPosition map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaybackPosition(
      mediaId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}media_id'])!,
      positionMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}position_ms'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $PlaybackPositionsTable createAlias(String alias) {
    return $PlaybackPositionsTable(attachedDatabase, alias);
  }
}

class PlaybackPosition extends DataClass
    implements Insertable<PlaybackPosition> {
  final String mediaId;
  final int positionMs;
  final DateTime updatedAt;
  const PlaybackPosition(
      {required this.mediaId,
      required this.positionMs,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['media_id'] = Variable<String>(mediaId);
    map['position_ms'] = Variable<int>(positionMs);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PlaybackPositionsCompanion toCompanion(bool nullToAbsent) {
    return PlaybackPositionsCompanion(
      mediaId: Value(mediaId),
      positionMs: Value(positionMs),
      updatedAt: Value(updatedAt),
    );
  }

  factory PlaybackPosition.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaybackPosition(
      mediaId: serializer.fromJson<String>(json['mediaId']),
      positionMs: serializer.fromJson<int>(json['positionMs']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'mediaId': serializer.toJson<String>(mediaId),
      'positionMs': serializer.toJson<int>(positionMs),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PlaybackPosition copyWith(
          {String? mediaId, int? positionMs, DateTime? updatedAt}) =>
      PlaybackPosition(
        mediaId: mediaId ?? this.mediaId,
        positionMs: positionMs ?? this.positionMs,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  PlaybackPosition copyWithCompanion(PlaybackPositionsCompanion data) {
    return PlaybackPosition(
      mediaId: data.mediaId.present ? data.mediaId.value : this.mediaId,
      positionMs:
          data.positionMs.present ? data.positionMs.value : this.positionMs,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaybackPosition(')
          ..write('mediaId: $mediaId, ')
          ..write('positionMs: $positionMs, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(mediaId, positionMs, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaybackPosition &&
          other.mediaId == this.mediaId &&
          other.positionMs == this.positionMs &&
          other.updatedAt == this.updatedAt);
}

class PlaybackPositionsCompanion extends UpdateCompanion<PlaybackPosition> {
  final Value<String> mediaId;
  final Value<int> positionMs;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PlaybackPositionsCompanion({
    this.mediaId = const Value.absent(),
    this.positionMs = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlaybackPositionsCompanion.insert({
    required String mediaId,
    this.positionMs = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : mediaId = Value(mediaId);
  static Insertable<PlaybackPosition> custom({
    Expression<String>? mediaId,
    Expression<int>? positionMs,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (mediaId != null) 'media_id': mediaId,
      if (positionMs != null) 'position_ms': positionMs,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlaybackPositionsCompanion copyWith(
      {Value<String>? mediaId,
      Value<int>? positionMs,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return PlaybackPositionsCompanion(
      mediaId: mediaId ?? this.mediaId,
      positionMs: positionMs ?? this.positionMs,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (mediaId.present) {
      map['media_id'] = Variable<String>(mediaId.value);
    }
    if (positionMs.present) {
      map['position_ms'] = Variable<int>(positionMs.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaybackPositionsCompanion(')
          ..write('mediaId: $mediaId, ')
          ..write('positionMs: $positionMs, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SchemaMetadataTable extends SchemaMetadata
    with TableInfo<$SchemaMetadataTable, SchemaMetadataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SchemaMetadataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'schema_metadata';
  @override
  VerificationContext validateIntegrity(Insertable<SchemaMetadataData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SchemaMetadataData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SchemaMetadataData(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $SchemaMetadataTable createAlias(String alias) {
    return $SchemaMetadataTable(attachedDatabase, alias);
  }
}

class SchemaMetadataData extends DataClass
    implements Insertable<SchemaMetadataData> {
  final String key;
  final String value;
  const SchemaMetadataData({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SchemaMetadataCompanion toCompanion(bool nullToAbsent) {
    return SchemaMetadataCompanion(
      key: Value(key),
      value: Value(value),
    );
  }

  factory SchemaMetadataData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SchemaMetadataData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SchemaMetadataData copyWith({String? key, String? value}) =>
      SchemaMetadataData(
        key: key ?? this.key,
        value: value ?? this.value,
      );
  SchemaMetadataData copyWithCompanion(SchemaMetadataCompanion data) {
    return SchemaMetadataData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SchemaMetadataData(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SchemaMetadataData &&
          other.key == this.key &&
          other.value == this.value);
}

class SchemaMetadataCompanion extends UpdateCompanion<SchemaMetadataData> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SchemaMetadataCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SchemaMetadataCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value);
  static Insertable<SchemaMetadataData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SchemaMetadataCompanion copyWith(
      {Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return SchemaMetadataCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SchemaMetadataCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MigrationRecordsTable extends MigrationRecords
    with TableInfo<$MigrationRecordsTable, MigrationRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MigrationRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _startedAtMeta =
      const VerificationMeta('startedAt');
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
      'started_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _detailMeta = const VerificationMeta('detail');
  @override
  late final GeneratedColumn<String> detail = GeneratedColumn<String>(
      'detail', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, status, startedAt, completedAt, detail];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'migration_records';
  @override
  VerificationContext validateIntegrity(Insertable<MigrationRecord> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('started_at')) {
      context.handle(_startedAtMeta,
          startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta));
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    if (data.containsKey('detail')) {
      context.handle(_detailMeta,
          detail.isAcceptableOrUnknown(data['detail']!, _detailMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MigrationRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MigrationRecord(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      startedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}started_at'])!,
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
      detail: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}detail']),
    );
  }

  @override
  $MigrationRecordsTable createAlias(String alias) {
    return $MigrationRecordsTable(attachedDatabase, alias);
  }
}

class MigrationRecord extends DataClass implements Insertable<MigrationRecord> {
  final String id;
  final String status;
  final DateTime startedAt;
  final DateTime? completedAt;
  final String? detail;
  const MigrationRecord(
      {required this.id,
      required this.status,
      required this.startedAt,
      this.completedAt,
      this.detail});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['status'] = Variable<String>(status);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || detail != null) {
      map['detail'] = Variable<String>(detail);
    }
    return map;
  }

  MigrationRecordsCompanion toCompanion(bool nullToAbsent) {
    return MigrationRecordsCompanion(
      id: Value(id),
      status: Value(status),
      startedAt: Value(startedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      detail:
          detail == null && nullToAbsent ? const Value.absent() : Value(detail),
    );
  }

  factory MigrationRecord.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MigrationRecord(
      id: serializer.fromJson<String>(json['id']),
      status: serializer.fromJson<String>(json['status']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      detail: serializer.fromJson<String?>(json['detail']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'status': serializer.toJson<String>(status),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'detail': serializer.toJson<String?>(detail),
    };
  }

  MigrationRecord copyWith(
          {String? id,
          String? status,
          DateTime? startedAt,
          Value<DateTime?> completedAt = const Value.absent(),
          Value<String?> detail = const Value.absent()}) =>
      MigrationRecord(
        id: id ?? this.id,
        status: status ?? this.status,
        startedAt: startedAt ?? this.startedAt,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
        detail: detail.present ? detail.value : this.detail,
      );
  MigrationRecord copyWithCompanion(MigrationRecordsCompanion data) {
    return MigrationRecord(
      id: data.id.present ? data.id.value : this.id,
      status: data.status.present ? data.status.value : this.status,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      detail: data.detail.present ? data.detail.value : this.detail,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MigrationRecord(')
          ..write('id: $id, ')
          ..write('status: $status, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('detail: $detail')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, status, startedAt, completedAt, detail);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MigrationRecord &&
          other.id == this.id &&
          other.status == this.status &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt &&
          other.detail == this.detail);
}

class MigrationRecordsCompanion extends UpdateCompanion<MigrationRecord> {
  final Value<String> id;
  final Value<String> status;
  final Value<DateTime> startedAt;
  final Value<DateTime?> completedAt;
  final Value<String?> detail;
  final Value<int> rowid;
  const MigrationRecordsCompanion({
    this.id = const Value.absent(),
    this.status = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.detail = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MigrationRecordsCompanion.insert({
    required String id,
    this.status = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.detail = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<MigrationRecord> custom({
    Expression<String>? id,
    Expression<String>? status,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? completedAt,
    Expression<String>? detail,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (status != null) 'status': status,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (detail != null) 'detail': detail,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MigrationRecordsCompanion copyWith(
      {Value<String>? id,
      Value<String>? status,
      Value<DateTime>? startedAt,
      Value<DateTime?>? completedAt,
      Value<String?>? detail,
      Value<int>? rowid}) {
    return MigrationRecordsCompanion(
      id: id ?? this.id,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      detail: detail ?? this.detail,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (detail.present) {
      map['detail'] = Variable<String>(detail.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MigrationRecordsCompanion(')
          ..write('id: $id, ')
          ..write('status: $status, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('detail: $detail, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DownloadRecordsTable downloadRecords =
      $DownloadRecordsTable(this);
  late final $PlaybackPositionsTable playbackPositions =
      $PlaybackPositionsTable(this);
  late final $SchemaMetadataTable schemaMetadata = $SchemaMetadataTable(this);
  late final $MigrationRecordsTable migrationRecords =
      $MigrationRecordsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [downloadRecords, playbackPositions, schemaMetadata, migrationRecords];
}

typedef $$DownloadRecordsTableCreateCompanionBuilder = DownloadRecordsCompanion
    Function({
  required String taskId,
  required String url,
  Value<String> platform,
  Value<String> title,
  Value<String> format,
  Value<String> quality,
  Value<String> status,
  Value<int> progress,
  Value<int?> fileSize,
  Value<String?> fileSizeStr,
  Value<String?> error,
  Value<String?> localPath,
  Value<String?> filename,
  Value<String?> thumbnailUrl,
  Value<bool> isPrivate,
  Value<String?> vaultPath,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$DownloadRecordsTableUpdateCompanionBuilder = DownloadRecordsCompanion
    Function({
  Value<String> taskId,
  Value<String> url,
  Value<String> platform,
  Value<String> title,
  Value<String> format,
  Value<String> quality,
  Value<String> status,
  Value<int> progress,
  Value<int?> fileSize,
  Value<String?> fileSizeStr,
  Value<String?> error,
  Value<String?> localPath,
  Value<String?> filename,
  Value<String?> thumbnailUrl,
  Value<bool> isPrivate,
  Value<String?> vaultPath,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$DownloadRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $DownloadRecordsTable> {
  $$DownloadRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get taskId => $composableBuilder(
      column: $table.taskId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get platform => $composableBuilder(
      column: $table.platform, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get format => $composableBuilder(
      column: $table.format, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get quality => $composableBuilder(
      column: $table.quality, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get progress => $composableBuilder(
      column: $table.progress, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get fileSize => $composableBuilder(
      column: $table.fileSize, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fileSizeStr => $composableBuilder(
      column: $table.fileSizeStr, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get error => $composableBuilder(
      column: $table.error, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localPath => $composableBuilder(
      column: $table.localPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get filename => $composableBuilder(
      column: $table.filename, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get thumbnailUrl => $composableBuilder(
      column: $table.thumbnailUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isPrivate => $composableBuilder(
      column: $table.isPrivate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get vaultPath => $composableBuilder(
      column: $table.vaultPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$DownloadRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $DownloadRecordsTable> {
  $$DownloadRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get taskId => $composableBuilder(
      column: $table.taskId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get platform => $composableBuilder(
      column: $table.platform, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get format => $composableBuilder(
      column: $table.format, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get quality => $composableBuilder(
      column: $table.quality, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get progress => $composableBuilder(
      column: $table.progress, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get fileSize => $composableBuilder(
      column: $table.fileSize, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fileSizeStr => $composableBuilder(
      column: $table.fileSizeStr, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get error => $composableBuilder(
      column: $table.error, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localPath => $composableBuilder(
      column: $table.localPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get filename => $composableBuilder(
      column: $table.filename, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get thumbnailUrl => $composableBuilder(
      column: $table.thumbnailUrl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isPrivate => $composableBuilder(
      column: $table.isPrivate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get vaultPath => $composableBuilder(
      column: $table.vaultPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$DownloadRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DownloadRecordsTable> {
  $$DownloadRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get platform =>
      $composableBuilder(column: $table.platform, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get format =>
      $composableBuilder(column: $table.format, builder: (column) => column);

  GeneratedColumn<String> get quality =>
      $composableBuilder(column: $table.quality, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get progress =>
      $composableBuilder(column: $table.progress, builder: (column) => column);

  GeneratedColumn<int> get fileSize =>
      $composableBuilder(column: $table.fileSize, builder: (column) => column);

  GeneratedColumn<String> get fileSizeStr => $composableBuilder(
      column: $table.fileSizeStr, builder: (column) => column);

  GeneratedColumn<String> get error =>
      $composableBuilder(column: $table.error, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get filename =>
      $composableBuilder(column: $table.filename, builder: (column) => column);

  GeneratedColumn<String> get thumbnailUrl => $composableBuilder(
      column: $table.thumbnailUrl, builder: (column) => column);

  GeneratedColumn<bool> get isPrivate =>
      $composableBuilder(column: $table.isPrivate, builder: (column) => column);

  GeneratedColumn<String> get vaultPath =>
      $composableBuilder(column: $table.vaultPath, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DownloadRecordsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DownloadRecordsTable,
    DownloadRecord,
    $$DownloadRecordsTableFilterComposer,
    $$DownloadRecordsTableOrderingComposer,
    $$DownloadRecordsTableAnnotationComposer,
    $$DownloadRecordsTableCreateCompanionBuilder,
    $$DownloadRecordsTableUpdateCompanionBuilder,
    (
      DownloadRecord,
      BaseReferences<_$AppDatabase, $DownloadRecordsTable, DownloadRecord>
    ),
    DownloadRecord,
    PrefetchHooks Function()> {
  $$DownloadRecordsTableTableManager(
      _$AppDatabase db, $DownloadRecordsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DownloadRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DownloadRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DownloadRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> taskId = const Value.absent(),
            Value<String> url = const Value.absent(),
            Value<String> platform = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> format = const Value.absent(),
            Value<String> quality = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> progress = const Value.absent(),
            Value<int?> fileSize = const Value.absent(),
            Value<String?> fileSizeStr = const Value.absent(),
            Value<String?> error = const Value.absent(),
            Value<String?> localPath = const Value.absent(),
            Value<String?> filename = const Value.absent(),
            Value<String?> thumbnailUrl = const Value.absent(),
            Value<bool> isPrivate = const Value.absent(),
            Value<String?> vaultPath = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DownloadRecordsCompanion(
            taskId: taskId,
            url: url,
            platform: platform,
            title: title,
            format: format,
            quality: quality,
            status: status,
            progress: progress,
            fileSize: fileSize,
            fileSizeStr: fileSizeStr,
            error: error,
            localPath: localPath,
            filename: filename,
            thumbnailUrl: thumbnailUrl,
            isPrivate: isPrivate,
            vaultPath: vaultPath,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String taskId,
            required String url,
            Value<String> platform = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> format = const Value.absent(),
            Value<String> quality = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> progress = const Value.absent(),
            Value<int?> fileSize = const Value.absent(),
            Value<String?> fileSizeStr = const Value.absent(),
            Value<String?> error = const Value.absent(),
            Value<String?> localPath = const Value.absent(),
            Value<String?> filename = const Value.absent(),
            Value<String?> thumbnailUrl = const Value.absent(),
            Value<bool> isPrivate = const Value.absent(),
            Value<String?> vaultPath = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DownloadRecordsCompanion.insert(
            taskId: taskId,
            url: url,
            platform: platform,
            title: title,
            format: format,
            quality: quality,
            status: status,
            progress: progress,
            fileSize: fileSize,
            fileSizeStr: fileSizeStr,
            error: error,
            localPath: localPath,
            filename: filename,
            thumbnailUrl: thumbnailUrl,
            isPrivate: isPrivate,
            vaultPath: vaultPath,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DownloadRecordsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DownloadRecordsTable,
    DownloadRecord,
    $$DownloadRecordsTableFilterComposer,
    $$DownloadRecordsTableOrderingComposer,
    $$DownloadRecordsTableAnnotationComposer,
    $$DownloadRecordsTableCreateCompanionBuilder,
    $$DownloadRecordsTableUpdateCompanionBuilder,
    (
      DownloadRecord,
      BaseReferences<_$AppDatabase, $DownloadRecordsTable, DownloadRecord>
    ),
    DownloadRecord,
    PrefetchHooks Function()>;
typedef $$PlaybackPositionsTableCreateCompanionBuilder
    = PlaybackPositionsCompanion Function({
  required String mediaId,
  Value<int> positionMs,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$PlaybackPositionsTableUpdateCompanionBuilder
    = PlaybackPositionsCompanion Function({
  Value<String> mediaId,
  Value<int> positionMs,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$PlaybackPositionsTableFilterComposer
    extends Composer<_$AppDatabase, $PlaybackPositionsTable> {
  $$PlaybackPositionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get mediaId => $composableBuilder(
      column: $table.mediaId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get positionMs => $composableBuilder(
      column: $table.positionMs, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$PlaybackPositionsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaybackPositionsTable> {
  $$PlaybackPositionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get mediaId => $composableBuilder(
      column: $table.mediaId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get positionMs => $composableBuilder(
      column: $table.positionMs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$PlaybackPositionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaybackPositionsTable> {
  $$PlaybackPositionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get mediaId =>
      $composableBuilder(column: $table.mediaId, builder: (column) => column);

  GeneratedColumn<int> get positionMs => $composableBuilder(
      column: $table.positionMs, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PlaybackPositionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PlaybackPositionsTable,
    PlaybackPosition,
    $$PlaybackPositionsTableFilterComposer,
    $$PlaybackPositionsTableOrderingComposer,
    $$PlaybackPositionsTableAnnotationComposer,
    $$PlaybackPositionsTableCreateCompanionBuilder,
    $$PlaybackPositionsTableUpdateCompanionBuilder,
    (
      PlaybackPosition,
      BaseReferences<_$AppDatabase, $PlaybackPositionsTable, PlaybackPosition>
    ),
    PlaybackPosition,
    PrefetchHooks Function()> {
  $$PlaybackPositionsTableTableManager(
      _$AppDatabase db, $PlaybackPositionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaybackPositionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaybackPositionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaybackPositionsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> mediaId = const Value.absent(),
            Value<int> positionMs = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PlaybackPositionsCompanion(
            mediaId: mediaId,
            positionMs: positionMs,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String mediaId,
            Value<int> positionMs = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PlaybackPositionsCompanion.insert(
            mediaId: mediaId,
            positionMs: positionMs,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PlaybackPositionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PlaybackPositionsTable,
    PlaybackPosition,
    $$PlaybackPositionsTableFilterComposer,
    $$PlaybackPositionsTableOrderingComposer,
    $$PlaybackPositionsTableAnnotationComposer,
    $$PlaybackPositionsTableCreateCompanionBuilder,
    $$PlaybackPositionsTableUpdateCompanionBuilder,
    (
      PlaybackPosition,
      BaseReferences<_$AppDatabase, $PlaybackPositionsTable, PlaybackPosition>
    ),
    PlaybackPosition,
    PrefetchHooks Function()>;
typedef $$SchemaMetadataTableCreateCompanionBuilder = SchemaMetadataCompanion
    Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$SchemaMetadataTableUpdateCompanionBuilder = SchemaMetadataCompanion
    Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$SchemaMetadataTableFilterComposer
    extends Composer<_$AppDatabase, $SchemaMetadataTable> {
  $$SchemaMetadataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$SchemaMetadataTableOrderingComposer
    extends Composer<_$AppDatabase, $SchemaMetadataTable> {
  $$SchemaMetadataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$SchemaMetadataTableAnnotationComposer
    extends Composer<_$AppDatabase, $SchemaMetadataTable> {
  $$SchemaMetadataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SchemaMetadataTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SchemaMetadataTable,
    SchemaMetadataData,
    $$SchemaMetadataTableFilterComposer,
    $$SchemaMetadataTableOrderingComposer,
    $$SchemaMetadataTableAnnotationComposer,
    $$SchemaMetadataTableCreateCompanionBuilder,
    $$SchemaMetadataTableUpdateCompanionBuilder,
    (
      SchemaMetadataData,
      BaseReferences<_$AppDatabase, $SchemaMetadataTable, SchemaMetadataData>
    ),
    SchemaMetadataData,
    PrefetchHooks Function()> {
  $$SchemaMetadataTableTableManager(
      _$AppDatabase db, $SchemaMetadataTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SchemaMetadataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SchemaMetadataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SchemaMetadataTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SchemaMetadataCompanion(
            key: key,
            value: value,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) =>
              SchemaMetadataCompanion.insert(
            key: key,
            value: value,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SchemaMetadataTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SchemaMetadataTable,
    SchemaMetadataData,
    $$SchemaMetadataTableFilterComposer,
    $$SchemaMetadataTableOrderingComposer,
    $$SchemaMetadataTableAnnotationComposer,
    $$SchemaMetadataTableCreateCompanionBuilder,
    $$SchemaMetadataTableUpdateCompanionBuilder,
    (
      SchemaMetadataData,
      BaseReferences<_$AppDatabase, $SchemaMetadataTable, SchemaMetadataData>
    ),
    SchemaMetadataData,
    PrefetchHooks Function()>;
typedef $$MigrationRecordsTableCreateCompanionBuilder
    = MigrationRecordsCompanion Function({
  required String id,
  Value<String> status,
  Value<DateTime> startedAt,
  Value<DateTime?> completedAt,
  Value<String?> detail,
  Value<int> rowid,
});
typedef $$MigrationRecordsTableUpdateCompanionBuilder
    = MigrationRecordsCompanion Function({
  Value<String> id,
  Value<String> status,
  Value<DateTime> startedAt,
  Value<DateTime?> completedAt,
  Value<String?> detail,
  Value<int> rowid,
});

class $$MigrationRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $MigrationRecordsTable> {
  $$MigrationRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get detail => $composableBuilder(
      column: $table.detail, builder: (column) => ColumnFilters(column));
}

class $$MigrationRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $MigrationRecordsTable> {
  $$MigrationRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get detail => $composableBuilder(
      column: $table.detail, builder: (column) => ColumnOrderings(column));
}

class $$MigrationRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MigrationRecordsTable> {
  $$MigrationRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<String> get detail =>
      $composableBuilder(column: $table.detail, builder: (column) => column);
}

class $$MigrationRecordsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MigrationRecordsTable,
    MigrationRecord,
    $$MigrationRecordsTableFilterComposer,
    $$MigrationRecordsTableOrderingComposer,
    $$MigrationRecordsTableAnnotationComposer,
    $$MigrationRecordsTableCreateCompanionBuilder,
    $$MigrationRecordsTableUpdateCompanionBuilder,
    (
      MigrationRecord,
      BaseReferences<_$AppDatabase, $MigrationRecordsTable, MigrationRecord>
    ),
    MigrationRecord,
    PrefetchHooks Function()> {
  $$MigrationRecordsTableTableManager(
      _$AppDatabase db, $MigrationRecordsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MigrationRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MigrationRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MigrationRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> startedAt = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<String?> detail = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MigrationRecordsCompanion(
            id: id,
            status: status,
            startedAt: startedAt,
            completedAt: completedAt,
            detail: detail,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String> status = const Value.absent(),
            Value<DateTime> startedAt = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<String?> detail = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MigrationRecordsCompanion.insert(
            id: id,
            status: status,
            startedAt: startedAt,
            completedAt: completedAt,
            detail: detail,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MigrationRecordsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MigrationRecordsTable,
    MigrationRecord,
    $$MigrationRecordsTableFilterComposer,
    $$MigrationRecordsTableOrderingComposer,
    $$MigrationRecordsTableAnnotationComposer,
    $$MigrationRecordsTableCreateCompanionBuilder,
    $$MigrationRecordsTableUpdateCompanionBuilder,
    (
      MigrationRecord,
      BaseReferences<_$AppDatabase, $MigrationRecordsTable, MigrationRecord>
    ),
    MigrationRecord,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DownloadRecordsTableTableManager get downloadRecords =>
      $$DownloadRecordsTableTableManager(_db, _db.downloadRecords);
  $$PlaybackPositionsTableTableManager get playbackPositions =>
      $$PlaybackPositionsTableTableManager(_db, _db.playbackPositions);
  $$SchemaMetadataTableTableManager get schemaMetadata =>
      $$SchemaMetadataTableTableManager(_db, _db.schemaMetadata);
  $$MigrationRecordsTableTableManager get migrationRecords =>
      $$MigrationRecordsTableTableManager(_db, _db.migrationRecords);
}
