In **Copilot Chat, in Agent mode**, copy one of the prompts below. Keep the skill saved at `.github/skills/salesforce-copado-qa/SKILL.md`.

**1. Analyze the project**
```text
Use the salesforce-copado-qa skill to analyze this repository. Identify Copado libraries, test structure, settings, and execution commands. Report what is ready and what is still needed for testing.
```

**2. Create manual tests**
```text
Use the salesforce-copado-qa skill to create manual tests for creating an Opportunity in Salesforce Lightning. Include positive and negative scenarios, required fields, and permissions. Save the cases in qa/manual/opportunity.md and mark all of them as NOT_RUN.
```

**3. Test a user story**
```text
Use the salesforce-copado-qa skill to analyze the story below. Create manual cases, a traceability matrix, and automated Copado CRT tests for P0 and P1 scenarios. Reuse this project's libraries and conventions.

Story:
[paste the story and acceptance criteria here]
```

**4. Automate existing manual cases**
```text
Use the salesforce-copado-qa skill to automate the cases in qa/manual/opportunity.md with Copado CRT and Robot Framework. Reuse existing resources and keywords. Confirm keyword signatures before generating code.
```

**5. Validate tests without running the UI**
```text
Use the salesforce-copado-qa skill to validate the Robot Framework test structure. Check imports, variables, and keywords, and perform a dry run using the project configuration. Report any errors found and fix those you can.
```

**6. Run smoke tests**
```text
Use the salesforce-copado-qa skill to run tests tagged smoke in the QA sandbox configured in this project. Use the existing runner. Present results and paths to actual evidence. If access or configuration is missing, report the blocker.
```

**7. Fix a failure**
```text
Use the salesforce-copado-qa skill to analyze the failure below. Investigate whether the cause is the product, automation, data, or environment. Fix the identified cause and rerun the affected test while preserving assertions.

Failure:
[paste the log or specify the file]
```

**8. Test permissions**
```text
Use the salesforce-copado-qa skill to create a permissions test matrix for the Opportunity object. Compare the personas available in the project and cover CRUD, field-level security, and sharing. Generate manual cases and automate feasible scenarios.
```

**9. Review existing automation**
```text
Use the salesforce-copado-qa skill to review this project's tests. Identify fragile locators, fixed waits, dependencies between tests, missing assertions, and data cleanup issues. Fix the issues with the greatest impact and validate the changes.
```

**To get started, use prompt 1.** Then provide a real story using prompt 3.


Copy the following into **Copilot Chat in Agent mode** and replace the URL:

```text
Use the salesforce-copado-qa skill to explore the system at [PASTE THE URL] and generate test cases directly in this project.

1. Analyze the repository structure and reuse its conventions.
2. Use the available browser tools to access the URL. If authentication is required, let me log in without asking for my password in chat. If no browser tool is available, report the required capability.
3. Explore the screens, menus, forms, and journeys accessible to the authenticated user. Create an inventory of observed features.
4. Base tests on observed behavior and requirements found in the project. Identify inferred rules as assumptions to confirm.
5. Generate positive, negative, boundary, validation, and navigation cases. For permissions, cover only available personas and record the others as gaps.
6. Save cases in qa/manual/, organized by feature, including ID, objective, preconditions, data, steps, expected result, priority, and NOT_RUN status.
7. Create qa/traceability/exploration.md linking screens, features, and cases. Record inaccessible pages and unexplored flows.
8. Create qa/automation-candidates.md with cases recommended for Copado CRT automation, prioritized by risk and frequency of use.

Explore without changing existing data. Perform write operations only in an authorized test sandbox, using identifiable synthetic data. Do not delete existing records, send communications, or trigger payments or external integrations.

Do not invent features or mark cases as passed merely because they have been generated. Continue until the files are saved and present a summary of coverage and blockers.
```
