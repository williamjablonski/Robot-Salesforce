# Running the test suite with Docker

The image includes Python 3.11, Tk, Robot Framework, SeleniumLibrary, QWeb,
Chromium, its matching Debian WebDriver, and Xvfb. Existing `chrome` calls run
with a virtual display. No local Python installation is required.

## Prerequisites

- Docker Engine or Docker Desktop running, with Docker Compose v2.
- Internet access during the build to Debian repositories and the Python package index.
- For Salesforce: an authorized sandbox, a dedicated test user, and network access
  from the container/CI runner to the org. The existing login examples require
  an authentication flow that completes without interactive SSO/MFA; adapt them
  to your organization's approved flow when necessary.
- For QForce: your organization's approved Linux/Python 3.11-compatible wheel
  and any private dependency wheels. This library is not installed from a
  similarly named public package. Follow the vendor's licensing requirements.

## Configure and use the published image

Run from the repository root:

```bash
if [ ! -f .env ]; then cp .env.example .env; fi
mkdir -p results
chmod 777 results
```

Edit `.env` locally with the actual sandbox URLs, username, and password. Use
single-quoted values if a password contains `$` or `#`. The file is ignored by
Git and excluded from the image. Shell environment variables take precedence
over `.env`; do not print the rendered Compose configuration with real secrets.

```bash
docker compose pull tests
```

Compose uses the published `williamjablonski/robot-salesforce-tests:latest`
image and pulls it when running the test service. Normal test runs do not build
the image. The result directory is writable by the container's non-root user.
On a shared host, replace the example's broad directory permissions with
appropriate ACLs for container UID 1000.

To build a custom image locally (for example, to include your organization's
approved QForce wheel), place the wheel and its private dependencies in
`docker/wheels/`, then explicitly run:

```bash
docker compose build tests
docker compose run --rm -T --entrypoint python tests -c 'import QForce'
```

The import check is needed only for QForce. Test files are copied into the
image at build time, so rebuild only when intentionally creating a custom image.

## Run manually from the terminal

Run **every suite**, including QForce and the QWeb example:

```bash
docker compose run --rm -T tests tests/
```

“Manually” means starting the automated suite yourself from the terminal.
The browser runs inside Xvfb; no interactive desktop is exposed.

Run individual suites:

```bash
# Local installation check; no Salesforce credentials needed.
docker compose run --rm -T tests tests/smoke.robot

# Salesforce login smoke test (requires SF_USERNAME and SF_PASSWORD in .env).
docker compose run --rm -T tests tests/salesforce-login-success.robot

# Create a Salesforce Contact (requires SF_USERNAME and SF_PASSWORD in .env).
docker compose run --rm -T tests tests/salesforce-contacts.robot

# Salesforce through SeleniumLibrary and XPath.
docker compose run --rm -T tests tests/salesforce-lightning-xpath.robot

# Salesforce through the private QForce library.
docker compose run --rm -T tests tests/salesforce-QForce.robot

# QWeb demonstration.
docker compose run --rm -T tests tests/salesforce-QWeb.robot
```

Filter by tag or test name:

```bash
docker compose run --rm -T tests --include smoke tests/
docker compose run --rm -T tests --include regression tests/
docker compose run --rm -T tests --test 'Account Name Is Required' tests/salesforce-lightning-xpath.robot
```

The `smoke` tag selects Salesforce tests; the local installation check has no
`smoke` tag. Running a tag filter against `tests/` still imports the QForce suite,
so it requires QForce. To check the installation without Salesforce or QForce,
select `tests/smoke.robot` directly as shown above. To filter only the XPath
suite, use:

```bash
docker compose run --rm -T tests --include smoke tests/salesforce-lightning-xpath.robot
```

The login smoke test uses `SF_LOGIN_URL` (default:
`https://q4sureplatform.my.salesforce.com`) and requires `SF_USERNAME` and
`SF_PASSWORD`. Keep credentials only in the ignored local `.env` file or an
approved secret manager; do not commit them or put them in the Docker image.
The browser runs headlessly inside the container's Xvfb display, and reports
are written to `results/`.

Validate test structure without executing browser actions:

```bash
docker compose run --rm -T tests --dryrun tests/
```

A full dry run still requires QForce. Compose defines the environment variables
referenced by the suites, even when credentials are empty. A dry run does not
execute setup assertions or validate credential values, authentication, locators,
or business rules. To validate only the suites with public dependencies, use:

```bash
docker compose run --rm -T tests --dryrun tests/smoke.robot tests/salesforce-lightning-xpath.robot tests/salesforce-QWeb.robot
```

Robot's exit code is preserved by the container and makes the pipeline fail
when tests fail. No failure is silently skipped.

## Current suite limitations

`tests/salesforce-QWeb.robot` is an existing placeholder: it opens
`https://example.com` and expects Email/Password/Sign in/Dashboard elements that
are not present there. It must be adapted to an actual application before a
complete run can pass. The all-suite command deliberately includes it and
reports its actual failure.

The Salesforce suites create and update synthetic Account records and leave
them in the org. Use a sandbox authorized for those writes. Their locators and
English UI labels must match the target org. Docker does not configure org
permissions, authentication, QForce licensing, or test data cleanup.

## Reports

After each run, inspect:

- `results/report.html`: execution summary.
- `results/log.html`: detailed log.
- `results/output.xml`: machine-readable Robot results.
- Screenshots produced by SeleniumLibrary on failures, when available.

Runs overwrite these filenames. Use a subdirectory to preserve a particular run:

```bash
docker compose run --rm -T tests --outputdir /app/results/run-001 tests/
```

Reports/screenshots can contain Salesforce data. Keep them in authorized
storage. The pipeline retains smoke artifacts for seven days and full-suite
artifacts for three days; adjust retention to your organization's policy.

## Automatic pipeline: GitHub Actions

Workflow: `.github/workflows/docker-tests.yml`.

On pull requests and pushes to `main` or `master`, the `smoke` job builds the
image and runs `tests/smoke.robot` without Salesforce credentials. Reports are
uploaded even when execution fails.

To enable all suites automatically on pushes:

1. Create a GitHub Actions environment named `salesforce-qa`.
2. In that environment, set variables `SF_LOGIN_URL`, `SF_LIGHTNING_URL`, and
   `QFORCE_WHEEL_FILENAME` (the original wheel filename, including `.whl`).
3. Set environment secrets `SF_USERNAME`, `SF_PASSWORD`, and
   `QFORCE_WHEEL_URL` (an HTTPS download URL for the approved QForce wheel,
   such as a signed URL from your private artifact store). Keep access tokens
   in the secret, not in workflow source. Refresh expiring signed URLs as needed.
4. Set the **repository variable** `RUN_SALESFORCE_TESTS` to `true`.
5. Adapt the QWeb placeholder and complete the org-specific test configuration.
6. Push to `main` or `master`. After smoke passes, `full-suite` builds with
   QForce, verifies its import, and executes `tests/`.

Private wheel dependencies must also be made available through your approved
package distribution mechanism before enabling the full job. The supplied
workflow downloads one private QForce wheel over HTTPS using the secret URL;
if your artifact store requires header-based authentication or additional
wheels, adapt that provisioning step to its documented API. The downloaded
wheel keeps the original filename configured in `QFORCE_WHEEL_FILENAME`.

To start the pipeline manually, open **Actions → Docker Robot tests → Run
workflow** (the workflow must first exist on the repository's default branch).
Enable `full_suite` for all suites; leave it disabled for the local
smoke test. If the environment has required reviewers, GitHub waits for their
approval before running the Salesforce job. Full runs are excluded from pull
requests and do not run until configured.

Download reports from the workflow run's **Artifacts** section. Missing secrets,
a missing/incompatible QForce wheel, authentication failures, and test failures
fail the job. The pipeline creates no successful execution evidence in advance.

## Troubleshooting

- **Cannot connect to the Docker daemon:** start Docker Desktop/Engine.
- **Permission denied in `/app/results`:** grant the container user write access
  to the host's `results/` directory.
- **No module named QForce:** obtain the approved distribution, add its wheels,
  rebuild, and repeat the import check.
- **Browser/driver errors:** run `docker compose build --pull --no-cache` to
  refresh the base image and installed packages, including the Chromium and
  chromium-driver pair from the same Debian repositories. A normal build may
  reuse cached installation layers. Do not inject a macOS/Windows driver.
- **Salesforce login timeout:** check URLs, user permissions, network restrictions,
  and the approved SSO/MFA flow.
- **QWeb demonstration fails on Email:** adapt the existing placeholder as noted
  above; this is not resolved by installing Docker.

References: [Compose environment variables](https://docs.docker.com/compose/how-tos/environment-variables/set-environment-variables/),
[GitHub Actions artifacts](https://docs.github.com/en/actions/tutorials/store-and-share-data).
