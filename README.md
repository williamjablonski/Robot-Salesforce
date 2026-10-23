# Robot Framework and Salesforce Lightning examples

This project contains Robot Framework Salesforce Lightning suites using
SeleniumLibrary and reusable Python label-based keywords. QForce examples and
the Selenium/XPath references can be adapted to a Copado test execution
environment.

## Setup

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements.txt
```

The QWeb suite uses the `qweb` package in `requirements.txt` and a Python
interpreter built with Tk support (`tkinter`). The QForce suite also requires
the QForce library and a browser supported by the target Copado runner.
Install/configure QForce through the distribution approved for your
organization; it is not available from the public package index used by pip.
The UI suites use SeleniumLibrary, also included in `requirements.txt`, and
require a browser and compatible WebDriver in the local or Copado runner.

## Label-based Python Robot keywords

The reusable library in `libraries/label_ui_keywords.py` provides `Type Text`,
`Click Text`, and `Verify Text` by reusing the active SeleniumLibrary session.
Every executable Salesforce `.robot` suite imports the shared
[salesforce-session.resource](resources/salesforce-session.resource), which
imports the label-based library and centralizes login/object-list setup. Each
suite also imports its business-data resource from `data/`. Files ending in
`.txt` are reference examples and are intentionally not affected by this
pattern.

Import [label-ui.resource](resources/label-ui.resource) directly only when a
suite does not need the shared Salesforce session:

```robot
*** Settings ***
Library     SeleniumLibrary
Resource    ../resources/label-ui.resource

*** Test Cases ***
Fill And Submit A Form
    LabelUI.Type Text      Account Name    Example Account
    LabelUI.Click Text     Save
    LabelUI.Verify Text    Example Account
```

`Type Text` resolves a visible HTML `label` association or exact `aria-label`;
it fails if the label is missing, ambiguous, or does not identify a text input.
`Click Text` targets one visible button, link, supported ARIA control, or label
by exact visible text/accessibility label. `Verify Text` waits for exact
normalized text to become visible. The `LabelUI` namespace avoids keyword-name
collisions with QWeb. Confirm labels and accessible names in the target DOM;
the helper does not validate Salesforce org markup by itself.

## Salesforce test configuration

Configure these environment variables in Copado (or locally in a secure
environment) before running the Salesforce suite:

| Variable | Purpose |
| --- | --- |
| `SF_LOGIN_URL` | Salesforce login URL; use `https://test.salesforce.com` for a sandbox. |
| `SF_LIGHTNING_URL` | Lightning domain for the target org, e.g. `https://my-domain.lightning.force.com`. |
| `SF_USERNAME` | Dedicated Salesforce test user. |
| `SF_PASSWORD` | Test user's password; store it as a secret/private variable. |

The example assumes that login completes without an interactive MFA prompt. Add
your organization's approved SSO/MFA handling before using it in an org that
requires an additional login step.

## Run

Run all project test suites from the macOS terminal:

```bash
robot --outputdir reports tests/
```

Robot Framework will discover the `.robot` suites under `tests/` and save the
HTML report and log in `reports/`. Salesforce suites need their required
libraries, browser setup, and environment variables configured as described
above.

To execute all suites in Docker (without dry run):

```bash
docker compose run --rm -T tests --outputdir /app/reports tests/
```

To run an individual suite:

```bash
robot --outputdir reports tests/smoke.robot
robot --outputdir reports tests/salesforce-QForce.robot
robot --outputdir reports tests/salesforce-lightning-xpath.robot
```

The Salesforce examples use `SF_LOGIN_URL`, `SF_LIGHTNING_URL`, `SF_USERNAME`,
and `SF_PASSWORD` as described above. The SeleniumLibrary example also accepts
`SF_BROWSER` (defaults to `chrome`). Keep credentials in secret/private
variables. Complete any org-specific SSO/MFA flow before relying on the session.

Both Salesforce examples create uniquely named Account records; the XPath suite
also edits an Account and checks the required-name validation. Use a
sandbox/test org: records created by these tests remain in Salesforce for
inspection. The HTML report and log are written to `reports/`.

## Docker and CI

The Docker image is published on [Docker Hub](https://hub.docker.com/r/williamjablonski/robot-salesforce-tests)
as `williamjablonski/robot-salesforce-tests:latest`.

Download the image:

```bash
docker pull williamjablonski/robot-salesforce-tests:latest
```

The published image includes the public dependencies and browser setup. Running
the full suite also requires Salesforce sandbox configuration and your
organization's approved private QForce library. The existing QWeb placeholder
must be adapted to a real application before the full suite can pass.

See [readme-docker.md](readme-docker.md) for Docker setup, commands to run all
suites or individual tests, Salesforce/QForce prerequisites, and the GitHub
Actions pipeline configuration.
