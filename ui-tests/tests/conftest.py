from __future__ import annotations

from datetime import datetime
from pathlib import Path

import pytest

from ui_tests.config import EndpointSpec, TestSettings, load_endpoints, load_settings
from ui_tests.driver import build_driver


@pytest.fixture(scope="session")
def settings() -> TestSettings:
    return load_settings()


@pytest.fixture(scope="session")
def endpoints(settings: TestSettings) -> list[EndpointSpec]:
    return load_endpoints(settings.endpoints_file)


@pytest.fixture(scope="session")
def driver(settings: TestSettings):
    browser = build_driver(settings)
    yield browser
    browser.quit()


@pytest.hookimpl(hookwrapper=True)
def pytest_runtest_makereport(item, call):
    outcome = yield
    report = outcome.get_result()

    if report.when != "call" or report.passed:
        return

    driver = item.funcargs.get("driver")
    settings = item.funcargs.get("settings")
    if not driver or not settings:
        return

    screenshot_dir = Path(settings.screenshot_dir)
    screenshot_dir.mkdir(parents=True, exist_ok=True)
    test_name = item.name.replace("/", "_").replace(" ", "_")
    timestamp = datetime.utcnow().strftime("%Y%m%d-%H%M%S")
    screenshot_path = screenshot_dir / f"{test_name}-{timestamp}.png"
    driver.save_screenshot(str(screenshot_path))
    report.sections.append(("screenshot", f"Saved screenshot to {screenshot_path}"))
