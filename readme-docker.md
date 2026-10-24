# Running the test suite with Docker

The image includes Python 3.11, Tk, Robot Framework, SeleniumLibrary, QWeb,
Chromium, its matching Debian WebDriver, and Xvfb. Existing `chrome` calls run
with a virtual display. No local Python installation is required.

## Prerequisites

- Docker Engine or Docker Desktop running, with Docker Compose v2.
- Internet access during the build to Debian repositories and the Python package index.
- For Salesforce: an authorized target org, a dedicated test user, and network access
  from the container/CI runner to the org. If Salesforce presents email
  verification, the runner also needs network access to the configured IMAP
  server and secure mailbox credentials. Other SSO/MFA methods still require
  your organization's approved flow.
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

Edit `.env` locally with the target org URLs, environment, Salesforce
credentials, and mailbox credentials for the account receiving verification
emails. For Gmail, enable IMAP and use a dedicated app password in
`SF_MFA_EMAIL_PASSWORD`, not the account's normal password. Set
`SF_TARGET_ENVIRONMENT=sandbox` for a sandbox, or set it to
`production` and explicitly set `SF_ALLOW_PRODUCTION_WRITES=true` to permit
production runs. Production suites create persistent records and may trigger
org automation; use only after org-owner approval and with a dedicated test
user. For an approved production run, the relevant `.env` settings are:

```dotenv
SF_TARGET_ENVIRONMENT=production
SF_ALLOW_PRODUCTION_WRITES=true
```

Use single-quoted values if a password contains `$` or `#`. The file is ignored
by Git and excluded from the image. Shell environment variables take
precedence over `.env`; do not print the rendered Compose configuration with
real secrets.

```bash
docker compose pull tests
```

Compose uses the published `williamjablonski/robot-salesforce-tests:latest`
image and pulls it when running the test service. It mounts local `tests/`,
`libraries/`, `resources/`, `data/`, and the Docker runner script, so changes to
suites, screenshot reporting, Python keywords, resources, and datasets are
available immediately without rebuilding or publishing the image. The
`results/` directory is writable
by the container's non-root user. On a shared host, replace the example's broad
directory permissions with appropriate ACLs for container UID 1000.

The published image does not include the private QForce library. If a QForce
suite is needed, obtain the organization's approved Linux-compatible wheel and
dependencies, place them in `docker/wheels/`, then explicitly build a separate
custom image:

```bash
docker build --tag robot-salesforce-tests:qforce .
ROBOT_TEST_IMAGE=robot-salesforce-tests:qforce ROBOT_TEST_PULL_POLICY=never \
  docker compose run --rm -T --pull never --entrypoint python tests -c 'import QForce'
```

Use that custom image only for tests requiring QForce. Ordinary suites continue
to use the published image; source tests remain supplied through the read-only
mount.

## Run manually from the terminal

Run all executable `.robot` suites in `tests/`:

```bash
docker compose run --rm -T tests --outputdir /app/results tests/
```

“Manually” means starting the automated suite yourself from the terminal.
The browser runs inside Xvfb; no interactive desktop is exposed.

Run individual suites:

```bash
# Validate suite structure without Salesforce credentials or browser actions.
docker compose run --rm -T tests --dryrun --outputdir /app/results tests/

# Salesforce login smoke test (requires SF_USERNAME and SF_PASSWORD in .env).
docker compose run --rm -T tests --outputdir /app/results tests/salesforce-login-success.robot

# Create a Salesforce Contact (requires SF_USERNAME and SF_PASSWORD in .env).
docker compose run --rm -T tests --outputdir /app/results tests/salesforce-contacts.robot

# Create a Salesforce Account (requires SF_USERNAME and SF_PASSWORD in .env).
docker compose run --rm -T tests --outputdir /app/results tests/salesforce-accounts.robot

# Create a Salesforce Opportunity (requires credentials, valid Stage, and Close Date in .env).
docker compose run --rm -T tests --outputdir /app/results tests/salesforce-opportunities.robot

# Create a Salesforce Order (requires credentials and an authorized Account, Effective Date, and valid Status in .env).
docker compose run --rm -T tests --outputdir /app/results tests/salesforce-orders.robot

# Create a service catalog entry (Product2; requires SF credentials).
docker compose run --rm -T tests --outputdir /app/results tests/salesforce-services.robot

# Run Campaign create/read/update/delete (requires SF credentials and confirmed
# Campaign fields; set SF_CAMPAIGN_STATUS if required by the org).
docker compose run --rm -T tests --outputdir /app/results tests/salesforce-campaigns.robot

```

The legacy smoke, XPath, QForce, and QWeb examples currently use the
`.robot.txt` suffix. They are reference files, not executable Robot suites; the
Robot Framework runner does not discover them as `.robot` files. The published
image does not include QForce. Use an approved QForce-enabled image only when
an executable QForce suite is available.

The Campaign CRUD test creates one uniquely named Campaign, reads it, updates
its name, then confirms deletion of that same record. It does not delete
pre-existing campaigns. Confirm the Campaign form labels and required fields
in the target org; set `SF_CAMPAIGN_STATUS` to a valid org status if required.

Filter by tag or test name:

```bash
docker compose run --rm -T tests --include smoke --outputdir /app/results tests/
docker compose run --rm -T tests --include regression --outputdir /app/results tests/
docker compose run --rm -T tests --test 'Criar Conta E Validar Dados' --outputdir /app/results tests/salesforce-accounts.robot
```

The `smoke` tag selects Salesforce tests. A dry run does not execute suite
setup, authenticate, validate the live Salesforce DOM, or create records.

The login smoke test uses `SF_LOGIN_URL` and requires `SF_USERNAME`,
`SF_PASSWORD`, and `SF_TARGET_ENVIRONMENT`; if Salesforce presents an email
verification challenge, it also requires `SF_MFA_EMAIL_USERNAME` and
`SF_MFA_EMAIL_PASSWORD`. Production requires the explicit
`SF_ALLOW_PRODUCTION_WRITES=true` opt-in. Keep credentials only in the ignored
local `.env` file or an approved secret manager; do not commit them or put them
in the Docker image. GitHub Copilot can start the local command but does not
itself grant Salesforce access; Docker receives credentials from the local
environment or `.env`.
The browser runs headlessly inside the container's Xvfb display, and reports
are written to `results/`.

Validate test structure without executing browser actions:

```bash
docker compose run --rm -T tests --dryrun --outputdir /app/results tests/
```

A dry run validates test structure and keyword resolution only. Compose defines the environment variables
referenced by the suites, even when credentials are empty. A dry run does not
execute setup assertions or validate credential values, authentication, locators,
or business rules.

Robot's exit code is preserved by the container and makes the pipeline fail
when tests fail. No failure is silently skipped.

## Current suite limitations

`tests/salesforce-QWeb.robot.txt` is an existing placeholder: it opens
`https://example.com` and expects Email/Password/Sign in/Dashboard elements that
are not present there. It must be adapted and renamed to an executable `.robot`
suite before it can run.

The Salesforce suites create and update synthetic Account records and leave
them in the org. Use a sandbox authorized for those writes. Their locators and
English UI labels must match the target org. Docker does not configure org
permissions, authentication, QForce licensing, or test data cleanup.

## Reports

After each run, inspect:

- `results/report.html`: execution summary.
- `results/log.html`: detailed log.
- `results/output.xml`: machine-readable Robot results.
- Failure screenshots produced by SeleniumLibrary, shown in `report.html` and
  available as image files alongside the results.

Runs overwrite these filenames. Use a subdirectory to preserve a particular run:

```bash
docker compose run --rm -T tests --outputdir /app/results/run-001 tests/
```

Reports/screenshots can contain Salesforce data. Keep them in authorized
storage. The pipeline retains smoke artifacts for seven days and full-suite
artifacts for three days; adjust retention to your organization's policy.

## Automatic pipeline: GitHub Actions

Workflow: `.github/workflows/docker-tests.yml`.

On pull requests and pushes to `main` or `master`, the `smoke` job pulls the
published image and dry-runs the Account suite without Salesforce credentials
or record creation. Reports are uploaded even when validation fails.

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
6. Push to `main` or `master`. After smoke validation passes, `full-suite`
   builds the private QForce-enabled image, verifies its import, and executes
   the executable `.robot` suites in `tests/`.

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
  mailbox IMAP settings/app password, and any organization-specific SSO flow.
- **QWeb demonstration fails on Email:** adapt the existing placeholder as noted
  above; this is not resolved by installing Docker.

References: [Compose environment variables](https://docs.docker.com/compose/how-tos/environment-variables/set-environment-variables/),
[GitHub Actions artifacts](https://docs.github.com/en/actions/tutorials/store-and-share-data).
