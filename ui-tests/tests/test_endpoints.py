from __future__ import annotations

from urllib.parse import urlparse

from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as ec
from selenium.webdriver.support.ui import WebDriverWait

from ui_tests.config import EndpointSpec, TestSettings, load_endpoints, load_settings


def pytest_generate_tests(metafunc):
    if "endpoint" not in metafunc.fixturenames:
        return

    settings = load_settings()
    endpoints = load_endpoints(settings.endpoints_file)
    metafunc.parametrize("endpoint", endpoints, ids=[endpoint.id for endpoint in endpoints])


def test_endpoint_smoke(driver, settings: TestSettings, endpoint: EndpointSpec):
    target_url = settings.absolute_url(endpoint.path)
    driver.get(target_url)

    if endpoint.wait_for_css:
        WebDriverWait(driver, settings.page_load_timeout).until(
            ec.presence_of_element_located((By.CSS_SELECTOR, endpoint.wait_for_css))
        )

    assert urlparse(driver.current_url).scheme in {"http", "https"}

    if endpoint.expected_title_contains:
        assert endpoint.expected_title_contains in driver.title

    if endpoint.expected_url_contains:
        assert endpoint.expected_url_contains in driver.current_url

    if endpoint.expected_text:
        body_text = driver.find_element(By.TAG_NAME, "body").text
        assert endpoint.expected_text in body_text
