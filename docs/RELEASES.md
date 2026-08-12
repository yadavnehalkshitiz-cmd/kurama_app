# Release and Update Compatibility

- Android application ID remains `com.kuramabot.kurama_mobile`.
- Android release builds use the permanent Kurama signing key.
- Never regenerate or replace that key for an update release.
- Version code must increase for every Android update.
- Tagged builds publish Android and Windows artifacts only after both build jobs pass.
- Phase 0 artifacts are engineering builds; public rollout waits for Phase 1 user authentication.
