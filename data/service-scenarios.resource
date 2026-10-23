*** Settings ***
Documentation    Purpose: create a synthetic Product2 catalog entry used as a service. Expected: the saved record shows the generated product name. Other required fields depend on target-org configuration; records remain in the authorized target org for inspection. No acceptance-criteria ID was supplied.

*** Variables ***
${SERVICE_NAME_LABEL}    Product Name
${SERVICE_TEST_NAME_PREFIX}    Robot Service
