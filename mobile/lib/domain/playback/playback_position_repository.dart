/// Abstract boundary for persisting and reading media playback positions.
///
/// Implementations: [InMemoryPlaybackPositionRepository] (tests),
/// [SqlitePlaybackPositionRepository] (production after Task 4).
abstract interface class PlaybackPositionRepository {
  /// Persist the current playback [positionMs] for [mediaId].
  Future<void> savePosition(String mediaId, int positionMs);

  /// Retrieve the last known position for [mediaId].
  /// Returns 0 if never persisted.
  Future<int> getPosition(String mediaId);

  /// Watch real-time updates for a single media item.
  Stream<int> watchPosition(String mediaId);

  /// Remove the persisted position for [mediaId].
  Future<void> clearPosition(String mediaId);

  /// Clear all persisted positions (e.g. on sign-out or storage reset).
  Future<void> clearAll();
}
