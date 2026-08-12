"""kurama_api.auth — authentication dependency boundary.

Wraps the legacy constant-time Bearer check without importing api_server directly.
"""
from __future__ import annotations

import hmac

from fastapi import Header, HTTPException


def make_auth_dependency(get_key, get_admin_key=None):
    """Return a FastAPI dependency that validates the Bearer token.

    Args:
        get_key: callable → str | None  returning the expected API key.
        get_admin_key: optional callable returning the admin key (falls back to get_key).
    """

    async def verify_auth(authorization: str | None = Header(None)) -> bool:
        key = get_key()
        if key is None:
            raise HTTPException(
                503,
                "API key not configured — set KURAMA_API_KEY in .env",
            )
        _check_bearer(authorization, key)
        return True

    async def verify_admin(authorization: str | None = Header(None)) -> bool:
        key = get_key()
        if key is None:
            raise HTTPException(
                503,
                "API key not configured — set KURAMA_API_KEY in .env",
            )
        admin_key = (get_admin_key() if get_admin_key else None) or key
        _check_bearer(authorization, admin_key)
        return True

    return verify_auth, verify_admin


def _check_bearer(authorization: str | None, expected: str) -> None:
    if not authorization:
        raise HTTPException(401, "Missing Authorization header")
    scheme, _, token = authorization.partition(" ")
    if scheme.lower() != "bearer":
        raise HTTPException(401, "Authorization scheme must be Bearer")
    if not hmac.compare_digest(token.encode(), expected.encode()):
        raise HTTPException(401, "Invalid API key")
