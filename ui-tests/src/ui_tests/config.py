from __future__ import annotations

import json
import os
from dataclasses import dataclass
from pathlib import Path
from urllib.parse import urljoin


@dataclass(frozen=True)
class EndpointSpec:
    name: str
    path: str
    expected_title_contains: str | None = None
    expected_url_contains: str | None = None
    expected_text: str | None = None
    wait_for_css: str | None = None

    @property
    def id(self) -> str:
        return self.name.lower().replace(" ", "-")


@dataclass(frozen=True)
class TestSettings:
    base_url: str
    browser: str
    headless: bool
    implicit_wait: int
    page_load_timeout: int
    screenshot_dir: Path
    endpoints_file: Path

    def absolute_url(self, path: str) -> str:
        return urljoin(f"{self.base_url.rstrip('/')}/", path.lstrip('/'))


def _read_bool(value: str | None, default: bool) -> bool:
    if value is None:
        return default
    return value.strip().lower() in {"1", "true", "yes", "on"}


def load_settings() -> TestSettings:
    base_url = os.getenv("BASE_URL", "https://example.com")
    endpoints_file = Path(os.getenv("ENDPOINTS_FILE", "endpoints.sample.json"))

    return TestSettings(
        base_url=base_url,
        browser=os.getenv("BROWSER", "chrome").strip().lower(),
        headless=_read_bool(os.getenv("HEADLESS"), True),
        implicit_wait=int(os.getenv("IMPLICIT_WAIT", "5")),
        page_load_timeout=int(os.getenv("PAGE_LOAD_TIMEOUT", "30")),
        screenshot_dir=Path(os.getenv("SCREENSHOT_DIR", "artifacts/screenshots")),
        endpoints_file=endpoints_file,
    )


def load_endpoints(endpoints_file: Path) -> list[EndpointSpec]:
    if not endpoints_file.exists():
        raise FileNotFoundError(
            f"Endpoint definition file not found: {endpoints_file}. "
            "Set ENDPOINTS_FILE to a valid JSON file."
        )

    data = json.loads(endpoints_file.read_text())
    if not isinstance(data, list) or not data:
        raise ValueError("Endpoint definition file must contain a non-empty JSON array.")

    endpoints: list[EndpointSpec] = []
    for item in data:
        if not isinstance(item, dict):
            raise ValueError("Each endpoint entry must be a JSON object.")

        name = item.get("name")
        path = item.get("path")
        if not name or not path:
            raise ValueError("Each endpoint entry requires both 'name' and 'path'.")

        endpoints.append(
            EndpointSpec(
                name=name,
                path=path,
                expected_title_contains=item.get("expected_title_contains"),
                expected_url_contains=item.get("expected_url_contains"),
                expected_text=item.get("expected_text"),
                wait_for_css=item.get("wait_for_css"),
            )
        )

    return endpoints
