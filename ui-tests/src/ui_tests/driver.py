from __future__ import annotations

from selenium import webdriver
from selenium.webdriver.chrome.options import Options as ChromeOptions
from selenium.webdriver.firefox.options import Options as FirefoxOptions

from ui_tests.config import TestSettings


def build_driver(settings: TestSettings) -> webdriver.Remote:
    if settings.browser == "chrome":
        options = ChromeOptions()
        if settings.headless:
            options.add_argument("--headless=new")
        options.add_argument("--window-size=1440,1080")
        options.add_argument("--disable-dev-shm-usage")
        options.add_argument("--no-sandbox")
        driver = webdriver.Chrome(options=options)
    elif settings.browser == "firefox":
        options = FirefoxOptions()
        if settings.headless:
            options.add_argument("-headless")
        driver = webdriver.Firefox(options=options)
        driver.set_window_size(1440, 1080)
    else:
        raise ValueError("Unsupported browser. Use 'chrome' or 'firefox'.")

    driver.implicitly_wait(settings.implicit_wait)
    driver.set_page_load_timeout(settings.page_load_timeout)
    return driver
