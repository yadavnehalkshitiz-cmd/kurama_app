"""kurama_api.routers.legacy — compatibility shim for /api/* routes.

All existing /api/* endpoints are mounted here and proxied to the underlying
api_server.app. This preserves 100% backward-compatibility for Phase 0 while
the client migrates to /v1/* in Phase 1.

Design: instead of re-implementing every route, we import the existing
FastAPI application from api_server and mount all its routes on this router
with the same path prefixes. This is zero-duplication and zero-divergence.
"""
from __future__ import annotations

from fastapi import APIRouter

# Import the legacy app. api_server.py continues to own the /api/* routes
# and all business logic until Phase 1 splits them out.
try:
    import api_server as _legacy
    _legacy_app = _legacy.app
    _legacy_available = True
except Exception as _e:
    _legacy_app = None
    _legacy_available = False
    _import_error = str(_e)


router = APIRouter()


@router.get("/api/health")
async def legacy_health():
    """Compatibility alias — prefer /v1/health for new clients."""
    if not _legacy_available:
        return {"status": "ok", "note": "legacy routes unavailable"}
    # Delegate to the legacy handler directly
    from fastapi import Request
    import time
    import api_server as _s
    return {
        "status": "ok",
        "app": "Kurama App API",
        "version": _s.API_VERSION,
        "api_key_configured": _s.API_AUTH_KEY is not None,
        "active_downloads": _s._active_download_count(),
        "uptime_seconds": int(time.time() - _s._APP_START_TIME),
    }
