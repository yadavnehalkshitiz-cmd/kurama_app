/// Typed failure hierarchy for the Kurama App domain layer.
///
/// All domain operations return `Either<AppFailure, T>` or throw [AppFailure]
/// instead of platform exceptions. The client layer maps [AppFailure] to a
/// user-visible message using [AppFailure.userMessage].
library;

import 'package:flutter/foundation.dart';

/// Top-level sealed failure hierarchy.
@immutable
sealed class AppFailure {
  const AppFailure();

  /// Short, user-displayable description. Must not contain stack traces.
  String get userMessage;

  /// Stable machine-readable code for telemetry / analytics.
  String get code;

  /// Whether the operation can be retried by the user.
  bool get retryable => false;

  /// Recommended action shown in the UI.
  RecoveryAction get recoveryAction => RecoveryAction.none;
}

// ── Network failures ──────────────────────────────────────────────────────────

final class NetworkFailure extends AppFailure {
  final int? statusCode;
  final String? serverCode;

  const NetworkFailure({this.statusCode, this.serverCode});

  @override
  String get userMessage =>
      statusCode == 429 ? 'Server busy — please wait a moment.' : 'Network error. Check your connection.';

  @override
  String get code => 'network_failure';

  @override
  bool get retryable => true;

  @override
  RecoveryAction get recoveryAction => RecoveryAction.retry;
}

// ── Storage failures ──────────────────────────────────────────────────────────

final class StorageFailure extends AppFailure {
  final String detail;

  const StorageFailure(this.detail);

  @override
  String get userMessage => 'Storage error. Try clearing the cache.';

  @override
  String get code => 'storage_failure';
}

// ── Validation failures ───────────────────────────────────────────────────────

final class ValidationFailure extends AppFailure {
  final String field;
  final String detail;

  const ValidationFailure({required this.field, required this.detail});

  @override
  String get userMessage => detail;

  @override
  String get code => 'validation_failure';
}

// ── Server failures ───────────────────────────────────────────────────────────

final class ServerFailure extends AppFailure {
  final String serverCode;
  final String serverMessage;

  const ServerFailure({required this.serverCode, required this.serverMessage});

  @override
  String get userMessage => serverMessage;

  @override
  String get code => serverCode;

  @override
  bool get retryable => serverCode.contains('unavailable') || serverCode.contains('capacity');

  @override
  RecoveryAction get recoveryAction =>
      retryable ? RecoveryAction.retry : RecoveryAction.none;
}

// ── Unknown / unexpected ──────────────────────────────────────────────────────

final class UnknownFailure extends AppFailure {
  final Object? cause;

  const UnknownFailure([this.cause]);

  @override
  String get userMessage => 'Something went wrong. Please try again.';

  @override
  String get code => 'unknown_failure';

  @override
  bool get retryable => true;

  @override
  RecoveryAction get recoveryAction => RecoveryAction.retry;
}

// ── Recovery actions ──────────────────────────────────────────────────────────

enum RecoveryAction {
  none,
  retry,
  openSettings,
  contactSupport,
}
