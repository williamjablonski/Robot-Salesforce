# Robot Framework and Salesforce Lightning examples

This project contains a Robot Framework smoke test, a Salesforce Lightning
example using QForce, and a separate SeleniumLibrary suite with XPath locators
and no custom Python code. Both Salesforce examples can be adapted to a Copado
test execution environment.

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
The XPath suite uses SeleniumLibrary, also included in `requirements.txt`, and
requires a browser and compatible WebDriver in the local or Copado runner.

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
robot --outputdir results tests/
```

Robot Framework will discover the `.robot` suites under `tests/` and save the
HTML report and log in `results/`. Salesforce suites need their required
libraries, browser setup, and environment variables configured as described
above.

To run an individual suite:

```bash
robot --outputdir results tests/smoke.robot
robot --outputdir results tests/salesforce-QForce.robot
robot --outputdir results tests/salesforce-lightning-xpath.robot
```

The Salesforce examples use `SF_LOGIN_URL`, `SF_LIGHTNING_URL`, `SF_USERNAME`,
and `SF_PASSWORD` as described above. The SeleniumLibrary example also accepts
`SF_BROWSER` (defaults to `chrome`). Keep credentials in secret/private
variables. Complete any org-specific SSO/MFA flow before relying on the session.

Both Salesforce examples create uniquely named Account records; the XPath suite
also edits an Account and checks the required-name validation. Use a
sandbox/test org: records created by these tests remain in Salesforce for
inspection. The HTML report and log are written to `results/`.
