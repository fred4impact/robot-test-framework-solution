# How to Set Up and Run This Project

This is a Robot Framework sample project for training. It tests the Sauce Labs demo shop at [saucedemo.com](https://www.saucedemo.com) with Selenium, using the Page Object Model. It contains 31 tests: login, products, cart, checkout and end-to-end.

---

## 1. Prerequisites

| Tool | Version | Check with |
|---|---|---|
| Python | 3.10 or newer (tested on 3.13) | `python3 --version` |
| Google Chrome | Any recent version | Open Chrome → *About Google Chrome* |
| Internet access | Needed: the tests run against the live site | |

You do **not** need to download ChromeDriver. Selenium 4 finds or downloads the matching driver automatically ("Selenium Manager").

Firefox also works if you prefer it (see [Run options](#5-run-options)).

---

## 2. Install

Open a terminal in the project root (the folder that contains this file).

### macOS / Linux

```bash
# 1. Create a virtual environment (an isolated Python just for this project)
python3 -m venv venv

# 2. Activate it - your prompt will show (venv)
source venv/bin/activate

# 3. Install the packages the tests need
pip install robotframework==7.0 robotframework-seleniumlibrary selenium pyyaml
```

### Windows (PowerShell)

```powershell
python -m venv venv
venv\Scripts\Activate.ps1
pip install robotframework==7.0 robotframework-seleniumlibrary selenium pyyaml
```

> **Why not `pip install -r requirements.txt`?**
> `requirements.txt` pins old versions of extra libraries that this project does not use
> (REST, database, Allure, image testing). On Python 3.13 it fails with
> `No matching distribution found for robotframework-restinstance==1.8.0`.
> The four packages above are all the tests need.

### Check the install

```bash
robot --version
# Robot Framework 7.0 (Python 3.x on ...)
```

---

## 3. Run the tests

### Easiest: the run script (macOS / Linux)

```bash
./run_tests.sh all chrome false
```

The script activates `venv` by itself and loads `config/env_config.yaml`.

Arguments: `./run_tests.sh <mode> <browser> <headless>`

| Mode | What runs |
|---|---|
| `all` | Every test (31) |
| `smoke` | Tests tagged `smoke`: quick, most important checks (9) |
| `regression` | Tests tagged `regression` (22) |
| `e2e` | Tests tagged `e2e` |
| `login` / `products` / `cart` / `checkout` / `e2e_file` | One test file |
| `parallel` | All tests split across 4 processes (needs `pip install robotframework-pabot`) |

`headless` = `true` hides the browser window (faster, good for CI). Use `false` to watch the tests click through the site.

If you get `permission denied`, run `chmod +x run_tests.sh` once.

### Directly with the `robot` command (any OS)

```bash
# Everything
robot --variablefile config/env_config.yaml --outputdir results tests

# One file
robot --outputdir results tests/01_login_tests.robot

# One test by name (wildcards allowed)
robot --outputdir results --test "TC101*" tests

# By tag
robot --outputdir results --include smoke tests

# Headless
robot --variable HEADLESS_MODE:True --outputdir results tests

# Check syntax and keyword names without opening a browser (seconds, not minutes)
robot --dryrun --outputdir results tests
```

---

## 4. Read the results

After each run Robot Framework writes three files to the output folder (`results/reports/` when you use the script):

| File | What it is |
|---|---|
| `report.html` | Summary: pass/fail per suite and per tag. **Start here.** |
| `log.html` | Every keyword, argument and timing, step by step. Use it to find *why* a test failed. |
| `output.xml` | Machine-readable results (for CI tools or `rebot`). |

Screenshots taken by `Take Screenshot With Name` and on failures are saved in `results/screenshots/`.

macOS: `open results/reports/report.html` · Windows: `start results\reports\report.html`

---

## 5. Run options

You can override any variable from the command line with `--variable NAME:value`:

| Variable | Default | Example |
|---|---|---|
| `BROWSER` | `chrome` | `--variable BROWSER:firefox` |
| `HEADLESS_MODE` | `False` | `--variable HEADLESS_MODE:True` |
| `EXPLICIT_WAIT` | `15` (seconds) | `--variable EXPLICIT_WAIT:30` on a slow network |
| `BASE_URL` | `https://www.saucedemo.com` | Point the tests at another copy of the site |

Variable priority, highest first:

1. `--variable` on the command line
2. `--variablefile config/env_config.yaml`
3. `*** Variables ***` in `resources/variables.robot`

---

## 6. Project structure

```
robot-automation/
├── tests/                      WHAT is tested - readable test cases
│   ├── 01_login_tests.robot
│   ├── 02_product_tests.robot
│   ├── 03_shopping_cart_tests.robot
│   ├── 04_checkout_tests.robot
│   └── 05_end_to_end_tests.robot
├── resources/
│   ├── keywords/               Business steps built from page objects
│   │   ├── login_keywords.robot      e.g. "User Is Logged In As Standard User"
│   │   ├── product_keywords.robot
│   │   ├── cart_keywords.robot
│   │   └── checkout_keywords.robot
│   ├── common.robot            Browser open/close, waits, screenshots, logging
│   └── variables.robot         URLs, users, test data, expected messages
├── page_objects/               HOW each page works - locators + clicks
│   ├── login_page.robot
│   ├── products_page.robot
│   ├── cart_page.robot
│   └── checkout_page.robot
├── config/
│   ├── settings.robot          One import for test files + shared teardowns
│   └── env_config.yaml         Environment settings (variable file)
├── run_tests.sh                Test runner script
└── results/                    Created by test runs (reports, logs, screenshots)
```

Each layer only uses the layers below it:

```
tests  →  resources/keywords  →  page_objects  →  resources/common + variables  →  SeleniumLibrary
```

A test file therefore needs just one import:

```robotframework
*** Settings ***
Resource    ../config/settings.robot
```

---

## 7. Write your first test

Add this to any file in `tests/` (or create `tests/06_my_tests.robot` with the
`*** Settings ***` block above):

```robotframework
*** Settings ***
Resource          ../config/settings.robot
Test Setup        User Is Logged In As Standard User
Test Teardown     Test Cleanup

*** Test Cases ***
TC601: My First Test
    [Tags]    practice
    Add Products And Open Cart    ${PRODUCT_BACKPACK}
    Cart Should Contain Exactly    ${PRODUCT_BACKPACK}
```

Run it with `robot --outputdir results --include practice tests`.

Exercises to try:

1. Write a test that orders two products and checks `Order Totals Should Be Correct`.
2. Add a row to the `[Template]` table in `TC106` for a new invalid login.
3. Log in as `problem_user` and see which tests break (that user has deliberate bugs).

---

## 8. Troubleshooting

| Problem | Fix |
|---|---|
| `robot: command not found` | Activate the venv: `source venv/bin/activate` (Windows: `venv\Scripts\Activate.ps1`) |
| `No keyword with name 'Open Browser' found` | SeleniumLibrary is missing. Run the `pip install` line from step 2. |
| `Using YAML variable files requires PyYAML module to be installed` | `pip install pyyaml` |
| `SessionNotCreatedException` / driver errors | Update Chrome, then `pip install -U selenium` |
| A test sometimes fails with `Element ... not found` | Slow network: increase `--variable EXPLICIT_WAIT:30`. Prefer a "wait until visible" keyword over `Sleep`. |
| Chrome shows a "Change your password" popup | Already disabled in `Open Application` (`resources/common.robot`). Make sure you did not remove the `prefs` lines. |
| Windows can't run `run_tests.sh` | Use the `robot` commands in step 3, or run the script from Git Bash / WSL. |
| `Activate.ps1 cannot be loaded` (Windows) | Run once: `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned` |

---

## Test accounts

All users have the password `secret_sauce`.

| Username | Behaviour |
|---|---|
| `standard_user` | Works normally (used by most tests) |
| `locked_out_user` | Cannot log in: shows "locked out" error |
| `problem_user` | Broken images, sorting and form fields: good for practising failure analysis |
| `performance_glitch_user` | Slow login: good for practising waits |
