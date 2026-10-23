# Using the Salesforce Copado QA skill

In **Copilot Chat, in Agent mode**, copy a prompt below. Keep the skill at
[salesforce-copado-qa/SKILL.md](salesforce-copado-qa/SKILL.md). Replace bracketed
placeholders with actual requirements, paths, or authorized environment details.

Start with **prompt 1**, then use **prompt 3** for a real user story. For Docker
commands and pipeline setup, see [readme-docker.md](../../readme-docker.md).
The skill provides guidance; it does not install QForce, grant Salesforce access,
or enable Copado AI features.

## Provide useful context

Include the story and acceptance criteria, affected objects/Flows, available
personas, environment, library versions when known, and desired deliverables.
Provide sanitized examples and references to approved secrets rather than secret
values. State which sandbox writes and external test integrations are authorized.

Preserve the project's framework and conventions. This skill generates
automation only with Robot Framework and the configured Copado CRT, QForce, or
QWeb capabilities that have been verified.
Do not generate Playwright or introduce a parallel automation framework.
For Robot code quality, reuse, resource files, and business test data, also
follow [robot-framework-test-engineering/SKILL.md](robot-framework-test-engineering/SKILL.md).
Every automation must include or update a readable business-data artifact;
Copilot may help author synthetic data but must not be called at test runtime.
Manually authored cases must retain applicable P0 and P1 scenarios, even when
automation is also created. Generated cases start as `NOT_RUN`; a dry run checks
structure and keyword resolution rather than business behavior. Request real
execution evidence before treating a case as passed.

## Discover, design, and execute

### 1. Analyze the project

```text
Use the salesforce-copado-qa skill to analyze this repository. Identify the Salesforce test architecture, installed Copado/QForce/QWeb versions, test data strategy, authentication, personas, execution commands, Docker setup, and CI workflows. Distinguish working suites from placeholders and missing dependencies. Identify high-risk coverage gaps and report what is ready, blocked, or still needs configuration. Do not reveal secrets or replace the existing framework.
```

### 2. Create manual tests

```text
Use the salesforce-copado-qa skill to create manual tests for creating an Opportunity in Salesforce Lightning, based on the project's actual requirements. Include positive, negative, boundary, required-field, and permissions scenarios. Save qa/manual/opportunity.md with criteria, personas, preconditions/data, numbered steps, verifiable expected results, priority, status NOT_RUN, and an evidence column. Add a focused exploratory charter and list missing requirements without inventing expected behavior.
```

Keep every applicable P0 and P1 case in the manual deliverable; do not replace
these cases with automation. Add P2/P3 cases when justified by risk and scope.

### 3. Test a user story end to end

```text
Use the salesforce-copado-qa skill to analyze the story below. Extract testable rules, identify ambiguous acceptance criteria, and create manual cases, including all applicable P0 and P1 scenarios, an AC -> MAN -> AUTO traceability matrix, and Copado CRT/Robot Framework automation for feasible P0/P1 scenarios supported by verified project libraries. Choose automation candidates by business risk, frequency, stability, and maintenance cost. Reuse the project's libraries and conventions. Do not generate Playwright or invent requirements, keywords, locators, API behavior, or evidence. Save the artifacts, distinguish generated cases from executed tests, and report assumptions, gaps, and blockers.

Story and acceptance criteria:
[paste the actual story, criteria, affected objects/Flows, and available personas]
```

### 4. Automate existing manual cases

```text
Use the salesforce-copado-qa and robot-framework-test-engineering skills to automate the cases in qa/manual/opportunity.md with Copado CRT and Robot Framework. Reuse resources, authentication, setup/teardown, and domain keywords. Confirm keyword signatures and actual locators before claiming they are valid. Create or update a readable, business-relevant synthetic dataset file (prefer a Robot `.resource`, unless a verified existing loader supports another format) and import it into the suite. Use runtime-generated unique values only where valid and deterministic business expectations are preserved; do not call Copilot at runtime. Map each automated test to its data scenario, manual case, and criterion; explain cases left manual or blocked. Limit cleanup to records created by the run.
```

The automation deliverable must include its dataset/resource file(s) and
imports, not just instructions to create them later.

### 5. Refactor suites, data, and reusable keywords

```text
Use the robot-framework-test-engineering skill to refactor the Robot Framework suites for [business flow]. Inspect existing suites, resources, data fixtures, library versions, and runner first. Remove duplicated business/setup logic by extracting meaningful reusable keywords into a separate `.resource` file and importing it where appropriate. Create or update a readable business-relevant synthetic data artifact for every automated scenario; prefer native Robot resource variables unless an existing CSV/JSON/YAML loader is verified. Clearly identify confirmed values, placeholders that need org configuration, data relationships, uniqueness, and cleanup constraints. Use locally generated runtime values only when domain-valid; Copilot may help author data but must not be called by the running tests. Preserve behavior, tags, assertions, and execution conventions. Validate imports/dry-run and report exactly what was and was not executed.

Business flow and requirements:
[provide approved requirements, scenarios, fields, valid-value sources, and existing test paths]
```

### 6. Validate without running the UI

```text
Use the salesforce-copado-qa skill to validate Robot Framework imports, variables, keyword signatures, and test structure using the project's configured runner, Docker image, or documented Copado CRT runner. Inspect import/configuration side effects before running a dry run. Verify keywords against the installed versions or authoritative version-matched documentation. Report missing private libraries and fix feasible structural issues. State exactly what was validated; do not claim that dry-run success validates credentials, UI locators, business rules, or connectivity.
```

### 7. Run smoke, sanity, or affected regression tests

```text
Use the salesforce-copado-qa skill to select and execute the smallest meaningful test set for the scope below in the configured QA sandbox. Distinguish smoke checks for critical build functionality, sanity checks for the specific change, and regression checks for impacted existing behavior. Use the existing runner and actual tags; do not assume the local installation check has a smoke tag. Present the command without secrets, environment, exit code, test counts, and paths to actual evidence. Report missing access or configuration as blockers and distinguish PASS, FAIL, BLOCKED, NOT_RUN, and SKIPPED.

Scope and authorized test environment:
[describe the build/change, test selection, and permitted sandbox operations]
```

### 8. Diagnose and fix a failure

```text
Use the salesforce-copado-qa skill to investigate the failure below using logs, screenshots, test code, and reproduction where available. Classify the cause as product, automation, data, environment, or inconclusive. For intermittent failures, compare synchronization, locator ambiguity, shared data, order dependencies, and environment differences. Apply a minimal supported fix, preserve assertions and original failure history, and rerun the affected test. Use bounded repeat runs only when needed to assess stability; do not hide failures with skips, broad timeouts, or retries.

Failure and evidence:
[paste sanitized details or specify files and the run identifier]
```

### 9. Test permissions

```text
Use the salesforce-copado-qa skill to create a permissions test matrix for the Opportunity object using confirmed project personas. Distinguish CRUD and field-level permissions supplied by profiles/permission sets from record access through sharing and role hierarchy. Include authorized and unauthorized actions, field visibility/editability, and record visibility. Generate manual cases and automate feasible scenarios; do not test every persona as an administrator. Record unavailable personas as coverage gaps.
```

### 10. Review existing automation

```text
Use the salesforce-copado-qa skill to review this project's tests for fragile locators, fixed waits, ambiguous matches, dependencies between tests, missing assertions, and data cleanup issues. Check that saved records and business outcomes are verified instead of relying only on toasts. Prioritize fixes by risk and maintenance impact, preserve the existing framework, and validate the changes with the affected tests. Report remaining limitations with evidence.
```

## Apply the expanded practices

### 11. Test Salesforce Flows

```text
Use the salesforce-copado-qa skill to design tests for the Flow below. Cover documented trigger conditions, decision branches, record updates, missing data, error paths, asynchronous outcomes, and final persisted results across the available personas. Link cases to requirements, select P0/P1 automation candidates, and use bounded waits for observable outcomes. Do not assume access to external systems or invent Flow branches.

Flow, requirements, and authorized environment:
[provide the Flow name, metadata or requirements, personas, and test scope]
```

### 12. Test financial workflows

```text
Use the salesforce-copado-qa skill to plan and implement tests for the financial workflow below. Confirm the implemented business rules before defining expected results. Where applicable, cover application creation, eligibility boundaries, document requirements, approval/rejection reasons, permitted status transitions, and required audit information. Validate amounts using approved formulas, precision, rounding, and currency rules. Prioritize incorrect calculations, unauthorized access, inconsistent data, duplicate transactions, and integration failures. Use synthetic profiles and protect sensitive fields in evidence. Treat loan examples as candidate scenarios rather than confirmed company processes; list missing formulas or rules as gaps.

Workflow and approved rules:
[provide requirements, formulas, available personas, and authorized sandbox operations]
```

### 13. Validate APIs and reconcile data

```text
Use the salesforce-copado-qa skill to test the integration below against its actual API contract. Cover authentication/authorization, parameters, HTTP status codes, response schemas, field mapping, business errors, unavailable dependencies, retries, duplicate prevention, and idempotency. Track a synthetic record across the authorized test systems by ID or correlation identifier. Compare mapped values and poll for the documented final state within a bounded interval. Use SOQL/documented APIs for Salesforce and read-only SQL for authorized external databases where available. Record inaccessible systems as blockers rather than claiming end-to-end reconciliation.

Contract, mappings, and authorized test systems:
[provide project paths, expected synchronization window, and permitted test operations]
```

Only create API automation if an approved Robot Framework library or documented
CRT integration is present and its installed version, keywords, and arguments
are verified. Otherwise deliver the manual API cases and state the automation
blocker. Derive all endpoints and expected responses from the actual contract.

### 14. Test responsive web or mobile

```text
Use the salesforce-copado-qa skill to plan tests for the web/mobile journey below. First confirm whether the target is responsive web, a mobile browser, or a native/hybrid app, and verify the actual device/OS/browser matrix and available Copado CRT, QForce, or QWeb capabilities for the installed versions. Create manual P0/P1 cases and traceability. Automate only flows supported by verified project libraries; do not treat desktop browser tests as native mobile coverage and do not introduce Playwright or another framework. Include viewport/device-specific navigation, layout, controls, keyboard/focus/accessibility, orientation, and interruption/recovery only when applicable to the confirmed target and requirements. Mark unavailable devices or capabilities as blockers and unexecuted cases NOT_RUN.

Requirements, supported devices, target type, and authorized environment:
[provide acceptance criteria, device/OS/browser matrix, library versions, and test access]
```

### 15. Review AI-generated or self-healed tests

```text
Use the salesforce-copado-qa skill to review the AI-generated tests or self-healed locator changes below. Compare them with the original acceptance criteria, actual library versions, intended DOM elements, test data, negative scenarios, and required assertions. Check for false positives, ambiguous matches, invented behavior, and sensitive data exposure. Correct supported issues and execute the affected tests where access is available. Use the same review standard as manually authored tests; do not assume Copado AI features are enabled or that a self-healed locator preserves business coverage.

Requirements, generated code, and original/changed locators:
[provide sanitized artifacts or project paths]
```

### 16. Review pipeline checks and release risk

```text
Use the salesforce-copado-qa skill to review and update the existing test pipeline for the scope below. Reuse the configured runner or Docker setup, confirm private dependency provisioning, and align smoke and affected regression checks with the existing release stages and failure gates. Preserve nonzero exit codes and retain sanitized logs, reports, and screenshots. For confirmed critical defects, document evidence, business impact, and a recommendation to block release or follow the established risk-acceptance process. Do not trigger deployments or change release approvals as part of this review. Save configuration changes and report what was actually validated versus what requires CI access.

Pipeline scope and release criteria:
[provide the workflow path, target checks, and existing failure/retention requirements]
```

### 17. Measure AI-assisted testing benefits

```text
Use the salesforce-copado-qa skill to assess AI-assisted testing using the available baseline and observations below. Compare authoring time, maintenance effort, execution stability, defect detection, meaningful requirement coverage, and correction effort for generated output. State the observation period, sample, definitions, and limitations. Distinguish test count from coverage and correlation from demonstrated improvement. If baseline data is missing, propose a measurement plan without inventing gains or percentages.

Baseline and observations:
[provide measured data or project paths]
```

## Explore an application and generate cases

Replace the URL and identify the authorized environment before using this prompt:

```text
Use the salesforce-copado-qa skill to explore the system at [PASTE THE URL] and generate test cases directly in this project. Generate automation only as Robot Framework with the verified Copado CRT/QForce/QWeb capabilities already configured in this project; do not generate Playwright or a parallel framework.

1. Analyze the repository structure and reuse its conventions.
2. Use the available browser tools to access the URL. If authentication is required, let me log in without asking for my password in chat. If no browser tool is available, report the required capability.
3. Explore the screens, menus, forms, and journeys accessible to the authenticated user. Create an inventory of observed features.
4. Base tests on observed behavior and confirmed requirements found in the project. Separate confirmed facts, assumptions, and unknowns. Label inferred rules as assumptions to confirm; do not use interview examples as evidence of implemented financial workflows or invent objects, fields, locators, APIs, or expected results.
5. Generate positive, negative, boundary, validation, and navigation cases. Cover only available personas for permissions and distinguish field/object access from record visibility. Record missing personas and requirements as gaps.
6. Save cases in qa/manual/, organized by feature, including ID, criterion, objective, confirmed persona, preconditions/data, numbered steps, verifiable expected results, priority, status NOT_RUN, and an evidence column. Retain all applicable P0 and P1 manual cases; do not replace them with automation.
7. Create qa/traceability/exploration.md linking screens, features, criteria, and cases. Record inaccessible pages and unexplored flows.
8. Create qa/automation-candidates.md with cases recommended for Copado CRT automation, prioritized by business risk, frequency, stability, and maintenance cost. Keep subjective visual assessment and exploration manual where appropriate.

Explore without changing existing data. Perform write operations only in an authorized test sandbox, using identifiable synthetic data. Do not delete existing records, send communications, or trigger payments or external integrations. Protect customer data and secrets in prompts and evidence. If access, library capabilities, or expected behavior cannot be verified, report the limitation instead of guessing or claiming completion.

Do not invent features or mark cases as passed merely because they have been generated. Continue until the files are saved and present a summary of coverage, assumptions, exclusions, and blockers.
```
