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
`.txt` are reference examples and are not run by the standard runner. The
Selenium XPath reference uses the highlight keyword directly; QForce/QWeb
references remain examples because their libraries are not configured here.

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
Before typing or clicking, the helper briefly outlines the resolved element in
magenta and restores its original inline style. Use `LabelUI.Highlight Element`
with a SeleniumLibrary locator to highlight an element directly. This visual
cue is visible in a locally displayed browser; Docker executes under Xvfb and
does not show the transient highlight on the host desktop. The outline is shown
for 0.3 seconds before the interaction.

## Salesforce test configuration

Configure these environment variables in Copado (or locally in a secure
environment) before running the Salesforce suite:

| Variable | Purpose |
| --- | --- |
| `SF_LOGIN_URL` | Login URL of the target Salesforce org. |
| `SF_LIGHTNING_URL` | Lightning domain for the target org, e.g. `https://my-domain.lightning.force.com`. |
| `SF_TARGET_ENVIRONMENT` | Required: `sandbox` or `production`. |
| `SF_ALLOW_PRODUCTION_WRITES` | Must be `true` to run suites that create records against production. Defaults to `false`. |
| `SF_USERNAME` | Dedicated Salesforce test user. |
| `SF_PASSWORD` | Test user's password; store it as a secret/private variable. |
| `SF_MFA_IMAP_HOST` | IMAP server for the mailbox receiving Salesforce verification messages; defaults to `imap.gmail.com`. |
| `SF_MFA_EMAIL_USERNAME` | Mailbox account used to read the verification message; store it as a secret/private variable. |
| `SF_MFA_EMAIL_PASSWORD` | Mailbox app password or other IMAP password; store it as a secret/private variable. |
| `SF_MFA_EMAIL_SENDER` | Expected sender of the Salesforce verification message; defaults to `noreply@salesforce.com`. |
| `SF_CAMPAIGN_STATUS` | Optional valid Campaign Status label for the Campaign CRUD test; configure it if required by the target org. |

When Salesforce displays the email verification challenge, the login keyword
searches the mailbox's INBOX over IMAP/TLS for a matching message received after
the current login attempt, then enters and submits its `Código de verificação`.
For Gmail, configure IMAP access and use a dedicated app password in
`SF_MFA_EMAIL_PASSWORD`; do not use the account's normal password. The test
does not read email when Salesforce proceeds directly to Lightning. Salesforce
and mailbox credentials must be configured in the local ignored `.env` file or
an approved secret manager. The UI suites create Salesforce records that
remain in the org; production execution requires explicit approval and the
production-write opt-in above. GitHub Copilot does not provide Salesforce
authentication.

## Run

Run all project test suites from the macOS terminal:

```bash
python -m libraries.robot_runner --outputdir results tests/
```

The runner discovers the `.robot` suites under `tests/`, saves the HTML report
and log in `results/`, and adds captured failure screenshots to `report.html`.
Salesforce suites need their required libraries, browser setup, and environment
variables configured as described above.

To execute all suites in Docker (without dry run):

```bash
docker compose run --rm -T tests --outputdir /app/results tests/
```

To run an individual suite:

```bash
python -m libraries.robot_runner --outputdir results tests/smoke.robot
python -m libraries.robot_runner --outputdir results tests/salesforce-QForce.robot
python -m libraries.robot_runner --outputdir results tests/salesforce-lightning-xpath.robot
python -m libraries.robot_runner --outputdir results tests/salesforce-campaigns.robot
```

The Salesforce examples use `SF_LOGIN_URL`, `SF_LIGHTNING_URL`, `SF_USERNAME`,
and `SF_PASSWORD` as described above. The SeleniumLibrary example also accepts
`SF_BROWSER` (defaults to `chrome`). Keep credentials in secret/private
variables. Email-based Salesforce verification is supported as described
above; other SSO or MFA methods still require the organization's approved flow.

The Salesforce suites create uniquely named records in the configured org;
records are not automatically deleted. Use a dedicated test user and review
production automations and side effects before enabling production writes. The
HTML report and log are written to `results/`. Open `report.html` to see the
execution summary and captured failure screenshots; `log.html` retains the
detailed keyword-level log.

The Campaign CRUD suite is an exception to the general record-retention
behavior: after creating, reading, and renaming its uniquely named synthetic
Campaign, it deletes only that record. Confirm the Campaign Name/Status labels
and required fields in the target org before running it. Configure
`SF_CAMPAIGN_STATUS` when the org requires a valid Campaign status; the value
must be accepted by that org.

## Docker and CI

The Docker image is published on [Docker Hub](https://hub.docker.com/r/williamjablonski/robot-salesforce-tests)
as `williamjablonski/robot-salesforce-tests:latest`.

Download the image:

```bash
docker pull williamjablonski/robot-salesforce-tests:latest
```

The published image includes the public dependencies and browser setup. Running
the full suite also requires Salesforce target-org configuration and your
organization's approved private QForce library. The existing QWeb placeholder
must be adapted to a real application before the full suite can pass.

See [readme-docker.md](readme-docker.md) for Docker setup, commands to run all
suites or individual tests, Salesforce/QForce prerequisites, and the GitHub
Actions pipeline configuration.
