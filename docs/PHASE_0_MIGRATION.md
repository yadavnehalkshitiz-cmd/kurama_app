# Phase 0 Migration Runbook

> **Status:** In rollout. Monitor via the `migration_completed` analytics event.

This runbook covers:
1. How the SharedPreferences → SQLite migration works
2. Rollout gate: when to remove the legacy mirror
3. Rollback procedure (APK downgrade path)
4. Operator checklist before Phase 0 release

---

## Overview

Phase 0 replaces `SharedPreferences` as the task persistence store with
**Drift / SQLite** (`kurama_app.db`). The migration is:

- **Idempotent** — runs once; tracked in the `migration_records` SQLite table.
- **Transactional** — all rows are written in a single Drift transaction; if
  anything fails the DB is rolled back to its pre-migration state.
- **Non-destructive** — SharedPreferences data is never deleted.
- **Reversible** — `LegacyStateMirror` keeps SharedPreferences in sync with
  every SQLite write so downgrading to the previous APK restores user data.

---

## Rollout Procedure

1. Release APK with Phase 0 build.
2. On first cold start, `AppBootstrap.initialize()` calls
   `LegacyStateMigrator.run()`.
3. Monitor the `migration_completed` analytics event:
   - `success` dimension: migration ran without error.
   - `task_count` dimension: number of tasks migrated.
4. Monitor `migration_failed` event for any rollback cases.

---

## Rollback Procedure

> [!WARNING]
> Only roll back if critical data loss is observed in > 0.1 % of sessions.

Steps to roll back:
1. Revert the Play Store / sideload to the previous APK version.
2. On downgrade, the app reads from SharedPreferences (not SQLite) — tasks
   migrated before the downgrade are still visible because `LegacyStateMirror`
   kept SharedPreferences in sync.
3. SQLite file (`kurama_app.db`) is left on disk and ignored by the old app.
4. On a re-upgrade, `LegacyStateMigrator` checks the `migration_records` table
   and is idempotent — it will not re-run if it was already completed.

---

## Legacy Mirror Removal Gate

The `LegacyStateMirror` in
`mobile/lib/infrastructure/migration/legacy_state_mirror.dart` must remain
in place for **one release cycle** after Phase 0 ships. It can be removed when:

- [ ] ≥ 99 % of **active** users (DAU-7) are on Phase 0 or newer.
- [ ] Zero `migration_failed` events in the last 7 days.
- [ ] `P99 migration_duration_ms < 2000` (no slow devices stalling on startup).
- [ ] QA sign-off on the downgrade path (APK rollback test).

**When removing the mirror:**
1. Delete `mobile/lib/infrastructure/migration/legacy_state_mirror.dart`.
2. Remove all `LegacyStateMirror` references from `AppBootstrap`.
3. Optionally add a `SharedPreferences.remove('download_tasks')` cleanup on
   next boot (guarded by a new migration record `cleanup_legacy_prefs_v1`).

---

## Operator Checklist (Pre-Release)

- [ ] `python -m unittest discover -s tests -v` — all tests pass.
- [ ] `flutter analyze --no-fatal-infos` — zero issues.
- [ ] `flutter build apk --release` — APK produced.
- [ ] Smoke: install APK over existing app with existing tasks; verify tasks appear.
- [ ] Smoke: add a download → confirm it appears in SQLite AND SharedPreferences (mirror).
- [ ] Smoke: force-stop app mid-download → re-open → task shows as RECOVERED.
- [ ] Smoke: roll back to previous APK → tasks visible via SharedPreferences.
- [ ] CI: `flutter_build.yml` `test_flutter` job is green.
- [ ] CI: `backend_ci.yml` job is green (31 new backend tests pass).
- [ ] GitHub Release: tag `v1.3.0` to trigger the release job.

---

## Architecture Changes Summary

| Component | Before | After |
|---|---|---|
| Task persistence | SharedPreferences JSON blob | Drift SQLite `download_records` |
| Playback positions | SharedPreferences JSON | Drift SQLite `playback_positions` |
| API versioning | `/api/*` only | `/v1/*` (new) + `/api/*` (legacy compat) |
| Error envelope | Ad-hoc `{error: string}` | Stable `{error:{code,message,retryable,recovery_action,request_id}}` |
| Backend structure | Monolithic `api_server.py` | `api_server.py` + `kurama_api/` package |
| Idempotency | None | `Idempotency-Key` header on `/v1/downloads` |
| Theme | Inline `ThemeData` in `main.dart` | `buildKuramaTheme()` from `kurama_colors.dart` |
| DownloadStatus states | 4 | 12 |
