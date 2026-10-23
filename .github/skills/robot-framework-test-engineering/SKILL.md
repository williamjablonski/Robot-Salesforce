---
name: robot-framework-test-engineering
description: "Design, implement, refactor, and review maintainable Robot Framework automated tests. Use for suite/resource organization, reusable keywords, business-relevant test data, runtime synthetic data, data files, fixtures, isolation, assertions, setup/teardown, debugging, and execution. Preserve the repository's configured runner and libraries."
argument-hint: "Describe the Robot Framework suite, workflow, data, or maintainability issue"
---

# Robot Framework Test Engineering

## Goal and scope

Create reliable, readable, maintainable Robot Framework tests that express verified requirements and workflows. Preserve repository conventions, dependency versions, runner, and approved libraries. For Salesforce/Copado work, follow the project `salesforce-copado-qa` skill as well.

Do not invent keywords, library features, locators, contracts, requirements, data rules, or execution results. Verify keyword signatures in existing code, installed Libdoc, or authoritative documentation compatible with the installed version. Never introduce another automation framework or mix libraries' APIs as if interchangeable.

## Mandatory test-data deliverable

**Every automation task must create or update an explicit business-relevant test-data artifact alongside the Robot suite.** This is required even when the suite also generates unique values dynamically. The artifact documents what data the flow needs, why it is valid, and which cases consume it. Do not finish automation with only unexplained inline literals or random strings.

Choose the simplest readable format that the repository can load without new, unapproved dependencies:

1. Prefer a separate Robot Framework `.resource` data file with a `*** Variables ***` section when native Robot imports are sufficient.
2. Use XLSX, CSV, JSON, YAML, or another human-readable format only when a loader/library is already installed and its syntax/API are verified.
3. If a separate data file would add complexity and all values are execution-specific, create a named data-builder keyword (preferably in a shared `.resource` file when reused) and document the business-data contract in that resource. Keep the generated fields and valid-value sources explicit.

If the data format/loader or business rules are unknown, do not add a speculative parser or guess values. Create a readable `.resource` with only confirmed data and clearly named configuration placeholders, or state the exact blocker while providing a structurally useful data artifact.

The data artifact must:

- Represent the real business workflow (for example, a valid customer/order/service scenario), not arbitrary filler values.
- Link each case/row to its purpose, expected outcome, and relevant AC or requirement where known.
- Distinguish fixed, deterministic values from per-run generated values and externally configured values.
- Include required relationships, valid reference values, boundaries, negative inputs, and personas only when supported by requirements, schema, org metadata, or an approved test contract.
- Use synthetic values only. Never include credentials, tokens, production/customer data, or real personal details.
- Identify setup dependencies, uniqueness strategy, cleanup conditions, and any record IDs/correlation IDs that must be retained.

When a workflow creates business records, provide the synthetic source data or a validated data-builder for every case that needs it. Do not seed or mutate an external environment unless explicitly authorized.

### Runtime data generation and Copilot

- Prefer deterministic, reviewable scenario data for business rules and expected outcomes. Add a short unique suffix, execution ID, or timestamp only to fields that must avoid collisions.
- Generate unique runtime values with verified built-in Robot keywords or existing project helpers. Confirm the `String` library import and keyword signature before using it. Do not assume an optional Faker/data library exists.
- Keep runtime-generated values semantically valid: generate names, emails, dates, prices, statuses, currencies, and references only within confirmed formats and business rules. Randomness must not choose an expected result or silently bypass validation.
- GitHub Copilot may help author synthetic datasets during test development from sanitized requirements. Verify every row/value against approved business rules before use. Do not call an LLM/Copilot service from the test at runtime: runtime data must be deterministic or generated locally using approved Robot code, reproducible when needed, and independent of external AI availability.
- Never send secrets, customer records, or sensitive org data to Copilot to create fixtures.

## Suite and resource design

Use existing repository layout. If none exists, use only the files needed:

```text
tests/<feature>.robot
resources/<feature>.resource
data/<feature>.resource
```

- Keep test cases as readable business scenarios: setup, action, observable assertion.
- Put reusable domain keywords, authentication/setup helpers, and shared locator conventions in appropriately named `.resource` files; import them with Robot's `Resource` setting.
- Keep reusable test data in a clearly named data resource/file and import it explicitly. Avoid coupling large datasets to unrelated suite files.
- Extract a keyword when it represents a meaningful domain action, is reused, or improves clarity. Do not wrap every Robot command or create generic indirection without value.
- Search for existing keywords and resources before adding duplicates. Extend a shared resource when appropriate; avoid copy/paste login, save, navigation, and data preparation logic across suites.
- Keep keyword names specific, arguments explicit, and return values documented through clear naming/usage. Avoid hidden global state and order-dependent setup.
- Separate test configuration, secrets, data fixtures, and reusable behavior. Store credentials only in approved environment/secret stores, never in `.robot`, `.resource`, data files, reports, or image layers.
- Prefer business-specific files (for example `resources/order-keywords.resource` and `data/order-scenarios.resource`) over one oversized generic resource.

## Reliable test behavior

### Arrange, act, assert

Each test should express:

1. **Arrange:** load or build its business scenario data and prepare only authorized prerequisites.
2. **Act:** perform the user/API action with the configured Robot library.
3. **Assert:** verify the requirement-specific result, including persisted state or side effects when required.

Use explicit assertions against confirmed outcomes. A page load, absence of an exception, toast, or generic HTTP success is not enough when the business criterion requires a particular value or persisted record.

### Independence and isolation

- Make tests independently runnable and order-independent; avoid shared mutable fixtures unless their lifecycle and concurrency are controlled.
- Use a unique identifier for records created by each execution and preserve IDs needed for verification or cleanup.
- Never delete unrelated or pre-existing records. Cleanup must be limited to records created by the current test and must be explicitly authorized.
- Preserve the original test failure when teardown fails; surface cleanup errors rather than hiding them.
- Enable parallelism only after evaluating shared users, records, org/API limits, and external dependencies.
- Make time, locale, timezone, currency, and asynchronous windows explicit when they affect expected outcomes.

### Synchronization and diagnostics

- Use condition-based waits supported by the installed library; synchronize on meaningful UI/API states, not arbitrary elapsed time.
- Avoid fixed `Sleep`, broad exception catches, silent fallbacks, retries that mask defects, and assertions weakened to stabilize a flaky suite.
- Bound polling and retries. Never repeat a non-idempotent create/update action blindly.
- Use actionable test/keyword names and failure messages. Preserve logs and evidence safely, sanitized for secrets and sensitive data.
- Distinguish functional execution from lint, syntax validation, and Robot `--dryrun`. A dry run checks parsing and keyword resolution; it does not prove UI/API behavior.

## Refactoring existing suites

1. Inventory suites, library imports, repeated sequences, resources, data, and current commands.
2. Identify duplication that represents a shared concept; retain distinct scenario intent and assertions.
3. Extract reusable behavior to a `.resource` file and import it. Keep test-specific orchestration in the suite.
4. Create/update the required business test-data artifact and connect each test to its dataset or data-builder.
5. Preserve tags, test names where practical, failure behavior, output/evidence, and existing runner contracts.
6. Review for circular resource imports, variable collisions, hidden order dependencies, data leakage, and over-abstraction.
7. Run the smallest relevant syntax/dry-run and unit/functional test command. Report actual results and any unverified behavior.

## Review checklist

- [ ] Every automation task includes a readable business-relevant test-data artifact.
- [ ] Dataset values come from confirmed rules/contracts; assumptions and required configuration are explicit.
- [ ] Runtime-generated values are unique where needed, semantically valid, and reproducible where expected.
- [ ] No runtime LLM dependency or sensitive data exposure.
- [ ] Shared keywords/resources are reused; no unnecessary duplicate logic or excessive abstraction.
- [ ] Tests are isolated, order-independent, and safe for authorized environments.
- [ ] Assertions verify the required business result, not just that an action ran.
- [ ] Keywords/libraries, syntax, runner, and validation results are verified and accurately reported.

For Salesforce-specific traceability, P0/P1 manual cases, Copado CRT constraints, and Lightning/API/mobile test strategy, use [salesforce-copado-qa](../salesforce-copado-qa/SKILL.md).
