# Kurama App

Kurama App is the standalone Android and Windows media downloader. This
repository owns the Flutter client, app backend, tests and release automation.

The Telegram product remains independently maintained in
`yadavnehalkshitiz-cmd/kurama_telebot`; neither product imports or launches the
other.

## Layout

- `mobile/` — Flutter Android and Windows client
- `backend/` — FastAPI download service
- `deployment/` — backend container and environment contract
- `tests/` — cross-component and migration tests
- `docs/` — operations, release and architecture notes
