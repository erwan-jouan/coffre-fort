"""Password retrieval from COFFRE_FORT_PASSWORD environment variable."""

import os


def get_password() -> bytes:
    pw = os.environ.get("COFFRE_FORT_PASSWORD")
    if not pw:
        raise RuntimeError(
            "COFFRE_FORT_PASSWORD environment variable is not set"
        )
    return pw.encode("utf-8")