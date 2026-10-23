*** Settings ***
Documentation    Purpose: create a synthetic Opportunity. Expected: the saved record shows the generated name and configured Stage. Stage and Close Date must be valid target-org values supplied through environment configuration; records remain for sandbox inspection. No acceptance-criteria ID was supplied.

*** Variables ***
${OPPORTUNITY_NAME_LABEL}    Opportunity Name
${OPPORTUNITY_CLOSE_DATE_LABEL}    Close Date
${OPPORTUNITY_STAGE_LABEL}    Stage
${OPPORTUNITY_TEST_NAME_PREFIX}    Robot Opportunity
