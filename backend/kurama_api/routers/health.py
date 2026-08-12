"""kurama_api.routers.health — GET /v1/health"""
import time

from fastapi import APIRouter

router = APIRouter()

_start_time = time.time()


@router.get("/v1/health")
async def health():
    return {
        "service": "kurama-api",
        "status": "ok",
        "uptime_seconds": round(time.time() - _start_time, 1),
    }
