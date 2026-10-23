*** Settings ***
Documentation    Purpose: create a synthetic Account. Expected: the saved record shows the generated name, phone, website, and description. The run suffix makes these values unique; records remain for authorized sandbox inspection. No acceptance-criteria ID was supplied.

*** Variables ***
${ACCOUNT_NAME_LABEL}                 Account Name
${ACCOUNT_PHONE_LABEL}                Phone
${ACCOUNT_WEBSITE_LABEL}              Website
${ACCOUNT_DESCRIPTION_LABEL}          Description
${ACCOUNT_TEST_NAME_PREFIX}           Robot Account
${ACCOUNT_TEST_PHONE_PREFIX}          555
${ACCOUNT_TEST_WEBSITE_PREFIX}        https://example.com/robot-account-
${ACCOUNT_TEST_DESCRIPTION_PREFIX}    Created by Robot Framework test
