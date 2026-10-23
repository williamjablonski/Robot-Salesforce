*** Settings ***
Documentation    Synthetic Account creation data. Each run appends a unique suffix; created records are retained for authorized sandbox inspection.

*** Variables ***
${ACCOUNT_NAME_LABEL}                 Account Name
${ACCOUNT_PHONE_LABEL}                Phone
${ACCOUNT_WEBSITE_LABEL}              Website
${ACCOUNT_DESCRIPTION_LABEL}          Description
${ACCOUNT_TEST_NAME_PREFIX}           Robot Account
${ACCOUNT_TEST_PHONE_PREFIX}          555
${ACCOUNT_TEST_WEBSITE_PREFIX}        https://example.com/robot-account-
${ACCOUNT_TEST_DESCRIPTION_PREFIX}    Created by Robot Framework test
