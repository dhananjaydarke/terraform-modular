# Selenium UI test starter repo

This folder is a self-contained Python/Selenium test scaffold that can be pointed at any user-provided base URL and a list of endpoints.

## Features
- Runs smoke tests against a configurable base URL.
- Iterates through any number of endpoints defined in JSON.
- Supports Chrome or Firefox in headed or headless mode.
- Captures screenshots automatically when a test fails.
- Lets you assert response/page expectations such as title fragments, URL fragments, and visible text.

## Repository layout
```text
ui-tests/
├── README.md
├── requirements.txt
├── pytest.ini
├── endpoints.sample.json
├── src/
│   └── ui_tests/
│       ├── __init__.py
│       ├── config.py
│       └── driver.py
└── tests/
    ├── conftest.py
    └── test_endpoints.py
```

## Requirements
- Python 3.10+
- Google Chrome or Mozilla Firefox installed locally
- The matching driver is resolved automatically through Selenium Manager

## Install
```bash
cd ui-tests
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

## Configure the target application
Copy the sample endpoint file and update it for the site you want to test.

```bash
cp endpoints.sample.json endpoints.json
```

Example `endpoints.json`:

```json
[
  {
    "name": "Home page",
    "path": "/",
    "expected_title_contains": "Example",
    "expected_text": "Example Domain"
  },
  {
    "name": "Login page",
    "path": "/login",
    "expected_url_contains": "/login"
  }
]
```

## Run tests
Set your base URL and point the tests at your endpoint file.

```bash
export BASE_URL="https://example.com"
export ENDPOINTS_FILE="$(pwd)/endpoints.json"
pytest
```

## Useful environment variables
- `BASE_URL`: Base site URL to test, for example `https://example.com`
- `ENDPOINTS_FILE`: Absolute or relative path to the endpoint definition JSON file
- `BROWSER`: `chrome` (default) or `firefox`
- `HEADLESS`: `true` (default) or `false`
- `IMPLICIT_WAIT`: Seconds for Selenium implicit wait, default `5`
- `PAGE_LOAD_TIMEOUT`: Seconds for page load timeout, default `30`
- `SCREENSHOT_DIR`: Directory for failure screenshots, default `artifacts/screenshots`

## Endpoint schema
Each endpoint entry can include:

- `name` *(required)*: Human-readable test name
- `path` *(required)*: Path appended to `BASE_URL`
- `expected_title_contains` *(optional)*: Substring that should appear in the page title
- `expected_url_contains` *(optional)*: Substring that should appear in the final browser URL
- `expected_text` *(optional)*: Visible text that must be present in the page body
- `wait_for_css` *(optional)*: CSS selector to wait for before assertions begin

## Notes
- These tests are intended for UI smoke testing and navigation checks.
- For authenticated flows, extend the suite with page objects and login helpers specific to your app.
